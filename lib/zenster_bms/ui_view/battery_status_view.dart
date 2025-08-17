import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';
import '../../services/battery_service.dart';
import '../../services/api_service.dart';
import 'dart:async';
import '../../models/battery_data.dart';
// ...existing code...

class BatteryStatusView extends StatefulWidget {
	const BatteryStatusView({super.key, this.animationController, this.animation});

	final AnimationController? animationController;
	final Animation<double>? animation;

	@override
	_BatteryStatusViewState createState() => _BatteryStatusViewState();
}

class _BatteryStatusViewState extends State<BatteryStatusView> with TickerProviderStateMixin {
	final BatteryService _batteryService = BatteryService();
	String _status = 'unknown';
	int _batteryLevel = 0 ;

	// double _batteryVoltage = 0.0;
	bool _ledRelayState = false;
	Timer? _apiTimer;
	StreamSubscription<BatteryData>? _batterySub;

	@override
	void initState() {
		super.initState();
		_loadCurrent();
		_startApiPolling();
		_batterySub = _batteryService.batteryStream?.listen((data) {
			if (!mounted) return;
			setState(() {
				_batteryLevel = data.batteryLevel;
				_status = data.status;
			});
		});
	}

	@override
	void dispose() {
		_apiTimer?.cancel();
		_batterySub?.cancel();
		super.dispose();
	}

	void _startApiPolling() {
		// Fetch data immediately
		_fetchApiData();
		
		// Then fetch every 5 seconds
		_apiTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
			_fetchApiData();
		});
	}

	Future<void> _fetchApiData() async {
		final apiData = await ApiService.fetchData();
		if (apiData != null && mounted) {
			setState(() {
				BatteryService().batteryVoltage = apiData.batteryVoltage;
				_ledRelayState = apiData.ledRelayState;
			});
		}
	}

	Future<void> _loadCurrent() async {
		final current = await _batteryService.getCurrentBatteryData();
		if (!mounted) return;
		if (current != null) {
			setState(() {
				_batteryLevel = current.batteryLevel;
				_status = current.status;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
			child: Container(
				decoration: BoxDecoration(
					color: ZensterBMSTheme.white,
					borderRadius: const BorderRadius.all(Radius.circular(8.0)),
					boxShadow: <BoxShadow>[
						BoxShadow(color: ZensterBMSTheme.nearlyBlack.withOpacity(0.1), offset: const Offset(0,2), blurRadius: 8.0),
					],
				),
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						children: [
							// First row - Battery Level and Status
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: <Widget>[
									Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: <Widget>[
											Text('Battery Level', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 14, color: ZensterBMSTheme.darkText)),
											const SizedBox(height: 8.0),
											Text('${BatteryService().batteryLevel}%', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 28, fontWeight: FontWeight.bold, color: ZensterBMSTheme.nearlyBlue)),
										],
									),
									Column(
										crossAxisAlignment: CrossAxisAlignment.end,
										children: <Widget>[
											Text('Status', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 14, color: ZensterBMSTheme.darkText)),
											const SizedBox(height: 8.0),
											Text(_status, style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 16, color: ZensterBMSTheme.darkText)),
										],
									),
								],
							),
							const SizedBox(height: 20.0),
							// Divider
							Container(
								height: 1,
								color: ZensterBMSTheme.grey.withOpacity(0.3),
							),
							const SizedBox(height: 20.0),
							// Second row - API Data from localhost:8080
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: <Widget>[
									Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: <Widget>[
											Text('Battery Voltage', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 14, color: ZensterBMSTheme.darkText)),
											const SizedBox(height: 8.0),
											Text('${BatteryService().batteryVoltage.toStringAsFixed(1)}V', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 24, fontWeight: FontWeight.bold, color: ZensterBMSTheme.nearlyDarkBlue)),
										],
									),
									Column(
										crossAxisAlignment: CrossAxisAlignment.end,
										children: <Widget>[
											Text('LED Relay', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 14, color: ZensterBMSTheme.darkText)),
											const SizedBox(height: 8.0),
											Row(
												children: [
													Container(
														width: 12,
														height: 12,
														decoration: BoxDecoration(
															color: _ledRelayState ? Colors.green : Colors.red,
															shape: BoxShape.circle,
														),
													),
													const SizedBox(width: 8),
													Text(_ledRelayState ? 'ON' : 'OFF', style: TextStyle(fontFamily: ZensterBMSTheme.fontName, fontSize: 16, fontWeight: FontWeight.w600, color: _ledRelayState ? Colors.green : Colors.red)),
												],
											),
										],
									),
								],
							),
							const SizedBox(height: 12.0),
							// Data source indicator
							Center(
								child: Text(
									'Source: ${ApiService.getDataSource()}',
									style: TextStyle(
										fontFamily: ZensterBMSTheme.fontName,
										fontSize: 12,
										color: ZensterBMSTheme.grey,
										fontStyle: FontStyle.italic,
									),
								),
							),
						],
					),
				),
			),
		);
	}
}

