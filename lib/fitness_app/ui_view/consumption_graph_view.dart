import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';
import '../../models/battery_data.dart';
import '../../services/battery_service.dart';

class ConsumptionGraphView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const ConsumptionGraphView({
    Key? key,
    this.animationController,
    this.animation,
  }) : super(key: key);

  @override
  State<ConsumptionGraphView> createState() => _ConsumptionGraphViewState();
}

class _ConsumptionGraphViewState extends State<ConsumptionGraphView> {
  final BatteryService _batteryService = BatteryService();
  List<BatteryData> _batteryHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatteryHistory();
  }

  Future<void> _loadBatteryHistory() async {
    try {
      final history = await _batteryService.getBatteryHistory(days: 1);
      setState(() {
        _batteryHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading battery history: $e');
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
                  color: ZensterBMSTheme.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: ZensterBMSTheme.grey.withOpacity(0.2),
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
                                  'Battery Consumption',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: ZensterBMSTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.1,
                                    color: ZensterBMSTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Last 24 hours',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: ZensterBMSTheme.fontName,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      color: ZensterBMSTheme.grey
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ZensterBMSTheme.nearlyWhite,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.battery_charging_full,
                                color: ZensterBMSTheme.nearlyDarkBlue,
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
                        height: 220,
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : _buildBatteryChart(),
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

  Widget _buildBatteryChart() {
    if (_batteryHistory.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: ZensterBMSTheme.grey,
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: ZensterBMSTheme.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: ZensterBMSTheme.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 4,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < _batteryHistory.length) {
                  final data = _batteryHistory[value.toInt()];
                  final time = DateTime.parse(data.timestamp);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: ZensterBMSTheme.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: ZensterBMSTheme.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: (_batteryHistory.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: _batteryHistory.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.batteryLevel.toDouble(),
              );
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                ZensterBMSTheme.nearlyDarkBlue,
                ZensterBMSTheme.nearlyBlue,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1),
                  ZensterBMSTheme.nearlyBlue.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final data = _batteryHistory[barSpot.x.toInt()];
                final time = DateTime.parse(data.timestamp);
                return LineTooltipItem(
                  '${data.batteryLevel}%\n${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
