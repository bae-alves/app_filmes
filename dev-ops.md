# DevOps

Repositório: https://github.com/bae-alves/app_filmes

Este arquivo explica o que confere o código do app_filmes antes de ele chegar na `main`: um hook de pre-push na máquina de cada um, o CI no GitHub Actions e a proteção da `main` no GitHub.

## Fluxo de trabalho

Cada tarefa é um ticket do Jira com a chave `MOVIEAI`, e o commit começa pela chave, como em `MOVIEAI-22: avalia filmes assistidos com nota e humor`.

Cada integrante trabalha numa branch própria por sprint, `sprint-<n>-<integrante>` (por exemplo, `sprint-2-ber`). No fim da sprint, a branch abre um pull request para a `main`. O pull request só entra com o CI verde e a aprovação de outro integrante.

## Antes do push: o hook

O hook [`.githooks/pre-push`](.githooks/pre-push) roda três passos, nesta ordem, e bloqueia o push no primeiro que falhar:

1. `dart format`: formata o código. Se mudou algum arquivo, o push é bloqueado porque o commit enviado ainda está sem formatar. É necessário commit da formatação e repetir o push.
2. `flutter analyze`: a análise estática. Qualquer warning bloqueia.
3. `flutter test`: todos os testes.

O hook confere a pasta de trabalho, não só os commits enviados: mudanças sem commit também entram no hook.

O Git não ativa hooks sozinho. É necessário rodar uma vez em cada clone:

```sh
git config core.hooksPath .githooks
```

O hook é a primeira barreira, e a mais rápida. Quem esquecer de ativá-lo esbarra no CI, que confere as mesmas coisas.

## CI no GitHub Actions

O workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) roda em cada pull request para a `main`, em cada push na `main` e sob demanda (aba Actions → CI → Run workflow).

| Etapa | O que faz | Depende de |
| --- | --- | --- |
| Lint | confere a formatação (`dart format`, sem mudar nada) e roda `flutter analyze` | — |
| Testes | `flutter test` | — |
| Build web | `flutter build web --release` e guarda o resultado como artefato `web` | Lint e Testes |
| Build Android | `flutter build apk --release` e guarda o APK como artefato `apk` | Lint e Testes |
| Smoke web | abre o build web num Chrome headless e fecha | Build web |
| Smoke Android | instala o APK num emulador Android, abre o app e fecha | Build Android |

Lint e Testes rodam em paralelo. Os builds só começam se os dois passarem, e cada smoke usa o artefato do build da sua plataforma, ou seja, testa exatamente o que foi gerado abrindo e fechando na web e no android. Um run completo leva aproximadamente 10 minutos; o build do Android é a parte mais lenta.

Todas as etapas usam a mesma preparação, [`.github/actions/flutter-setup`](.github/actions/flutter-setup/action.yml): instala o Flutter 3.44.9 (a versão do desenvolvimento), cria o `.env` e roda `flutter pub get`.

### Por que um `.env` falso

O `.env` é um asset do app: sem ele o build não fecha e o app não abre. As credenciais do TMDB não ficam no repositório, então o CI grava um `.env` com um token falso. Os testes não usam a rede (rodam com fakes), e os smoke tests só provam que o app abre. Com o token falso, a home abre e mostra o erro do TMDB ("Não foi possível carregar os filmes."), o que basta. Desta forma, nenhuma credencial vaza nos artefatos que qualquer pessoa com acesso ao repositório pode baixar.

### O que os smoke tests conferem

Os dois scripts ficam em [`tool/smoke/`](tool/smoke/) e saem com erro quando o app não abre.

- **Web** (`web_smoke.mjs`): serve o build, abre num Chrome headless com o Playwright, espera o Flutter montar a tela e liga a árvore de acessibilidade para ler o texto. Falha se a página der erro ou se o app não desenhar nenhum texto, que é o caso da tela de erro do Flutter.
- **Android** (`android_smoke.sh`): instala o APK, abre o app e espera 15 segundos. Falha se o processo morrer, se a tela não tiver texto do app ou se o logcat mostrar um crash. Depois fecha o app e confere que ele fechou. No CI, o emulador é um Android 14 (API 34).

Os dois foram testados contra builds quebrados de propósito (sem o `.env`, ou com o token vazio) e falharam como deveriam.

Para rodar:

```sh
npm ci --prefix tool/smoke
flutter build web && node tool/smoke/web_smoke.mjs build/web
flutter build apk && tool/smoke/android_smoke.sh   # com um aparelho no adb
```

### Artefatos

O CI guarda o build web e o APK de release por 7 dias, na página de cada run. O upload do build web inclui arquivos ocultos (`include-hidden-files`): o `.env` do bundle fica em `assets/.env` e, sem essa opção, sairia do artefato e o app não abriria.

Ainda não há deploy automático pois o app ainda não está hospedado em um ambiente produção. A entrega, por ora, são esses dois artefatos.

## Proteção da `main`

A `main` tem proteção clássica de branch no GitHub:

- **Pull request obrigatório**, com pelo menos **uma aprovação**. Ninguém faz push direto na `main`.
- **CI obrigatório**: as seis etapas (Lint, Testes, Build web, Build Android, Smoke web e Smoke Android) precisam passar, e só valem se vierem do GitHub Actions.
- A branch **não precisa estar atualizada** com a `main` para entrar. Isso evita refazer o CI a cada pull request que entra antes do seu.
- As regras **valem também para os administradores**.
- Ninguém pode dar **force push** na `main` nem **apagá-la**.

Juntas, essas regras garantem que todo código na `main` passou por revisão de alguém e por todas as etapas do CI.