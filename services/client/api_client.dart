import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:point_of_sales/utils/constants/api_constants.dart';

/// 🔹 **Centralized API Client**
class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: ApiConstants.defaultHeaders,
  ));

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("📤 Request: ${options.method} ${options.uri}");
        print("📝 Headers: ${options.headers}");
        print("📨 Body: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ Response [${response.statusCode}]: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ Dio Error: ${e.message}");
        if (e.response != null) {
          print("🔴 Error Response: ${e.response?.data}");
          print("⚠️ Status Code: ${e.response?.statusCode}");
        }
        return handler.next(e);
      },
    ));

    if (kIsWeb) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (DioException e, handler) async {
            if (_shouldRetry(e)) {
              try {
                print("🔄 Retrying request due to network error...");
                final options = e.requestOptions;
                final response = await _dio.request(
                  options.path,
                  data: options.data,
                  queryParameters: options.queryParameters,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                  ),
                );
                return handler.resolve(response);
              } catch (retryError) {
                return handler.next(e);
              }
            }
            return handler.next(e);
          },
        ),
      );
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        (error.message?.contains('XMLHttpRequest') ?? false);
  }

  /// 🔹 **GET Request**
  Future<Map<String, dynamic>?> get(String path,
      {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await _dio.get(path, queryParameters: queryParams);
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 **POST Request**
  Future<Map<String, dynamic>?> post(
      String path, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(path, data: data);
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 **PUT Request**
  Future<Map<String, dynamic>?> put(
      String path, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.put(path, data: data);
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 **DELETE Request**
  Future<Map<String, dynamic>?> delete(String path,
      {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await _dio.delete(path, queryParameters: queryParams);
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 **PATCH Request**
  Future<Map<String, dynamic>?> patch(
      String path, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.patch(path, data: data);
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 **File Upload (Multipart)**
  Future<Map<String, dynamic>?> uploadFile(String path, String filePath,
      {Map<String, dynamic>? data}) async {
    try {
      FormData formData = FormData.fromMap({
        ...?data,
        "file": await MultipartFile.fromFile(filePath),
      });

      Response response = await _dio.post(path, data: formData);
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic>? _processResponse(Response response) {
    final responseData = response.data;

    if (responseData is Map<String, dynamic>) {
      final result = Map<String, dynamic>.from(responseData);

      /// ✅ Normalize success status
      final dynamic status = responseData["status"];
      final dynamic success = responseData["success"];

      result["success"] = success is bool
          ? success
          : (status is String ? status.toLowerCase() == "success" : false);

      /// ✅ Normalize message
      if (result["message"] == null && result["error"] != null) {
        result["message"] = result["error"];
      } else {
        result["message"] ??= "Operation completed";
      }

      /// ✅ Normalize error
      result["error"] = responseData["error"] ?? "";

      return result;
    }

    return {
      "success": false,
      "message": "Invalid response format",
      "statusCode": response.statusCode
    };
  }

  Map<String, dynamic>? _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      final data = response?.data;

      print("❌ Dio Error: ${error.message}");
      print("📨 Error Response Data: $data");

      if (data is Map<String, dynamic>) {
        final errorMessage = data['error']?.toString() ??
            data['message']?.toString() ??
            error.message ??
            'An unknown error occurred';

        return {
          "success": false,
          "error": data['error'] ?? "",
          "message": errorMessage,
          "statusCode": response?.statusCode ?? 500
        };
      }

      // If data is not a map (e.g., string, HTML error page)
      return {
        "success": false,
        "error": "",
        "message": error.message ?? "An unknown error occurred",
        "statusCode": response?.statusCode ?? 500
      };
    }

    // Handle non-Dio exceptions
    print("❌ Unknown Error: $error");
    return {
      "success": false,
      "error": "",
      "message": error.toString(),
      "statusCode": 500
    };
  }
}
