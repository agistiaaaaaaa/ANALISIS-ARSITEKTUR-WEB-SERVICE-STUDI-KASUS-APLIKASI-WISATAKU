/**
 * Generator laporan PDF Tugas 1 WisataKu
 * Menggunakan Google Chrome / Microsoft Edge headless (tanpa mengubah package.json root).
 *
 * Cara pakai (dari folder docs):
 *   node generate-report.mjs
 */
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const docsDir = path.dirname(__filename);
const htmlPath = path.join(docsDir, 'laporan-print.html');
const htmlFallback = path.join(docsDir, 'Tugas-1-Analisis-Arsitektur-Web-Service.html');
const pdfPath = path.join(docsDir, 'Tugas-1-Analisis-Arsitektur-Web-Service.pdf');

const browserCandidates = [
  process.env.PROGRAMFILES && path.join(process.env.PROGRAMFILES, 'Google', 'Chrome', 'Application', 'chrome.exe'),
  process.env['PROGRAMFILES(X86)'] && path.join(process.env['PROGRAMFILES(X86)'], 'Google', 'Chrome', 'Application', 'chrome.exe'),
  process.env.LOCALAPPDATA && path.join(process.env.LOCALAPPDATA, 'Google', 'Chrome', 'Application', 'chrome.exe'),
  process.env.PROGRAMFILES && path.join(process.env.PROGRAMFILES, 'Microsoft', 'Edge', 'Application', 'msedge.exe'),
  process.env['PROGRAMFILES(X86)'] && path.join(process.env['PROGRAMFILES(X86)'], 'Microsoft', 'Edge', 'Application', 'msedge.exe'),
].filter(Boolean);

function findBrowser() {
  return browserCandidates.find((p) => fs.existsSync(p));
}

function toFileUrl(filePath) {
  const normalized = path.resolve(filePath).replace(/\\/g, '/');
  return 'file:///' + encodeURI(normalized);
}

if (!fs.existsSync(htmlPath) && !fs.existsSync(htmlFallback)) {
  console.error('HTML source tidak ditemukan:', htmlPath);
  process.exit(1);
}

const sourceHtml = fs.existsSync(htmlPath) ? htmlPath : htmlFallback;

const browser = findBrowser();
if (!browser) {
  console.error('Chrome/Edge tidak ditemukan. Tidak dapat membuat PDF.');
  process.exit(1);
}

if (fs.existsSync(pdfPath)) {
  fs.unlinkSync(pdfPath);
}

console.log('Browser:', browser);
console.log('HTML   :', sourceHtml);
console.log('PDF    :', pdfPath);

const result = spawnSync(browser, [
  '--headless=new',
  '--disable-gpu',
  '--no-pdf-header-footer',
  `--print-to-pdf=${pdfPath}`,
  toFileUrl(sourceHtml),
], { encoding: 'utf8' });
if (result.status !== 0) {
  console.error('Gagal membuat PDF.');
  console.error(result.stderr || result.stdout);
  process.exit(result.status || 1);
}

if (!fs.existsSync(pdfPath)) {
  console.error('PDF tidak terbentuk.');
  process.exit(1);
}

const stats = fs.statSync(pdfPath);
console.log(`PDF berhasil dibuat (${stats.size} bytes).`);
