// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

// import 'package:in_app_review/in_app_review.dart';
import 'package:marquee/marquee.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';

// import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:terminal_demo/Screens/bankdetails_screen.dart';
import 'package:terminal_demo/Screens/contactus_screen.dart';
import 'package:terminal_demo/Screens/liverate_screen.dart';
import 'package:terminal_demo/Screens/login_screen.dart';
import 'package:terminal_demo/Screens/profile_screen.dart';
import 'package:terminal_demo/Screens/trade_screen.dart';
import 'package:terminal_demo/Screens/update_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/client_header.dart';
import '../Models/loginData.dart';
import '../Popup/alert_confirm_popup.dart';
import '../Providers/liveRate_Provider.dart';
import '../Routes/page_route.dart';
import '../Services/notification_service.dart';
import '../Services/openorder_service.dart';
import '../Services/socket_service.dart';
import '../Utils/shared.dart';
import '../Widgets/custom_text.dart';

// import 'coin_screen.dart';
import 'economiccalender_scree.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = PageRoutes.homescreen;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Future<String> permissionStatusFuture;
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  int selectedIndex = 0;
  double left = 10;
  double bottom1 = 100;
  double right = 10;
  double bottom2 = 100;
  late LiveRateProvider _liverateProvider;
  ClientHeaderData clientHeaderData = ClientHeaderData();
  bool isBannerVisible = false;
  bool isInternetConnected = false;
  bool isAddVisible = true;
  List<Widget> widgetsList = [
    const LiveRateScreen(),
    const Trade_Screen(),
    const Update_Screen(),
    // const Coin_Screen(),
    const ContactUs_Screen(),
    const BankDetail_Screen(),
    // const EconomicCalenderScreen(),
    // const ProfileScreen()
  ];
  final AdvancedDrawerController _advancedDrawerController =
      AdvancedDrawerController();
  DateTime? currentBackPressTime;
  DateTime now = DateTime.now();
  List<String> bookingNumber = [];
  bool isLoading = false;
  bool isDiscoveredOverlay = false;
  Shared shared = Shared();
  OpenorderService openOrderService = OpenorderService();
  late LoginData userData;
  late NotificationService notificationService;
  late ProfileDetails accountDetails;
  int tapCount = 0;
  int lastTap = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void checkIsLogin() async {
    String loginData = await shared.getLoginData();
    shared.getIsLogin().then((loginStatus) {
      setState(() {
        Constants.isLogin = loginStatus;
      });
    });
    if (loginData.isNotEmpty) {
      userData = LoginData.getJson(json.decode(loginData));
      Constants.loginId = userData.loginId;
      Constants.token = userData.token;
      // debugPrint('L-------O-------G-------I-------N------DATA');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    notificationService = NotificationService();
    permissionStatusFuture = getCheckNotificationPermStatus();

    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    // checkDiscovered();
    notificationService.initializePlatformNotifications();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);

    NotificationPermissions.requestNotificationPermissions(
            iosSettings: const NotificationSettingsIos(
                sound: true, badge: true, alert: true))
        .then((_) {
      // when finished, check the permission status
      setState(() {
        permissionStatusFuture = getCheckNotificationPermStatus();
      });
    });

    loadLiveData();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('${message.data}');
      debugPrint('${message.senderId}');
      if (message.data['bit'] == '1') {
        showNotificationAlertDialog(
          message.data['title'],
          message.data['body'],
          message.data['bit'],
        );
      }

      if (!Platform.isIOS) {
        NotificationService().showLocalNotification(
            body: message.data['title'],
            title: message.data['body'],
            payload: 'Hello');
      }
    });
    // listenToNotificationStream();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      debugPrint('Opened');
      if (message != null) {
        if (message.data['bit'] == '1') {
          onItemTapped(2);
        } else {
          onItemTapped(0);
        }
      }
    });
    //on open notification while in kill mode
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (message.data['bit'] == '1') {
          onItemTapped(2);
        } else {
          onItemTapped(0);
        }
      }
    });
    checkIsLogin();

    // callGetOpenOrderDetailsApi();
    initStreamControllers();
    initConnectivityListener();
    // checkForInAppReview();
  }

  void initStreamControllers() {
    NotifySocketUpdate.controllerHome = StreamController.broadcast();
    NotifySocketUpdate.controllerOrderDetails = StreamController.broadcast();
    NotifySocketUpdate.controllerAccountDetails = StreamController();

    NotifySocketUpdate.controllerHome!.stream.listen((event) {
      loadLiveData();
    });
    NotifySocketUpdate.controllerOrderDetails!.stream.listen((event) {
      setState(() {
        if (Constants.isLogin) {
          if (Constants.tradeType.isNotEmpty) {
            if (Constants.tradeType == '1' ||
                Constants.tradeType == '2' ||
                Constants.tradeType == '3' ||
                Constants.tradeType == '4') {
              onItemTapped(1);

              Future.delayed(const Duration(seconds: 1), () {
                Constants.tradeType = '';
              });
            }
          }
        }
        // onItemTapped(1);
      });
    });
  }

  void initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((connection) {
      if (connection == ConnectivityResult.none) {
        setState(() {
          isInternetConnected = false;
        });
      } else {
        setState(() {
          isInternetConnected = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<String> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        case PermissionStatus.unknown:
          return permUnknown;
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return permUnknown;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        debugPrint('appLifeCycleState resumed');
        setState(() {
          permissionStatusFuture = getCheckNotificationPermStatus();
        });
        // handleResumedState();
        break;
      case AppLifecycleState.paused:
        debugPrint('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        // shared.setisAddBannerVisible(false);
        // bool isAddVisible
        debugPrint('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  loadLiveData() async {
    setState(() {
      clientHeaderData = _liverateProvider.getClientHeaderData();
    });

    _liverateProvider.bannerImage!.trim().isNotEmpty
        ? isAddVisible
            ? setState(() {
                isBannerVisible = true;
                isAddVisible = false;
              })
            : null
        : setState(() {
            isAddVisible = true;
          });
    if (clientHeaderData.bookingNo1 != null &&
        clientHeaderData.bookingNo1!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo1!);
    }
    if (clientHeaderData.bookingNo2 != null &&
        clientHeaderData.bookingNo2!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo2!);
    }
    if (clientHeaderData.bookingNo3 != null &&
        clientHeaderData.bookingNo3!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo3!);
    }
    if (clientHeaderData.bookingNo4 != null &&
        clientHeaderData.bookingNo4!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo4!);
    }
    if (clientHeaderData.bookingNo5 != null &&
        clientHeaderData.bookingNo5!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo5!);
    }
    if (clientHeaderData.bookingNo6 != null &&
        clientHeaderData.bookingNo6!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo6!);
    }
    if (clientHeaderData.bookingNo7 != null &&
        clientHeaderData.bookingNo7!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.bookingNo7!);
    }
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerHome!.close();
    NotifySocketUpdate.controllerOrderDetails!.close();
    NotifySocketUpdate.controllerAccountDetails!.close();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
    checkIsLogin();
  }

  closeDrawer() {
    if (_scaffoldKey.currentState != null) {
      _advancedDrawerController.hideDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AdvancedDrawer(
      // backdropColor: AppColor.defaultColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 250),
      animateChildDecoration: true,
      rtlOpening: false,
      openRatio: 0.55,
      disabledGestures: true,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.secondaryColor,
            offset: Offset(1.0, 0.0),
            blurRadius: 10.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      drawer: buildAppDrawer(),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Scaffold(
            // backgroundColor: AppColors.bg,
            // onDrawerChanged: (isOpened) {
            //   checkIsLogin();
            // },
            key: _scaffoldKey,
            // backgroundColor: AppColor.defaultColor,
            appBar: AppBar(
              // systemOverlayStyle:
              //     SystemUiOverlayStyle(statusBarColor: AppColor.primaryColor),
              backgroundColor: AppColors.primaryColor,
              automaticallyImplyLeading: false,
              toolbarHeight: 60,
              // elevation: 5.0,
              iconTheme: const IconThemeData(color: AppColors.primaryColor),
              title: Image.asset(
                AppImagePath.headerLogo,
                scale: 8,
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: _handleMenuButtonPressed,
                icon: ValueListenableBuilder<AdvancedDrawerValue>(
                  valueListenable: _advancedDrawerController,
                  builder: (_, value, __) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        value.visible
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                        key: ValueKey<bool>(value.visible),
                        color: AppColors.defaultColor,
                        size: 25.0,
                      ),
                    );
                  },
                ),
              ),
            ),
            // drawer: buildAppDrawer(),
            body: Container(
              // color: AppColors.black,
              decoration: BoxDecoration(
                // color:
                image: DecorationImage(
                  image: AssetImage(AppImagePath.bg),
                  fit: BoxFit.cover,
                ),
              ),
              child: buildBody(size),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.defaultColor,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: AppColors.secondaryTextColor,
              selectedLabelStyle: TextStyle(
                fontSize: 15,
              ),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: selectedIndex == 0
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor,
                    size: 24,
                  ),
                  label: 'Live Rate',
                  backgroundColor: AppColors.primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.post_add_rounded,
                    color: selectedIndex == 1
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor,
                    size: 24,
                  ),
                  label: 'Trade',
                  backgroundColor: AppColors.primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notification_add_rounded,
                    color: selectedIndex == 2
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor,
                    size: 24,
                  ),
                  label: 'Updates',
                  backgroundColor: AppColors.primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.contact_phone_rounded,
                    color: selectedIndex == 3
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor,
                    size: 24,
                  ),
                  label: 'Contact',
                  backgroundColor: AppColors.primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.account_balance_rounded,
                    color: selectedIndex == 4
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor,
                    size: 24,
                  ),
                  label: 'Bank',
                  backgroundColor: AppColors.primaryColor,
                ),
              ],
              onTap: (index) {
                onItemTapped(index);
              },
            ),
          ),
          Visibility(
            visible: isBannerVisible,
            child: Container(
              color: AppColors.textColor.withOpacity(.7),
              child: Center(
                child: Stack(
                  // mainAxisSize: MainAxisSize.max,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Center(
                      child: Image.network(
                        _liverateProvider.bannerImage!.trim(),
                        height: size.height * .7,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: size.width * .6,
                          // margin: const EdgeInsets.only(bottom: .01),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              padding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const CustomText(
                              text: 'SKIP',
                              size: 16.0,
                              textColor: AppColors.defaultColor,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              setState(() {
                                isBannerVisible = false;
                                isAddVisible = false;
                                // shared.setisAddBannerVisible(false);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: left,
            bottom: bottom1,
            child: GestureDetector(
              onTap: () {
                showCallDialog();
              },
              onPanUpdate: (dragDetails) {
                setState(() {
                  left += dragDetails.delta.dx;
                  bottom1 -= dragDetails.delta.dy;
                });
              },
              child: Container(
                // heroTag: 'call1',
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // color: AppColors.secondaryColor,
                    gradient: AppColors.primaryGradient),
                child: const Icon(
                  Icons.call,
                  color: AppColors.defaultColor,
                  size: 30.0,
                ),
              ),
            ),
          ),
          Positioned(
            right: right,
            bottom: bottom2,
            child: GestureDetector(
              onTap: () {
                openWhatsapp();
              },
              onPanUpdate: (dragDetails) {
                setState(() {
                  right -= dragDetails.delta.dx;
                  bottom2 -= dragDetails.delta.dy;
                });
              },
              child: Container(
                // heroTag: 'call1',
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: AppColors.primaryGradient

                    // color: AppColors.secondaryColor,
                    ),
                child: Image.asset(
                  AppImagePath.whatsapp,
                  scale: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildAppDrawer() {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            height: 160.0,
            alignment: Alignment.center,
            child: Stack(
              children: [
                const Center(
                  child: Image(
                    image: AssetImage(AppImagePath.drawerLogo),
                    height: 130.0,
                    width: 130.0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: Constants.isLogin ? true : false,
                    child: CustomText(
                      text: Constants.isLogin && Constants.loginName.isNotEmpty
                          ? Constants.loginName
                          : '',
                      textColor: AppColors.defaultColor,
                      size: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            // height: 10.0,
            color: AppColors.primaryColor,
            thickness: .5,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Column(
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 0
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                            closeDrawer();
                            // Navigator.of(context).pop();
                          },
                          leading: Icon(
                            Icons.bar_chart_rounded,
                            color: selectedIndex == 0
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Live Rate',
                              size: 16,
                              textColor: selectedIndex == 0
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 1
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedIndex = 1;
                            });
                            closeDrawer();

                            // Navigator.of(context).pop();
                          },
                          leading: Icon(
                            Icons.post_add_rounded,
                            color: selectedIndex == 1
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Trade',
                              size: 16,
                              textColor: selectedIndex == 1
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 2
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedIndex = 2;
                            });
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.notification_add_rounded,
                            color: selectedIndex == 2
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Updates',
                              size: 16,
                              textColor: selectedIndex == 2
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)
                          // Text(
                          //   textScaleFactor: 1.0,
                          //   'Updates',
                          //   style: TextStyle(
                          //     color: selectedIndex == 2
                          //         ? AppColor.primaryColor
                          //         : AppColor.primaryColor,
                          //     fontSize: 16.0,
                          //   ),
                          // ),
                          ),
                    ),
                    // Container(
                    //   decoration: ShapeDecoration(
                    //     color: selectedIndex == 3
                    //         ? AppColors.primaryLightColor
                    //         : Colors.transparent,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30.0),
                    //     ),
                    //     // shadows: const [AppColor.boxShadow],
                    //   ),
                    //   child: ListTile(
                    //       onTap: () {
                    //         setState(() {
                    //           selectedIndex = 3;
                    //         });
                    //         closeDrawer();
                    //         // Navigator.of(context)
                    //         //     .pushNamed(Coin_Screen.routeName);
                    //       },
                    //       leading: Icon(
                    //         Icons.currency_bitcoin_rounded,
                    //         color: selectedIndex == 3
                    //             ? AppColors.primaryColor
                    //             : AppColors.primaryColor,
                    //         size: 24,
                    //       ),
                    //       title: CustomText(
                    //           text: 'Coins',
                    //           size: 16,
                    //           textColor: selectedIndex == 3
                    //               ? AppColors.primaryColor
                    //               : AppColors.primaryColor,
                    //           fontWeight: FontWeight.normal)),
                    // ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 3
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedIndex = 3;
                            });
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.contact_phone_rounded,
                            color: selectedIndex == 3
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Contact Us',
                              size: 16,
                              textColor: selectedIndex == 3
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 4
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedIndex = 4;
                            });
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.account_balance_rounded,
                            color: selectedIndex == 4
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Bank Details',
                              size: 16,
                              textColor: selectedIndex == 4
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 6
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          onTap: () {
                            // setState(() {
                            //   selectedIndex = 6;
                            // });
                            // closeDrawer();
                            Navigator.of(context)
                                .pushNamed(EconomicCalenderScreen.routeName);
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.calendar_month_rounded,
                            color: selectedIndex == 6
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Eco-Calender',
                              size: 16,
                              textColor: selectedIndex == 6
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 7
                            ? AppColors.primaryLightColor
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //  shadows: const [AppColor.boxShadow],
                      ),
                      child: Visibility(
                        visible: Constants.isLogin,
                        child: ListTile(
                            onTap: () {
                              // setState(() {
                              //   selectedIndex = 7;
                              // });

                              // closeDrawer();
                              Navigator.of(context)
                                  .pushNamed(ProfileScreen.routeName);
                              closeDrawer();
                            },
                            leading: Icon(
                              Icons.file_copy_rounded,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                            title: CustomText(
                                text: 'Profile',
                                size: 16,
                                textColor: AppColors.primaryColor,
                                fontWeight: FontWeight.normal)),
                      ),
                    ),
                    ListTile(
                        onTap: () async {
                          Platform.isIOS
                              ? Share.share(Constants.iOSAppRedirect)
                              : Share.share(Constants.androidAppStoreRedirect);
                        },
                        leading: Icon(
                          Icons.share_sharp,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        title: CustomText(
                            text: 'Share',
                            size: 16,
                            textColor: AppColors.primaryColor,
                            fontWeight: FontWeight.normal)),
                    ListTile(
                        onTap: () {
                          StoreRedirect.redirect(
                            androidAppId: Constants.androidAppRateAndUpdate,
                            iOSAppId: Constants.iOSAppId,
                          );
                          closeDrawer();
                        },
                        leading: Icon(
                          Icons.star_rate_rounded,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        title: CustomText(
                            text: 'Rate App',
                            size: 16,
                            textColor: AppColors.primaryColor,
                            fontWeight: FontWeight.normal)),
                    Visibility(
                      visible: Constants.isLogin,
                      child: ListTile(
                          onTap: () {
                            openLogoutPopup();
                          },
                          leading: Icon(
                            Icons.logout_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Logout',
                              size: 16,
                              textColor: AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Visibility(
                      visible: !Constants.isLogin,
                      child: ListTile(
                          onTap: () {
                            closeDrawer();
                            Navigator.of(context).pushNamed(
                              Login_Screen.routeName,
                              arguments: const Login_Screen(
                                isFromSplash: false,
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.login_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Login',
                              size: 16,
                              textColor: AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  openLogoutPopup() {
    return DialogUtil.showConfirmDialog(context,
        title: Constants.alertAndCnfTitle,
        content: 'Are you sure you want to logout?',
        okBtnText: 'Logout',
        cancelBtnText: 'Cancel',
        okBtnFunctionConfirm: onLogout,
        isVisible: false);
  }

  onLogout() {
    Navigator.of(context).pop();

    shared.clear();
    if (selectedIndex == 0) {
      Constants.isLogin = false;
      closeDrawer();
      // Navigator.of(context).pop();
    }
    setState(() {
      onItemTapped(0);
      selectedIndex == 0;
      closeDrawer();
      // Navigator.of(context).pop();
    });
  }

  buildBody(Size size) {
    return WillPopScope(
      onWillPop: () {
        DialogUtil.showConfirmDialog(context,
            title: Constants.alertAndCnfTitle,
            content: 'Are you sure you want to exit app?',
            okBtnText: 'Exit',
            cancelBtnText: 'Cancel',
            okBtnFunctionConfirm: onExit,
            isVisible: false);
        return Future.value(false);
      },
      child: Stack(
        children: [
          Column(
            children: [
              Visibility(
                visible: clientHeaderData.marquee != null &&
                    clientHeaderData.marquee!.isNotEmpty,
                child: Container(
                  height: 22.0,
                  decoration: BoxDecoration(
                      gradient: AppColors
                          .primaryGradient), // color: AppColors.primaryColor,
                  child: Marquee(
                    textScaleFactor: 1.0,
                    text: clientHeaderData.marquee == null
                        ? 'No Marquee Found'
                        : clientHeaderData.marquee!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 400.0,
                    velocity: 50.0,
                    pauseAfterRound: const Duration(milliseconds: 10),
                    startPadding: 10.0,
                    accelerationDuration: const Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: const Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),
              widgetsList.elementAt(selectedIndex),
              Visibility(
                visible: clientHeaderData.marquee2 != null &&
                    clientHeaderData.marquee2!.isNotEmpty,
                child: Container(
                  height: 22.0,
                  decoration:
                      BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Marquee(
                    textScaleFactor: 1.0,
                    text: clientHeaderData.marquee != null
                        ? clientHeaderData.marquee2!
                        : 'No Marquee Found',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 400.0,
                    velocity: 50.0,
                    pauseAfterRound: const Duration(milliseconds: 10),
                    startPadding: 10.0,
                    accelerationDuration: const Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: const Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),
              // SizedBox(height: 5,)
              // Divider(
              //   height: 1.0,
              //   color: AppColors.defaultColor,
              // )
            ],
          ),
          Visibility(
            visible: !isInternetConnected,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImagePath.nointernet),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        turnOnInternet();
                      },
                      child: Container(
                        height: 45.0,
                        width: (size.width) - 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          text: 'Try Again',
                          size: 15.0,
                          fontWeight: FontWeight.bold,
                          textColor: AppColors.defaultColor,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> callGetOpenOrderDetailsApi() async {
    String loginData = await shared.getLoginData();
    shared.getIsLogin().then(
      (loginStatus) {
        if (loginStatus) {
          setState(() {
            userData = LoginData.getJson(json.decode(loginData));
            Constants.loginId = userData.loginId;
            Constants.token = userData.token;
            if (loginData.isNotEmpty) {
              userData = LoginData.getJson(json.decode(loginData));
              Constants.loginId = userData.loginId;
              Constants.token = userData.token;
              Functions.checkConnectivity().then((isConnected) {
                if (isConnected) {
                  var objVariable = openOrderReqToJson(OpenOrderRequest(
                      loginid: userData.loginId,
                      firmname: Constants.projectName,
                      clientId: int.parse(Constants.clientId),
                      fromdate: Constants.startDate,
                      todate: Constants.endDate));
                  openOrderService
                      .openOrdObj(objVariable, context)
                      .then((response) {
                    if (response.data != null) {
                      // List<dynamic> accountDetailsList = jsonDecode(response.data!);
                      // List<Accountdetails> accountDetails = accountDetailsList
                      //     .map((item) => Accountdetails.fromJson(item))
                      //     .toList();
                      // setState(() {
                      //   isLoading = false;
                      //   firstAccountDetails =
                      //   accountDetails.isNotEmpty ? accountDetails[0] : null;
                      // });
                      // debugPrint('ACC-------DETAIL------List--${accountDetails.length}');
                    } else {
                      // setState(() {
                      //   isLoading = false;
                      // });
                      // Functions.showToast(Constants.noData);
                    }
                  });
                } else {
                  // setState(() {
                  //   isLoading = false;
                  // });
                  // Functions.showToast(Constants.noInternet);
                }
              });
              // debugPrint('L-------O-------G-------I-------N------DATA');
            }
          });
        }
      },
    );
  }

  showNotificationAlertDialog(String title, String body, String bit) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              // color: AppColor.primaryColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: size.width * 0.15,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Image(
                      image: AssetImage(AppImagePath.headerLogo),
                      // height: 50.0,
                      // width: 50.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Divider(
                    thickness: 1,
                    color: AppColors.secondaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    text: title,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primaryColor,
                    size: 15.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    text: body,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.textColor,
                    size: 15.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Container(
                      height: size.width * 0.11,
                      decoration: BoxDecoration(
                        // color: AppColors.primaryColor,
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        text: 'Ok',
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primaryColor,
                        size: 15.0,
                      ),
                    ),
                    onTap: () {
                      onNotificationClick(bit);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  onNotificationClick(String bit) {
    if (bit == '1') {
      onItemTapped(2);
    } else {
      onItemTapped(0);
    }
    Navigator.of(context).pop();
  }

  showCallDialog() {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          actions: [
            Visibility(
              visible: (clientHeaderData.bookingNo1 == null ||
                          clientHeaderData.bookingNo1!.isEmpty) &&
                      (clientHeaderData.bookingNo2 == null ||
                          clientHeaderData.bookingNo2!.isEmpty) &&
                      (clientHeaderData.bookingNo3 == null ||
                          clientHeaderData.bookingNo3!.isEmpty) &&
                      (clientHeaderData.bookingNo4 == null ||
                          clientHeaderData.bookingNo4!.isEmpty) &&
                      (clientHeaderData.bookingNo5 == null ||
                          clientHeaderData.bookingNo5!.isEmpty) &&
                      (clientHeaderData.bookingNo6 == null ||
                          clientHeaderData.bookingNo6!.isEmpty) &&
                      (clientHeaderData.bookingNo7 == null ||
                          clientHeaderData.bookingNo7!.isEmpty)
                  ? false
                  : true,
              child: Container(
                width: MediaQuery.of(context).size.width * 100,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(
                    color: AppColors.primaryColor,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 100,
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(color: Colors.transparent),
                              gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor,
                                  ],
                                  begin: FractionalOffset(0.0, 1.0),
                                  end: FractionalOffset(1.0, 0.0),
                                  stops: [0.0, 2.0],
                                  tileMode: TileMode.clamp),
                            ),
                            padding: const EdgeInsets.all(7),
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              children: const <Widget>[
                                Icon(
                                  Icons.mobile_screen_share_rounded,
                                  color: AppColors.defaultColor,
                                  size: 30.0,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            width: MediaQuery.of(context).size.width * 100,
                            child: CustomText(
                                text: 'BOOKING NUMBER',
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.textColor,
                                size: 16.0,
                                align: TextAlign.center),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo1 == null ||
                                    clientHeaderData.bookingNo1!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo1!)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.bookingNo1!,
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo2 == null ||
                                    clientHeaderData.bookingNo2!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo2!)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.bookingNo2!,
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo3 == null ||
                                    clientHeaderData.bookingNo3!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo3!)),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * 100,
                                  child: CustomText(
                                      text: clientHeaderData.bookingNo3!,
                                      fontWeight: FontWeight.normal,
                                      textColor: AppColors.textColor,
                                      size: 16.0,
                                      align: TextAlign.center)),
                            ),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo4 == null ||
                                    clientHeaderData.bookingNo4!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo4!)),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * 100,
                                  child: CustomText(
                                      text: clientHeaderData.bookingNo4!,
                                      fontWeight: FontWeight.normal,
                                      textColor: AppColors.textColor,
                                      size: 16.0,
                                      align: TextAlign.center)),
                            ),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo5 == null ||
                                    clientHeaderData.bookingNo5!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo5!)),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * 100,
                                  child: CustomText(
                                      text: clientHeaderData.bookingNo5!,
                                      fontWeight: FontWeight.normal,
                                      textColor: AppColors.textColor,
                                      size: 16.0,
                                      align: TextAlign.center)),
                            ),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo6 == null ||
                                    clientHeaderData.bookingNo6!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo6!)),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * 100,
                                  child: CustomText(
                                      text: clientHeaderData.bookingNo6!,
                                      fontWeight: FontWeight.normal,
                                      textColor: AppColors.textColor,
                                      size: 16.0,
                                      align: TextAlign.center)),
                            ),
                          ),
                          Visibility(
                            visible: clientHeaderData.bookingNo7 == null ||
                                    clientHeaderData.bookingNo7!.isEmpty
                                ? false
                                : true,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri(
                                      scheme: 'tel',
                                      path: Functions.alphaNum(
                                          clientHeaderData.bookingNo7!)),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * 100,
                                  child: CustomText(
                                      text: clientHeaderData.bookingNo7!,
                                      fontWeight: FontWeight.normal,
                                      textColor: AppColors.textColor,
                                      size: 16.0,
                                      align: TextAlign.center)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> openWhatsapp() async {
    var whatsapp = "+91${clientHeaderData.whatsappNo1}";
    var whatsappUrlAndroid = "whatsapp://send?phone=$whatsapp&text=''";
    // var whatsappUrlIOS = "https://wa.me/$whatsapp?text=''}";
    var whatsappUrlIOS = "whatsapp://wa.me/$whatsapp/?text=";
    var urlIOS = Uri.parse(whatsappUrlIOS);
    var urlAndroid = Uri.parse(whatsappUrlAndroid);
    if (Platform.isIOS) {
      launchUrl(urlIOS).then((isLaunched) {
        if (isLaunched) {
          // Functions.showToast('Whatsapp Launched');
        } else {
          Functions.showToast('Whatsapp not Installed');
        }
      }).catchError(
        (exception) {
          Functions.showToast('Whatsapp not Found');
        },
      );
    }

    if (Platform.isAndroid) {
      launchUrl(urlAndroid).then((isLaunched) {
        if (isLaunched) {
          // Functions.showToast('Whatsapp Launched');
        } else {
          Functions.showToast('Whatsapp not Installed');
        }
      }).catchError((exception) {
        Functions.showToast('Whatsapp not Found');
      });
    }
  }

  void handleResumedState() async {
    try {
      await SocketService.getLiveRateData(context);
    } catch (error) {
      debugPrint('Error in getLiveRateData: $error');
    }
  }

  checkDiscovered() {
    shared.getIsDiscoverd().then((isDiscovered) {
      if (!isDiscovered) {
        isDiscoveredOverlay = true;
      } else {
        isDiscoveredOverlay = false;
      }
    });
  }

  void loadProfileData() {
    setState(() {
      accountDetails = _liverateProvider.getAccountData();
    });
  }

  onExit() {
    return exit(0);
  }

  void handleTap() {
    const int tripleClickDuration = 800; // Adjust as needed
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastTap < tripleClickDuration) {
      tapCount++;
    } else {
      tapCount = 1;
    }

    if (tapCount == 3) {
      // Perform the task when triple click occurs
      Navigator.of(context)
          .pushNamed(
        Login_Screen.routeName,
        arguments: const Login_Screen(
          isFromSplash: false,
        ),
      )
          .then((_) {
        checkIsLogin();
      });
      debugPrint("Triple click!");
      // Reset tap count after performing the task
      tapCount = 0;
    }

    lastTap = now;
  }

  // Future<void> checkForInAppReview() async {
  //   final InAppReview _inAppReview = InAppReview.instance;

  //   if (await _inAppReview.isAvailable()) {
  //     _inAppReview.requestReview();
  //     // _inAppReview.openStoreListing(appStoreId: Constants.iOSAppId, microsoftStoreId: Constants.androidAppRateAndUpdate);
  //   }
  // }

  void turnOnInternet() {
    var shared = OpenSettingsPlus.shared;
    // switch (shared.runtimeType) {
    //   case OpenSettingsPlusAndroid:
    //     (shared as OpenSettingsPlusAndroid).wifi();
    //     break;
    //   case OpenSettingsPlusIOS:
    //     (shared as OpenSettingsPlusIOS).wifi();
    //     break;
    //   default:
    //     throw Exception('Platform not supported');
    // }
    Platform.isAndroid
        ? AppSettings.openAppSettingsPanel(
            AppSettingsPanelType.internetConnectivity)
        : (shared as OpenSettingsPlusIOS).settings();
  }
}
