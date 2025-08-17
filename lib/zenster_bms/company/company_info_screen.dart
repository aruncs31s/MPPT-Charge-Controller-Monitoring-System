import 'package:flutter/material.dart';
import '../zenster_bms_theme.dart';

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({Key? key, this.animationController})
    : super(key: key);

  final AnimationController? animationController;

  @override
  _CompanyInfoScreenState createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZensterBMSTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: ZensterBMSTheme.nearlyDarkBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Company Info',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  color: ZensterBMSTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ZensterBMSTheme.nearlyDarkBlue,
                      ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: ZensterBMSTheme.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.solar_power,
                          size: 60,
                          color: ZensterBMSTheme.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'MPPT Solutions',
                        style: TextStyle(
                          fontFamily: ZensterBMSTheme.fontName,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ZensterBMSTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCompanyOverview(),
                SizedBox(height: 16),
                _buildContactInfo(),
                SizedBox(height: 16),
                _buildProductInfo(),
                SizedBox(height: 16),
                _buildSupportInfo(),
                SizedBox(height: 16),
                _buildVersionInfo(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyOverview() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'About Us',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'MPPT Solutions is a leading provider of advanced Battery Management Systems and Solar Charge Controllers. We specialize in developing innovative monitoring solutions for renewable energy systems.',
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 14,
              height: 1.5,
              color: ZensterBMSTheme.grey,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Solar Energy'),
              _buildTag('Battery Management'),
              _buildTag('IoT Solutions'),
              _buildTag('Renewable Energy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: ZensterBMSTheme.fontName,
          fontSize: 12,
          color: ZensterBMSTheme.nearlyDarkBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildContactRow(Icons.email, 'Email', 'info@mpptsolutions.com'),
          SizedBox(height: 12),
          _buildContactRow(Icons.phone, 'Phone', '+1 (555) 123-4567'),
          SizedBox(height: 12),
          _buildContactRow(Icons.language, 'Website', 'www.mpptsolutions.com'),
          SizedBox(height: 12),
          _buildContactRow(
            Icons.location_on,
            'Address',
            '123 Solar Street, Energy City, EC 12345',
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ZensterBMSTheme.nearlyDarkBlue, size: 16),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 12,
                  color: ZensterBMSTheme.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 14,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Our Products',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildProductCard(
            'MPPT Charge Controller',
            'Advanced maximum power point tracking for optimal solar energy harvesting',
            Icons.solar_power,
          ),
          SizedBox(height: 12),
          _buildProductCard(
            'Battery Management System',
            'Comprehensive battery monitoring and protection system',
            Icons.battery_charging_full,
          ),
          SizedBox(height: 12),
          _buildProductCard(
            'IoT Monitoring Platform',
            'Real-time remote monitoring and control capabilities',
            Icons.cloud_sync,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.nearlyWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZensterBMSTheme.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ZensterBMSTheme.nearlyDarkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ZensterBMSTheme.nearlyDarkBlue, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: ZensterBMSTheme.fontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZensterBMSTheme.darkText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: ZensterBMSTheme.fontName,
                    fontSize: 12,
                    color: ZensterBMSTheme.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Support & Warranty',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSupportItem(
            '24/7 Technical Support',
            'Round-the-clock assistance for all your needs',
          ),
          SizedBox(height: 12),
          _buildSupportItem(
            '2-Year Warranty',
            'Comprehensive warranty coverage on all products',
          ),
          SizedBox(height: 12),
          _buildSupportItem(
            'Remote Diagnostics',
            'Advanced remote troubleshooting capabilities',
          ),
          SizedBox(height: 12),
          _buildSupportItem(
            'Software Updates',
            'Regular firmware and software updates',
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: ZensterBMSTheme.nearlyDarkBlue,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 12,
                  color: ZensterBMSTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZensterBMSTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ZensterBMSTheme.grey.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ZensterBMSTheme.nearlyDarkBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'App Information',
                style: TextStyle(
                  fontFamily: ZensterBMSTheme.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ZensterBMSTheme.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildVersionRow('App Version', '1.0.0'),
          SizedBox(height: 8),
          _buildVersionRow('Build Number', '100'),
          SizedBox(height: 8),
          _buildVersionRow('Last Updated', 'August 2025'),
          SizedBox(height: 8),
          _buildVersionRow('Platform', 'Flutter 3.x'),
          SizedBox(height: 16),
          Text(
            '© 2025 MPPT Solutions. All rights reserved.',
            style: TextStyle(
              fontFamily: ZensterBMSTheme.fontName,
              fontSize: 12,
              color: ZensterBMSTheme.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontSize: 14,
            color: ZensterBMSTheme.darkText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: ZensterBMSTheme.fontName,
            fontSize: 14,
            color: ZensterBMSTheme.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
