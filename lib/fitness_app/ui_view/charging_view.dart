import '../zenster_bms_theme.dart';
import '../../main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChargingView extends StatelessWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  const ChargingView(
      {super.key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - mainScreenAnimation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: ZensterBMSTheme.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: ZensterBMSTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Charging Status',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: ZensterBMSTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: ZensterBMSTheme.darkText,
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: ZensterBMSTheme.nearlyDarkBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.power,
                                          color: ZensterBMSTheme.nearlyWhite,
                                          size: 16,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '85',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: ZensterBMSTheme.fontName,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 34,
                                          letterSpacing: 0.0,
                                          color: ZensterBMSTheme.nearlyDarkBlue,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, top: 0, bottom: 8),
                                        child: Text(
                                          '%',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: ZensterBMSTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            letterSpacing: -0.2,
                                            color: ZensterBMSTheme.nearlyDarkBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, top: 2, bottom: 14),
                                  child: Text(
                                    'Charging with 20W adapter',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: ZensterBMSTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: 0.0,
                                      color: ZensterBMSTheme.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, right: 4, top: 8, bottom: 16),
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: ZensterBMSTheme.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, right: 4, top: 0, bottom: 0),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Time to Full',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: ZensterBMSTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          color: ZensterBMSTheme.darkText,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '25 min',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                ZensterBMSTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: ZensterBMSTheme.grey
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Power Input',
                                        style: TextStyle(
                                          fontFamily: ZensterBMSTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          color: ZensterBMSTheme.darkText,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '18.5W',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                ZensterBMSTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: ZensterBMSTheme.grey
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, right: 4, top: 8, bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: ZensterBMSTheme.nearlyWhite,
                                          shape: BoxShape.circle,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: ZensterBMSTheme
                                                    .nearlyDarkBlue
                                                    .withOpacity(0.4),
                                                offset: const Offset(4.0, 4.0),
                                                blurRadius: 8.0),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Icon(
                                            Icons.flash_on,
                                            color: ZensterBMSTheme.nearlyDarkBlue,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 28,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: ZensterBMSTheme.nearlyWhite,
                                          shape: BoxShape.circle,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: ZensterBMSTheme
                                                    .nearlyDarkBlue
                                                    .withOpacity(0.4),
                                                offset: const Offset(4.0, 4.0),
                                                blurRadius: 8.0),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Icon(
                                            Icons.remove,
                                            color: ZensterBMSTheme.nearlyDarkBlue,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 8, top: 16),
                        child: Container(
                          width: 60,
                          height: 160,
                          decoration: BoxDecoration(
                            color: HexColor('#E8EDFE'),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(80.0),
                                bottomLeft: Radius.circular(80.0),
                                bottomRight: Radius.circular(80.0),
                                topRight: Radius.circular(80.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: ZensterBMSTheme.grey.withOpacity(0.4),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4),
                            ],
                          ),
                          child: BatteryWaveView(
                            percentageValue: 85.0,
                          ),
                        ),
                      )
                    ],
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

class BatteryWaveView extends StatefulWidget {
  const BatteryWaveView({super.key, this.percentageValue = 100.0});

  final double percentageValue;
  @override
  _BatteryWaveViewState createState() => _BatteryWaveViewState();
}

class _BatteryWaveViewState extends State<BatteryWaveView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animationController?.repeat();
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
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: BatteryWavePainter(
              animationController!.value,
              widget.percentageValue,
            ),
            child: SizedBox(
              width: 60,
              height: 160,
            ),
          );
        },
      ),
    );
  }
}

class BatteryWavePainter extends CustomPainter {
  final double animationValue;
  final double percentage;

  BatteryWavePainter(this.animationValue, this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    Color waveColor = ZensterBMSTheme.nearlyDarkBlue;
    
    if (percentage > 20) {
      waveColor = ZensterBMSTheme.nearlyDarkBlue;
    } else {
      waveColor = Colors.redAccent;
    }

    double waveHeight = (size.height / 100) * percentage;

    final paint = Paint()
      ..color = waveColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path();

    double waveLength = size.width;
    double waveAmplitude = 4.0;

    path.moveTo(0, size.height);
    path.lineTo(0, size.height - waveHeight);

    for (double i = 0; i <= size.width; i++) {
      double waveY = waveAmplitude *
          math.sin((i / waveLength * 2 * math.pi) + (animationValue * 2 * math.pi));
      path.lineTo(i, size.height - waveHeight + waveY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw second wave for charging effect
    final paint2 = Paint()
      ..color = waveColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height - waveHeight);

    for (double i = 0; i <= size.width; i++) {
      double waveY = waveAmplitude *
          math.sin((i / waveLength * 2 * math.pi) + (animationValue * 2 * math.pi) + math.pi);
      path2.lineTo(i, size.height - waveHeight + waveY);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
