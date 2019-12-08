import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  DateTime _date = DateTime.now();
  Timer _timer;

  AnimationController _minuteAnimationController;
  Animation<double> _minuteAnimationValue;

  AnimationController _hourAnimationController;
  Animation<double> _hourAnimationValue;

  /// This will be called when the widget is created
  /// We put here all the initialization code.
  /// However, please note that in this function the [BuildContext] does not
  /// exist
  @override
  void initState() {
    super.initState();
    // Create the animation Controllers for minutes
    _minuteAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _minuteAnimationValue = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 20.0, end: 1.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 60.0,
        ),
      ],
    ).animate(_minuteAnimationController);

    // Create the animation Controllers for hours
    _hourAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _hourAnimationValue = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 20.0, end: 1.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 60.0,
        ),
      ],
    ).animate(_hourAnimationController);

    _updateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColour(_date),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: ScaleTransition(
                    scale: _hourAnimationValue,
                    alignment: Alignment.centerRight,
                    child: Text(_date.hour.toString(), textAlign: TextAlign.right,
                      style: _getTextStyle(),
                    ),
                  ),
                ),
                Text(":", style: _getTextStyle(),),
                Expanded(
                  child: ScaleTransition(
                    scale: _minuteAnimationValue,
                    alignment: Alignment.centerLeft,
                    child: Text(_date.minute <= 9 ? "0${_date.minute}" : _date.minute.toString(), textAlign: TextAlign
                        .left, style: _getTextStyle(),),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _updateTime() {
    // update minutes
    setState(() {
      _date = DateTime.now();
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _date.second) -
            Duration(milliseconds: _date.millisecond),
        () {
          // when changing the minutes, we will display the animation for the minutes
          _minuteAnimationController.forward(from: 0);
          // Then, we will check if the minutes = 0, which means that we have passed 1 hour
          print(_date.minute.toString());
          if (_date.minute == 0) {
            _hourAnimationController.forward(from: 0);
          }
          _updateTime();
        },
      );
    });
    //update hour
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel(); //the same as `if (_timer != null) _timer.cancel`
  }

  TextStyle _getTextStyle() =>
      TextStyle(
          fontSize: 90,
          color: Colors.lightGreen,
          fontWeight: FontWeight.bold);

  Color _getBackgroundColour(DateTime date) {
    double lerp;
    if (date.hour <= 4 || date.hour >= 21) {
      lerp = 0;
    } else if (date.hour >= 12 && date.hour <= 16) {
      lerp = 1;
    } else if (date.hour > 4 && date.hour < 12) {
      lerp = (date.hour - 4) / (12 - 4);
    } else {
      lerp = 1 - (date.hour - 16) / (21 - 16);
    }

    return Color.lerp(Color(0xFF212121), Color(0xFFF9F9F9), lerp);
  }
}
