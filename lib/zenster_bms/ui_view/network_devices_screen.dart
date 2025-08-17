import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';
import '../../services/network_scanner_service.dart';

class NetworkDevicesScreen extends StatefulWidget {
  const NetworkDevicesScreen({Key? key}) : super(key: key);

  @override
  _NetworkDevicesScreenState createState() => _NetworkDevicesScreenState();
}

class _NetworkDevicesScreenState extends State<NetworkDevicesScreen>
    with TickerProviderStateMixin {
  List<NetworkDevice> _devices = [];
  bool _isScanning = false;
  String _scanProgress = '';
  final NetworkScannerService _scanner = NetworkScannerService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Start with a quick scan
    _performQuickScan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performQuickScan() async {
    setState(() {
      _isScanning = true;
      _scanProgress = 'Performing quick scan...';
    });

    try {
      final devices = await _scanner.quickScan();
      setState(() {
        _devices = devices;
        _isScanning = false;
        _scanProgress = '';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanProgress = 'Scan failed: $e';
      });
    }
  }

  Future<void> _performFullScan() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    _animationController.repeat();

    try {
      final devices = await _scanner.scanNetwork(
        onProgress: (progress) {
          setState(() {
            _scanProgress = progress;
          });
        },
      );
      
      setState(() {
        _devices = devices;
        _isScanning = false;
        _scanProgress = '';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanProgress = 'Scan failed: $e';
      });
    } finally {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZensterBMSTheme.background,
      appBar: AppBar(
        title: Text(
          'Network Devices',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: ZensterBMSTheme.darkText,
          ),
        ),
        backgroundColor: ZensterBMSTheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: ZensterBMSTheme.darkText),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isScanning ? null : _performQuickScan,
          ),
          IconButton(
            icon: Icon(Icons.network_check),
            onPressed: _isScanning ? null : _performFullScan,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScanning) _buildScanningIndicator(),
          if (_devices.isNotEmpty) _buildDeviceCount(),
          Expanded(
            child: _devices.isEmpty && !_isScanning
                ? _buildEmptyState()
                : _buildDeviceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _animationController,
                child: Icon(
                  Icons.wifi_find,
                  color: ZensterBMSTheme.nearlyDarkBlue,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Scanning Network...',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          if (_scanProgress.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                _scanProgress,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 14,
                  color: ZensterBMSTheme.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceCount() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            color: ZensterBMSTheme.nearlyDarkBlue,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            '${_devices.length} device${_devices.length != 1 ? 's' : ''} found',
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: ZensterBMSTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color: ZensterBMSTheme.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Devices Found',
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: ZensterBMSTheme.darkText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the refresh button to scan for devices',
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 16,
              color: ZensterBMSTheme.grey,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _performQuickScan,
                icon: Icon(Icons.refresh),
                label: Text('Quick Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZensterBMSTheme.nearlyDarkBlue,
                  foregroundColor: ZensterBMSTheme.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _performFullScan,
                icon: Icon(Icons.network_check),
                label: Text('Full Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZensterBMSTheme.nearlyDarkBlue,
                  foregroundColor: ZensterBMSTheme.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return _buildDeviceCard(device, index);
      },
    );
  }

  Widget _buildDeviceCard(NetworkDevice device, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: device.isOnline 
                ? ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1)
                : ZensterBMSTheme.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getDeviceIcon(device.ipAddress),
            color: device.isOnline 
                ? ZensterBMSTheme.nearlyDarkBlue
                : ZensterBMSTheme.grey,
            size: 24,
          ),
        ),
        title: Text(
          device.ipAddress,
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ZensterBMSTheme.darkText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device.hostname != null && device.hostname!.isNotEmpty)
              Text(
                device.hostname!,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 14,
                  color: ZensterBMSTheme.grey,
                ),
              ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: device.isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  device.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontFamily: ZensterBMSTheme.fontName,
                    fontSize: 12,
                    color: device.isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (device.responseTime != null) ...[
                  SizedBox(width: 12),
                  Text(
                    '${device.responseTime}ms',
                    style: TextStyle(
                      fontFamily: ZensterBMSTheme.fontName,
                      fontSize: 12,
                      color: ZensterBMSTheme.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, color: ZensterBMSTheme.grey),
          onPressed: () => _showDeviceInfo(device),
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String ipAddress) {
    if (ipAddress.endsWith('.1') || ipAddress.endsWith('.254')) {
      return Icons.router;
    } else if (ipAddress.contains('.100') || ipAddress.contains('.101')) {
      return Icons.solar_power; // MPPT controller
    } else if (ipAddress.contains('.150')) {
      return Icons.battery_charging_full; // Battery monitor
    } else {
      return Icons.device_unknown;
    }
  }

  void _showDeviceInfo(NetworkDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Device Information',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('IP Address', device.ipAddress),
            if (device.hostname != null && device.hostname!.isNotEmpty)
              _buildInfoRow('Hostname', device.hostname!),
            _buildInfoRow('Status', device.isOnline ? 'Online' : 'Offline'),
            if (device.responseTime != null)
              _buildInfoRow('Response Time', '${device.responseTime}ms'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: ZensterBMSTheme.nearlyDarkBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontFamily: ZensterBMSTheme.fontName,
                fontWeight: FontWeight.w500,
                color: ZensterBMSTheme.darkText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: ZensterBMSTheme.fontName,
                color: ZensterBMSTheme.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
