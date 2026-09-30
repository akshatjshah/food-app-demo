import { MediaService } from './media.service';
interface UploadedMorph {
    filename: string;
    mimetype: string;
    size: number;
}
export declare class MediaController {
    private mediaService;
    constructor(mediaService: MediaService);
    upload(file: UploadedMorph | undefined, kind?: string): Promise<{
        filename: string;
        url: string;
        mimetype: string;
        size: number;
    }>;
    list(): Promise<{
        filename: string;
        url: string;
        ext: string;
        size: number;
    }[]>;
    remove(filename: string): Promise<{
        message: string;
    }>;
}
export {};
