import 'package:flutter/foundation.dart';

/// URL base da API Laravel (prefixo `/api` quando usar `routes/api.php`).
///
/// Sobrescreva em build/run:
/// `flutter run --dart-define=API_BASE_URL=https://exemplo.com/api`
class ApiConfig {
  ApiConfig._();

  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) {
      final trimmed = _fromEnv.trim();
      return trimmed.endsWith('/')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
    }
    return '${_defaultOrigin()}/api';
  }

  static String _defaultOrigin() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Emulador Android: localhost do host é 10.0.2.2
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }
}
