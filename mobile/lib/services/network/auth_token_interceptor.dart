import 'package:dio/dio.dart';

import '../storage/auth_token_storage.dart';

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._tokenStorage);

  final AuthTokenStorage _tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _tokenStorage.readAccessToken().then(
      (token) {
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (Object error, StackTrace stack) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: error,
            stackTrace: stack,
          ),
        );
      },
    );
  }
}
