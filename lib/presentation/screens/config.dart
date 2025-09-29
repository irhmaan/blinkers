import 'package:cvs/core/tray_manager.dart';
import 'package:cvs/presentation/widgets/elevated_button.dart';
import 'package:cvs/presentation/widgets/message_box.dart';
import 'package:cvs/presentation/widgets/row_textbox.dart';
import 'package:cvs/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Drawer(),
      body: Consumer<SystemTrayService>(
        builder: (
          BuildContext context,
          SystemTrayService value,
          Widget? child,
        ) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                height: CommonUtils.screenHeight(context),
                width: CommonUtils.screenWidth(context) / 1.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back),
                          ),
                          Text(
                            title,
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.labelLarge!.copyWith(),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RowTextWidget(
                              show: false,
                              value:
                                  context
                                      .watch<SystemTrayService>()
                                      .isTimerRunning,
                              label:
                                  value.isTimerRunning
                                      ? value.showNextRemindTime()
                                      : "Nothing to show here",

                              hintText: '',
                            ),
                            SizedBox(
                              height: CommonUtils.screenHeight(context) / 50,
                            ),
                            RowTextWidget(
                              value:
                                  context
                                      .watch<SystemTrayService>()
                                      .isTimerRunning,
                              label:
                                  value.isTimerRunning
                                      ? 'Stop watchmen'
                                      : 'Start watchmen',
                              onChanged: (p0) {
                                if (!value.isTimerRunning) {
                                  value.startBackgroundTimer();
                                } else {
                                  value.stopBackgroundTimer();
                                }
                              },
                              hintText: '',
                            ),

                            RowTextWidget(
                              label: 'Run with Windows',
                              hintText:
                                  'Allow the app to run as windows starts',
                              value:
                                  context
                                      .watch<SystemTrayService>()
                                      .startWithSystem,
                              onChanged:
                                  (args) => {
                                    if (!value.startWithSystem)
                                      {value.enableAutoStartWindows()}
                                    else
                                      {value.disableAutoStart()},
                                  },
                            ),
                            RowTextWidget(
                              label: 'Minimize to tray on exit',
                              value:
                                  context
                                      .watch<SystemTrayService>()
                                      .isMinimizeToTray,
                              onChanged:
                                  (arg) => {
                                    value.enableDisableMinimizeToTray(),
                                  },

                              hintText:
                                  'Minimize the app to system tray when closed',
                            ),
                            SizedBox(
                              height: CommonUtils.screenHeight(context) / 1.6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButtonWidget(
                                  label: 'Clear app data',
                                  visibility:
                                      context
                                          .watch<SystemTrayService>()
                                          .showHideClearBtn,
                                  onPressed:
                                      () => MessageDialog.show(
                                        context,
                                        title: title,
                                        message:
                                            'Do you want to clear app preferences?',
                                        okLabel: 'Ok',
                                        cancelLabel: 'Cancel',
                                        onAccept: () {
                                          context
                                              .read<SystemTrayService>()
                                              .clearAppData();
                                        },
                                      ),
                                  hintText:
                                      'Clear stored user app configuration.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
