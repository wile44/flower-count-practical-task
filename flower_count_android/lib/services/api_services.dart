import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  Future<void> uploadImages(List<File> imageFiles, String metadata, BuildContext context) async {
    try {
      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/process-images/'),
      );
      
      // Add API key in headers
      request.headers['X-API-Key'] = 'your_api_key_here';

      // Loop through all files and add them to the request
      for (var imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('files', imageFile.path)
        );
      }

      // Add metadata as part of the request fields
      request.fields['metadata'] = metadata;

      // Send the request
      final response = await request.send();

      // Print logs and handle success or failure
      if (response.statusCode == 200) {
        print('Images uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Images uploaded successfully')),
        );
      } else {
        print('Failed to upload images');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images: ${response.statusCode}')),
        );
        throw Exception('Failed to upload images');
      }
    } catch (e) {
      print('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading images: $e')));
    }
  }
}
