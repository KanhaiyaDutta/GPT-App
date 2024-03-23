import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:gpt_app/models/chat_model.dart';
import 'package:gpt_app/models/models_model.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiService {
  static Future<String> getModels() async {
    try {
      String temp = "gemini-pro";

      //print('jsonResponse $jsonResponse');
      return temp;
    } catch (e) {
      log('error: $e');
      rethrow;
    }
  }

  // send message
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      var response = await http.post(
          Uri.parse(
              "$BASE_URL/v1beta/models/gemini-pro:generateContent?key=$API_KEY"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
            {
              "contents": [
                {
                  "parts": [
                    {"text": message}
                  ]
                }
              ]
            },
          ));

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print('jsonResponse[\'error\'] ${jsonResponse['error']["message"]}');
        throw HttpException(jsonResponse['error']["message"]);
      }
      if (jsonResponse['promptFeedback']['blockReason'] != null) {
        // print('jsonResponse[\'error\'] ${jsonResponse['error']["message"]}');
        var blockReason = "";
        for (int i = 0;
            i < jsonResponse['promptFeedback']['safetyRatings'].length;
            i++) {
          if (jsonResponse['promptFeedback']['safetyRatings'][i]
                  ['probability'] ==
              'HIGH') {
            blockReason =
                jsonResponse['promptFeedback']['safetyRatings'][i]['category'];
          }
        }
        throw HttpException("Prompt blocked\n Reason: $blockReason");
      }

      List<ChatModel> chatList = [];
      if (jsonResponse["candidates"].length > 0) {
        //log("jsonResponse[choices]Text ${jsonResponse["candidates"][index]["content"]["parts"][0]["text"]}");
        chatList = List.generate(
            jsonResponse["candidates"].length,
            (index) => ChatModel(
                  msg: jsonResponse["candidates"][index]["content"]["parts"][0]
                      ["text"],
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
