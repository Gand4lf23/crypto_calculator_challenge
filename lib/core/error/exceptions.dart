class ServerException implements Exception {
  final int? statusCode;
  final String? body;

  const ServerException({this.statusCode, this.body});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, body: $body)';
}
