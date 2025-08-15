import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../../services/battery_service.dart';

class BatteryStatusView extends StatefulWidget {
	const BatteryStatusView({super.key, this.animationController, this.animation});

	final AnimationController? animationController;
	final Animation<double>? animation;

	@override
	_BatteryStatusViewState createState() => _BatteryStatusViewState();
}

class _BatteryStatusViewState extends State<BatteryStatusView> with TickerProviderStateMixin {
	final BatteryService _batteryService = BatteryService();
	int _batteryLevel = 0;
	String _status = 'unknown';

	@override
	void initState() {
		super.initState();
		_loadCurrent();
		_batteryService.batteryStream?.listen((data) {
			setState(() {
				_batteryLevel = data.batteryLevel;
				_status = data.status;
			});
		});
	}

	Future<void> _loadCurrent() async {
		final current = await _batteryService.getCurrentBatteryData();
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
					color: FitnessAppTheme.white,
					borderRadius: const BorderRadius.all(Radius.circular(8.0)),
					boxShadow: <BoxShadow>[
						BoxShadow(color: FitnessAppTheme.nearlyBlack.withOpacity(0.1), offset: const Offset(0,2), blurRadius: 8.0),
					],
				),
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									Text('Battery Level', style: TextStyle(fontFamily: FitnessAppTheme.fontName, fontSize: 14, color: FitnessAppTheme.darkText)),
									const SizedBox(height: 8.0),
									Text('$_batteryLevel%', style: TextStyle(fontFamily: FitnessAppTheme.fontName, fontSize: 28, fontWeight: FontWeight.bold, color: FitnessAppTheme.nearlyBlue)),
								],
							),
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: <Widget>[
									Text('Status', style: TextStyle(fontFamily: FitnessAppTheme.fontName, fontSize: 14, color: FitnessAppTheme.darkText)),
									const SizedBox(height: 8.0),
									Text(_status, style: TextStyle(fontFamily: FitnessAppTheme.fontName, fontSize: 16, color: FitnessAppTheme.darkText)),
								],
							),
						],
					),
				),
			),
		);
	}
}

