import 'package:flutter/material.dart';
import 'package:gpt_app/models/models_model.dart';
import 'package:gpt_app/services/api_service.dart';

class ModelsProvider with ChangeNotifier {
  String currentModel = 'text-babbage-001';

  String get getcurrentModel {
    return currentModel;
  }

  void setCurrentModel(String newModel) {
    currentModel = newModel;
    notifyListeners();
  }

  List<ModelsModel> modelsList = [];

  List<ModelsModel> get getModelsList {
    return modelsList;
  }

  Future<List<ModelsModel>> getALLModels() async {
    modelsList = await ApiService.getModels();
    return modelsList;
  }
}
