export declare const UPLOAD_DIR: string;
export declare function ensureUploadDir(): void;
export declare class MediaService {
    list(): {
        filename: string;
        url: string;
        ext: string;
        size: number;
    }[];
    toPublicUrl(filename: string): string;
}
export declare function mediaFileFilter(req: any, file: {
    mimetype: string;
    originalname: string;
}, cb: (err: Error | null, accept: boolean) => void): void;
