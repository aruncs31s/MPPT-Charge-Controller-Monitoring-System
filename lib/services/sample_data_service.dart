import 'dart:math';
import '../models/battery_data.dart';
import '../services/database_helper.dart';

class SampleDataService {
  static final SampleDataService _instance = SampleDataService._internal();
  factory SampleDataService() => _instance;
  SampleDataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Random _random = Random();

  Future<void> generateSampleBatteryData() async {
    final now = DateTime.now();
    
    // Generate 24 hours of sample battery data (every 30 minutes)
    for (int i = 48; i >= 0; i--) {
      final timestamp = now.subtract(Duration(minutes: i * 30));
      
      // Simulate realistic battery drain pattern
      int batteryLevel;
      if (i > 40) {
        batteryLevel = 85 + _random.nextInt(15); // 85-100%
      } else if (i > 30) {
        batteryLevel = 70 + _random.nextInt(20); // 70-90%
      } else if (i > 20) {
        batteryLevel = 50 + _random.nextInt(25); // 50-75%
      } else if (i > 10) {
        batteryLevel = 30 + _random.nextInt(25); // 30-55%
      } else {
        batteryLevel = 15 + _random.nextInt(20); // 15-35%
      }

      // Simulate charging periods
      String status = 'discharging';
      if (i > 45 || (i > 20 && i < 25)) {
        status = 'charging';
        batteryLevel = min(100, batteryLevel + 10);
      }

      final batteryData = BatteryData(
        batteryLevel: batteryLevel,
        status: status,
        temperature: 20.0 + _random.nextDouble() * 15.0, // 20-35°C
        timestamp: timestamp.toIso8601String(),
        consumptionRate: _random.nextInt(8) + 2, // 2-10% per hour
      );

      await _dbHelper.insertBatteryData(batteryData);
    }
  }

  Future<void> generateSampleAppUsageData() async {
    final apps = [
      {'name': 'Chrome', 'package': 'com.android.chrome'},
      {'name': 'Instagram', 'package': 'com.instagram.android'},
      {'name': 'WhatsApp', 'package': 'com.whatsapp'},
      {'name': 'YouTube', 'package': 'com.google.android.youtube'},
      {'name': 'Gmail', 'package': 'com.google.android.gm'},
      {'name': 'Maps', 'package': 'com.google.android.apps.maps'},
      {'name': 'Spotify', 'package': 'com.spotify.music'},
      {'name': 'Camera', 'package': 'com.android.camera'},
      {'name': 'Settings', 'package': 'com.android.settings'},
      {'name': 'Phone', 'package': 'com.android.dialer'},
    ];

    final today = DateTime.now().toIso8601String().split('T')[0];

    for (final app in apps) {
      final usageTime = _random.nextInt(120) + 10; // 10-130 minutes
      final batteryConsumption = (usageTime / 60.0) * (2 + _random.nextDouble() * 3); // 2-5% per hour

      final appUsageData = AppUsageData(
        appName: app['name']!,
        packageName: app['package']!,
        usageTime: usageTime,
        timestamp: today,
        batteryConsumption: batteryConsumption,
      );

      await _dbHelper.insertAppUsageData(appUsageData);
    }
  }

  Future<void> initializeSampleData() async {
    // Check if data already exists
    final existingBatteryData = await _dbHelper.getBatteryData(limit: 1);
    final existingAppData = await _dbHelper.getAppUsageData(limit: 1);

    if (existingBatteryData.isEmpty) {
      print('Generating sample battery data...');
      await generateSampleBatteryData();
    }

    if (existingAppData.isEmpty) {
      print('Generating sample app usage data...');
      await generateSampleAppUsageData();
    }

    print('Sample data initialization complete');
  }
}
