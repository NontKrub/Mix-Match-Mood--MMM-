import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'package:mix_match_mood/core/services/mlkit_service.dart';
import 'package:mix_match_mood/core/models/clothes.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final HiveService _hiveService = HiveService();
  final MLKitService _mlKitService = MLKitService();
  final TextEditingController _nameController = TextEditingController();
  XFile? _selectedImage;
  String? _cropResult;
  String? _selectedType;
  List<String> _selectedColors = [];
  List<String> _selectedStyles = [];
  List<String> _selectedOccasions = ['daily'];

  final List<String> _types = [
    'top',
    'bottom',
    'pants',
    'hat',
    'jewelry',
    'accessory'
  ];
  final List<String> _defaultColors = [
    'white',
    'black',
    'gray',
    'blue',
    'red',
    'green',
    'yellow'
  ];
  final List<String> _defaultStyles = [
    'casual',
    'formal',
    'classic',
    'modern',
    'boho'
  ];
  final List<String> _defaultOccasions = [
    'daily',
    'work',
    'party',
    'travel',
    'sport'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
            _buildNameInput(),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildStyleSelector(),
            const SizedBox(height: 16),
            _buildOccasionSelector(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A688),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showGalleryPicker,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8E4DC),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              _buildSaveButton(),
            ],
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
            ? Text(
                'No image selected yet.\nTap a button above to add clothes.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Color(0xFF2D2A26).withValues(alpha: 0.6)),
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
                  Text('Preview',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  if (_selectedType != null)
                    Text('Type: $_selectedType',
                        style: const TextStyle(fontSize: 12)),
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
        Wrap(
          spacing: 8,
          children: _types.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(_typeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                } else {
                  setState(() => _selectedType = null);
                }
              },
              backgroundColor: const Color(0xFFE8E4DC),
              selectedColor: const Color(0xFFC9A688).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                  color:
                      isSelected ? const Color(0xFFC9A688) : Color(0xFF2D2A26)),
            );
          }).toList(),
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
        if (_selectedImage != null)
          Wrap(
            spacing: 8,
            children: _defaultColors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return FilterChip(
                label: Text(color.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
                backgroundColor: const Color(0xFFE8E4DC),
                selectedColor: const Color(0xFFC9A688).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFFC9A688)
                        : Color(0xFF2D2A26)),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildNameInput() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Item Name (optional)',
        hintText: 'e.g., White Linen Shirt',
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Style', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          Wrap(
            spacing: 8,
            children: _defaultStyles.map((style) {
              final isSelected = _selectedStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStyles.add(style);
                    } else {
                      _selectedStyles.remove(style);
                    }
                  });
                },
                backgroundColor: const Color(0xFFE8E4DC),
                selectedColor: const Color(0xFFC9A688).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFFC9A688)
                        : Color(0xFF2D2A26)),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildOccasionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Occasion', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _defaultOccasions.map((occasion) {
            final isSelected = _selectedOccasions.contains(occasion);
            return FilterChip(
              label: Text(occasion),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedOccasions.add(occasion);
                  } else {
                    _selectedOccasions.remove(occasion);
                  }
                });
              },
              backgroundColor: const Color(0xFFE8E4DC),
              selectedColor: const Color(0xFFC9A688).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFFC9A688)
                    : const Color(0xFF2D2A26),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveClothes,
      icon: const Icon(Icons.save),
      label: const Text('Save Clothes'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC9A688),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleImagePicked(XFile image) {
    setState(() {
      _selectedImage = image;
      _cropResult = image.path;
    });
  }

  Future<void> _saveClothes() async {
    if (_cropResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an image first')),
      );
      return;
    }

    if (_selectedType == null || _selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one color')),
      );
      return;
    }

    // Perform ML Kit analysis for better accuracy
    final analysis = await _mlKitService.analyzeClothing(_cropResult!);

    // Use AI predictions as fallback defaults.
    if ((_selectedType == null || _selectedType!.isEmpty) &&
        analysis['type'] != null &&
        analysis['type'] != 'unknown') {
      _selectedType = analysis['type'];
    }
    if (_selectedColors.isEmpty && analysis['colors'] != null) {
      _selectedColors.addAll(analysis['colors']);
    }
    if (_selectedStyles.isEmpty && analysis['styles'] != null) {
      _selectedStyles.addAll(analysis['styles']);
    }

    // Remove duplicates
    _selectedColors = _selectedColors.toSet().toList();
    _selectedStyles = _selectedStyles.toSet().toList();

    final itemName = _nameController.text.trim().isEmpty
        ? _typeLabel(_selectedType ?? 'top')
        : _nameController.text.trim();

    final clothes = Clothes(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: itemName,
      type: _selectedType ?? 'top',
      colors: _selectedColors,
      styles: _selectedStyles,
      occasions: _selectedOccasions.isEmpty ? ['daily'] : _selectedOccasions,
      imagePath: _cropResult,
      detectionConfidence: (analysis['confidence'] as num?)?.toDouble(),
    );

    await _hiveService.addClothes(clothes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Saved: ${clothes.name} (${clothes.type}) - AI detected ${analysis['confidence'] * 100}% confidence'),
          backgroundColor: const Color(0xFF8DB998),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _typeLabel(String type) {
    const labels = {
      'top': 'Top',
      'bottom': 'Bottom',
      'pants': 'Pants',
      'hat': 'Hat',
      'jewelry': 'Jewelry',
      'accessory': 'Accessory',
    };
    return labels[type] ?? type;
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
          Image.file(File(imagePath),
              fit: BoxFit.contain, width: 300, height: 300),
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
