import 'package:flutter_easyloading/flutter_easyloading.dart';

class ShowToastDialog {
  static showToast(String? errorMessage,
      {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    String message = extractErrorMessage(errorMessage!);
    EasyLoading.instance.userInteractions = true;

    EasyLoading.showToast(
      message,
      toastPosition: position,
    );
  }

  static showLoader(String message) {
    // EasyLoading.instance.userInteractions = false;
    EasyLoading.show(status: message);
  }

  static closeLoader() {
    EasyLoading.dismiss();
  }

  static String extractErrorMessage(String error) {
    if (error.contains(']')) {
      return error.split(']').last.trim();
    }
    return error;
  }
}
