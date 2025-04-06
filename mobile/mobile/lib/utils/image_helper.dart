import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A utility class to handle cross-platform image display
class ImageHelper {
  /// Returns a widget that displays an image from a file, handling web platform appropriately
  static Widget imageFromFile(File file, {BoxFit fit = BoxFit.cover, BorderRadius? borderRadius}) {
    if (kIsWeb) {
      // For web, we need to convert the file to memory
      // Since we can't directly get bytes from File on web, we'll have to ensure
      // bytes are passed to this function where needed
      return Container(
        child: Text('Image preview not available on web. Submit to see results.'),
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
      );
    } else {
      // For non-web platforms, we can use Image.file directly
      Widget image = Image.file(
        file,
        fit: fit,
      );
      
      // Apply border radius if provided
      if (borderRadius != null) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: image,
        );
      }
      
      return image;
    }
  }
  
  /// Helper method to display an image from memory (useful for web)
  static Widget imageFromMemory(Uint8List bytes, {BoxFit fit = BoxFit.cover, BorderRadius? borderRadius}) {
    Widget image = Image.memory(
      bytes,
      fit: fit,
    );
    
    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }
    
    return image;
  }
  
  /// Convert image bytes to base64 string for API calls
  static String encodeImageToBase64(Uint8List bytes) {
    String base64Image = base64Encode(bytes);
    return base64Image;
  }
} 