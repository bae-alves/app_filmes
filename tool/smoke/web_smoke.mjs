#!/usr/bin/env node
// Smoke test do CI para a web: serve o build, abre o app num Chrome headless,
// confirma que ele subiu e fecha.
//
// "Subiu" quer dizer: o engine montou a <flutter-view>, a árvore de semântica
// tem algum texto (o ErrorWidget de release não tem) e nenhuma exceção
// apareceu, seja erro não tratado da página (ex.: .env faltando) ou erro
// capturado pelo Flutter (ex.: falta o TMDB_READ). Não testa a rede: o CI usa
// um token falso, e a home mostra o erro do TMDB normalmente.
//
// Uso: node tool/smoke/web_smoke.mjs [pasta do build, default build/web]
// Variáveis: CHROME_EXECUTABLE (default: o Google Chrome instalado).
import { chromium } from 'playwright-core';
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';

const root = path.resolve(process.argv[2] || 'build/web');
const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm',
  '.css': 'text/css', '.png': 'image/png', '.ico': 'image/x-icon',
  '.ttf': 'font/ttf', '.otf': 'font/otf',
};

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  let file = path.join(root, urlPath);
  if (!file.startsWith(root)) { res.writeHead(403).end(); return; }
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) {
    file = path.join(file, 'index.html');
  }
  if (!fs.existsSync(file)) { res.writeHead(404).end(); return; }
  res.writeHead(200, {
    'content-type': types[path.extname(file)] || 'application/octet-stream',
  });
  fs.createReadStream(file).pipe(res);
});
await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
const url = `http://127.0.0.1:${server.address().port}/`;

const problems = [];
const browser = await chromium.launch({
  ...(process.env.CHROME_EXECUTABLE
    ? { executablePath: process.env.CHROME_EXECUTABLE }
    : { channel: 'chrome' }),
  args: ['--no-sandbox', '--disable-dev-shm-usage'],
});

try {
  const page = await browser.newPage();
  page.on('pageerror', (e) => problems.push(`erro na página: ${e}`));
  page.on('console', (m) => {
    // O Flutter imprime as exceções que captura com este cabeçalho.
    if (m.text().includes('EXCEPTION CAUGHT BY')) {
      problems.push(`exceção do Flutter: ${m.text().split('\n')[0]}`);
    }
  });

  console.log(`abrindo ${url}`);
  await page.goto(url);
  await page.waitForSelector('flutter-view', { timeout: 60000 });

  // A UI é um <canvas>; o texto só aparece no DOM com a semântica ligada.
  await page.waitForTimeout(3000);
  await page.evaluate(() =>
    document.querySelector('flt-semantics-placeholder')?.click());
  let text = '';
  for (let i = 0; i < 20 && !text; i++) {
    await page.waitForTimeout(500);
    text = await page.evaluate(() => {
      const host = document.querySelector('flt-semantics-host');
      if (!host) return '';
      const labels = [...host.querySelectorAll('[aria-label]')]
        .map((el) => el.getAttribute('aria-label'));
      return [host.innerText, ...labels].join(' ').trim();
    });
  }
  if (!text) problems.push('o app não desenhou nenhum texto');
  else console.log(`texto na tela: ${text.slice(0, 120).replace(/\s+/g, ' ')}`);
} catch (e) {
  problems.push(String(e));
} finally {
  await browser.close();
  server.close();
}

if (problems.length) {
  for (const p of problems) console.log(`FALHA ${p}`);
  process.exit(1);
}
console.log('OK: o app abriu e fechou sem erros');
