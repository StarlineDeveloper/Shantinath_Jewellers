import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Functions.dart';

import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Constants/notify_socket_update.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/api_response.dart';
import 'openorder_service.dart';

class DeletelimitService {

  Future<APIResponse<String>> delLimitObj(
      String obj) async {

    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<DeleteCloseOrder xmlns="http://tempuri.org/">',
      '<ObjOrder>$obj</ObjOrder>',
      '</DeleteCloseOrder>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();
    debugPrint(envelope);

    return await http
        .post(Uri.parse('${Constants.baseUrlTerminal}?op=DeleteCloseOrder'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
            },
            body: envelope)
        .then((response) {
      if (response.statusCode == 200) {
        var rawXmlResponse = response.body;
        XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
        debugPrint(parsedXml.text);
        String jsonData = parsedXml.text;
        Map<String, dynamic> data = jsonDecode(jsonData);
        if (data['ReturnCode'] == 'E512') {

          Functions.showToast(data['ReturnMsg']);

          // _addToControllerIfNotClosed(
          //     data['ReturnCode'], NotifySocketUpdate.controllerOpen);
        }else{
          Functions.showToast(data['ReturnMsg']);
        }
        return APIResponse<String>(data: data['ReturnCode']);


      } else {
        return APIResponse<String>(
            isError: true, errorMessage: Constants.serverError);
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }

  // static void _addToControllerIfNotClosed<T>(
  //     T data, StreamController<T>? controller) {
  //   if (controller != null && !controller.isClosed) {
  //     controller.sink.add(data);
  //   }
  // }
}
