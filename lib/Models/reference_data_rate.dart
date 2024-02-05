// To parse this JSON data, do
//
//     final referenceDataRate = referenceDataRateFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';


ReferenceDataRate referenceDataRateFromJson(String str) =>
    ReferenceDataRate.fromJson(json.decode(str));

String referenceDataRateToJson(ReferenceDataRate data) =>
    json.encode(data.toJson());

class ReferenceDataRate {
  ReferenceDataRate({
    this.name,
    this.symbol,
    this.bid,
    this.ask,
    this.high,
    this.low,
    this.time,
    this.askBGColor = AppColors.defaultColor,
    this.askTextColor = AppColors.textColor,
    this.bidBGColor = AppColors.defaultColor,
    this.bidTextColor = AppColors.textColor,
  });

  String? name;
  dynamic bid;
  dynamic ask;
  dynamic high;
  dynamic low;
  dynamic time;
  dynamic symbol;
  Color askBGColor;
  Color askTextColor;
  Color bidBGColor;
  Color bidTextColor;

  factory ReferenceDataRate.fromJson(Map<String, dynamic> json) =>
      ReferenceDataRate(
        name: json["Name"],
        symbol: json["symbol"],
        bid: json["Bid"],
        ask: json["Ask"],
        high: json["High"],
        low: json["Low"],
        time: json["Time"],
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "symbol": symbol,
        "Bid": bid,
        "Ask": ask,
        "High": high,
        "Low": low,
        "Time": time,
      };
}
