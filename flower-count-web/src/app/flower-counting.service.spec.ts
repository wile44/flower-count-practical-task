import { TestBed } from '@angular/core/testing';

import { FlowerCountingService } from './flower-counting.service';

describe('FlowerCountingService', () => {
  let service: FlowerCountingService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FlowerCountingService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
