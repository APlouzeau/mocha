class ResponseUtils {
  static Response jsonResponse(Map<String, dynamic> body,
      {int statusCode = 200}) {
    return Response(statusCode,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
  }

  static Response badResponse(
      {required Map<String, dynamic> body}) {
    return jsonResponse(body, statusCode: 400);
  }
}