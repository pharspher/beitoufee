import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.brown,
      ),
      home: new InputForm(),
    );
  }
}

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final degreeRemainedController = TextEditingController();
  final degreeLowController = TextEditingController();
  final degreeHighController = TextEditingController();

  DateTime previousShotDate;
  DateTime latestShotDate;
  DateTime chargedDate;

  String previousShotDateString = "Date";
  String latestShotDateString = "Date";
  String chargedDateString = "Date";

  String resultString = "N/A";
  String nextDrString = "";

  @override
  void dispose() {
    degreeRemainedController.dispose();
    degreeLowController.dispose();
    degreeHighController.dispose();
    super.dispose();
  }

  Column createDrSection() {
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            '前次剩餘度數',
            textAlign: TextAlign.left,
            textScaleFactor: 1.3,
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
          new TextField(
            decoration: new InputDecoration(
              hintText: 'degree',
            ),
            controller: degreeRemainedController,
            onChanged: (s) {
              updateResult();
            },
          )
        ]);
  }

  Container createSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(top: 25.0, bottom: 12.0),
      child: new Text(
        title,
        textAlign: TextAlign.left,
        textScaleFactor: 1.3,
        style: new TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Column createDegreeSection(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text('度數'),
        new TextField(
          decoration: new InputDecoration(
            hintText: 'degree',
          ),
          controller: controller,
          onChanged: (s) {
            updateResult();
          },
        ),
      ],
    );
  }

  Column createDateSection(Function dateCallback, DateTime currentDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.only(top: 12.0),
          child: new Text('日期'),
        ),
        new GestureDetector(
          onTap: () async {
            DateTime time = await _selectDate(context);
            dateCallback(time);
            updateResult();
          },
          child: new Text(
            currentDate == null ? "Date" : format(currentDate),
            style: new TextStyle(decoration: TextDecoration.underline),
          ),
        )
      ],
    );
  }

  Column createResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(resultString),
        new Text(nextDrString),
      ],
    );
  }

  Widget createPage() {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          createDrSection(),
          createSectionTitle("照片1"),
          createDegreeSection(degreeLowController),
          createDateSection(
              (DateTime time) => previousShotDate = time, previousShotDate),
          createSectionTitle("照片2"),
          createDegreeSection(degreeHighController),
          createDateSection(
              (DateTime time) => (latestShotDate = time), latestShotDate),
          createSectionTitle("收費截止日"),
          createDateSection((DateTime time) => chargedDate = time, chargedDate),
          createSectionTitle("Result"),
          createResultSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Beitou Fee'),
      ),
      body: new ListView(
        children: <Widget>[createPage()],
      ),
    );
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    final DateTime _picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime.now().subtract(new Duration(days: 365)),
        lastDate: new DateTime.now());
    return _picked;
  }

  void updateResult() {
    setState(() {
      String remainString = degreeRemainedController.text;
      int degreeRemained = remainString.isEmpty ? 0 : int.parse(remainString);

      String highString = degreeHighController.text;
      String lowString = degreeLowController.text;
      int degreeDiff = (highString.isEmpty || lowString.isEmpty)
          ? 0
          : int.parse(highString) - int.parse(lowString);

      if (previousShotDate != null &&
          latestShotDate != null &&
          chargedDate != null &&
          degreeRemainedController.text.isNotEmpty &&
          degreeLowController.text.isNotEmpty &&
          degreeHighController.text.isNotEmpty) {
        int diffA = chargedDate.difference(previousShotDate).inDays;
        int diffB = latestShotDate.difference(chargedDate).inDays;

        double factor1 = diffA / (diffA + diffB);
        double factor2 = 1.0 - factor1;
        resultString =
            "cost($factor1 * $degreeDiff + $degreeRemained) = cost(${(factor1 *
            degreeDiff) + degreeRemained})";
        nextDrString = "Dr = ${factor2 * degreeDiff}";
      } else {
        resultString = "N/A";
        nextDrString = "";
      }
    });
  }

  String format(DateTime time) {
    return new DateFormat.yMd().format(time);
  }
}
