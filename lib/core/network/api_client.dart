import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;
  final String _baseUrl;
  final Duration _timeout;
  Completer<bool>? _refreshCompleter;

  ApiClient({
    http.Client? client,
    TokenStorage? tokenStorage,
    String? baseUrl,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
        _timeout = timeout ?? const Duration(seconds: 30);

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final uri = Uri.parse(path);
      if (queryParameters == null || queryParameters.isEmpty) return uri;
      final mergedParams = Map<String, String>.from(uri.queryParameters);
      queryParameters.forEach((key, value) {
        if (value != null) mergedParams[key] = value.toString();
      });
      return uri.replace(queryParameters: mergedParams);
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$_baseUrl$cleanPath';
    return Uri.parse(fullUrl).replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  Future<Map<String, String>> _buildHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw const UnauthorizedException(
          message: 'Full authentication is required to access this resource. Please sign in.',
        );
      }
    }

    return headers;
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }
      final uri = _buildUri(ApiEndpoints.refreshToken);
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map ? (decoded['data'] ?? decoded) : null;
        if (data is Map) {
          final newAccess = (data['accessToken'] ?? data['token'])?.toString();
          final newRefresh = data['refreshToken']?.toString() ?? refreshToken;
          if (newAccess != null && newAccess.isNotEmpty) {
            await _tokenStorage.saveSession(
              accessToken: newAccess,
              refreshToken: newRefresh,
              userId: (await _tokenStorage.getUserId()) ?? '',
              role: (await _tokenStorage.getRole()) ?? 'ROLE_CUSTOMER',
              phoneNumber: await _tokenStorage.getPhoneNumber(),
            );
            _refreshCompleter!.complete(true);
            return true;
          }
        }
      }
      await _tokenStorage.clearSession();
      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<http.Response> _sendWithAuthRetry(
    Future<http.Response> Function(Map<String, String> headers) send,
    bool requiresAuth,
  ) async {
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    final response = await send(headers);
    if (response.statusCode == 401 && requiresAuth) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requiresAuth: requiresAuth);
        return await send(newHeaders);
      }
    }
    return response;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _sendWithAuthRetry(
        (headers) => _client.get(uri, headers: headers).timeout(_timeout),
        requiresAuth,
      );
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'No internet connection or server unreachable: ${e.message}',
        details: e,
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'The server took too long to respond. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network communication failure: ${e.message}',
        details: e,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error occurred: $e', details: e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _sendWithAuthRetry(
        (headers) => _client
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(_timeout),
        requiresAuth,
      );

      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'No internet connection or server unreachable: ${e.message}',
        details: e,
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'The server took too long to respond. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network communication failure: ${e.message}',
        details: e,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error occurred: $e', details: e);
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyText = response.body;

    Map<String, dynamic> decoded;
    try {
      if (bodyText.isEmpty) {
        decoded = <String, dynamic>{};
      } else {
        final raw = jsonDecode(bodyText);
        decoded = raw is Map<String, dynamic>
            ? raw
            : <String, dynamic>{'data': raw};
      }
    } catch (_) {
      throw ServerException(
        message: 'Invalid JSON response from server (HTTP $statusCode)',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    final message = (decoded['message'] ?? decoded['error'] ?? 'Request failed (HTTP $statusCode)').toString();
    if (statusCode == 401) {
      throw UnauthorizedException(message: message, details: decoded);
    }
    if (statusCode == 400 || statusCode == 422) {
      final rawValidation = decoded['errors'] ?? decoded['validationErrors'];
      final validationMap = <String, String>{};
      if (rawValidation is Map) {
        rawValidation.forEach((k, v) {
          validationMap[k.toString()] = v.toString();
        });
      }
      throw ValidationException(
        message: message,
        validationErrors: validationMap,
        statusCode: statusCode,
        details: decoded,
      );
    }
    throw ServerException(
      message: message,
      statusCode: statusCode,
      details: decoded,
    );
  }
}
