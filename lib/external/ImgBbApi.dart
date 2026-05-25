import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImgBbApi {
  static const String _apiKey = '18ced11376d88014ccb29bba77e74e64';
  static const String _endpoint = 'https://api.imgbb.com/1/upload';
  static const int _maxRetries = 2;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<String> uploadImage(XFile imageFile) async {
    final String fileName = imageFile.name.isNotEmpty
        ? imageFile.name
        : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final List<int> bytes = await imageFile.readAsBytes();

    final Response response = await _postWithRetry(
      bytes: bytes,
      fileName: fileName,
    );

    final dynamic data = response.data;
    if (response.statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['success'] == true) {
      final Map<String, dynamic>? imageData =
          data['data'] as Map<String, dynamic>?;
      final String? url =
          (imageData?['url'] ?? imageData?['display_url'])?.toString();
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    throw Exception('Falha ao enviar imagem para o ImgBB.');
  }

  Future<Response<dynamic>> _postWithRetry({
    required List<int> bytes,
    required String fileName,
  }) async {
    DioException? lastError;

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final FormData formData = FormData.fromMap({
          'name': fileName,
          'image': MultipartFile.fromBytes(bytes, filename: fileName),
        });

        return await _dio.post(
          '$_endpoint?key=$_apiKey',
          data: formData,
        );
      } on DioException catch (e) {
        lastError = e;
        final bool shouldRetry = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError;

        if (!shouldRetry || attempt == _maxRetries) {
          rethrow;
        }

        await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
      }
    }

    throw lastError ?? Exception('Falha desconhecida no upload para ImgBB.');
  }

  Future<List<String>> uploadImages(List<XFile> files) async {
    final List<String> urls = <String>[];
    for (final XFile file in files) {
      urls.add(await uploadImage(file));
    }
    return urls;
  }
}
