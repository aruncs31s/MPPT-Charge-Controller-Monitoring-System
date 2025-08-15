class BatteryData {
  final int? id;
  final int batteryLevel;
  final String status; // charging, discharging, full, unknown
  final double temperature;
  final String timestamp;
  final int consumptionRate; // estimated rate (percentage per hour)

  BatteryData({
    this.id,
    required this.batteryLevel,
    required this.status,
    required this.temperature,
    required this.timestamp,
    required this.consumptionRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'battery_level': batteryLevel,
      'status': status,
      'temperature': temperature,
      'timestamp': timestamp,
      'consumption_rate': consumptionRate,
    };
  }

  factory BatteryData.fromMap(Map<String, dynamic> map) {
    return BatteryData(
      id: map['id'] as int?,
      batteryLevel: map['battery_level'] as int,
      status: map['status'] as String,
      temperature: (map['temperature'] as num).toDouble(),
      timestamp: map['timestamp'] as String,
      consumptionRate: map['consumption_rate'] as int,
    );
  }
}

class AppUsageData {
  final int? id;
  final String appName;
  final String packageName;
  final int usageTime; // in minutes
  final String timestamp;
  final double batteryConsumption; // estimated battery consumption percentage

  AppUsageData({
    this.id,
    required this.appName,
    required this.packageName,
    required this.usageTime,
    required this.timestamp,
    required this.batteryConsumption,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_name': appName,
      'package_name': packageName,
      'usage_time': usageTime,
      'timestamp': timestamp,
      'battery_consumption': batteryConsumption,
    };
  }

  factory AppUsageData.fromMap(Map<String, dynamic> map) {
    return AppUsageData(
      id: map['id'] as int?,
      appName: map['app_name'] as String,
      packageName: map['package_name'] as String,
      usageTime: map['usage_time'] as int,
      timestamp: map['timestamp'] as String,
      batteryConsumption: (map['battery_consumption'] as num).toDouble(),
    );
  }
}

