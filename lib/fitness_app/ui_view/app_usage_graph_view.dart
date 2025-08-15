import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../../models/battery_data.dart';
import '../../services/battery_service.dart';

class AppUsageGraphView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const AppUsageGraphView({
    Key? key,
    this.animationController,
    this.animation,
  }) : super(key: key);

  @override
  State<AppUsageGraphView> createState() => _AppUsageGraphViewState();
}

class _AppUsageGraphViewState extends State<AppUsageGraphView> {
  final BatteryService _batteryService = BatteryService();
  List<AppUsageData> _appUsageData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppUsageData();
  }

  Future<void> _loadAppUsageData() async {
    try {
      final data = await _batteryService.getTodayAppUsage();
      setState(() {
        _appUsageData = data.take(8).toList(); // Show top 8 apps
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading app usage data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16, left: 16, right: 24, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'App Battery Usage',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.1,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Today',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      color: FitnessAppTheme.grey
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.nearlyWhite,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.apps,
                                color: FitnessAppTheme.nearlyDarkBlue,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 16),
                      child: Container(
                        height: 200,
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : _buildAppUsageChart(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppUsageChart() {
    if (_appUsageData.isEmpty) {
      return Center(
        child: Text(
          'No app usage data available',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: FitnessAppTheme.grey,
          ),
        ),
      );
    }

    final colors = [
      FitnessAppTheme.nearlyDarkBlue,
      FitnessAppTheme.nearlyBlue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _appUsageData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final color = colors[index % colors.length];
          
          return PieChartSectionData(
            color: color,
            value: data.batteryConsumption,
            title: '${data.batteryConsumption.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
