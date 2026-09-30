import { Injectable } from '@nestjs/common';
import { existsSync, mkdirSync, readdirSync, statSync } from 'fs';
import { join, extname } from 'path';

export const UPLOAD_DIR = join(process.cwd(), 'uploads');

const IMAGE_MIMES = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);
const VIDEO_MIMES = new Set(['video/mp4', 'video/webm']);

export function ensureUploadDir() {
  if (!existsSync(UPLOAD_DIR)) mkdirSync(UPLOAD_DIR, { recursive: true });
}

/** Canonical media storage: ONE backend system for all admin-managed images. */
@Injectable()
export class MediaService {
  list() {
    ensureUploadDir();
    return readdirSync(UPLOAD_DIR)
      .filter((f) => statSync(join(UPLOAD_DIR, f)).isFile())
      .map((f) => ({
        filename: f,
        url: `/uploads/${f}`,
        ext: extname(f).toLowerCase(),
        size: statSync(join(UPLOAD_DIR, f)).size,
      }))
      .sort((a, b) => a.filename.localeCompare(b.filename));
  }

  toPublicUrl(filename: string) {
    return `/uploads/${filename}`;
  }
}

export function mediaFileFilter(
  req: any,
  file: { mimetype: string; originalname: string },
  cb: (err: Error | null, accept: boolean) => void,
) {
  const kind = req?.query?.kind === 'video' || req?.body?.kind === 'video' ? 'video' : 'image';
  const allowed = kind === 'video' ? VIDEO_MIMES : IMAGE_MIMES;
  if (!allowed.has(file.mimetype)) {
    return cb(new Error(`Invalid file type ${file.mimetype}. Expected ${kind} file.`), false);
  }
  const ext = extname(file.originalname).toLowerCase();
  const allowedExts =
    kind === 'video' ? ['.mp4', '.webm'] : ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
  if (!allowedExts.includes(ext)) {
    return cb(new Error(`Invalid file extension ${ext}.`), false);
  }
  cb(null, true);
}
