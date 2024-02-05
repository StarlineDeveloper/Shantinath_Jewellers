import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import '../Models/api_response.dart';

class BankService {

  Future<APIResponse<String>> bankDet(int obj) async {
    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<BankDetail xmlns="http://tempuri.org/">',
      '<ClientId>$obj</ClientId>',
      '</BankDetail>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();
    // debugPrint(envelope);

    return await http
        .post(Uri.parse('${Constants.baseUrl}?op=BankDetail'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",},
            body: envelope)
        .then((response) {
      if (response.statusCode == 200) {
        var rawXmlResponse = response.body;
        XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
        // debugPrint(parsedXml.text);
        String jsonData = parsedXml.text;
        return APIResponse<String>(data: jsonData);
      } else {
        return APIResponse<String>(isError: true, errorMessage: Constants.serverError);
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }
}
