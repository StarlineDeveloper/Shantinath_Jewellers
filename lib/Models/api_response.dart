class APIResponse<T> {
  T? data;
  String? errorMessage;
  bool isError;

  APIResponse({this.data, this.errorMessage, this.isError = false});
}
