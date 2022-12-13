import 'dart:io';

import 'package:datetime_setting/datetime_setting.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:safe_device/safe_device.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../widgets/button.dart';

Future<bool> isNetConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      // showToastMsg('Check Your Internet Connection',
      //     title: 'Network Error', background: colorPrimary);
      showToastMsg('Check your internet connection');
      return false;
    }
  } catch (_) {
    showToastMsg('Check your internet connection');
    // showToastMsg('Check Your Internet Connection',
    //     title: 'Network Error', background: colorPrimary);
    return false;
  }
  
}

showToastMsg(String msg,{
  bool longToast=false,
}){
  Fluttertoast.showToast(
      msg: msg,
      toastLength: longToast ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
  );
}

// showSnackbar(
//     String msg, {
//       String? title,
//       Color? background,
//     }) {
//   AdvanceSnackBar(
//     message: msg,
//     bgColor: background ?? const Color(0xFF323232),
//     textColor: background != null ? Colors.white : const Color(0xFFffffff),
//     isFixed: true,
//     fontWeight: FontWeight.w400,
//     textSize: 15,
//   ).show(Get.context!);
// }

String getDate({String format = 'dd/MM/yyyy', DateTime? dateTime}) {
  return DateFormat(format).format(dateTime ?? DateTime.now());
}


int getDifferenceInSecond(String startDate, String endDate, String format){
  try {
    return DateFormat(format)
        .parse(endDate)
        .difference(DateFormat(format).parse(startDate))
        .inSeconds;
  }catch(e){
    debugPrint(e.toString());
    return -1;
  }
}

Future<String?> getDeviceUniqueId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if(Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id; // unique ID on Android
  }
  return null;
}

Future<dynamic> getDeviceOs() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.systemVersion;
  } else if(Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.version.sdkInt; //
  }
  return null;
}

String getCustomUniqueId() {
  var uuid = const Uuid();
  return uuid.v4();
}

call(String mobileNo){
  launchUrlString("tel://$mobileNo");
}

openFile(String filePath) async{
  final Uri uri = Uri.file(filePath);

  if (!File(uri.toFilePath()).existsSync()) {
    throw '$uri does not exist!';
  }
  
  if (!await launchUrl(uri)) {
  throw 'Could not launch $uri';
  }
}

Future<String> getAppVersion() async{
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

checkTimeSetting(BuildContext context) async {
  if (Platform.isAndroid) {
    if (!await DatetimeSetting.timeIsAuto()) {
      await showModalBottomSheet(
          enableDrag: false,
          isDismissible: false,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => await DatetimeSetting.timeIsAuto(),
              child: Container(
                height: 190,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Security Warning!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Network provided time is disabled. Please enable the same to proceed further.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                        width: 100,
                        buttonText: 'Setting',
                        onPressed: () {
                          DatetimeSetting.openSetting();
                        }),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            );
          });
    }
  } else {
    debugPrint('Except android its not working');
  }
}

checkRootedDevice(BuildContext context) async {
  if ((await SafeDevice.isJailBroken) || !(await SafeDevice.isRealDevice)) {
    await showModalBottomSheet(
        enableDrag: false,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
              height: 150,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Security Warning!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'This application is not supported your device. please contact admin.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ],
              ),
            ),
          );
        });
  }
}


void showMessage(String title, String message, BuildContext context,
    {Widget? actionBtn, Widget? cancelBtn, bool? isDismiss}) {
  showDialog(
    context: context,
    barrierDismissible: isDismiss ?? true,
    builder: (BuildContext con) {
      return WillPopScope(
        onWillPop: () async => isDismiss ?? true,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                cancelBtn != null
                    ? Row(
                  children: [
                    Expanded(child: cancelBtn),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(child: actionBtn ?? const SizedBox.shrink())
                  ],
                )
                    : Align(
                    alignment: Alignment.centerRight,
                    child: actionBtn ?? const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      );
    },
  );
}