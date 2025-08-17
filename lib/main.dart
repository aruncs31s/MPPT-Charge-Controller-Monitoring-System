import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zenster_bms/zenster_bms_home_screen.dart';
import 'app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/sample_data_service.dart';
import 'services/battery_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms (Linux, Windows, macOS)
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Platform detection for web compatibility
  final bool isWeb = identical(0, 0.0);

  // Initialize sample data (creates sample DB rows if empty)
  await SampleDataService().initializeSampleData();

  // Start background battery monitoring (writes to DB periodically)
  final batteryService = BatteryService();
  await batteryService.startMonitoring();

  // Add sample data for web platform
  if (isWeb) {
    await batteryService.addSampleDataForWeb();
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const MPPTMonitor()));
}

class MPPTMonitor extends StatelessWidget {
  const MPPTMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: !kIsWeb && Platform.isAndroid
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      title: 'Zenster MPPT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
        dividerTheme: DividerThemeData(color: Color(0xFFE0E0E0)),
      ),
      home: ZensterBMSHomeScreen(),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
