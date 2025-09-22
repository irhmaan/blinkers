import 'package:cvs/core/global.dart';
import 'package:cvs/core/tray_manager.dart';
import 'package:cvs/presentation/widgets/row_textbox.dart';
import 'package:cvs/utils/common_utils.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final winMgr = SystemTrayService();

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
                      value: Global.startWithSystem,
                      onChanged:
                          (v) => setState(() {
                            winMgr.enableAutoStartWindows();
                          }),
                    ),
                    // spacing between rows
                    RowTextWidget(
                      label: 'Minimize when closed',
                      value: Global.isMinimizeToTray,
                      onChanged:
                          (p0) => setState(() {
                            winMgr.enableDisable();
                          }),
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
