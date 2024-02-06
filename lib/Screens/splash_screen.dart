import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:terminal_demo/Constants/app_colors.dart';
import 'package:terminal_demo/Screens/home_screen.dart';
import 'package:terminal_demo/Utils/shared.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Functions.dart';
import '../Routes/page_route.dart';
import '../Services/notification_service.dart';
import '../Services/socket_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../Widgets/custom_text.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = PageRoutes.splash;

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer timer;
  Shared shared = Shared();
  var appVersion = '';
  bool isInternetConnected = false;

  @override
  void initState() {
    super.initState();
    SocketService.getLiveRateData(context);
    final notificationService = NotificationService();
    listenToNotificationStream(notificationService);
    notificationService.getFCMToken();
    getVersion();
    // startTimer();
  }

  void getVersion() {
    Functions.checkConnectivity().then((isConnected) async {
      if (isConnected) {
        if (Platform.isIOS) {
          PackageInfo info = await PackageInfo.fromPlatform();
          appVersion = info.version;
          callForIOS();
        } else if (Platform.isAndroid) {
          PackageInfo info = await PackageInfo.fromPlatform();
          appVersion = info.version;
          callForAndroid();
        }
      } else {
        startTimer();
        Functions.showToast(Constants.noInternet);
      }
    });
  }

  void callForIOS() async {
    String objVariable = json.encode({"ClientId": Constants.clientId});
    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<GetVersionApple xmlns="http://tempuri.org/">',
      '<Obj>$objVariable</Obj>',
      '</GetVersionApple>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();

    http.Response response = await http.post(Uri.parse(Constants.baseUrl),
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "http://tempuri.org/GetVersionApple",
          "Host": "starlinebuild.co.in"
          //"Accept": "text/xml"
        },
        body: envelope);

    var rawXmlResponse = response.body;
    XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);

    var chekis = parsedXml.text;

    var apiVersion = double.parse(chekis);
    var deviceAppVersion = double.parse(appVersion);
    if (deviceAppVersion < apiVersion) {
      showUpdateDialog();
    } else {
      startTimer();
    }
  }

  void callForAndroid() async {
    String objVariable = json.encode({"ClientId": Constants.clientId});

    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<GetVersionAndroid xmlns="http://tempuri.org/">',
      '<Obj>$objVariable</Obj>',
      '</GetVersionAndroid>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();

    http.Response response = await http.post(Uri.parse(Constants.baseUrl),
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "http://tempuri.org/GetVersionAndroid",
          "Host": "starlinebuild.co.in"
          //"Accept": "text/xml"
        },
        body: envelope);

    var rawXmlResponse = response.body;
    XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);

    var chekis = parsedXml.text;

    var apiVersion = double.parse(chekis);
    var deviceAppVersion = double.parse(appVersion);
    if (deviceAppVersion < apiVersion) {
      showUpdateDialog();
    } else {
      startTimer();
    }
  }

  void listenToNotificationStream(NotificationService notificationService) {
    notificationService.behaviorSubject.listen((payload) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  showUpdateDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Image.asset(
                  AppImagePath.splashImage,
                  width: 150,
                  height: 100,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: CustomText(
                  text: 'App Update Required!',
                  textColor: AppColors.defaultColor,
                  fontWeight: FontWeight.bold,
                  size: 18,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CustomText(
                    text:
                        'New version is available, please update now for exploring best features of ${Constants.alertAndCnfTitle.toUpperCase()}',
                    size: 15.0,
                    textColor: AppColors.defaultColor,
                    fontWeight: FontWeight.normal,
                    align: TextAlign.center,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Container(
                      height: size.width * 0.11,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: const CustomText(
                          text: 'Update',
                          size: 15.0,
                          textColor: AppColors.primaryColor,
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    StoreRedirect.redirect(
                      androidAppId: Constants.androidAppRateAndUpdate,
                      iOSAppId: Constants.iOSAppId,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultColor,
      body: Container(
        decoration: const BoxDecoration(
          // color:
          image: DecorationImage(
            image: AssetImage(AppImagePath.bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            AppImagePath.splashImage,
            scale: 4.5,
          ),
        ),
      ),
    );
  }

  void startTimer() {
    timer = Timer(const Duration(seconds: 3), navigateUser);
  }

  void navigateUser() {
    //Comment below line if without OTR
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    //UnComment below code with OTR

    // shared.getIsFirstTimeRegister().then((isFirstTime) {
    //   if (!isFirstTime) {
    //     Navigator.of(context).pushReplacementNamed(
    //       Login_Screen.routeName,
    //       arguments: const Login_Screen(
    //         isFromSplash: true,
    //       ),
    //     );
    //   } else {
    //     Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    //   }
    // });
  }
}
