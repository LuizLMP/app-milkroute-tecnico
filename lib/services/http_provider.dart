import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';

class HttpProvider {
  Future<Response> getData(String url, {Map<String, String>? headers}) async {
    try {
      var file = await DefaultCacheManager().getSingleFile(url, headers: headers);

      if (file != null && await file.exists()) {
        var res = await file.readAsString();
        return Response(res, 200);
      }
      return Response('', 404);
    } catch (ex) {
      throw Exception("Sem sinal de internet ou API");
    }
  }

  Future<Response> postData(String url, {Map<String, String>? headers, Object? body}) async {
    final response = await post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response;
  }
}
