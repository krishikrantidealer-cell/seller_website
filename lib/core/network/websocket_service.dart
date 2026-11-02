import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

/// Real-time Enterprise WebSocket Client for Seller Website.
/// Connects to `/ws` on `ebs_biocrop_backend`, maintains a 15-second PING/PONG
/// keep-alive heartbeat, and broadcasts real-time events (`categories:*`,
/// `products:*`, `collections:*`, `orders:*`, `inventory:stock_update`,
/// `auth:session_revoked`) directly to BLoCs.
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _retryCount = 0;

  final _productUpdatesController = StreamController<Map<String, dynamic>>.broadcast();
  final _categoryUpdatesController = StreamController<Map<String, dynamic>>.broadcast();
  final _collectionUpdatesController = StreamController<Map<String, dynamic>>.broadcast();
  final _orderUpdatesController = StreamController<Map<String, dynamic>>.broadcast();
  final _authRevokedController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get productUpdates => _productUpdatesController.stream;
  Stream<Map<String, dynamic>> get categoryUpdates => _categoryUpdatesController.stream;
  Stream<Map<String, dynamic>> get collectionUpdates => _collectionUpdatesController.stream;
  Stream<Map<String, dynamic>> get orderUpdates => _orderUpdatesController.stream;
  Stream<Map<String, dynamic>> get authRevokedUpdates => _authRevokedController.stream;
  Stream<bool> get connectionStatus => _connectionStateController.stream;
  bool get isConnected => _isConnected;

  TokenStorage? _tokenStorage;

  /// Global toggle: Active for live bidirectional real-time sync with backend.
  static bool enabled = true;

  void setTokenStorage(TokenStorage storage) {
    _tokenStorage = storage;
  }

  /// Connects to the WebSocket server when authenticated credentials are available.
  Future<void> connect({String? customUrl, String? token, String? userId}) async {
    if (!enabled || _isTestEnvironment) return;
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;

    try {
      final storage = _tokenStorage ?? TokenStorage();
      final effectiveToken = token ?? await storage.getAccessToken();
      final effectiveUserId = userId ?? await storage.getUserId();

      // Backend WebSocketAuthInterceptor requires userId & token query params
      if ((customUrl == null || customUrl.isEmpty) &&
          (effectiveToken == null ||
              effectiveToken.isEmpty ||
              effectiveUserId == null ||
              effectiveUserId.isEmpty)) {
        _isConnecting = false;
        return;
      }

      final wsUri = _resolveWebSocketUri(
        customUrl: customUrl,
        token: effectiveToken,
        userId: effectiveUserId,
      );

      debugPrint('[SellerWebsite WS] Connecting to $wsUri');
      _channel = WebSocketChannel.connect(wsUri);

      _subscription = _channel!.stream.listen(
        (message) {
          if (!_isConnected) {
            _isConnected = true;
            _isConnecting = false;
            _connectionStateController.add(true);
            _retryCount = 0;
            if (!_isTestEnvironment) {
              _startHeartbeat();
            }
            debugPrint('[SellerWebsite WS] Connected successfully.');
          }
          _handleMessage(message);
        },
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: false,
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  Uri _resolveWebSocketUri({String? customUrl, String? token, String? userId}) {
    if (customUrl != null && customUrl.isNotEmpty) {
      return Uri.parse(customUrl);
    }

    const envWsUrl = String.fromEnvironment('WS_BASE_URL', defaultValue: '');
    if (envWsUrl.isNotEmpty) {
      return Uri.parse(envWsUrl);
    }

    final baseApi = ApiEndpoints.baseUrl;
    final cleanUrl = baseApi.replaceAll('/api', '').replaceAll(RegExp(r'/+$'), '');
    final wsProtocol = cleanUrl.startsWith('https') ? 'wss' : 'ws';
    final wsHost = cleanUrl.replaceFirst(RegExp(r'https?://'), '');

    final queryParams = <String, String>{};
    if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;
    if (token != null && token.isNotEmpty) queryParams['token'] = token;

    return Uri(
      scheme: wsProtocol,
      host: wsHost.split(':').first,
      port: wsHost.contains(':') ? int.tryParse(wsHost.split(':').last) : null,
      path: '/ws',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isConnected) {
        _send({
          'type': 'PING',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        debugPrint('[SellerWebsite WS] Send error: $e');
      }
    }
  }

  /// Allows injecting simulated or test WebSocket messages into the stream pipeline.
  @visibleForTesting
  void handleRawMessageForTest(String rawJson) {
    _handleMessage(rawJson);
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage.toString());
      if (decoded is! Map<String, dynamic>) return;

      // 1. Heartbeat Pong
      final type = decoded['type'];
      if (type == 'PONG') return;

      // 2. Handshake ACK from backend (system:connected)
      final event = decoded['event'] as String?;
      if (event == 'system:connected' || type == 'CONNECTION_ACK') {
        _isConnected = true;
        _isConnecting = false;
        _connectionStateController.add(true);
        _retryCount = 0;
        return;
      }

      // 3. Standard Backend Event Envelope Routing
      if (event != null) {
        if (event.startsWith('products:') || event == 'inventory:stock_update') {
          _productUpdatesController.add(decoded);
        } else if (event.startsWith('categories:')) {
          _categoryUpdatesController.add(decoded);
        } else if (event.startsWith('collections:')) {
          _collectionUpdatesController.add(decoded);
        } else if (event.startsWith('orders:')) {
          _orderUpdatesController.add(decoded);
        } else if (event == 'auth:session_revoked') {
          _authRevokedController.add(decoded);
        }
        return;
      }

      // 4. Legacy / Client-simulated event routing
      if (type == 'CATEGORY_UPDATE' || type == 'CATEGORIES_UPDATED') {
        _categoryUpdatesController.add(decoded);
      } else if (type == 'PRODUCT_UPDATE' || type == 'STOCK_UPDATED') {
        _productUpdatesController.add(decoded);
      }
    } catch (_) {}
  }

  void _handleDisconnect() {
    _isConnected = false;
    _isConnecting = false;
    _connectionStateController.add(false);
    _heartbeatTimer?.cancel();
    _subscription?.cancel();

    _reconnectTimer?.cancel();
    if (!_isTestEnvironment && enabled) {
      final delaySeconds = (1 << _retryCount.clamp(0, 4)) * 2; // 2s, 4s, 8s, 16s, 32s
      _retryCount++;
      _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
        connect();
      });
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    _connectionStateController.add(false);
  }
}
