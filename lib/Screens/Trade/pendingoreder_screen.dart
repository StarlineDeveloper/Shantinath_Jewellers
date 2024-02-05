import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Widgets/buildorderstatus.dart';

import '../../Constants/app_colors.dart';
import '../../Constants/notify_socket_update.dart';
import '../../Models/CommonRequestModel.dart';
import '../../Providers/liveRate_Provider.dart';
import '../../Widgets/custom_text.dart';

class PendingOrder_Screen extends StatefulWidget {
  Function? openOrder;

  PendingOrder_Screen({super.key, required this.openOrder});

  @override
  State<PendingOrder_Screen> createState() => _PendingOrder_ScreenState();
}

class _PendingOrder_ScreenState extends State<PendingOrder_Screen> {
  late LiveRateProvider _liverateProvider;
  List<OpenOrderElement> pendingOrdList = [];

  void initStreamControllers() {
    NotifySocketUpdate.controllerPending = StreamController.broadcast();
    NotifySocketUpdate.controllerPending!.stream.listen((event) {
      setState(() {
        pendingOrdList = _liverateProvider.getPendingOrder();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    pendingOrdList = _liverateProvider.getPendingOrder();
    initStreamControllers();
    debugPrint('pendingOrder');
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerPending!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pendingOrdList.isEmpty
        ? const Center(
            child: CustomText(
              text: 'Pending Order Not Available',
              textColor: AppColors.defaultColor,
              size: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )
        : ListView.builder(
            itemCount: pendingOrdList.length,
            itemBuilder: (builder, index) {
              return OrderStatus_Widget(
                  isEdit: true,
                  dataList: pendingOrdList[index],
                  openOrder: widget.openOrder,
                  update: null);
            },
          );
  }
}
