import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class FlowerCountingService {

  constructor(private http: HttpClient) { }

  processImages(files: File[]) {
    const formData = new FormData();
    for (const file of files) {
      formData.append('files', file);
    }

    return this.http.post('http://127.0.0.1:8000/process-image/', formData);
  }

  processDataset() {
    return this.http.post('http://127.0.0.1:8000/process-dataset/', {});
  }
}