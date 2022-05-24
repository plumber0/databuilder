import 'package:http/http.dart' as http;
import 'dart:convert';

extension E on String {
  String lastChars(int n) => substring(length - n);
}

Future get({
  endpoint,
  path,
  params,
  headers,
}) async {
  final url = Uri.parse('$endpoint/$path');
  var response = await http.get(
    url,
    headers: headers,
  );
  return jsonDecode(utf8.decode(response.bodyBytes));
}

Stream getPages({
  endpoint,
  path,
  params,
  headers,
}) async* {
  var url = Uri.https(
    endpoint = endpoint,
    path = path,
    params = params,
  );

  Map pageInfo = {};
  var response = await http.get(url, headers: headers);
  response.headers['link']?.split(', ').forEach((element) {
    pageInfo.addAll({element.split('; ')[1]: element.split('; ')[0]});
  });
  yield jsonDecode(utf8.decode(response.bodyBytes));
  while (pageInfo['rel="next"'] != pageInfo['rel="last"']) {
    String nextUrl =
        pageInfo['rel="next"'].substring(1, pageInfo['rel="next"'].length - 1);
    var url = Uri.parse(nextUrl);

    response = await http.get(url, headers: headers);
    response.headers['link']?.split(', ').forEach((element) {
      pageInfo.addAll({element.split('; ')[1]: element.split('; ')[0]});
    });
    yield jsonDecode(utf8.decode(response.bodyBytes));
  }
}

Future post({
  endpoint,
  path,
  data,
  headers,
}) async {
  final url = Uri.parse('$endpoint/$path');
  var response = await http.post(url, headers: headers, body: data);
  return jsonDecode(utf8.decode(response.bodyBytes));
}

Future postStream({
  endpoint,
  path,
  data,
  headers,
  params,
}) async {
  var url = Uri.https(
    endpoint = endpoint,
    path = path,
    params = params,
  );
  var request = http.Request("POST", url);

  headers.forEach((k, v) => request.headers.addAll({k: v}));
  request.body = json.encode(data);

  var response = await request.send();
  return response;
}

Map stringToMap(String event) {
  if (event.startsWith('[')) {
    return {};
  }
  if (event.startsWith(']')) {
    return {};
  }
  if (event.lastChars(1) == ',') {
    event = event.substring(0, event.length - 1);
  }
  final row = jsonDecode(event);
  return row;
}
