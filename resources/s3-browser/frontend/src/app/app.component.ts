import { Component, OnInit } from '@angular/core';
import { S3Service } from './s3.service';
import { mergeMap } from 'rxjs';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import {MatSnackBar} from '@angular/material/snack-bar';
import { FolderDialogComponent } from './folder-dialog/folder-dialog.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  title = 'TAO_FileSharingRepo';
  list: any[] = [];
  currentPath = '';
  folderName = '';
  loading = false;
  constructor(
    private s3: S3Service,
    private _snackBar: MatSnackBar,
    public dialog: MatDialog,
  ) {}

  ngOnInit() {
    this.loading = true;
    this.s3.list().subscribe(res => {
        this.list = this.mapToDisplayedNames(res);
        this.loading = false;
    });
  }

  openFolder(item: any, path?: string) {
    console.log('open folder', item, path);
    
      let folder = item.Prefix;
      let newPath;
      if (folder) {
        if (!folder.startsWith('/') && !this.currentPath.endsWith('/')) {
            folder = '/' + folder;
        }
        newPath = this.currentPath + folder;
      }
      if (path) {
        newPath = path;
      }
      
    this.loading = true;
    this.currentPath = newPath || '';
    if (this.currentPath.startsWith('/')) {
        this.currentPath = this.currentPath.substring(1, this.currentPath.length);
    }
    this.s3.list(this.currentPath).subscribe(res => {
        this.list = this.mapToDisplayedNames(res);
        if (this.currentPath.endsWith('/')) {
            this.currentPath = '/' + this.currentPath.substring(0, this.currentPath.length -1);
        }
        
        this.loading = false;
    });
  }

  upload(event: any) {
    this.loading = true;
    const file = event.target.files[0];
    let fullPath = '';
    if (this.currentPath.startsWith('/')) {
        fullPath = this.currentPath.substring(1, this.currentPath.length);
    }
    if (!fullPath.endsWith('/')) {
        fullPath = fullPath + '/';
    }
    console.log('UPLOAD', fullPath, file);
    
    this.s3.uploadFile(fullPath + file.name, file)
    .pipe(mergeMap(() => this.s3.list(this.currentPath)))
    .subscribe((res) => {
        this.list = this.mapToDisplayedNames(res);
        this.loading = false;
    });
  }

  download(filename: string) {
    this.loading = true;
    if (this.currentPath.startsWith('/')) {
        this.currentPath = this.currentPath.substring(1, this.currentPath.length);
    }
    this.s3.downloadFile(this.currentPath + '/' + filename).subscribe((data) => {
        this.loading = false;
        const blob = new Blob([data], { type: 'application/octet-stream' });
        const objectUrl: string = URL.createObjectURL(blob);
        const a: HTMLAnchorElement = document.createElement('a') as HTMLAnchorElement;

        a.href = objectUrl;
        a.download = filename;
        document.body.appendChild(a);
        a.click();

        document.body.removeChild(a);
        URL.revokeObjectURL(objectUrl);
    });
  }

  delete(item: any) {
    this.loading = true;
    const name = item.Key || ('/' + item.Prefix);
    console.log('DELETE', item);
    
    console.log('DELETE', this.currentPath, name);
    if (this.currentPath.startsWith('/')) {
        this.currentPath = this.currentPath.substring(1, this.currentPath.length);
    }

    this.s3
        .delete(this.currentPath + name)
        .subscribe(res => {
            this.loading = false;
            if (res.statusCode === 200) {
                let deleted;
                if (item.Key) {
                    deleted = this.list.findIndex((e) => e.Key === item.Key);
                } else if (item.Prefix) {
                    deleted = this.list.findIndex((e) => e.Prefix === item.Prefix);
                }
                if (deleted) {
                    this.list.splice(deleted, 1);
                }
            }
        });
  }

  move(newPath: string) {
    if (newPath === '/') {
        newPath = '';
    } else {
        if (newPath.endsWith('/')) {
            newPath = newPath.substring(0, newPath.length -1);
        }
        if (newPath.startsWith('/')) {
            newPath = newPath.substring(1, newPath.length);
        }
        if (newPath !== '') {
            newPath += '/'
        }
    }
    this.openFolder({}, newPath)
  }

  openDialog(): void {
    const dialogRef = this.dialog.open(FolderDialogComponent, <MatDialogConfig>{
      data: {name: this.folderName, width: '30em',  minWidth: '30em'}
    });

    dialogRef.afterClosed().subscribe(result => {
      this.folderName = '';
      let fullPath = '';
      this.loading = true;
      console.log(this.currentPath, result);
      if (this.currentPath === '') {
        fullPath = encodeURIComponent(result) + '/';
      } else {
          let prefix = this.currentPath;
          if (this.currentPath.startsWith('/')) {
            prefix = this.currentPath.substring(1, this.currentPath.length);
          }
          console.log('prefix', this.currentPath);
          
          fullPath = this.currentPath + '/' + encodeURIComponent(result) + '/';
          console.log('fullPath', fullPath);
          if (fullPath.startsWith('/')) {
            fullPath = fullPath.substring(1, fullPath.length);
          }
      }
      this.s3.createFolder(fullPath)
        // .pipe(mergeMap(() => this.s3.list(fullPath)))
        .subscribe(() => {
            // this.currentPath = fullPath;
            // this.list = this.mapToDisplayedNames(res);
            // this.loading = false;
            this.move(fullPath);
        });
    });
  }

  private mapToDisplayedNames(list: any[]) {
    if (Array.isArray(list)) {
        return list
            .map((e) => {
                const path = e.Key || e.Prefix;
                if (e.Key && path.startsWith(this.currentPath)) {
                    e.Key = path.replace(this.currentPath, '');
                }
                if (e.Prefix && path.startsWith(this.currentPath)) {
                    e.Prefix = path.replace(this.currentPath, '');
                }
                return e;
            })
            .filter(e => e.Key !== '')
            .filter(e => e.Prefix !== '')
    } else {
        console.error(list);
        // this.openSnackBar();
        return [];
    }
  }

//   private openSnackBar(message?: string) {
//     this._snackBar.open(message || 'An error occured', 'Close', {duration: 10000});
//     setTimeout(() => location.reload(), 2000);
//   }
}
