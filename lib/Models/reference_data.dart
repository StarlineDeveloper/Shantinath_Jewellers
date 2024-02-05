// To parse this JSON data, do
//
//     final referenceData = referenceDataFromJson(jsonString);

import 'dart:convert';

ReferenceData referenceDataFromJson(String str) =>
    ReferenceData.fromJson(json.decode(str));

String referenceDataToJson(ReferenceData data) => json.encode(data.toJson());

class ReferenceData {
  ReferenceData({
    this.referanceId,
    this.bullionId,
    this.source,
    this.symbolName,
    this.isDisplay,
    this.isDisplayWidget,
  });

  int? referanceId;
  int? bullionId;
  String? source;
  String? symbolName;
  bool? isDisplay;
  bool? isDisplayWidget;

  factory ReferenceData.fromJson(Map<String, dynamic> json) => ReferenceData(
        referanceId: json["Referance_Id"],
        bullionId: json["Bullion_Id"],
        source: json["Source"],
        symbolName: json["Symbol_Name"],
        isDisplay: json["IsDisplay"],
        isDisplayWidget: json["IsDisplayWidget"],
      );

  Map<String, dynamic> toJson() => {
        "Referance_Id": referanceId,
        "Bullion_Id": bullionId,
        "Source": source,
        "Symbol_Name": symbolName,
        "IsDisplay": isDisplay,
        "IsDisplayWidget": isDisplayWidget,
      };
}
