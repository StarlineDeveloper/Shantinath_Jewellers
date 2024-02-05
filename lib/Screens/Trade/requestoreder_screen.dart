import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Widgets/buildorderstatus.dart';

import '../../Constants/app_colors.dart';
import '../../Constants/notify_socket_update.dart';
import '../../Models/CommonRequestModel.dart';
import '../../Providers/liveRate_Provider.dart';
import '../../Widgets/custom_text.dart';

class RequestOrder_Screen extends StatefulWidget {
  RequestOrder_Screen({super.key});

  @override
  State<RequestOrder_Screen> createState() => _RequestOrder_ScreenState();
}

class _RequestOrder_ScreenState extends State<RequestOrder_Screen> {
  late LiveRateProvider _liverateProvider;
  List<OpenOrderElement> reqOrdList = [];

  void initStreamControllers() {
    NotifySocketUpdate.controllerOpen = StreamController.broadcast();
    NotifySocketUpdate.controllerOpen!.stream.listen((event) {
      reqOrdList = _liverateProvider.getRequestOrder();
    });
  }

  @override
  void initState() {
    super.initState();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    reqOrdList = _liverateProvider.getRequestOrder();
    initStreamControllers();
    debugPrint('requestOrder');
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerOpen!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return reqOrdList.isEmpty
        ? const Center(
            child: CustomText(
              text: 'Request Order Not Available',
              textColor: AppColors.defaultColor,
              size: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )
        : ListView.builder(
            itemCount: reqOrdList.length,
            itemBuilder: (builder, index) {
              return OrderStatus_Widget(
                  isEdit: false, dataList: reqOrdList[index],openOrder: null,update: null);
            },
          );
  }
}
