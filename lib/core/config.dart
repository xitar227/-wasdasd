class AppConfig {
  const AppConfig._();

  /// Địa chỉ Kalo Server trong mạng Wi-Fi nội bộ.
  /// Khi IP máy tính thay đổi, chỉ cần sửa dòng này.
  static const String serverBaseUrl = 'http://192.168.1.53:8000';

  static const Duration requestTimeout = Duration(seconds: 8);
}
