import os
from fastapi import FastAPI, UploadFile, File, HTTPException, Depends
from typing import List
from PIL import Image, UnidentifiedImageError
from transformers import pipeline
from io import BytesIO
import torch
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security.api_key import APIKeyHeader


app = FastAPI()

origins = [
    "http://localhost.tiangolo.com",
    "https://localhost.tiangolo.com",
    "http://localhost",
    "http://localhost:8080",
    "http://localhost:4200",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


API_KEY = "your_api_key_here"  
api_key_header = APIKeyHeader(name="X-API-Key")

def authenticate(api_key: str = Depends(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")


model_name = "smutuvi/flower_count_model"
pipe = pipeline("object-detection", model=model_name)


def extract_flower_count(output: list) -> int:
    """Extracts the flower count from the model's output."""
    flower_count = sum(1 for obj in output if obj['label'] == 'LABEL_1')
    return flower_count


@app.get("/")
def read_root():
    return {"message": "Flower Counting API"}


@app.post("/process-image/")
async def upload(files: List[UploadFile] = File(...)):
    flower_counts = []  
    
    for file in files:
        
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="Invalid file type. Please upload an image.")

        try:
            
            image_bytes = await file.read()
            image_data = BytesIO(image_bytes)
            image = Image.open(image_data)

            
            with torch.no_grad():
                output = pipe(image)  

            
            count = extract_flower_count(output)
            
            
            flower_counts.append({"filename": file.filename, "flower_count": count})

        except UnidentifiedImageError:
            raise HTTPException(status_code=400, detail=f"File {file.filename} is not a valid image.")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error processing image {file.filename}: {str(e)}")

    
    return {"results": flower_counts}


@app.post("/process-dataset/")
async def process_dataset():
    
    dataset_directory = os.path.join(os.path.dirname(__file__), "test")  

    if not os.path.exists(dataset_directory):
        raise HTTPException(status_code=404, detail="Dataset directory not found.")

    flower_counts = []

    
    for image_file in os.listdir(dataset_directory):
        if image_file.endswith(('.png', '.jpg', '.jpeg')):
            try:
                image_path = os.path.join(dataset_directory, image_file)
                image = Image.open(image_path)

                
                with torch.no_grad():
                    output = pipe(image)

                
                count = extract_flower_count(output)

                
                flower_counts.append({"filename": image_file, "flower_count": count})

            except Exception as e:
                print(f"Error processing image {image_file}: {e}")
                continue

    return {"results": flower_counts}
