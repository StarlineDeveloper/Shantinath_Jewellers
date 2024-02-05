import 'package:intl/intl.dart';

class Constants {
  //Add clientId from web(custom.js)
  static const String clientId = "5";

  //Add baseUrl from web(custom.js)
  static const baseUrl =
      'https://starlinebuild.co.in/WebService/WebService.asmx';

  //Add baseUrlTerminal from web(custom.js)
  static const baseUrlTerminal =
      'https://starlinebuild.co.in/WebService/Terminal.asmx';

  //Add socketUrl from web(custom.js)
  static const socketUrl = 'https://starlinebuild.co.in:10001';

  //Add playstore link
  static const String androidAppStoreRedirect =
      "https://play.google.com/store/apps/details?id=com.shantinathjewellers&pli=1";

  //Add android package name
  static const String androidAppRateAndUpdate = "com.shantinathjewellers";

  //Add ios app id from app store(while creating app)
  static const String iOSAppId = "6476919269";

  //Replace ios app id at the end of url(while creating app)
  static const String iOSAppRedirect =
      "https://apps.apple.com/in/app/shantinath-jewellers/id6476919269";

  //Add prjName from web(custom.js)
  static const String projectName = 'shantinathjewellers';

  //same as project name
  static const String subscriberTopic = 'shantinathjewellers';

  // Add static
  static String alertAndCnfTitle = 'Shantinath Jewellers';

  // Leave it as it is
  static const String economicCalenderUrl =
      'https://www.mql5.com/en/economic-calendar/widget?mode=1&utm_source=www.pritamspot.com';
  static bool isLogin = false;
  static const noInternet = 'Please check internet connection...';
  static const serverError = 'Something went wrong...';
  static const noData = 'No Data Found...';
  static String startDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  static String endDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  static int loginId = 0;
  static String token = '';
  static String? fcmToken = '';
  static String loginName = '';
  static  String tradeType = '';
}
