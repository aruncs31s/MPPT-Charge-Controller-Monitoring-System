import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  bool _loadingDeviceInfo = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Load device information
    _loadDeviceInfo();
    
    // Load saved custom devices
    _loadSavedDevices();

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

  Future<void> _loadSavedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDevicesJson = prefs.getStringList('custom_devices') ?? [];
      
      final savedDevices = savedDevicesJson.map((deviceJson) {
        final deviceMap = json.decode(deviceJson) as Map<String, dynamic>;
        return NetworkDevice(
          ipAddress: deviceMap['ipAddress'] as String,
          hostname: deviceMap['hostname'] as String?,
          isOnline: deviceMap['isOnline'] as bool? ?? true,
          responseTime: deviceMap['responseTime'] as int?,
        );
      }).toList();

      setState(() {
        _customDevices = savedDevices;
      });
    } catch (e) {
      print('Error loading saved devices: $e');
    }
  }

  Future<void> _saveCustomDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = _customDevices.map((device) {
        return json.encode({
          'ipAddress': device.ipAddress,
          'hostname': device.hostname,
          'isOnline': device.isOnline,
          'responseTime': device.responseTime,
        });
      }).toList();
      
      await prefs.setStringList('custom_devices', devicesJson);
    } catch (e) {
      print('Error saving custom devices: $e');
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'save':
                  _saveCustomDevices();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Custom devices saved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  break;
                case 'clear':
                  _showClearDevicesDialog();
                  break;
                case 'export':
                  _showExportDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 16),
                    SizedBox(width: 8),
                    Text('Save Devices'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 16),
                    SizedBox(width: 8),
                    Text('Clear All Custom'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.ios_share, size: 16),
                    SizedBox(width: 8),
                    Text('Export List'),
                  ],
                ),
              ),
            ],
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
          if (_devices.isNotEmpty || _customDevices.isNotEmpty)
            _buildDeviceCount(),
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

  void _showAddDeviceDialog() {
    final ipController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Custom Device',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'IP Address',
                hintText: 'e.g., 192.168.1.100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Device Name (Optional)',
                hintText: 'e.g., Solar Controller',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ZensterBMSTheme.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              if (ip.isNotEmpty && _isValidIP(ip)) {
                _addCustomDevice(ip, nameController.text.trim());
                Navigator.of(context).pop();
              } else {
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid IP address'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ZensterBMSTheme.nearlyDarkBlue,
              foregroundColor: ZensterBMSTheme.white,
            ),
            child: Text('Add Device'),
          ),
        ],
      ),
    );
  }

  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (String part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  void _addCustomDevice(String ip, String customName) {
    final device = NetworkDevice(
      ipAddress: ip,
      hostname: customName.isNotEmpty ? customName : null,
      isOnline: true, // Assume custom devices are online
    );

    setState(() {
      _customDevices.add(device);
    });
    
    // Save devices persistently
    _saveCustomDevices();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device added and saved: $ip'),
        backgroundColor: Colors.green,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.save,
                    size: 12,
                    color: ZensterBMSTheme.nearlyDarkBlue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${_customDevices.length} saved',
                    style: TextStyle(
                      fontFamily: ZensterBMSTheme.fontName,
                      fontSize: 12,
                      color: ZensterBMSTheme.nearlyDarkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
    // Combine custom devices (show first) and scanned devices
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

  Widget _buildDeviceCard(
    NetworkDevice device,
    int index, [
    bool isCustomDevice = false,
  ]) {
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
            isCustomDevice
                ? Icons.person_add
                : _getDeviceIcon(device.ipAddress),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.save,
                      size: 8,
                      color: ZensterBMSTheme.nearlyDarkBlue,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontFamily: ZensterBMSTheme.fontName,
                        fontSize: 10,
                        color: ZensterBMSTheme.nearlyDarkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
        trailing: isCustomDevice
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.info_outline, color: ZensterBMSTheme.grey),
                    onPressed: () => _showDeviceInfo(device, isCustomDevice),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCustomDevice(device),
                  ),
                ],
              )
            : IconButton(
                icon: Icon(Icons.info_outline, color: ZensterBMSTheme.grey),
                onPressed: () => _showDeviceInfo(device, isCustomDevice),
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

  void _showDeviceInfo(NetworkDevice device, [bool isCustomDevice = false]) {
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
            if (isCustomDevice) _buildInfoRow('Type', 'Custom Device'),
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

  void _removeCustomDevice(NetworkDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Device',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${device.ipAddress}?',
          style: TextStyle(fontFamily: ZensterBMSTheme.fontName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ZensterBMSTheme.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customDevices.remove(device);
              });
              
              // Save updated devices list
              _saveCustomDevices();
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Device removed and saved: ${device.ipAddress}'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Custom Devices',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all ${_customDevices.length} custom devices? This action cannot be undone.',
          style: TextStyle(fontFamily: ZensterBMSTheme.fontName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ZensterBMSTheme.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customDevices.clear();
              });
              
              // Save updated (empty) devices list
              _saveCustomDevices();
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All custom devices cleared and saved'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final deviceList = _customDevices.map((device) {
      return '${device.ipAddress}${device.hostname != null ? ' (${device.hostname})' : ''}';
    }).join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Export Device List',
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Devices (${_customDevices.length}):',
              style: TextStyle(
                fontFamily: ZensterBMSTheme.fontName,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ZensterBMSTheme.nearlyWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ZensterBMSTheme.grey.withOpacity(0.3)),
              ),
              child: SelectableText(
                deviceList.isEmpty ? 'No custom devices to export' : deviceList,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 12,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Long press to select and copy the device list.',
              style: TextStyle(
                fontFamily: ZensterBMSTheme.fontName,
                fontSize: 11,
                color: ZensterBMSTheme.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
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
