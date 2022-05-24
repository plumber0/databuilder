import 'dart:io' as io;
import 'dart:convert';

Map getAuthHeaders(String credentialPath) {
  final file = io.File(credentialPath);
  final string = file.readAsStringSync();
  final data = json.decode(string);
  final headers = {
    'Authorization': 'Token ${data['default']['key']}',
    'Accept-Language': 'ko-KR',
    'databuilder': 'true',
    'content-type': 'application/json; charset=utf-8',
  };
  return headers;
}
