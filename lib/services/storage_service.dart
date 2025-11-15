import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // ==================== IMAGE OPERATIONS ====================

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images
  Future<List<XFile>?> pickMultipleImages({int limit = 5}) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultipleImages(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.length > limit) {
        return images.sublist(0, limit);
      }
      return images;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return null;
    }
  }

  /// Show image source selection dialog
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<XFile>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await pickImageFromGallery();
                if (context.mounted) {
                  Navigator.pop(context, image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await pickImageFromCamera();
                if (context.mounted) {
                  Navigator.pop(context, image);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== UPLOAD OPERATIONS ====================

  /// Upload profile image
  Future<String?> uploadProfileImage(
    File imageFile,
    String userId, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage
          .ref()
          .child(AppConstants.storageProfileImages)
          .child(fileName);

      final uploadTask = ref.putFile(imageFile);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Upload document (PDF, JPEG, etc.)
  Future<String?> uploadDocument(
    File documentFile,
    String userId,
    String documentType, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${userId}_${documentType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(documentFile.path)}';
      final ref = _storage
          .ref()
          .child(AppConstants.storageDocuments)
          .child(fileName);

      final uploadTask = ref.putFile(documentFile);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      return null;
    }
  }

  /// Upload planting photo
  Future<String?> uploadPlantingPhoto(
    File imageFile,
    String cooperativeId, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${cooperativeId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage
          .ref()
          .child(AppConstants.storagePlantingPhotos)
          .child(fileName);

      final uploadTask = ref.putFile(imageFile);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading planting photo: $e');
      return null;
    }
  }

  /// Upload harvest photo
  Future<String?> uploadHarvestPhoto(
    File imageFile,
    String cooperativeId, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${cooperativeId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage
          .ref()
          .child(AppConstants.storageHarvestPhotos)
          .child(fileName);

      final uploadTask = ref.putFile(imageFile);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading harvest photo: $e');
      return null;
    }
  }

  /// Upload delivery photo
  Future<String?> uploadDeliveryPhoto(
    File imageFile,
    String orderId, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${orderId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage
          .ref()
          .child(AppConstants.storageDeliveryPhotos)
          .child(fileName);

      final uploadTask = ref.putFile(imageFile);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading delivery photo: $e');
      return null;
    }
  }

  /// Upload multiple photos
  Future<List<String>> uploadMultiplePhotos(
    List<File> imageFiles,
    String storagePath,
    String prefix, {
    Function(int current, int total, double progress)? onProgress,
  }) async {
    final List<String> downloadUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final fileName = '${prefix}_${i}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child(storagePath).child(fileName);

      try {
        final uploadTask = ref.putFile(file);

        // Listen to progress for this file
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final fileProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(i + 1, imageFiles.length, fileProgress);
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        debugPrint('Error uploading image ${i + 1}: $e');
      }
    }

    return downloadUrls;
  }

  // ==================== DELETE OPERATIONS ====================

  /// Delete file by URL
  Future<bool> deleteFileByUrl(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Delete multiple files by URLs
  Future<void> deleteMultipleFiles(List<String> fileUrls) async {
    for (final url in fileUrls) {
      await deleteFileByUrl(url);
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get file size in MB
  Future<double?> getFileSize(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return null;
    }
  }

  /// Validate file size (max 5MB)
  Future<bool> validateFileSize(File file, {double maxSizeMB = 5.0}) async {
    final size = await getFileSize(file);
    if (size == null) return false;
    return size <= maxSizeMB;
  }

  /// Validate image file
  bool isValidImageExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
  }

  /// Validate document file
  bool isValidDocumentExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.pdf', '.jpg', '.jpeg', '.png'].contains(extension);
  }
}
