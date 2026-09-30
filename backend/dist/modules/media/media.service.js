"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaService = exports.UPLOAD_DIR = void 0;
exports.ensureUploadDir = ensureUploadDir;
exports.mediaFileFilter = mediaFileFilter;
const common_1 = require("@nestjs/common");
const fs_1 = require("fs");
const path_1 = require("path");
exports.UPLOAD_DIR = (0, path_1.join)(process.cwd(), 'uploads');
const IMAGE_MIMES = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);
const VIDEO_MIMES = new Set(['video/mp4', 'video/webm']);
function ensureUploadDir() {
    if (!(0, fs_1.existsSync)(exports.UPLOAD_DIR))
        (0, fs_1.mkdirSync)(exports.UPLOAD_DIR, { recursive: true });
}
let MediaService = class MediaService {
    list() {
        ensureUploadDir();
        return (0, fs_1.readdirSync)(exports.UPLOAD_DIR)
            .filter((f) => (0, fs_1.statSync)((0, path_1.join)(exports.UPLOAD_DIR, f)).isFile())
            .map((f) => ({
            filename: f,
            url: `/uploads/${f}`,
            ext: (0, path_1.extname)(f).toLowerCase(),
            size: (0, fs_1.statSync)((0, path_1.join)(exports.UPLOAD_DIR, f)).size,
        }))
            .sort((a, b) => a.filename.localeCompare(b.filename));
    }
    toPublicUrl(filename) {
        return `/uploads/${filename}`;
    }
};
exports.MediaService = MediaService;
exports.MediaService = MediaService = __decorate([
    (0, common_1.Injectable)()
], MediaService);
function mediaFileFilter(req, file, cb) {
    const kind = req?.query?.kind === 'video' || req?.body?.kind === 'video' ? 'video' : 'image';
    const allowed = kind === 'video' ? VIDEO_MIMES : IMAGE_MIMES;
    if (!allowed.has(file.mimetype)) {
        return cb(new Error(`Invalid file type ${file.mimetype}. Expected ${kind} file.`), false);
    }
    const ext = (0, path_1.extname)(file.originalname).toLowerCase();
    const allowedExts = kind === 'video' ? ['.mp4', '.webm'] : ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    if (!allowedExts.includes(ext)) {
        return cb(new Error(`Invalid file extension ${ext}.`), false);
    }
    cb(null, true);
}
//# sourceMappingURL=media.service.js.map