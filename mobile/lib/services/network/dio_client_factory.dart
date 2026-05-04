import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../storage/auth_token_storage.dart';
import 'auth_token_interceptor.dart';

abstract class HttpClientFactory {
  Dio create();
}

class DioClientFactory implements HttpClientFactory {
  DioClientFactory({
    required AuthTokenStorage tokenStorage,
    List<Interceptor> extraInterceptors = const [],
  }) : _tokenStorage = tokenStorage,
       _extraInterceptors = extraInterceptors;

  final AuthTokenStorage _tokenStorage;
  final List<Interceptor> _extraInterceptors;

  @override
  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.addAll([
      AuthTokenInterceptor(_tokenStorage),
      ..._extraInterceptors,
    ]);
    return dio;
  }
}
