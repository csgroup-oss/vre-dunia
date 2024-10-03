import { Component, Inject } from '@angular/core';
import {MatDialog, MAT_DIALOG_DATA, MatDialogRef} from '@angular/material/dialog';

@Component({
  selector: 'app-folder-dialog',
  templateUrl: './folder-dialog.component.html',
  styleUrls: ['./folder-dialog.component.scss']
})
export class FolderDialogComponent {
  name = '';

  constructor(
    public dialogRef: MatDialogRef<FolderDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: string,
  ) {}

  onNoClick(): void {
    this.dialogRef.close();
  }

  folderNameOk(): boolean {
    return !this.name.match(/(\^|\{|\\|\}|\%|\`|\[|\]|\>|\~|\>|\#|\||\/)/)
        && !this.name.includes(' ');
  }
}
