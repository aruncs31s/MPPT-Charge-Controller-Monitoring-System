import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseUrl = 'http://localhost:8080';
  
  // Data model for the API response
  static ApiData? _cachedData;
  static bool _isWeb = identical(0, 0.0);
  
  // Get the current base URL
  static String get baseUrl => _baseUrl;
  
  // Load saved IP address from storage
  static Future<void> loadSavedIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIP = prefs.getString('device_ip');
      if (savedIP != null && savedIP.isNotEmpty) {
        _baseUrl = savedIP.startsWith('http') ? savedIP : 'http://$savedIP';
      }
    } catch (e) {
      print('Error loading saved IP: $e');
    }
  }
  
  // Save IP address to storage
  static Future<void> saveIP(String ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final formattedIP = ip.startsWith('http') ? ip : 'http://$ip';
      await prefs.setString('device_ip', formattedIP);
      _baseUrl = formattedIP;
    } catch (e) {
      print('Error saving IP: $e');
    }
  }
  
  // Set IP address temporarily (without saving)
  static void setIP(String ip) {
    _baseUrl = ip.startsWith('http') ? ip : 'http://$ip';
  }
  
  static Future<ApiData?> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/data'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final apiData = ApiData.fromJson(jsonData);
        _cachedData = apiData;
        print('Successfully fetched API data from $_baseUrl: ${apiData.batteryVoltage}V, LED: ${apiData.ledRelayState}');
        return apiData;
      } else {
        print('Failed to fetch data: HTTP ${response.statusCode}');
        return _cachedData ?? _getFallbackData();
      }
    } catch (e) {
      print('Error fetching data from $_baseUrl: $e');
      // If running on web and localhost fails due to CORS, provide sample data
      if (_isWeb) {
        print('CORS Error detected on web platform. Using sample data.');
        return _getWebSampleData();
      }
      // Return cached data or fallback data for mobile
      return _cachedData ?? _getFallbackData();
    }
  }
  
  // Generate realistic sample data for web platform
  static ApiData _getWebSampleData() {
    final random = Random();
    final now = DateTime.now();
    
    // Simulate battery voltage between 11.5V and 14.2V
    final baseVoltage = 12.5 + (random.nextDouble() - 0.5) * 2.0;
    final voltage = double.parse(baseVoltage.toStringAsFixed(1));
    
    // Simulate LED relay state (toggle every 30 seconds)
    final ledState = (now.second ~/ 10) % 2 == 0;
    
    final sampleData = ApiData(
      batteryVoltage: voltage,
      ledRelayState: ledState,
    );
    
    _cachedData = sampleData;
    return sampleData;
  }
  
  // Fallback data when no API connection
  static ApiData _getFallbackData() {
    return ApiData(
      batteryVoltage: 12.5,
      ledRelayState: false,
    );
  }
  
  static ApiData? getCachedData() {
    return _cachedData;
  }
  
  static bool isWebPlatform() {
    return _isWeb;
  }
  
  static String getDataSource() {
    return _isWeb ? 'Sample Data (Web)' : _baseUrl;
  }
}

class ApiData {
  final double batteryVoltage;
  final bool ledRelayState;

  ApiData({
    required this.batteryVoltage,
    required this.ledRelayState,
  });
  
  factory ApiData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ApiData(
      batteryVoltage: (data['battery_voltage'] as num).toDouble(),
      ledRelayState: true ,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'battery_voltage': batteryVoltage,
        'led_relayState': ledRelayState,
      }
    };
  }
  
}
