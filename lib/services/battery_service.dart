import 'dart:async';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import '../models/battery_data.dart';
import '../services/database_helper.dart';
// Backwards-compatible top-level wrappers that forward to the service instance.
int lifepo4SocCell(double vCell) => BatteryService().lifepo4SocCell(vCell);

int lifepo4SocPack(double vPack, {int cellsInSeries = 4}) =>
  BatteryService().lifepo4SocPack(vPack, cellsInSeries: cellsInSeries);


class BatteryService {
  static final BatteryService _instance = BatteryService._internal();
  factory BatteryService() => _instance;
  BatteryService._internal();
  double _batteryVoltage = 12.8;
  double get batteryVoltage => _batteryVoltage;
   set batteryVoltage(double v) {
    _batteryVoltage = v;
    // optionally push update to stream so UI can listen:
    // _batteryStreamController?.add(/* create BatteryData or a simple wrapper */);
  }
  
  // Computed battery level from voltage
  int get batteryLevel => lifepo4SocPack(_batteryVoltage);
  
  // lifepo4SocPack(BatteryService().batteryVoltage)
  final Battery _battery = Battery();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Timer? _monitoringTimer;
  
  StreamController<BatteryData>? _batteryStreamController;
  Stream<BatteryData>? get batteryStream => _batteryStreamController?.stream;

  Future<void> startMonitoring() async {
    _batteryStreamController = StreamController<BatteryData>.broadcast();
    
    // Monitor battery every 30 seconds
    _monitoringTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      await _recordBatteryData();
    });

    // Record initial data
    await _recordBatteryData();
  }

  Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    await _batteryStreamController?.close();
    _batteryStreamController = null;
  }

  // Platform detection for web compatibility
  bool get isWeb => identical(0, 0.0);

  Future<void> _recordBatteryData() async {
    try {
      int batteryLevel;
      BatteryState batteryState;
      
      if (isWeb) {
        // Web: Simulate battery data since battery_plus doesn't work on web
        // batteryLevel = 75 + Random().nextInt(25); // Random 75-100%

        batteryLevel = lifepo4SocPack(BatteryService()._batteryVoltage);
        print(BatteryService()._batteryVoltage);
        print(batteryLevel);
        batteryState = BatteryState.unknown;
      } else {
        // Mobile: Use real battery data
        batteryLevel = await _battery.batteryLevel;
        batteryState = await _battery.batteryState;
      }
      
      // Simulate temperature (in real app, you'd get this from device sensors)
      final temperature = 20.0 + Random().nextDouble() * 15.0; // 20-35°C
      
      // Calculate consumption rate based on battery level change
      final consumptionRate = await _calculateConsumptionRate(batteryLevel);

      final batteryData = BatteryData(
        batteryLevel: batteryLevel,
        status: _batteryStateToString(batteryState),
        temperature: temperature,
        timestamp: DateTime.now().toIso8601String(),
        consumptionRate: consumptionRate,
      );

      await _dbHelper.insertBatteryData(batteryData);
      _batteryStreamController?.add(batteryData);
    } catch (e) {
      print('Error recording battery data: $e');
    }
  }

  Future<int> _calculateConsumptionRate(int currentLevel) async {
    final recentData = await _dbHelper.getBatteryData(limit: 2);
    
    if (recentData.length < 2) {
      return 0; // Not enough data to calculate rate
    }

    final previous = recentData[1];
    final timeDiff = DateTime.parse(recentData[0].timestamp)
        .difference(DateTime.parse(previous.timestamp))
        .inMinutes;

    if (timeDiff == 0) return 0;

    final levelDiff = previous.batteryLevel - currentLevel;
    final ratePerHour = (levelDiff * 60) ~/ timeDiff;
    
    return ratePerHour.abs();
  }

  String _batteryStateToString(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'charging';
      case BatteryState.discharging:
        return 'discharging';
      case BatteryState.full:
        return 'full';
      default:
        return 'unknown';
    }
  }

  // Convert single-cell LiFePO4 voltage to approximate SoC percentage.
  // Returns an integer percent (0-100).
  int lifepo4SocCell(double vCell) {
    // Voltage vs SoC map (approx, for one LiFePO4 cell at rest)
    final List<List<double>> points = [
      [2.50, 0],
      [2.90, 10],
      [3.10, 20],
      [3.20, 50],
      [3.30, 90],
      [3.40, 95],
      [3.45, 99],
      [3.65, 100],
    ];

    if (vCell <= points[0][0]) return 0;
    if (vCell >= points.last[0]) return 100;

    // Linear interpolation between points
    for (int i = 1; i < points.length; i++) {
      double v0 = points[i - 1][0];
      double s0 = points[i - 1][1];
      double v1 = points[i][0];
      double s1 = points[i][1];

      if (vCell >= v0 && vCell <= v1) {
        double soc = s0 + (s1 - s0) * (vCell - v0) / (v1 - v0);
        return soc.round(); // return as integer percentage
      }
    }

    return 0; // fallback
  }

  // Convert pack voltage to approximate SoC percentage given cells in series.
  int lifepo4SocPack(double vPack, {int cellsInSeries = 4}) {
    double vCell = vPack / cellsInSeries;
    // int vCell = vPack / cellsInSeries;
    return lifepo4SocCell(vCell);
  }

  Future<BatteryData?> getCurrentBatteryData() async {
    final data = await _dbHelper.getBatteryData(limit: 1);
    return data.isNotEmpty ? data.first : null;
  }

  Future<List<BatteryData>> getBatteryHistory({int days = 7}) async {
    final endDate = DateTime.now().toIso8601String();
    final startDate = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String();
    
    return await _dbHelper.getBatteryDataByDateRange(startDate, endDate);
  }

  Future<void> recordAppUsage(String appName, String packageName, 
      int usageTimeMinutes, double batteryConsumption) async {
    final appUsageData = AppUsageData(
      appName: appName,
      packageName: packageName,
      usageTime: usageTimeMinutes,
      timestamp: DateTime.now().toIso8601String(),
      batteryConsumption: batteryConsumption,
    );

    await _dbHelper.insertAppUsageData(appUsageData);
  }

  Future<List<AppUsageData>> getTodayAppUsage() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final tomorrow = DateTime.now()
        .add(Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    return await _dbHelper.getAppUsageDataByDateRange(today, tomorrow);
  }

  Future<double> getTotalBatteryConsumptionToday() async {
    return await _dbHelper.getTotalBatteryConsumptionToday();
  }

  // Add sample data for web testing
  Future<void> addSampleDataForWeb() async {
    if (!isWeb) return; // Only for web platform
    
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    
    // Add sample battery data for the last 24 hours
    // for (int i = 0; i < 48; i++) {
    //   final time = now.subtract(Duration(minutes: i * 30));
    //   final batteryData = BatteryData(
    //     batteryLevel: 100 - (i * 2) + Random().nextInt(5),
    //     status: i < 10 ? 'charging' : 'discharging',
    //     temperature: 25.0 + Random().nextDouble() * 10.0,
    //     timestamp: time.toIso8601String(),
    //     consumptionRate: 2 + Random().nextInt(8),
    //   );
      // await _dbHelper.insertBatteryData(batteryData);
    // }
    
    // Add sample app usage data
    final sampleApps = [
      {'name': 'Chrome', 'package': 'com.android.chrome', 'usage': 120, 'consumption': 15.5},
      {'name': 'Instagram', 'package': 'com.instagram.android', 'usage': 45, 'consumption': 8.2},
      {'name': 'YouTube', 'package': 'com.google.android.youtube', 'usage': 90, 'consumption': 12.3},
      {'name': 'WhatsApp', 'package': 'com.whatsapp', 'usage': 30, 'consumption': 3.1},
      {'name': 'Settings', 'package': 'com.android.settings', 'usage': 15, 'consumption': 1.2},
    ];
    
    for (final app in sampleApps) {
      final appUsageData = AppUsageData(
        appName: app['name'] as String,
        packageName: app['package'] as String,
        usageTime: app['usage'] as int,
        timestamp: today,
        batteryConsumption: app['consumption'] as double,
      );
      await _dbHelper.insertAppUsageData(appUsageData);
    }
  }
