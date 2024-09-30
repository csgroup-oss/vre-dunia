import { HttpException, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { basename, join } from 'path'

import { DeleteObjectCommand, DeleteObjectRequest, GetObjectCommand, GetObjectRequest, ListObjectsV2Command, ListObjectsV2Request, PutObjectCommand, PutObjectRequest, S3Client } from "@aws-sdk/client-s3";
import { AwsCredentialIdentity } from "@aws-sdk/types";
import { Readable, pipeline } from 'stream';
import { createReadStream, createWriteStream } from 'fs';

@Injectable()
export class S3apiService {
    private s3: S3Client;
    private bucket = this.env.get('JUPYTERHUB_USER');

    constructor(private env: ConfigService) {
        const config = {
            endpoint: this.env.get('ENDPOINT'),
            region: this.env.get('REGION'),
            credentials: <AwsCredentialIdentity>{
                accessKeyId: this.env.get('ACCESS_KEY_ID'),
                secretAccessKey: this.env.get('SECRET_ACCESS_KEY'),
            },
            // logger: console
        };
        // console.log(config)
        this.s3 = new S3Client(config);
    }

    async list(Prefix = ''): Promise<Object[]> {
        try {
            const res = await this.get(Prefix);
            Logger.log(res.KeyCount + ' object(s) found', 'LIST')
            Logger.debug(res);
            const files = (res.Contents || []).filter(this.cleanHiddenFile);
            const folders = (res.CommonPrefixes || []).filter(this.cleanHiddenFolder);
            return [].concat(files).concat(folders);
        } catch (error) {
            console.error(error)
            Logger.debug(error)
            throw new HttpException(error.Code, error.httpStatusCode);
        }
    }

    async upload(path = '/', file: Readable): Promise<HttpException["response"]> {
        let input: PutObjectRequest = {
            Bucket: this.bucket,
            Key: path,
            Body: file,
        };
        if (file && Number.isInteger(file.readableLength)) {
            input.ContentLength = file.readableLength;
        }
        let command = new PutObjectCommand(input);
        Logger.log(input, 'UPLOAD');
        try {
            await this.s3.send(command);
            return { message: 'ok', statusCode: 200 };
        } catch (error) {
            console.error(error)
            Logger.debug(error)
            throw new HttpException(error.Code, error.$metadata.httpStatusCode);
        }
    }

    async download(path = '/'): Promise<Uint8Array> {
        let input: GetObjectRequest = {
            Bucket: this.bucket,
            Key: path,
        }
        let command = new GetObjectCommand(input);
        Logger.log(input, 'DOWNLOAD');
        try {
            const res = await this.s3.send(command);
            return res.Body.transformToByteArray();
        } catch (error) {
            console.error(error)
            Logger.debug(error)
            throw new HttpException(error.Code, error.$metadata.httpStatusCode);
        }
    }

    /** Delete a file or a folder */
    async delete(path: string): Promise<HttpException["response"]> {
        if (path.endsWith('/')) {
            await this.deleteFolderContent(path);
        }
        let input: DeleteObjectRequest = {
            Bucket: this.bucket,
            Key: path,
        }
        let command = new DeleteObjectCommand(input);
        Logger.log(input, 'DELETE');
        try {
            await this.s3.send(command);
            return { message: 'ok', statusCode: 200 };
        } catch (error) {
            console.error(error)
            Logger.debug(error)
        }
    }

    /** Delete folder content reccursively */
    async deleteFolderContent(Prefix) {
        const res = await this.get(Prefix);
        if (res.Contents) {
            await Promise.all([...res.Contents?.map((file) => this.delete(file.Key))])
        }
        if (res.CommonPrefixes) {
            await Promise.all([
                ...res.CommonPrefixes?.map((folder) => this.deleteFolderContent(folder.Prefix)),
            ]);
        }
        Logger.log(Prefix + ' deleted', ['DELETE-FOLDER'])
    }

    /** Uploads a hidden empty file with the new path */
    async createFolder(path = '/') {
        const file = createReadStream(join(__dirname, '..', '..', '.s3keep'));
        return this.upload(path +  '/.s3keep', Readable.from(file));
    }

    private get(Prefix) {
        let input: ListObjectsV2Request = {
            Bucket: this.bucket,
            Delimiter: '/',
            Prefix
        }
        Logger.log(input, 'LIST');
        return this.s3.send(new ListObjectsV2Command(input));
    }

    private cleanHiddenFile(file: any) {
        return !basename(file.Key).startsWith('.');
    }

    private cleanHiddenFolder(file: any) {
        return !basename(file.Prefix).startsWith('.');
    }
}