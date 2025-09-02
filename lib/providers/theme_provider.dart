import 'package:flutter/cupertino.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isLightMode = true;

  bool get isLightMode => _isLightMode;

  void setLightTheme() {
    _isLightMode = true;
    notifyListeners();
  }

  void setDarkTheme() {
    _isLightMode = false;
    notifyListeners();
  }

  void toggleTheme() {
    _isLightMode = !_isLightMode;
    notifyListeners();
  }
}
