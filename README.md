# Flower Counting Application

## Overview

This repository contains a full-stack application comprising a backend API, a frontend web application, and an Android mobile app. The application utilizes a pre-trained computer vision model for counting flowers in images.

- **Backend**: A FastAPI service that serves the flower counting model and provides endpoints for batch processing images.
- **flower-count-web**: A web interface that allows users to upload images and view the count of flowers detected in each image.
- **flower_count_android**: A Flutter-based mobile app that captures images automatically at timed intervals and allows users to embed metadata.

---

## Features

- **Batch Image Processing**: Upload multiple images at once and get the flower counts for each.
- **Automated Image Capture**: The Android app captures images every second and allows metadata entry.
- **Metadata Embedding**: Embed text-based metadata into images captured via the Android app.
- **Asynchronous Requests**: Frontend makes asynchronous requests to the backend for smooth user experience.
- **API Authentication**: Secure API endpoints using API key authentication.

---

## Project Structure

```plaintext
├── backend
│   ├── main.py
│   └── requirements.txt
├── flower-count-web
│   ├── package.json
│   └── src
├── flower_count_android
│   ├── pubspec.yaml
│   └── lib
└── README.md
```

---

## Prerequisites

- **Backend**:
  - Python 3.8 or higher
  - `pip` package manager
- **flower-count-web**:
  - Node.js v12 or higher
  - npm v6 or higher
- **Android App**:
  - Flutter SDK
  - Android Studio or Visual Studio Code with Flutter extensions

---

## Setup Instructions

### 1. Backend Setup (FastAPI)

#### a. Install Dependencies

1. Navigate to the backend directory:

   ```bash
   cd backend
   ```

2. (Optional) Create a virtual environment:

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. Install the required Python packages:

   ```bash
   pip install -r requirements.txt
   ```

#### b. Set Up API Key Authentication

1. Open `main.py` and replace `"your_api_key_here"` with your actual API key:

   ```python
   API_KEY = "your_actual_api_key"
   ```

#### c. Run the Backend Server

```bash
uvicorn main:app --reload
```

The backend API will be available at `http://127.0.0.1:8000`.

---

### 2. Frontend Setup (Web Application)

#### a. Install Dependencies

1. Navigate to the flower-count-web directory:

   ```bash
   cd flower-count-web
   ```

2. Install the required npm packages:

   ```bash
   npm install
   ```

#### b. Configure API Endpoint

1. Open the frontend configuration file (e.g., `src/config.js`) and set the backend API URL:

   ```javascript
   export const API_URL = "http://127.0.0.1:8000";
   ```

#### c. Run the Frontend Application

```bash
npm start
```

The frontend web app will be available at `http://localhost:4200`.

---

### 3. Android App Setup (Flutter)

#### a. Install Dependencies

1. Navigate to the android app directory:

   ```bash
   cd flower_count_android
   ```

2. Get Flutter packages:

   ```bash
   flutter pub get
   ```

#### b. Configure Backend API URL

1. Open `lib/main.dart` and set the backend API URL (replace `'http://10.0.2.2:8000'` if necessary):

   ```dart
   final request = http.MultipartRequest(
     'POST',
     Uri.parse('http://10.0.2.2:8000/process-image/'),
   );
   ```

   - **Note**: When running on an Android emulator, use `http://10.0.2.2:8000` to refer to `localhost` on your machine. If using a physical device, replace with your machine's IP address.

#### c. Run the Android App

1. Connect your Android device or start an emulator.
2. Run the app:

   ```bash
   flutter run
   ```

---

## Usage

### 1. Using the Backend API

- **Batch Image Processing Endpoint**: `/process-dataset/`
  - Processes all images in the `test` directory located in the backend folder.
- **Upload Images Endpoint**: `/process-image/`
  - Accepts image files and returns the count of flowers detected in each image.
- **Authentication**:
  - Include the API key in the request headers:

    ```
    X-API-Key: your_actual_api_key
    ```

### 2. Using the Frontend Web App

1. Open the web app in your browser: `http://localhost:4200`.
2. Use the interface to upload images.
3. View the flower count results for each image after processing.

### 3. Using the Android App

1. Launch the app on your device.
2. Enter metadata in the provided text field.
3. Press **Start Capturing** to begin automatic image capture every second.
4. Press **Stop Capturing** to end the image capture process.
5. Press **Upload Images** to send the images and metadata to the backend for processing.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


---

**Note**: Ensure all API URLs and configurations are correctly set before running the applications. Replace placeholder values with actual data where necessary.