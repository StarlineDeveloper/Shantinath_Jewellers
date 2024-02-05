import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Widgets/buildorderstatus.dart';
import '../../Constants/app_colors.dart';
import '../../Constants/notify_socket_update.dart';
import '../../Models/CommonRequestModel.dart';
import '../../Providers/liveRate_Provider.dart';
import '../../Widgets/custom_text.dart';

class OpenOrder_Screen extends StatefulWidget {
  OpenOrder_Screen({super.key});

  @override
  State<OpenOrder_Screen> createState() => _OpenOrder_ScreenState();
}

class _OpenOrder_ScreenState extends State<OpenOrder_Screen> {
  late LiveRateProvider _liverateProvider;
  List<OpenOrderElement> openOrdList = [];

  void initStreamControllers() {
    NotifySocketUpdate.controllerOpen = StreamController.broadcast();
    NotifySocketUpdate.controllerOpen!.stream.listen((event) {
      openOrdList = _liverateProvider.getOpenOrder();
    });
  }

  @override
  void initState() {
    super.initState();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    openOrdList = _liverateProvider.getOpenOrder();
    initStreamControllers();

    debugPrint('openOrder');
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerOpen!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return openOrdList.isEmpty
        ? const Center(
            child: CustomText(
              text: 'Open Order Not Available',
              textColor: AppColors.defaultColor,
              size: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )
        : ListView.builder(
            itemCount: openOrdList.length,
            itemBuilder: (builder, index) {
              return OrderStatus_Widget(
                  isEdit: false,
                  dataList: openOrdList[index],
                  openOrder: null,
                  update: null);
            },
          );
  }
}
