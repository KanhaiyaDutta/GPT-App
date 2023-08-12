import 'package:flutter/material.dart';
import 'package:gpt_app/providers/chat_provider.dart';
import 'package:gpt_app/providers/models_provider.dart';
import 'package:provider/provider.dart';
import 'package:gpt_app/constants/constants.dart';
import 'package:gpt_app/screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModelsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: scaffoldBackgroundColor,
          appBarTheme: AppBarTheme(color: cardColor),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}


