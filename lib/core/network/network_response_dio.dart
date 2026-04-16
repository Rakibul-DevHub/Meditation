class NetworkResponseDio {
  final int? statusCode;

  final bool isSuccess;

  final Map<String, dynamic>? jsonResponse;

  final String? errorMessage;

  NetworkResponseDio({
    this.statusCode,
    required this.isSuccess,
    this.jsonResponse,
    this.errorMessage = 'Something went wrong',
  });
}