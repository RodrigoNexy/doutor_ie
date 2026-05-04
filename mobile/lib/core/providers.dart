import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/application/auth_session_notifier.dart';
import '../features/auth/application/login_action_notifier.dart';
import '../features/auth/application/register_action_notifier.dart';
import '../features/books/application/book_list_notifier.dart';
import '../models/auth_session.dart';
import '../services/auth/auth_remote_data_source.dart';
import '../services/auth/dio_auth_remote_data_source.dart';
import '../services/books/books_remote_data_source.dart';
import '../services/books/dio_books_remote_data_source.dart';
import '../services/network/dio_client_factory.dart';
import '../services/storage/auth_token_storage.dart';
import '../services/storage/shared_preferences_auth_token_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider não inicializado. '
    'Use ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]) em main.',
  );
});

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesAuthTokenStorage(prefs);
});

final httpClientFactoryProvider = Provider<HttpClientFactory>((ref) {
  final storage = ref.watch(authTokenStorageProvider);
  return DioClientFactory(tokenStorage: storage);
});

final dioProvider = Provider<Dio>((ref) {
  final factory = ref.watch(httpClientFactoryProvider);
  return factory.create();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DioAuthRemoteDataSource(dio);
});

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthSession>((ref) {
      final storage = ref.watch(authTokenStorageProvider);
      final remote = ref.watch(authRemoteDataSourceProvider);
      return AuthSessionNotifier(storage, remote);
    });

final loginActionProvider =
    StateNotifierProvider.autoDispose<LoginActionNotifier, LoginActionState>(
        (ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final session = ref.read(authSessionProvider.notifier);
  return LoginActionNotifier(remote, session);
});

final registerActionProvider = StateNotifierProvider.autoDispose<
    RegisterActionNotifier, RegisterActionState>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final session = ref.read(authSessionProvider.notifier);
  return RegisterActionNotifier(remote, session);
});

final booksRemoteDataSourceProvider = Provider<BooksRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DioBooksRemoteDataSource(dio);
});

BookListNotifier _buildBookListNotifier(Ref ref) {
  final remote = ref.watch(booksRemoteDataSourceProvider);
  final sessionNotifier = ref.read(authSessionProvider.notifier);
  final notifier = BookListNotifier(
    remote,
    onUnauthorized: sessionNotifier.signOut,
  );
  notifier.load();
  return notifier;
}

final homeBookListProvider =
    StateNotifierProvider.autoDispose<BookListNotifier, BookListState>((ref) {
      return _buildBookListNotifier(ref);
    });

final catalogBookListProvider =
    StateNotifierProvider.autoDispose<BookListNotifier, BookListState>((ref) {
      return _buildBookListNotifier(ref);
    });
