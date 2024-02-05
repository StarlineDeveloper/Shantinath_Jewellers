import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Providers/liveRate_Provider.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Constants/notify_socket_update.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/api_response.dart';

class OpenorderService {
  Future<APIResponse<String>> openOrdObj(
      String obj, BuildContext context) async {
    final provider = Provider.of<LiveRateProvider>(context, listen: false);

    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<GetOpenOrderDetails xmlns="http://tempuri.org/">',
      '<Obj>$obj</Obj>',
      '</GetOpenOrderDetails>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();
    // debugPrint(envelope);

    return await http
        .post(Uri.parse('${Constants.baseUrlTerminal}?op=GetOpenOrderDetails'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
            },
            body: envelope)
        .then((response) {
      if (response.statusCode == 200) {
        var rawXmlResponse = response.body;
        XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
        // debugPrint(parsedXml.text);
        String jsonData = parsedXml.text;
        Map<String, dynamic> data = jsonDecode(jsonData);
        if (data['ReturnCode'] == '400') {
          if (data['OpenOrder'] != []) {
            List<OpenOrderElement> openOrders = [];
            List<OpenOrderElement> requestOrders = [];
            List<OpenOrderElement> pendingOrders = [];
            List<dynamic> accountDetailsList = jsonDecode(data['OpenOrder']);
            for (var order in accountDetailsList) {
              String tradeType = order['TradeType'];
              String tradeMode = order['TradeMode'];
              OpenOrderElement openOrderElement = OpenOrderElement.fromJson(order);
              if ((tradeType == '1' || tradeType == '2') && tradeMode.trim() == 'M') {
                openOrders.add(openOrderElement);

              } else if ((tradeType == '1' || tradeType == '2') &&
                  tradeMode.trim() == 'R') {
                requestOrders.add(openOrderElement);

              } else if (tradeType == '3' || tradeType == '4') {
                pendingOrders.add(openOrderElement);

              }
            }
            provider.addOpenOrder(openOrders);
            provider.addRequestOrder(requestOrders);
            provider.addPendingOrder(pendingOrders);
            _addToControllerIfNotClosed(openOrders, NotifySocketUpdate.controllerOpen);
            _addToControllerIfNotClosed(requestOrders, NotifySocketUpdate.controllerOpen);
            _addToControllerIfNotClosed(pendingOrders, NotifySocketUpdate.controllerPending);
          }
        }

        if (data['Accountdetails'] != []) {
          return APIResponse<String>(data: data['Accountdetails']);
        }
        return APIResponse<String>(data: data['Accountdetails']);
      } else {
        return APIResponse<String>(
            isError: true, errorMessage: Constants.serverError);
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }

  static void _addToControllerIfNotClosed<T>(
      T data, StreamController<T>? controller) {
    if (controller != null && !controller.isClosed) {
      controller.sink.add(data);
    }
  }
}
