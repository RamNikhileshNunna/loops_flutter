import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provide SharedPreferences instance asynchronously
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

// StorageService depends on the initialized SharedPreferences
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => StorageService(prefs),
    loading: () => throw UnimplementedError('SharedPreferences loading'),
    error: (e, _) => throw UnimplementedError('SharedPreferences error: $e'),
  );
});

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String keyToken = 'app.token';
  static const String keyInstance = 'app.instance';
  static const String keyLoggedIn = 'app.logged_in';

  String? getToken() => _prefs.getString(keyToken);
  Future<void> setToken(String token) => _prefs.setString(keyToken, token);
  Future<void> clearToken() => _prefs.remove(keyToken);

  String? getInstance() => _prefs.getString(keyInstance);
  Future<void> setInstance(String instance) =>
      _prefs.setString(keyInstance, instance);

  bool getLoggedIn() => _prefs.getBool(keyLoggedIn) ?? false;
  Future<void> setLoggedIn(bool v) => _prefs.setBool(keyLoggedIn, v);
}
