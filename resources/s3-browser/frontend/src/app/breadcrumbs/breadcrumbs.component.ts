import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';

@Component({
  selector: 'app-breadcrumbs',
  templateUrl: './breadcrumbs.component.html',
  styleUrls: ['./breadcrumbs.component.scss']
})
export class BreadcrumbsComponent implements OnInit {
    @Input() currentPath = '';
    @Output() pathChanged = new EventEmitter<string>();
    fullPaths: string[] = [];

    ngOnInit(): void {
        this.fullPaths = this.currentPath.split('/');
    }

    displayPath(fullPath: string): string {
        const paths = fullPath.split('/');
        return fullPath.split('/')[paths.length];
    }

    changePath(index: number) {
        const newPaths = this.fullPaths.slice(0, index + 1);
        const newPath = newPaths.join('/');
        this.pathChanged.emit(newPath || '');
    }
}
