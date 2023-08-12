import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gpt_app/constants/constants.dart';
import 'package:gpt_app/providers/chat_provider.dart';
import 'package:gpt_app/providers/models_provider.dart';
import 'package:gpt_app/services/services.dart';
import 'package:gpt_app/widgets/chat_widget.dart';
import 'package:gpt_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../services/assets_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late final TextEditingController _controller;
  late ScrollController _listScrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    _controller = TextEditingController();
    _listScrollController = ScrollController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _listScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  //List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiLogo),
        ),
        title: const Text(
          'ChatGPT',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white,
          )
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Flexible(
            child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatProvider.getChatList[index].msg,
                    chatIndex: chatProvider.getChatList[index].chatIndex,
                  );
                }),
          ),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),
          ],
          const SizedBox(
            height: 15,
          ),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      controller: _controller,
                      onSubmitted: (value) async {
                        await sendMessageFCT(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider,
                        );
                      },
                      decoration: const InputDecoration.collapsed(
                        hintText: 'How can i help you',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider,
                        );
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              TextWidget(label: "You can't send multiple messages at a time"),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(label: "Please write a message"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final msg = _controller.text;
      setState(() {
        _isTyping = true;
        chatProvider.addUserMessage(msg: _controller.text);
        _controller.clear();
        _focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswer(
        msg: msg,
        chosenModelId: modelsProvider.getcurrentModel,
      );
      setState(() {});
    } catch (e) {
      log('error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(label: e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }
}
