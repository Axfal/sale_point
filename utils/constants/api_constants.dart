import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = 'https://pos.bonope.com.au/App_APIs';

  // Add other API-related constants here
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
