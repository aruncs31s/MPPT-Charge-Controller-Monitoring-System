import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkDevice {
  final String ipAddress;
  final String? hostname;
  final bool isOnline;
  final int? responseTime; // in milliseconds

  NetworkDevice({
    required this.ipAddress,
    this.hostname,
    required this.isOnline,
    this.responseTime,
  });

  @override
  String toString() {
    return 'NetworkDevice{ip: $ipAddress, hostname: $hostname, online: $isOnline, responseTime: ${responseTime}ms}';
  }
}

class NetworkScannerService {
  static const int _timeout = 3000; // 3 seconds timeout
  static const int _concurrentScans =
      20; // Number of concurrent ping operations

  /// Scans the network range 192.168.1.1 to 192.168.1.255
  /// Returns a list of online devices
  Future<List<NetworkDevice>> scanNetwork({
    String baseIp = '192.168.31',
    int startRange = 1,
    int endRange = 255,
    Function(String)? onProgress,
  }) async {
    if (kIsWeb) {
      // Web platform doesn't support raw sockets for ping
      return _mockNetworkScan();
    }

    List<NetworkDevice> onlineDevices = [];
    List<Future<NetworkDevice?>> futures = [];

    for (int i = startRange; i <= endRange; i++) {
      String ip = '$baseIp.$i';
      futures.add(_pingHost(ip));

      // Process in batches to avoid overwhelming the system
      if (futures.length >= _concurrentScans || i == endRange) {
        final results = await Future.wait(futures);
        for (final device in results) {
          if (device != null && device.isOnline) {
            onlineDevices.add(device);
          }
        }

        // Progress callback
        onProgress?.call(
          'Scanned ${i - startRange + 1}/${endRange - startRange + 1} addresses...',
        );

        futures.clear();
      }
    }

    return onlineDevices;
  }

  /// Ping a specific host
  Future<NetworkDevice?> _pingHost(String ipAddress) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Try to connect to the host on a common port (80 or 443)
      final socket =
          await Socket.connect(
                ipAddress,
                80,
                timeout: Duration(milliseconds: _timeout),
              )
              .catchError(
                (_) => Socket.connect(
                  ipAddress,
                  443,
                  timeout: Duration(milliseconds: _timeout),
                ),
              )
              .catchError((_) => throw Exception('Connection failed'));

      stopwatch.stop();
      socket.destroy();

      String? hostname;
      try {
        final result = await InternetAddress.lookup(ipAddress);
        if (result.isNotEmpty) {
          hostname = result.first.host;
        }
      } catch (e) {
        // Hostname lookup failed, continue without it
      }

      return NetworkDevice(
        ipAddress: ipAddress,
        hostname: hostname,
        isOnline: true,
        responseTime: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      // Host is not reachable
      return NetworkDevice(ipAddress: ipAddress, isOnline: false);
    }
  }

  /// Alternative ping using Process (for platforms that support it)
  Future<NetworkDevice?> _pingHostWithProcess(String ipAddress) async {
    try {
      final stopwatch = Stopwatch()..start();

      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('ping', [
          '-n',
          '1',
          '-w',
          '3000',
          ipAddress,
        ]);
      } else {
        result = await Process.run('ping', ['-c', '1', '-W', '3', ipAddress]);
      }

      stopwatch.stop();

      if (result.exitCode == 0) {
        return NetworkDevice(
          ipAddress: ipAddress,
          isOnline: true,
          responseTime: stopwatch.elapsedMilliseconds,
        );
      } else {
        return NetworkDevice(ipAddress: ipAddress, isOnline: false);
      }
    } catch (e) {
      return NetworkDevice(ipAddress: ipAddress, isOnline: false);
    }
  }

  /// Mock network scan for web platform
  List<NetworkDevice> _mockNetworkScan() {
    // Return some mock devices for demonstration on web
    return [
      NetworkDevice(
        ipAddress: '192.168.1.1',
        hostname: 'router.local',
        isOnline: true,
        responseTime: 5,
      ),
      NetworkDevice(
        ipAddress: '192.168.1.100',
        hostname: 'mppt-controller.local',
        isOnline: true,
        responseTime: 12,
      ),
      NetworkDevice(
        ipAddress: '192.168.1.150',
        hostname: 'battery-monitor.local',
        isOnline: true,
        responseTime: 8,
      ),
    ];
  }

  /// Quick scan of common device IPs
  Future<List<NetworkDevice>> quickScan() async {
    List<String> commonIps = [
      '192.168.31.1', // Router
      '192.168.31.2', // Secondary router
      '192.168.31.10', // Common static IPs
      '192.168.31.20',
      '192.168.31.100', // MPPT controllers often use this range
      '192.168.31.101',
      '192.168.31.102',
      '192.168.31.200', // Common device range
      '192.168.31.254', // Common router IP
    ];

    if (kIsWeb) {
      return _mockNetworkScan();
    }

    List<NetworkDevice> onlineDevices = [];
    List<Future<NetworkDevice?>> futures = commonIps.map(_pingHost).toList();

    final results = await Future.wait(futures);
    for (final device in results) {
      if (device != null && device.isOnline) {
        onlineDevices.add(device);
      }
    }

    return onlineDevices;
  }
}
