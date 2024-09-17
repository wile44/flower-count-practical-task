import os
from fastapi import FastAPI, UploadFile, File, HTTPException, Depends
from typing import List
from PIL import Image, UnidentifiedImageError
from transformers import pipeline
from io import BytesIO
import torch
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security.api_key import APIKeyHeader
import logging
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO)

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:8080",
    "http://localhost:4200"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


API_KEY = os.getenv("FLOWER_API_KEY", "your_api_key_here")  
api_key_header = APIKeyHeader(name="X-API-Key")

def authenticate(api_key: str = Depends(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized. Invalid API key.")


model_name = "smutuvi/flower_count_model"
pipe = pipeline("object-detection", model=model_name)


def extract_flower_count(output: list) -> int:
    flower_count = sum(1 for obj in output if obj['label'] == 'LABEL_1')
    return flower_count


def process_image(file: UploadFile):
    try:
        image_bytes = file.file.read()
        image_data = BytesIO(image_bytes)
        image = Image.open(image_data)
        with torch.no_grad():
            output = pipe(image)
        count = extract_flower_count(output)
        return {"filename": file.filename, "flower_count": count}
    except UnidentifiedImageError:
        logging.error(f"Invalid image format: {file.filename}")
        raise HTTPException(status_code=400, detail=f"File {file.filename} is not a valid image.")
    except Exception as e:
        logging.error(f"General error processing image {file.filename}: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing image {file.filename}: {str(e)}")
    

@app.get("/")
def read_root():
    return {
        "message": "Flower Counting API",
        "Author": "Goodluck Wile"
        }

@app.post("/process-images/", dependencies=[Depends(authenticate)])
async def process_images(files: List[UploadFile] = File(...)):
    flower_counts = []
    max_image_size = 5 * 1024 * 1024  

    
    with ThreadPoolExecutor() as executor:
        futures = []
        for file in files:
            if file.size > max_image_size:
                raise HTTPException(status_code=400, detail=f"Image {file.filename} exceeds size limit.")

            if not file.content_type.startswith("image/"):
                raise HTTPException(status_code=400, detail=f"Invalid file type for {file.filename}. Upload only images.")

            try:
                
                futures.append(executor.submit(process_image, file))

            except Exception as e:
                logging.error(f"Error processing image {file.filename}: {e}")
                raise HTTPException(status_code=500, detail=f"Error processing image {file.filename}")

        for future in futures:
            flower_counts.append(future.result())

    return {"results": flower_counts}



@app.post("/process-dataset/", dependencies=[Depends(authenticate)])
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
                logging.error(f"Error processing image {image_file}: {e}")
                continue

    return {"results": flower_counts}
