import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';
import '../../services/network_scanner_service.dart';
import '../../services/device_ip_service.dart';

class NetworkDevicesScreen extends StatefulWidget {
  const NetworkDevicesScreen({Key? key}) : super(key: key);

  @override
  _NetworkDevicesScreenState createState() => _NetworkDevicesScreenState();
}

class _NetworkDevicesScreenState extends State<NetworkDevicesScreen>
    with TickerProviderStateMixin {
  List<NetworkDevice> _devices = [];
  List<NetworkDevice> _customDevices = []; // Store manually added devices
  bool _isScanning = false;
  String _scanProgress = '';
  final NetworkScannerService _scanner = NetworkScannerService();
  late AnimationController _animationController;
  
  // Device IP information
  DeviceIPInfo? _currentDeviceIP;
  String _deviceName = 'Loading...';
  bool _loadingDeviceInfo = true;  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Load device information
    _loadDeviceInfo();

    // Start with a quick scan
    _performQuickScan();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceIP = await DeviceIPService.getCurrentDeviceIP();
      final deviceName = await DeviceIPService.getDeviceName();

      setState(() {
        _currentDeviceIP = deviceIP;
        _deviceName = deviceName;
        _loadingDeviceInfo = false;
      });
    } catch (e) {
      setState(() {
        _loadingDeviceInfo = false;
      });
    }
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
            icon: Icon(Icons.add),
            onPressed: _showAddDeviceDialog,
            tooltip: 'Add Device',
          ),
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
          _buildCurrentDeviceInfo(),
          if (_isScanning) _buildScanningIndicator(),
          if (_devices.isNotEmpty || _customDevices.isNotEmpty) _buildDeviceCount(),
          Expanded(
            child: (_devices.isEmpty && _customDevices.isEmpty) && !_isScanning
                ? _buildEmptyState()
                : _buildDeviceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDeviceInfo() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZensterBMSTheme.nearlyDarkBlue,
            ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ZensterBMSTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.smartphone,
                    color: ZensterBMSTheme.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Device',
                        style: TextStyle(
                          fontFamily: ZensterBMSTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: ZensterBMSTheme.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _deviceName,
                        style: TextStyle(
                          fontFamily: ZensterBMSTheme.fontName,
                          fontSize: 14,
                          color: ZensterBMSTheme.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showCurrentDeviceDetails(),
                  icon: Icon(Icons.info_outline, color: ZensterBMSTheme.white),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_loadingDeviceInfo)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ZensterBMSTheme.white,
                  ),
                ),
              )
            else if (_currentDeviceIP != null) ...[
              _buildDeviceIPRow(
                'IP Address',
                _currentDeviceIP!.ipAddress ?? 'Unknown',
                Icons.location_on,
              ),
              SizedBox(height: 8),
              _buildDeviceIPRow(
                'Interface',
                _currentDeviceIP!.interfaceName ?? 'Unknown',
                _currentDeviceIP!.isWifi
                    ? Icons.wifi
                    : _currentDeviceIP!.isEthernet
                    ? Icons.cable
                    : Icons.device_unknown,
              ),
              SizedBox(height: 8),
              _buildDeviceIPRow(
                'Connection Type',
                _currentDeviceIP!.isWifi
                    ? 'WiFi'
                    : _currentDeviceIP!.isEthernet
                    ? 'Ethernet'
                    : 'Unknown',
                Icons.network_check,
              ),
            ] else
              Text(
                'Network information unavailable',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 14,
                  color: ZensterBMSTheme.white.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceIPRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ZensterBMSTheme.white.withOpacity(0.8), size: 16),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontSize: 14,
            color: ZensterBMSTheme.white.withOpacity(0.8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ZensterBMSTheme.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrentDeviceDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Current Device Information',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Device Name', _deviceName),
            if (_currentDeviceIP != null) ...[
              _buildInfoRow(
                'IP Address',
                _currentDeviceIP!.ipAddress ?? 'Unknown',
              ),
              _buildInfoRow(
                'Interface',
                _currentDeviceIP!.interfaceName ?? 'Unknown',
              ),
              _buildInfoRow(
                'Connection Type',
                _currentDeviceIP!.isWifi
                    ? 'WiFi'
                    : _currentDeviceIP!.isEthernet
                    ? 'Ethernet'
                    : 'Unknown',
              ),
              if (_currentDeviceIP!.ipAddress != null)
                _buildInfoRow(
                  'Network Range',
                  '${DeviceIPService.getNetworkBase(_currentDeviceIP!.ipAddress)}.1-255',
                ),
            ],
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
    final totalDevices = _devices.length + _customDevices.length;
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
          Icon(Icons.devices, color: ZensterBMSTheme.nearlyDarkBlue, size: 20),
          SizedBox(width: 8),
          Text(
            '$totalDevices device${totalDevices != 1 ? 's' : ''} found',
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: ZensterBMSTheme.darkText,
            ),
          ),
          if (_customDevices.isNotEmpty) ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_customDevices.length} custom',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 12,
                  color: ZensterBMSTheme.nearlyDarkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 80, color: ZensterBMSTheme.grey),
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
    // Combine scanned devices and custom devices
    final allDevices = [..._customDevices, ..._devices];
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: allDevices.length,
      itemBuilder: (context, index) {
        final device = allDevices[index];
        final isCustomDevice = index < _customDevices.length;
        return _buildDeviceCard(device, index, isCustomDevice);
      },
    );
  }

  Widget _buildDeviceCard(NetworkDevice device, int index, [bool isCustomDevice = false]) {
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
            color: isCustomDevice
                ? ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1)
                : device.isOnline
                    ? ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1)
                    : ZensterBMSTheme.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            isCustomDevice ? Icons.person_add : _getDeviceIcon(device.ipAddress),
            color: isCustomDevice
                ? ZensterBMSTheme.nearlyDarkBlue
                : device.isOnline
                    ? ZensterBMSTheme.nearlyDarkBlue
                    : ZensterBMSTheme.grey,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.ipAddress,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ),
            if (isCustomDevice)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Custom',
                  style: TextStyle(
                    fontFamily: ZensterBMSTheme.fontName,
                    fontSize: 10,
                    color: ZensterBMSTheme.nearlyDarkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
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
