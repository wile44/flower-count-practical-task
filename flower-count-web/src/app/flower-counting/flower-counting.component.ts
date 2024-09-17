import { Component, OnInit } from '@angular/core';
import { FlowerCountingService } from '../services/flower-counting.service';

@Component({
  selector: 'app-flower-counting',
  templateUrl: './flower-counting.component.html',
  styleUrls: ['./flower-counting.component.css']
})
export class FlowerCountingComponent implements OnInit {

  results: any[] = [];
  loading: boolean = false;

  constructor(private flowerCountingService: FlowerCountingService) { }

  ngOnInit(): void {

  }

  onFileSelect(event: any) {
    const files = event.target.files;
    this.flowerCountingService.processImages(files)
      .subscribe({
        next: (results: any) => {
          this.results = results.results;
        },
        error: error => {
          console.error('Error processing images:', error);
          this.results = []; // Reset results to clear previous data
        },
        complete: () => {
          // Optional: Handle completion (e.g., hide loading indicator)
        }
      });
  }
  


  // Trigger processing and get the results
  processImages(): void {
    this.loading = true;
    this.results = [];
    this.flowerCountingService.processDataset().subscribe(
      (response: any) => {
        this.results = response.results;
        this.loading = false;
      },
      (error) => {
        console.error('Error processing images:', error);
        this.loading = false;
      }
    );
  }
}