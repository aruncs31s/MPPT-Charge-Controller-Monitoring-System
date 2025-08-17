import 'dart:io';
import 'package:flutter/foundation.dart';

class DeviceIPInfo {
  final String? ipAddress;
  final String? networkMask;
  final String? gateway;
  final String? interfaceName;
  final String? macAddress;
  final bool isWifi;
  final bool isEthernet;

  DeviceIPInfo({
    this.ipAddress,
    this.networkMask,
    this.gateway,
    this.interfaceName,
    this.macAddress,
    this.isWifi = false,
    this.isEthernet = false,
  });

  @override
  String toString() {
    return 'DeviceIPInfo{ip: $ipAddress, interface: $interfaceName, wifi: $isWifi, ethernet: $isEthernet}';
  }
}

class DeviceIPService {
  /// Gets the current device's IP information
  static Future<DeviceIPInfo?> getCurrentDeviceIP() async {
    if (kIsWeb) {
      // Web platform doesn't have access to network interfaces
      return DeviceIPInfo(
        ipAddress: 'Not available on web',
        interfaceName: 'Web Browser',
        isWifi: false,
        isEthernet: false,
      );
    }

    try {
      List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (NetworkInterface interface in interfaces) {
        if (interface.addresses.isNotEmpty) {
          final address = interface.addresses.first;
          
          // Skip loopback addresses
          if (address.address.startsWith('127.')) continue;
          
          // Determine interface type
          bool isWifi = _isWifiInterface(interface.name);
          bool isEthernet = _isEthernetInterface(interface.name);
          
          return DeviceIPInfo(
            ipAddress: address.address,
            interfaceName: interface.name,
            isWifi: isWifi,
            isEthernet: isEthernet,
          );
        }
      }
    } catch (e) {
      print('Error getting network interfaces: $e');
    }

    return null;
  }

  /// Gets all network interfaces
  static Future<List<DeviceIPInfo>> getAllNetworkInterfaces() async {
    if (kIsWeb) {
      return [
        DeviceIPInfo(
          ipAddress: 'Not available on web',
          interfaceName: 'Web Browser',
          isWifi: false,
          isEthernet: false,
        )
      ];
    }

    List<DeviceIPInfo> result = [];

    try {
      List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (NetworkInterface interface in interfaces) {
        for (InternetAddress address in interface.addresses) {
          // Skip loopback addresses
          if (address.address.startsWith('127.')) continue;
          
          bool isWifi = _isWifiInterface(interface.name);
          bool isEthernet = _isEthernetInterface(interface.name);
          
          result.add(DeviceIPInfo(
            ipAddress: address.address,
            interfaceName: interface.name,
            isWifi: isWifi,
            isEthernet: isEthernet,
          ));
        }
      }
    } catch (e) {
      print('Error getting network interfaces: $e');
    }

    return result;
  }

  static bool _isWifiInterface(String interfaceName) {
    final wifiPatterns = ['wlan', 'wifi', 'wlp', 'wlo'];
    return wifiPatterns.any((pattern) => 
        interfaceName.toLowerCase().contains(pattern));
  }

  static bool _isEthernetInterface(String interfaceName) {
    final ethernetPatterns = ['eth', 'enp', 'eno', 'ens'];
    return ethernetPatterns.any((pattern) => 
        interfaceName.toLowerCase().contains(pattern));
  }

  /// Gets the network base IP (e.g., 192.168.1 from 192.168.1.100)
  static String? getNetworkBase(String? ipAddress) {
    if (ipAddress == null) return null;
    
    final parts = ipAddress.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return null;
  }

  /// Gets the device name/hostname
  static Future<String> getDeviceName() async {
    try {
      if (kIsWeb) return 'Web Browser';
      
      final hostname = Platform.localHostname;
      return hostname.isNotEmpty ? hostname : 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }
}
