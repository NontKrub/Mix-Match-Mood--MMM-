import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _cropResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Add Clothes', style: TextStyle(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildStyleSelector(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectedImage != null ? _pickImage : null,
              icon: const Icon(Icons.add_a_photo),
              label: Text('Take Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A688),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selectedImage != null ? () => _showGalleryPicker() : null,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8E4DC),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _selectedImage == null
            ? const Text(
                'No image selected yet.\nTap a button above to add clothes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF2D2A26).withValues(alpha: 0.6)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
        aspectRatio: 1,
        child: Image.file(File(_cropResult!), fit: BoxFit.cover),
      ),
                  ),
                  const SizedBox(height: 12),
                  Text('Preview', style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                ],
              ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Type', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E4DC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'AI will detect clothing type automatically from the image.',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colors', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _selectedImage != null
            ? const Center(child: Text('Colors will be extracted here...', style: TextStyle(fontSize: 12)))
            : const SizedBox(),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Style', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _selectedImage != null
            ? const Center(child: Text('Style will be detected here...', style: TextStyle(fontSize: 12)))
            : const SizedBox(),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _handleImagePicked(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showGalleryPicker() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _handleImagePicked(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleImagePicked(XFile image) {
    setState(() {
      _selectedImage = image;
      _cropResult = image.path;
    });

    // Show crop screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropperScreen(imagePath: _cropResult!),
      ),
    ).then((croppedPath) {
      if (croppedPath != null) {
        setState(() {
          _cropResult = croppedPath;
        });
        // TODO: Implement image analysis with ML Kit
      }
    });
  }
}

// Cropper Screen for editing image
class CropperScreen extends StatelessWidget {
  const CropperScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Photo'),
      content: Stack(
        children: [
          Image.file(File(imagePath), fit: BoxFit.contain, width: 300, height: 300),
          Positioned(
            top: 10,
            right: 10,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context, null),
              icon: const Icon(Icons.close),
              label: const Text('Skip'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, imagePath),
          child: const Text('Use This'),
        ),
      ],
    );
  }
}
