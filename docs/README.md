# Dokumentasi Tugas 1 — WisataKu

Folder `docs` berisi luaran analisis arsitektur web service untuk praktikum NestJS WisataKu.

## Isi Folder

| File | Keterangan |
| --- | --- |
| `tugas-1-analisis-arsitektur.md` | Dokumen analisis arsitektur monolitik modular (sumber utama) |
| `wisataku-arsitektur.drawio` | Diagram arsitektur (format draw.io / diagrams.net) |
| `assets/wisataku-arsitektur.svg` | Representasi visual diagram untuk laporan |
| `Tugas-1-Analisis-Arsitektur-Web-Service.md` | Sumber laporan final (versi Markdown) |
| `Tugas-1-Analisis-Arsitektur-Web-Service.html` | Sumber cetak laporan (versi HTML) |
| `Tugas-1-Analisis-Arsitektur-Web-Service.pdf` | Laporan PDF siap dikumpulkan |
| `Tugas-1-Analisis-Arsitektur-Web-Service.docx` | Laporan Word (.docx) yang dapat diedit |
| `assets/screenshots/get-root.png` | Screenshot GET / |
| `assets/screenshots/get-destinasi.png` | Screenshot GET /destinasi |
| `generate-report.mjs` | Script generator PDF (Chrome/Edge headless) |
| `generate-docx.ps1` | Script generator Word (.docx) |
| `README.md` | Panduan isi folder ini |

## Cara Membuka Diagram Draw.io

1. Buka [https://app.diagrams.net](https://app.diagrams.net) (atau aplikasi desktop draw.io).
2. Pilih **Open Existing Diagram** / **File → Open**.
3. Pilih file `wisataku-arsitektur.drawio` dari folder `docs`.
4. Diagram dapat diedit, diekspor ke PNG/PDF, lalu dilampirkan pada laporan.

Alternatif di VS Code / Cursor: pasang ekstensi **Draw.io Integration**, lalu buka langsung file `.drawio`.

## Cara Membuat Ulang PDF

Dari folder `docs`, jalankan:

```bash
node generate-report.mjs
```

Script membutuhkan Google Chrome atau Microsoft Edge terpasang.

## Cara Membuat Ulang Word (.docx)

Dari folder `docs`, jalankan:

```powershell
powershell -ExecutionPolicy Bypass -File .\generate-docx.ps1
```

File hasil: `Tugas-1-Analisis-Arsitektur-Web-Service.docx` (dapat dibuka dan diedit di Microsoft Word).

## Ringkasan Arsitektur

- Backend: NestJS (`wisataku-api`)
- Pola: Monolitik Modular
- Client: Mobile App dan Web Admin
- Komunikasi: HTTP / REST API
- Endpoint praktikum saat ini:
  - `GET /` → `Hello World!`
  - `GET /destinasi` → `Daftar destinasi wisata akan tampil di sini`
