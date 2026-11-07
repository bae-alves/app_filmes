#!/usr/bin/env bash
# Smoke test do CI para Android: instala o APK, abre o app, confirma que ele
# subiu e fecha.
#
# "Subiu" quer dizer: depois de SMOKE_WAIT segundos o processo continua vivo,
# a tela do app tem algum texto acessível (o ErrorWidget de release não tem) e
# o logcat não mostra crash nem exceção do Flutter. Não testa a rede: o CI usa
# um token falso, e a home mostra o erro do TMDB normalmente.
#
# Uso: tool/smoke/android_smoke.sh [apk, default o APK de release]
# Variáveis: ANDROID_SERIAL (aparelho do adb), SMOKE_WAIT (default 15).
set -euo pipefail

apk="${1:-build/app/outputs/flutter-apk/app-release.apk}"
pkg=com.example.app_filmes
wait_s="${SMOKE_WAIT:-15}"

fail() { echo "FALHA $*"; exit 1; }

adb wait-for-device
echo "instalando $apk"
adb install -r "$apk" >/dev/null
adb shell am force-stop "$pkg"
adb logcat -c

echo "abrindo $pkg"
adb shell am start -W -n "$pkg/.MainActivity" | grep -q 'Status: ok' ||
  fail 'o Android não abriu a activity'
sleep "$wait_s"

adb shell pidof "$pkg" >/dev/null || fail 'o app fechou sozinho'

# O primeiro dump costuma falhar logo após abrir o app; um dump que falha deixa
# o arquivo do run anterior, por isso ele é apagado antes de cada tentativa.
ui=''
for _ in 1 2 3 4 5; do
  adb shell rm -f /sdcard/ui.xml
  if adb shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1; then
    ui="$(adb shell cat /sdcard/ui.xml)"
    break
  fi
  sleep 2
done
# Só os nós do app: as barras do sistema também têm texto.
labels="$(grep -oE '<node [^>]*>' <<<"$ui" | grep "package=\"$pkg\"" |
  grep -oE '(text|content-desc)="[^"]+"' || true)"
[ -n "$labels" ] || fail 'o app não desenhou nenhum texto'
echo "texto na tela: $(head -3 <<<"$labels" | tr '\n' ' ')"

errors="$(adb logcat -d |
  grep -E 'FATAL EXCEPTION|EXCEPTION CAUGHT BY|Unhandled Exception' || true)"
[ -z "$errors" ] || fail "erro no logcat:"$'\n'"$errors"

adb shell am force-stop "$pkg"
! adb shell pidof "$pkg" >/dev/null || fail 'o app não fechou'
echo 'OK: o app abriu e fechou sem erros'
