import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'dfcwitmux';
  // IMPORTANTE: Este preset debe estar configurado en https://cloudinary.com/console/settings/upload
  // Debe ser "Unsigned". 'ml_default' suele ser el nombre por defecto.
  static const String uploadPreset = 'xqbjzcjq'; 

  Future<String> uploadImage(XFile file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    try {
      // Usamos readAsBytes para compatibilidad con Web
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        throw Exception('Cloudinary Error ${response.statusCode}: ${jsonMap['error']['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
