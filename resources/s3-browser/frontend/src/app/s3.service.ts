import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { ApiResponse } from './types';

@Injectable({
  providedIn: 'root'
})
export class S3Service {

  serverUrl = 'http://localhost:3000/s3';

  constructor(private http: HttpClient) { }

  list(path = '') {
    let params = {};
    if (path) {
        path = this.cleanPath(path);
        if (!path.endsWith('/')) {
            path = path + '/';
        }
        params = { path };
    }
    return this.http.get<any[]>(`${this.serverUrl}/list`, { params });
  }

  delete(path: string) {
    const params = { path };
    return this.http.delete<ApiResponse>(`${this.serverUrl}/delete`, { params });
  }

  uploadFile(path: string, file: File) {
    path = this.cleanPath(path);
    const params = { path };
    const headers = new HttpHeaders();
    headers.append('Content-Type', 'multipart/form-data;boundary='+Math.random());
    headers.append('Accept', 'application/json');
    const body = new FormData();
    body.append('file', file, file.name);
    console.log(path, file);
    
    return this.http.post<ApiResponse>(`${this.serverUrl}/upload`, body, { headers, params });
  }

  downloadFile(path: string) {
    path = this.cleanPath(path);
    if (path.startsWith('/')) {
        path = path.substring(1)
    }
    const params = { path };
    return this.http.get(`${this.serverUrl}/download`, { params, responseType: 'arraybuffer' })
  }

  createFolder(path: string) {
    path = this.cleanPath(path);
    const params = { path };
    return this.http.post<ApiResponse>(`${this.serverUrl}/folder`, {}, { params });
  }

  private cleanPath(path: string) {
    return path.replaceAll('//', '/');
  }
}
