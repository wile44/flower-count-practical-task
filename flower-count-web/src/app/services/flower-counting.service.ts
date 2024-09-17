import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

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

    return this.http.post('http://127.0.0.1:8000/process-images/', formData);
  }

  processDataset() {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json', 
      'X-API-Key': 'your_api_key_here'
    });

    const options = { headers: headers };
    return this.http.post('http://127.0.0.1:8000/process-dataset/', {}, options);
  }
}