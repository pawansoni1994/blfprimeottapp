import 'package:dio/dio.dart';

class RequestHeaderInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    getCustomHeaders(options).then((customHeaders) {
      options.headers.addAll(customHeaders);
      super.onRequest(options, handler);
    });
  }

  Future<Map<String, String>> getCustomHeaders(RequestOptions options) async {
    var customHeaders = <String, String>{};
    
    // Only set content-type to application/json if data is not FormData
    // Dio automatically sets the correct content-type for FormData (multipart/form-data)
    if (options.data is! FormData) {
      customHeaders['content-type'] = 'application/json';
    }

    return customHeaders;
  }
}
