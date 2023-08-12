import 'package:flutter/material.dart';
import 'package:gpt_app/models/chat_model.dart';

import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];

  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(
      msg: msg,
      chatIndex: 0,
    ));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswer(
      {required String msg, required String chosenModelId}) async {
    chatList.addAll(await ApiService.sendMessage(
      message: msg,
      modelId: chosenModelId,
    ));
    notifyListeners();
  }
}
