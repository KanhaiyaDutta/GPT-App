import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:gpt_app/models/chat_model.dart';
import 'package:gpt_app/models/models_model.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse("$BASE_URL/models"),
          headers: {'Authorization': 'Bearer $API_KEY'});

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print('jsonResponse[\'error\'] ${jsonResponse['error']["message"]}');
        throw HttpException(jsonResponse['error']["message"]);
      }

      List temp = [];
      for (var value in jsonResponse['data']) {
        temp.add(value);
        //log("temp ${value['id']}");
      }
      //print('jsonResponse $jsonResponse');
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (e) {
      log('error: $e');
      rethrow;
    }
  }

  // send message
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      var response = await http.post(Uri.parse("$BASE_URL/chat/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode(
            {
              "model": modelId,
              "messages": [{"role": "user", "content": message}],
              "max_tokens": 50,
            },
          ));

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print('jsonResponse[\'error\'] ${jsonResponse['error']["message"]}');
        throw HttpException(jsonResponse['error']["message"]);
      }

      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        //log("jsonResponse[choices]Text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
            jsonResponse["choices"].length,
            (index) => ChatModel(
                  msg: jsonResponse["choices"][index]["message"]["content"],
                  chatIndex: 1,
                ));
      }
      return chatList;
    } catch (e) {
      log('error: $e');
      rethrow;
    }
  }
}
