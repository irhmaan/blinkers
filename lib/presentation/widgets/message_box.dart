import 'package:cvs/core/logger.dart';
import 'package:flutter/material.dart';

class MessageDialog {
  static final logger = Logger("MessageDialog");

  /// Shows a platform-aware dialog with customizable options
  /// Returns true if OK, false if Cancel, null if dismissed or error
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String okLabel = "OK",
    String cancelLabel = "Cancel",
    bool barrierDismissible = false,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    ButtonStyle? okButtonStyle,
    ButtonStyle? cancelButtonStyle,
    VoidCallback? onDismiss,
    VoidCallback? onAccept,
  }) async {
    try {
      // if (Platform.isWindows) {
      //   // Use win32 for native Windows dialog
      //   final hWnd = GetActiveWindow();
      //   final lpCaption = title.toNativeUtf16();
      //   final lpText = message.toNativeUtf16();

      //   final result = MessageBox(
      //     hWnd,
      //     lpText,
      //     lpCaption,
      //     MB_OKCANCEL |
      //         MB_ICONINFORMATION |
      //         MB_DEFBUTTON2, // OK/Cancel buttons, default to Cancel
      //   );

      //   // Free allocated memory
      //   free(lpText);
      //   free(lpCaption);

      //   switch (result) {
      //     case IDOK:
      //       logger.info("Windows dialog: OK pressed");
      //       onAccept?.call();
      //       return true;
      //     case IDCANCEL:
      //       logger.info("Windows dialog: Cancel pressed");
      //       onDismiss?.call();
      //       return false;
      //     default:
      //       logger.error("Windows dialog: Unexpected result $result");
      //       return null;
      //   }
      // } else if (Platform.isIOS) {
      //   return showCupertinoDialog<bool>(
      //     context: context,
      //     barrierDismissible: barrierDismissible,
      //     builder:
      //         (ctx) => CupertinoAlertDialog(
      //           title: Text(
      //             title,
      //             style:
      //                 titleStyle ??
      //                 const TextStyle(fontWeight: FontWeight.bold),
      //           ),
      //           content: Text(message, style: messageStyle),
      //           actions: [
      //             CupertinoDialogAction(
      //               onPressed: () {
      //                 Navigator.of(ctx).pop(false);
      //                 onDismiss?.call();
      //               },
      //               child: Text(
      //                 cancelLabel,
      //                 style:
      //                     cancelButtonStyle?.textStyle?.resolve({}) ??
      //                     const TextStyle(color: CupertinoColors.systemGrey),
      //               ),
      //             ),
      //             CupertinoDialogAction(
      //               isDefaultAction: true,
      //               onPressed: () {
      //                 Navigator.of(ctx).pop(true);
      //                 onAccept?.call();
      //               },
      //               child: Text(
      //                 okLabel,
      //                 style:
      //                     okButtonStyle?.textStyle?.resolve({}) ??
      //                     const TextStyle(color: CupertinoColors.systemBlue),
      //               ),
      //             ),
      //           ],
      //         ),
      //   );
      // } else {
      // Android / macOS / Linux → Material
      return _showMaterialDialog(
        context,
        title: title,
        message: message,
        okLabel: okLabel,
        cancelLabel: cancelLabel,
        barrierDismissible: barrierDismissible,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
        okButtonStyle: okButtonStyle,
        cancelButtonStyle: cancelButtonStyle,
        onDismiss: onDismiss,
        onAccept: onAccept,
      );
      // }
    } catch (e) {
      logger.error("Unexpected error showing dialog: $e");
      return null;
    }
  }

  static Future<bool?> _showMaterialDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String okLabel,
    required String cancelLabel,
    required bool barrierDismissible,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    ButtonStyle? okButtonStyle,
    ButtonStyle? cancelButtonStyle,
    VoidCallback? onDismiss,
    VoidCallback? onAccept,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              title,
              style: titleStyle ?? const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message, style: messageStyle),
            actions: [
              TextButton(
                style:
                    cancelButtonStyle ??
                    TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                  onDismiss?.call();
                },
                child: Text(
                  cancelLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ElevatedButton(
                style:
                    okButtonStyle ??
                    ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                  onAccept?.call();
                },
                child: Text(
                  okLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
    );
  }
}
