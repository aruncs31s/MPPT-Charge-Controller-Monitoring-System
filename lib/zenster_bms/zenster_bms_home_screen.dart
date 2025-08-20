import 'models/tabIcon_data.dart';
import 'analytics/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'zenster_bms_theme.dart';
import 'my_diary/my_diary_screen.dart';
import 'ui_view/network_devices_screen.dart';
import 'company/company_info_screen.dart';

class ZensterBMSHomeScreen extends StatefulWidget {
  const ZensterBMSHomeScreen({super.key});

  @override
  _ZensterBMSHomeScreenState createState() => _ZensterBMSHomeScreenState();
}

class _ZensterBMSHomeScreenState extends State<ZensterBMSHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(color: ZensterBMSTheme.background);

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    tabBody = HomeScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZensterBMSTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(children: <Widget>[tabBody, bottomBar()]);
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(child: SizedBox()),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            // Switch to Devices tab and trigger add device action
            setState(() {
              tabBody = NetworkDevicesScreen(shouldShowAddDialog: true);
            });
            // Update tab selection to show Devices tab as active
            tabIconsList.forEach((TabIconData tab) {
              tab.isSelected = false;
              if (tab.index == 2) {
                // Devices tab
                tab.isSelected = true;
              }
            });
          },
          changeIndex: (int index) {
            if (index == 0) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = HomeScreen(
                    animationController: animationController,
                  );
                });
              });
            } else if (index == 1) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = AnalyticsScreen(
                    animationController: animationController,
                  );
                });
              });
            } else if (index == 2) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = NetworkDevicesScreen();
                });
              });
            } else if (index == 3) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = CompanyInfoScreen(
                    animationController: animationController,
                  );
                });
              });
            }
          },
        ),
      ],
    );
  }
}
