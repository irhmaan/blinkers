import 'package:cvs/presentation/widgets/row_textbox.dart';
import 'package:cvs/utils/common_utils.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isOn = false;
  bool isMinimized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: CommonUtils.screenHeight(context) / 3,
                  width: CommonUtils.screenWidth(context) / 1.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowTextWidget(
                      label: 'Run in background',
                      hintText: 'Allow the app to run in background',
                      value: _isOn,
                      onChanged: (v) => setState(() => _isOn = v),
                    ),
                    // spacing between rows
                    RowTextWidget(
                      label: 'Minimize when closed',
                      value: isMinimized,
                      onChanged: (p0) => setState(() => isMinimized = p0),
                      hintText: 'Minimize the app to system tray when closed',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
