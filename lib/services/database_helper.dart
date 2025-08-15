import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/battery_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  // In-memory storage for web platform
  static List<BatteryData> _webBatteryData = [];
  static List<AppUsageData> _webAppUsageData = [];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  bool get isWeb => identical(0, 0.0); // Simple web detection

  Future<Database> _initDatabase() async {
    if (isWeb) {
      // For web, we'll use in-memory storage
      throw UnsupportedError('SQLite not supported on web - using in-memory storage');
    }
    
    String path = join(await getDatabasesPath(), 'battery_monitor.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE battery_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        battery_level INTEGER NOT NULL,
        status TEXT NOT NULL,
        temperature REAL NOT NULL,
        timestamp TEXT NOT NULL,
        consumption_rate INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_usage_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_name TEXT NOT NULL,
        package_name TEXT NOT NULL,
        usage_time INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        battery_consumption REAL NOT NULL
      )
    ''');
  }

  // Battery Data Operations
  Future<int> insertBatteryData(BatteryData batteryData) async {
    if (isWeb) {
      // Web: Use in-memory storage
      final newData = BatteryData(
        id: _webBatteryData.length + 1,
        batteryLevel: batteryData.batteryLevel,
        status: batteryData.status,
        temperature: batteryData.temperature,
        timestamp: batteryData.timestamp,
        consumptionRate: batteryData.consumptionRate,
      );
      _webBatteryData.add(newData);
      return newData.id!;
    }
    
    final db = await database;
    return await db.insert('battery_data', batteryData.toMap());
  }

  Future<List<BatteryData>> getBatteryData({int? limit}) async {
    if (isWeb) {
      // Web: Return from in-memory storage
      final sortedData = List<BatteryData>.from(_webBatteryData)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (limit != null && limit < sortedData.length) {
        return sortedData.take(limit).toList();
      }
      return sortedData;
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'battery_data',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return BatteryData.fromMap(maps[i]);
    });
  }

  Future<List<BatteryData>> getBatteryDataByDateRange(
      String startDate, String endDate) async {
    if (isWeb) {
      // Web: Filter in-memory data by date range
      return _webBatteryData.where((data) {
        return data.timestamp.compareTo(startDate) >= 0 && 
               data.timestamp.compareTo(endDate) <= 0;
      }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'battery_data',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) {
      return BatteryData.fromMap(maps[i]);
    });
  }

  // App Usage Data Operations
  Future<int> insertAppUsageData(AppUsageData appUsageData) async {
    if (isWeb) {
      // Web: Use in-memory storage
      final newData = AppUsageData(
        id: _webAppUsageData.length + 1,
        appName: appUsageData.appName,
        packageName: appUsageData.packageName,
        usageTime: appUsageData.usageTime,
        timestamp: appUsageData.timestamp,
        batteryConsumption: appUsageData.batteryConsumption,
      );
      _webAppUsageData.add(newData);
      return newData.id!;
    }
    
    final db = await database;
    return await db.insert('app_usage_data', appUsageData.toMap());
  }

  Future<List<AppUsageData>> getAppUsageData({int? limit}) async {
    if (isWeb) {
      // Web: Return from in-memory storage
      final sortedData = List<AppUsageData>.from(_webAppUsageData)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (limit != null && limit < sortedData.length) {
        return sortedData.take(limit).toList();
      }
      return sortedData;
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_usage_data',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return AppUsageData.fromMap(maps[i]);
    });
  }

  Future<List<AppUsageData>> getAppUsageDataByDateRange(
      String startDate, String endDate) async {
    if (isWeb) {
      // Web: Filter in-memory data by date range
      return _webAppUsageData.where((data) {
        return data.timestamp.compareTo(startDate) >= 0 && 
               data.timestamp.compareTo(endDate) <= 0;
      }).toList()..sort((a, b) => b.batteryConsumption.compareTo(a.batteryConsumption));
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_usage_data',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'battery_consumption DESC',
    );
    return List.generate(maps.length, (i) {
      return AppUsageData.fromMap(maps[i]);
    });
  }

  Future<double> getTotalBatteryConsumptionToday() async {
    if (isWeb) {
      // Web: Calculate from in-memory data
      final today = DateTime.now().toIso8601String().split('T')[0];
      final tomorrow = DateTime.now()
          .add(Duration(days: 1))
          .toIso8601String()
          .split('T')[0];
      
      final todayData = _webAppUsageData.where((data) {
        return data.timestamp.compareTo(today) >= 0 && 
               data.timestamp.compareTo(tomorrow) < 0;
      });
      
      double total = 0.0;
      for (final data in todayData) {
        total += data.batteryConsumption;
      }
      return total;
    }
    
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final tomorrow = DateTime.now()
        .add(Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(battery_consumption) as total
      FROM app_usage_data
      WHERE timestamp >= ? AND timestamp < ?
    ''', [today, tomorrow]);

    return result.first['total']?.toDouble() ?? 0.0;
  }

  Future<void> deleteBatteryData(int id) async {
    if (isWeb) {
      // Web: Remove from in-memory storage
      _webBatteryData.removeWhere((data) => data.id == id);
      return;
    }
    
    final db = await database;
    await db.delete(
      'battery_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAppUsageData(int id) async {
    if (isWeb) {
      // Web: Remove from in-memory storage
      _webAppUsageData.removeWhere((data) => data.id == id);
      return;
    }
    
    final db = await database;
    await db.delete(
      'app_usage_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearOldData({int daysToKeep = 30}) async {
    if (isWeb) {
      // Web: Remove old data from in-memory storage
      final cutoffDate = DateTime.now()
          .subtract(Duration(days: daysToKeep))
          .toIso8601String();
      
      _webBatteryData.removeWhere((data) => data.timestamp.compareTo(cutoffDate) < 0);
      _webAppUsageData.removeWhere((data) => data.timestamp.compareTo(cutoffDate) < 0);
      return;
    }
    
    final db = await database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .toIso8601String();

    await db.delete(
      'battery_data',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );

    await db.delete(
      'app_usage_data',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );
  }
}
