import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Functions.dart';

import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Models/api_response.dart';

class UpdatelimitService {
  Future<APIResponse<String>> updtLimitObj(
      String obj) async {

    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<UpdateLimitByDeal xmlns="http://tempuri.org/">',
      '<ObjOrder>$obj</ObjOrder>',
      '</UpdateLimitByDeal>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();
    debugPrint(envelope);

    return await http
        .post(Uri.parse('${Constants.baseUrlTerminal}?op=UpdateLimitByDeal'),
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
        if (data['ReturnCode'] == 'E511') {
          Functions.showToast(data['ReturnMsg']);
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
}
