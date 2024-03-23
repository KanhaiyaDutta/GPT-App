import 'package:flutter/material.dart';
import 'package:gpt_app/models/models_model.dart';
import 'package:gpt_app/services/api_service.dart';

class ModelsProvider with ChangeNotifier {
  String currentModel = 'gemini-pro';

  String get getcurrentModel {
    return currentModel;
  }

  void setCurrentModel(String newModel) {
    currentModel = newModel;
    notifyListeners();
  }

  String modelsList = "";

  String get getModelsList {
    return modelsList;
  }

  Future<String> getALLModels() async {
    modelsList = await ApiService.getModels();
    return modelsList;
  }
}
