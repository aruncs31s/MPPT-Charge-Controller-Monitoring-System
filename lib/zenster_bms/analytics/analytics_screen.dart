import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';
import '../../services/battery_service.dart';
import '../../models/battery_data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  final BatteryService _batteryService = BatteryService();
  BatteryData? _currentData;
  List<BatteryData> _weeklyData = [];
  bool _isLoading = true;

  // Analytics data
  double _maxTemperature = 0.0;
  double _minTemperature = 0.0;
  int _maxBatteryLevel = 0;
  int _minBatteryLevel = 100;
  double _avgTemperature = 0.0;
  double _avgConsumptionRate = 0.0;
  int _totalDataPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final currentData = await _batteryService.getCurrentBatteryData();
      final weeklyHistory = await _batteryService.getBatteryHistory(days: 7);

      setState(() {
        _currentData = currentData;
        _weeklyData = weeklyHistory;
        _calculateAnalytics();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateAnalytics() {
    if (_weeklyData.isEmpty) return;

    _maxTemperature = _weeklyData
        .map((d) => d.temperature)
        .reduce((a, b) => a > b ? a : b);
    _minTemperature = _weeklyData
        .map((d) => d.temperature)
        .reduce((a, b) => a < b ? a : b);
    _maxBatteryLevel = _weeklyData
        .map((d) => d.batteryLevel)
        .reduce((a, b) => a > b ? a : b);
    _minBatteryLevel = _weeklyData
        .map((d) => d.batteryLevel)
        .reduce((a, b) => a < b ? a : b);

    // Calculate average temperature
    double totalTemp = _weeklyData.fold(0.0, (sum, d) => sum + d.temperature);
    _avgTemperature = totalTemp / _weeklyData.length;

    // Calculate average consumption rate
    double totalConsumption = _weeklyData.fold(
      0.0,
      (sum, d) => sum + d.consumptionRate,
    );
    _avgConsumptionRate = totalConsumption / _weeklyData.length;

    _totalDataPoints = _weeklyData.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZensterBMSTheme.background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ZensterBMSTheme.nearlyDarkBlue,
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: ZensterBMSTheme.nearlyDarkBlue,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Analytics',
                      style: TextStyle(
                        fontFamily: ZensterBMSTheme.fontName,
                        color: ZensterBMSTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ZensterBMSTheme.nearlyDarkBlue,
                            ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.analytics,
                          size: 80,
                          color: ZensterBMSTheme.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCurrentStats(),
                      SizedBox(height: 16),
                      _buildMaxMinSection(),
                      SizedBox(height: 16),
                      _buildEfficiencySection(),
                      SizedBox(height: 16),
                      _buildSystemHealth(),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentStats() {
    if (_currentData == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.electrical_services,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Current Status',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Battery Level',
                  '${_currentData!.batteryLevel}%',
                  Icons.battery_charging_full,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Temperature',
                  '${_currentData!.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Status',
                  _currentData!.status.toUpperCase(),
                  Icons.power,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Consumption',
                  '${_currentData!.consumptionRate}%/h',
                  Icons.battery_alert,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 12,
                  color: ZensterBMSTheme.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ZensterBMSTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxMinSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Weekly Extremes',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildMinMaxRow(
            'Temperature',
            _minTemperature,
            _maxTemperature,
            '°C',
            Colors.blue,
          ),
          SizedBox(height: 12),
          _buildMinMaxRow(
            'Battery Level',
            _minBatteryLevel.toDouble(),
            _maxBatteryLevel.toDouble(),
            '%',
            Colors.orange,
          ),
          SizedBox(height: 12),
          _buildMinMaxRow(
            'Data Points',
            0,
            _totalDataPoints.toDouble(),
            '',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxRow(
    String label,
    double min,
    double max,
    String unit,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 14,
                  color: ZensterBMSTheme.grey,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Min: ${min.toStringAsFixed(2)} $unit',
                    style: TextStyle(
                      fontFamily: ZensterBMSTheme.fontName,
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Max: ${max.toStringAsFixed(2)} $unit',
                    style: TextStyle(
                      fontFamily: ZensterBMSTheme.fontName,
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencySection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg Temperature',
                  '${_avgTemperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Avg Consumption',
                  '${_avgConsumptionRate.toStringAsFixed(1)}%/h',
                  Icons.battery_alert,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ZensterBMSTheme.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 12,
              color: ZensterBMSTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'System Health',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildHealthIndicator('Temperature', 'Normal', Colors.green),
          SizedBox(height: 12),
          _buildHealthIndicator('Voltage Stability', 'Excellent', Colors.green),
          SizedBox(height: 12),
          _buildHealthIndicator('Connection Quality', 'Good', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String metric, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          metric,
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontSize: 14,
            color: ZensterBMSTheme.darkText,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
