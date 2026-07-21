import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  NetworkService({
    Connectivity? connectivity,
    http.Client? httpClient,
  })  : _connectivity = connectivity ?? Connectivity(),
        _httpClient = httpClient ?? http.Client();

  final Connectivity _connectivity;
  final http.Client _httpClient;

  // Địa chỉ Kalo Server trong mạng LAN hiện tại.
  static const String serverUrl = 'http://192.168.1.53:8000';

  /// Trả về danh sách kiểu kết nối mạng hiện tại.
  Future<List<ConnectivityResult>> getConnectionTypes() {
    return _connectivity.checkConnectivity();
  }

  /// Thiết bị có đang kết nối bằng Wi-Fi hay không.
  Future<bool> isWifi() async {
    final results = await getConnectionTypes();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Thiết bị có đang dùng dữ liệu di động hay không.
  Future<bool> isMobile() async {
    final results = await getConnectionTypes();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Kalo Server có phản hồi bình thường hay không.
  Future<bool> isServerOnline() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$serverUrl/status'))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Kalo chỉ được phép đồng bộ khi:
  /// 1. Thiết bị đang dùng Wi-Fi.
  /// 2. Kalo Server đang hoạt động.
  Future<bool> canSync() async {
    final wifiConnected = await isWifi();
    if (!wifiConnected) return false;

    return isServerOnline();
  }

  /// Giải phóng HTTP client khi service không còn được sử dụng.
  void dispose() {
    _httpClient.close();
  }
}
