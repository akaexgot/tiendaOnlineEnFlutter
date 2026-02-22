import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/cloudinary_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialUrl;
  final Function(String?) onImageChanged;
  final String label;

  const ImageUploadWidget({
    super.key,
    this.initialUrl,
    required this.onImageChanged,
    this.label = 'Imagen',
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final _urlController = TextEditingController();
  final _cloudinaryService = CloudinaryService();
  final _picker = ImagePicker();
  
  bool _isUploading = false;
  String? _currentUrl;
  bool _showUrlInput = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _urlController.text = widget.initialUrl ?? '';
  }

  @override
  void didUpdateWidget(ImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUrl != oldWidget.initialUrl) {
      setState(() {
        _currentUrl = widget.initialUrl;
        _urlController.text = widget.initialUrl ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isUploading = true);
        
        try {
          final imageUrl = await _cloudinaryService.uploadImage(image);
          if (mounted) {
            setState(() {
              _currentUrl = imageUrl;
              _urlController.text = imageUrl;
            });
            widget.onImageChanged(imageUrl);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir: $e'), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isUploading = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onUrlChanged(String value) {
    setState(() => _currentUrl = value);
    widget.onImageChanged(value.isEmpty ? null : value);
  }

  void _removeImage() {
    setState(() {
      _currentUrl = null;
      _urlController.clear();
    });
    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(widget.label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 8),
        ],
        
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator())
              : _currentUrl != null && _currentUrl!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _currentUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.6),
                            ),
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: _removeImage,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, 
                              size: 40, color: Colors.grey.shade600),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Subir Imagen'),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _showUrlInput = !_showUrlInput),
                            child: Text(_showUrlInput ? 'Ocultar URL' : 'O usar URL externa'),
                          ),
                        ],
                      ),
                    ),
        ),
        
        if (_showUrlInput) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            onChanged: _onUrlChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'URL de la imagen',
              hintText: 'https://...',
              prefixIcon: const Icon(Icons.link),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => setState(() => _showUrlInput = false),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
