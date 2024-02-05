import 'package:flutter/material.dart';
import 'package:terminal_demo/Routes/routes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Widgets/custom_text.dart';

class EconomicCalenderScreen extends StatefulWidget {
  static const String routeName = PageRoutes.economicCalenderScreen;

  const EconomicCalenderScreen({Key? key}) : super(key: key);

  @override
  State<EconomicCalenderScreen> createState() => _EconomicCalenderScreenState();
}

class _EconomicCalenderScreenState extends State<EconomicCalenderScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            } else {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(Constants.economicCalenderUrl));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return


    //   Expanded(
    //     child: Stack(
    //   children: [
    //     Visibility(
    //       visible: !isLoading,
    //       child: WebViewWidget(
    //         controller: _controller,
    //       ),
    //     ),
    //     Visibility(
    //       visible: isLoading,
    //       child: const Center(
    //         child: CircularProgressIndicator(
    //           color: AppColors.primaryColor,
    //           strokeWidth: 3,
    //         ),
    //       ),
    //     ),
    //   ],
    // ));


      Scaffold(
      // backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const CustomText(
          text: 'Economic Calendar',
          textColor: AppColors.defaultColor,
          size: 18.0,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.defaultColor,
          ),
        ),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body:
      Stack(
        children: [
          Visibility(
            visible: !isLoading,
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );

  }
}
