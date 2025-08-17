import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';
import '../../services/network_scanner_service.dart';
import 'network_devices_screen.dart';

class NetworkDevicesCard extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const NetworkDevicesCard({
    Key? key,
    this.animationController,
    this.animation,
  }) : super(key: key);

  @override
  _NetworkDevicesCardState createState() => _NetworkDevicesCardState();
}

class _NetworkDevicesCardState extends State<NetworkDevicesCard> {
  final NetworkScannerService _scanner = NetworkScannerService();
  List<NetworkDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _performQuickScan();
  }

  Future<void> _performQuickScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final devices = await _scanner.quickScan();
      if (mounted) {
        setState(() {
          _devices = devices;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
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
              padding: EdgeInsets.only(
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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NetworkDevicesScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.wifi_find,
                                color: ZensterBMSTheme.nearlyDarkBlue,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WiFi Devices',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: ZensterBMSTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: 0.0,
                                      color: ZensterBMSTheme.darkText,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _isScanning 
                                        ? 'Scanning network...' 
                                        : '${_devices.length} device${_devices.length != 1 ? 's' : ''} found',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: ZensterBMSTheme.fontName,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      color: _isScanning 
                                          ? ZensterBMSTheme.nearlyDarkBlue
                                          : ZensterBMSTheme.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isScanning)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ZensterBMSTheme.nearlyDarkBlue,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.arrow_forward_ios,
                                color: ZensterBMSTheme.grey,
                                size: 16,
                              ),
                          ],
                        ),
                        if (_devices.isNotEmpty && !_isScanning) ...[
                          SizedBox(height: 16),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              color: ZensterBMSTheme.grey.withOpacity(0.2),
                            ),
                          ),
                          SizedBox(height: 12),
                          ...(_devices.take(3).map((device) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: device.isOnline ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    device.ipAddress,
                                    style: TextStyle(
                                      fontFamily: ZensterBMSTheme.fontName,
                                      fontSize: 12,
                                      color: ZensterBMSTheme.darkText,
                                    ),
                                  ),
                                ),
                                if (device.responseTime != null)
                                  Text(
                                    '${device.responseTime}ms',
                                    style: TextStyle(
                                      fontFamily: ZensterBMSTheme.fontName,
                                      fontSize: 10,
                                      color: ZensterBMSTheme.grey,
                                    ),
                                  ),
                              ],
                            ),
                          )).toList()),
                          if (_devices.length > 3)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'and ${_devices.length - 3} more...',
                                style: TextStyle(
                                  fontFamily: ZensterBMSTheme.fontName,
                                  fontSize: 10,
                                  color: ZensterBMSTheme.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
