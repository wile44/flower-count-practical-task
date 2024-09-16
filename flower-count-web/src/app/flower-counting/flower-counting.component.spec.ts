import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FlowerCountingComponent } from './flower-counting.component';

describe('FlowerCountingComponent', () => {
  let component: FlowerCountingComponent;
  let fixture: ComponentFixture<FlowerCountingComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [FlowerCountingComponent]
    });
    fixture = TestBed.createComponent(FlowerCountingComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