Future<void> addDataForWeb() async {
    if (!isWeb) return; // Only for web platform
    
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    
    // Add sample battery data for the last 24 hours
    for (int i = 0; i < 48; i++) {
      final time = now.subtract(Duration(minutes: i * 30));
      final batteryData = BatteryData(
        batteryLevel: 100 - (i * 2) + Random().nextInt(5),
        status: i < 10 ? 'charging' : 'discharging',
        temperature: 25.0 + Random().nextDouble() * 10.0,
        timestamp: time.toIso8601String(),
        consumptionRate: 2 + Random().nextInt(8),
      );
      await _dbHelper.insertBatteryData(batteryData);
    }
    
    // Add sample app usage data
    final sampleApps = [
      {'name': 'Chrome', 'package': 'com.android.chrome', 'usage': 120, 'consumption': 15.5},
      {'name': 'Instagram', 'package': 'com.instagram.android', 'usage': 45, 'consumption': 8.2},
      {'name': 'YouTube', 'package': 'com.google.android.youtube', 'usage': 90, 'consumption': 12.3},
      {'name': 'WhatsApp', 'package': 'com.whatsapp', 'usage': 30, 'consumption': 3.1},
      {'name': 'Settings', 'package': 'com.android.settings', 'usage': 15, 'consumption': 1.2},
    ];
    
    for (final app in sampleApps) {
      final appUsageData = AppUsageData(
        appName: app['name'] as String,
        packageName: app['package'] as String,
        usageTime: app['usage'] as int,
        timestamp: today,
        batteryConsumption: app['consumption'] as double,
      );
      await _dbHelper.insertAppUsageData(appUsageData);
    }
  }
}
