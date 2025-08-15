import '../fitness_app_theme.dart';
import 'package:flutter/material.dart';

class AppUsageListView extends StatefulWidget {
  const AppUsageListView(
      {super.key, this.mainScreenAnimationController, this.mainScreenAnimation});

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _AppUsageListViewState createState() => _AppUsageListViewState();
}

class _AppUsageListViewState extends State<AppUsageListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<AppUsageCardData> appUsageDataList = AppUsageCardData.tabIconsList;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: appUsageDataList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count = appUsageDataList.length > 10
                      ? 10
                      : appUsageDataList.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return AppUsageView(
                    appUsageData: appUsageDataList[index],
                    animation: animation,
                    animationController: animationController!,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppUsageView extends StatelessWidget {
  const AppUsageView(
      {super.key, this.appUsageData, this.animationController, this.animation});

  final AppUsageCardData? appUsageData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: FitnessAppTheme.grey.withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <Color>[
                            appUsageData!.startColor ?? FitnessAppTheme.nearlyDarkBlue,
                            appUsageData!.endColor ?? FitnessAppTheme.nearlyDarkBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              appUsageData!.titleTxt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.2,
                                color: FitnessAppTheme.white,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      appUsageData!.usage,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        letterSpacing: 0.2,
                                        color: FitnessAppTheme.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 3),
                                      child: Text(
                                        'h',
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                          color: FitnessAppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            appUsageData?.assetsImage != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.nearlyWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: FitnessAppTheme.nearlyBlack
                                                .withOpacity(0.4),
                                            offset: Offset(8.0, 8.0),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(60.0)),
                                      child: Icon(
                                        appUsageData!.assetsImage ?? Icons.apps,
                                        color: appUsageData!.startColor ?? FitnessAppTheme.nearlyDarkBlue,
                                        size: 24,
                                      ),
                                    ))
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: Container(
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.nearlyWhite.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          appUsageData!.assetsImage ?? Icons.apps,
                          color: appUsageData!.startColor ?? FitnessAppTheme.nearlyDarkBlue,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppUsageCardData {
  AppUsageCardData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor,
    this.endColor,
    this.usage = '',
    this.assetsImage,
  });

  String imagePath;
  String titleTxt;
  String usage;
  Color? startColor;
  Color? endColor;
  IconData? assetsImage;

  static List<AppUsageCardData> tabIconsList = <AppUsageCardData>[
    AppUsageCardData(
      imagePath: '',
      titleTxt: 'Social Media',
      usage: '2.3',
      startColor: Color(0xFF738AE6),
      endColor: Color(0xFF5C5EDD),
      assetsImage: Icons.people,
    ),
    AppUsageCardData(
      imagePath: '',
      titleTxt: 'Games',
      usage: '1.8',
      startColor: Color(0xFF6F72CA),
      endColor: Color(0xFF1E1466),
      assetsImage: Icons.games,
    ),
    AppUsageCardData(
      imagePath: '',
      titleTxt: 'Productivity',
      usage: '0.9',
      startColor: Color(0xFF6AE6E6),
      endColor: Color(0xFF1DB5C4),
      assetsImage: Icons.work,
    ),
    AppUsageCardData(
      imagePath: '',
      titleTxt: 'Entertainment',
      usage: '1.5',
      startColor: Color(0xFFF56E98),
      endColor: Color(0xFFFC6286),
      assetsImage: Icons.movie,
    ),
    AppUsageCardData(
      imagePath: '',
      titleTxt: 'Browser',
      usage: '0.7',
      startColor: Color(0xFF6AE6E6),
      endColor: Color(0xFF1DB5C4),
      assetsImage: Icons.web,
    ),
  ];
}
