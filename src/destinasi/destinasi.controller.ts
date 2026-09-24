import { Controller, Get } from '@nestjs/common';

@Controller('destinasi')
export class DestinasiController {
  @Get()
  getDestinasi(): string {
    return 'Daftar destinasi wisata akan tampil di sini';
  }
}
