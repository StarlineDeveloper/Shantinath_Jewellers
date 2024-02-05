import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Widgets/buildorderstatus.dart';

import '../../Constants/app_colors.dart';
import '../../Constants/constant.dart';
import '../../Constants/notify_socket_update.dart';
import '../../Functions.dart';
import '../../Models/CommonRequestModel.dart';
import '../../Providers/liveRate_Provider.dart';
import '../../Services/closeorder_service.dart';
import '../../Widgets/custom_text.dart';

class CloseOrder_Screen extends StatefulWidget {
  CloseOrder_Screen({super.key});

  @override
  State<CloseOrder_Screen> createState() => _CloseOrder_ScreenState();
}

class _CloseOrder_ScreenState extends State<CloseOrder_Screen> {
  late LiveRateProvider _liverateProvider;
  List<OpenOrderElement> closeOrdList = [];
  CloseorderService closeorderService = CloseorderService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    closeOrdList = _liverateProvider.getCloseOrder();
    initStreamControllers();
    // callGetCloseOrderDetailsApi();
    debugPrint('CloseOrder');
  }

  void initStreamControllers() {
    NotifySocketUpdate.controllerClose = StreamController.broadcast();
    NotifySocketUpdate.controllerClose!.stream.listen((event) {
      closeOrdList = _liverateProvider.getCloseOrder();
    });
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerClose!.close();

    closeOrdList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return closeOrdList.isEmpty
        ? const Center(
            child: CustomText(
              text: 'Close Order Not Available',
              textColor: AppColors.defaultColor,
              size: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )
        : ListView.builder(
            itemCount: closeOrdList.length,
            itemBuilder: (builder, index) {
              return OrderStatus_Widget(
                  isEdit: false, dataList: closeOrdList[index],openOrder: null,update: null);
            },
          );
  }

  void callGetCloseOrderDetailsApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        var objVariable = openOrderReqToJson(OpenOrderRequest(
            loginid: Constants.loginId,
            firmname: Constants.projectName,
            clientId: int.parse(Constants.clientId),
            fromdate: Constants.startDate,
            todate: Constants.endDate));
        closeorderService.closeOrdObj(objVariable, context).then((response) {
          if (response.data != null) {
            // List<dynamic> accountDetailsList = jsonDecode(response.data!);
            // List<Accountdetails> accountDetails = accountDetailsList
            //     .map((item) => Accountdetails.fromJson(item))
            //     .toList();
            setState(() {
              // isLoading = false;
              closeOrdList = _liverateProvider.getCloseOrder();
              // firstAccountDetails =
              //     accountDetails.isNotEmpty ? accountDetails[0] : null;
            });
            debugPrint(response.data);
          } else {
            Functions.showToast(Constants.noData);
          }
        });
      } else {
        // setState(() {
        //   isLoading = false;
        // });
        Functions.showToast(Constants.noInternet);
      }
    });
  }
}
