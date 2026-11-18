import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
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
  bool _isPublicChannel = false;
  bool _manualDisconnect = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  DateTime? _lastMessageAt;
  int _retryCount = 0;
  final math.Random _random = math.Random();

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

  /// Connects to the WebSocket server:
  /// - Authenticated users connect to `/ws?userId=...&token=...`
  /// - Anonymous storefront visitors connect to `/ws/public` for real-time catalog updates.
  Future<void> connect({String? customUrl, String? token, String? userId, bool forceReconnect = false}) async {
    if (!enabled || _isTestEnvironment) return;

    final storage = _tokenStorage ?? TokenStorage();
    final effectiveToken = token ?? await storage.getAccessToken();
    final effectiveUserId = userId ?? await storage.getUserId();
    final hasAuth = effectiveToken != null &&
        effectiveToken.isNotEmpty &&
        effectiveUserId != null &&
        effectiveUserId.isNotEmpty;

    // Upgrade guest /ws/public connection to authenticated /ws when credentials become available.
    if ((_isConnected || _isConnecting) && !forceReconnect) {
      if (_isPublicChannel && hasAuth) {
        disconnect();
      } else {
        return;
      }
    } else if (forceReconnect) {
      disconnect();
    }

    _manualDisconnect = false;
    _isConnecting = true;

    try {
      _isPublicChannel = (customUrl == null || customUrl.isEmpty) && !hasAuth;
      final wsUri = _resolveWebSocketUri(
        customUrl: customUrl,
        token: hasAuth ? effectiveToken : null,
        userId: hasAuth ? effectiveUserId : null,
        publicOnly: _isPublicChannel,
      );

      debugPrint('[SellerWebsite WS] Connecting to $wsUri');
      _channel = WebSocketChannel.connect(wsUri);

      _subscription = _channel!.stream.listen(
        (message) {
          _lastMessageAt = DateTime.now();
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

      // Await ready so handshake failures (e.g. WebSocketChannelException) are
      // caught cleanly instead of leaking as unhandled zone errors.
      await _channel!.ready;
    } catch (_) {
      _handleDisconnect();
    }
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  Uri _resolveWebSocketUri({
    String? customUrl,
    String? token,
    String? userId,
    bool publicOnly = false,
  }) {
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
    if (!publicOnly) {
      if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;
      if (token != null && token.isNotEmpty) queryParams['token'] = token;
    }

    return Uri(
      scheme: wsProtocol,
      host: wsHost.split(':').first,
      port: wsHost.contains(':') ? int.tryParse(wsHost.split(':').last) : null,
      path: publicOnly ? '/ws/public' : '/ws',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _lastMessageAt ??= DateTime.now();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isConnected) return;
      final last = _lastMessageAt;
      if (last != null && DateTime.now().difference(last) > const Duration(seconds: 35)) {
        debugPrint('[SellerWebsite WS] Heartbeat timeout (>35s without PONG/frames); reconnecting.');
        try {
          _channel?.sink.close();
        } catch (_) {}
        _handleDisconnect();
        return;
      }
      _send({
        'type': 'PING',
        'timestamp': DateTime.now().toIso8601String(),
      });
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
    if (!_manualDisconnect && !_isTestEnvironment && enabled) {
      final baseMs = (1 << _retryCount.clamp(0, 4)) * 2000; // 2s, 4s, 8s, 16s, 32s
      final jitterMs = _random.nextInt(1000);
      _retryCount++;
      _reconnectTimer = Timer(Duration(milliseconds: baseMs + jitterMs), () {
        connect();
      });
    }
  }

  void disconnect() {
    _manualDisconnect = true;
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
