import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../fitness_app_theme.dart';

class IPSettingsDialog extends StatefulWidget {
  const IPSettingsDialog({super.key});

  @override
  _IPSettingsDialogState createState() => _IPSettingsDialogState();
}

class _IPSettingsDialogState extends State<IPSettingsDialog> {
  final TextEditingController _ipController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentIP();
  }

  void _loadCurrentIP() {
    // Extract IP from current baseUrl
    String currentUrl = ApiService.baseUrl;
    if (currentUrl.startsWith('http://')) {
      currentUrl = currentUrl.substring(7);
    } else if (currentUrl.startsWith('https://')) {
      currentUrl = currentUrl.substring(8);
    }
    _ipController.text = currentUrl;
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _saveAndTest() async {
    if (_ipController.text.isEmpty) {
      _showSnackBar('Please enter an IP address', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save the IP
      await ApiService.saveIP(_ipController.text);
      
      // Test the connection
      final testData = await ApiService.fetchData();
      
      if (testData != null) {
        _showSnackBar('✅ Connection successful!', isError: false);
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        _showSnackBar('❌ Connection failed. Check IP and try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings, color: FitnessAppTheme.nearlyBlue),
          SizedBox(width: 8),
          Text(
            'Device Settings',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              color: FitnessAppTheme.darkText,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Device IP Address:',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
                color: FitnessAppTheme.darkText,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'e.g. 192.168.1.100:8080',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.computer, color: FitnessAppTheme.grey),
                suffixIcon: _isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(FitnessAppTheme.nearlyBlue),
                        ),
                      ),
                    )
                  : null,
              ),
              keyboardType: TextInputType.url,
              enabled: !_isLoading,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Examples:',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FitnessAppTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• localhost:8080',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                  Text(
                    '• 192.168.1.100:8080',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                  Text(
                    '• 10.0.0.50:3000',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              color: FitnessAppTheme.grey,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAndTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: FitnessAppTheme.nearlyBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _isLoading ? 'Testing...' : 'Save & Test',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
