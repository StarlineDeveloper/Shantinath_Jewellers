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
import '../../Services/deleteorder_service.dart';
import '../../Widgets/custom_text.dart';

class DeleteOrder_Screen extends StatefulWidget {
  DeleteOrder_Screen({super.key});

  @override
  State<DeleteOrder_Screen> createState() => _DeleteOrder_ScreenState();
}

class _DeleteOrder_ScreenState extends State<DeleteOrder_Screen> {
  late LiveRateProvider _liverateProvider;
  List<OpenOrderElement> deleteOrdList = [];
  DeleteorderService deleteorderService = DeleteorderService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    deleteOrdList = _liverateProvider.getDeleteOrder();
    initStreamControllers();

    callGetDeleteOrderDetailsApi();
    debugPrint('deleteOrder');
  }

  void initStreamControllers() {
    NotifySocketUpdate.controllerDelete = StreamController.broadcast();
    NotifySocketUpdate.controllerDelete!.stream.listen((event) {
      deleteOrdList = _liverateProvider.getDeleteOrder();
    });
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerDelete!.close();

    deleteOrdList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return deleteOrdList.isEmpty
        ? const Center(
            child: CustomText(
              text: 'Delete Order Not Available',
              textColor: AppColors.defaultColor,
              size: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )
        : ListView.builder(
            itemCount: deleteOrdList.length,
            itemBuilder: (builder, index) {
              return OrderStatus_Widget(
                  isEdit: false, dataList: deleteOrdList[index],openOrder: null,update: null);
            },
          );
  }

  void callGetDeleteOrderDetailsApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        var objVariable = openOrderReqToJson(OpenOrderRequest(
            loginid: Constants.loginId,
            firmname: Constants.projectName,
            clientId: int.parse(Constants.clientId),
            fromdate: Constants.startDate,
            todate: Constants.endDate));
        deleteorderService.delOrdObj(objVariable, context).then((response) {
          if (response.data != null) {
            // deleteOrdList = _liverateProvider.getDeleteOrder();

            // List<dynamic> accountDetailsList = jsonDecode(response.data!);
            // List<Accountdetails> accountDetails = accountDetailsList
            //     .map((item) => Accountdetails.fromJson(item))
            //     .toList();
            setState(() {
              // isLoading = false;
              deleteOrdList = _liverateProvider.getDeleteOrder();
              // firstAccountDetails =
              //     accountDetails.isNotEmpty ? accountDetails[0] : null;
            });
            debugPrint(response.data);
          } else {
            // setState(() {
            //   isLoading = false;
            // });
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
