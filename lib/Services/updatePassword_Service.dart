import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Services/socket_service.dart';

import 'package:terminal_demo/Utils/shared.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Models/loginData.dart';
import '../Models/api_response.dart';

class UpdatePasswordService {

  Future<APIResponse<Object>> updatePass(int clientId,int loginId,String password,BuildContext context) async {
    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<UpdatePassword xmlns="http://tempuri.org/">',
      '<ClientId>$clientId</ClientId>',
      '<loginid>$loginId</loginid>',
      '<Password>$password</Password>',
      '</UpdatePassword>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();

    return await http
        .post(Uri.parse('${Constants.baseUrlTerminal}?op=UpdatePassword'),
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
        // Map<String, dynamic> data = jsonDecode(jsonData);
        // if (data['ReturnCode'] == '200') {
        //   return APIResponse<String>(data: data['ReturnCode']);
        // }
        return APIResponse<String>(data: jsonData);
      } else {
        return APIResponse<String>(
            isError: true, errorMessage: Constants.serverError);
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }
}
