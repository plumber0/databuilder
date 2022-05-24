import 'package:flutter/material.dart';

import 'src/auth.dart';
import 'src/transport.dart' as tr;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String endpoint = 'api.deepnatural.ai';
const String credentialPath = '/Users/yoo/.deepnatural.ai/credentials.json';

Future getAuthToken({email, password}) async {
  final response = await tr.post(
      endpoint: endpoint,
      path: 'auth/login/',
      headers: null,
      data: {'email': email, 'password': password});
  return response;
}

Future getProject({uid}) async {
  final header = getAuthHeaders(credentialPath);
  final result =
      await tr.get(endpoint: endpoint, path: 'projects/$uid', headers: header);
  return result;
}

Future<List> getManagingProjects() async {
  final header = getAuthHeaders(credentialPath);
  final pages = [];
  Stream pageStream = tr.getPages(
      endpoint: endpoint,
      path: 'auth/user/projects/managing/',
      params: {'page_size': '100'},
      headers: header);
  await for (final page in pageStream) {
    pages.add(page);
  }
  return pages;
}

Stream exportTaskrun(String projectUid) async* {
  final header = getAuthHeaders(credentialPath);
  final data = {
    'include_context': true,
    'include_result': true,
    'public_mode': true,
    'timezone': 'Asia/Seoul',
    'date_format': '%Y-%m-%d %H:%M:%S',
    'completed_only': true,
    'accepted_only': true,
  };
  final response = await tr.postStream(
    endpoint: endpoint,
    path: 'projects/$projectUid/taskruns/exports/',
    params: {'export_format': 'JSON'},
    headers: header,
    data: data,
  );
  var downloadStream = response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map(tr.stringToMap);

  await for (final d in downloadStream) {
    yield d;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // exportTaskrun('wWKpnpRJ2Rg').forEach(print);
  final storage = FlutterSecureStorage();

  final response = await getAuthToken();

  await storage.write(key: 'key', value: response['key']);

  String? value = await storage.read(key: 'key');
  print(value);
  await storage.delete(key: 'key');

  Map<String, String> allValues = await storage.readAll();
  print(allValues);
}
