export interface File {
    Key: string;
}

export interface Folder {
    Prefix: string;
}

// export type ApiResponse = File[] | Folder[]

export interface ApiResponse {
    message: string;
    statusCode: number;
}