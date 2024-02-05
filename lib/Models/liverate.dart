// To parse this JSON data, do
//
//     final liverate = liverateFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';

Liverate liverateFromJson(String str) => Liverate.fromJson(json.decode(str));

String liverateToJson(Liverate data) => json.encode(data.toJson());

class Liverate {
  Liverate({
    this.id,
    this.name,
    this.src,
    this.usr,
    this.isView,
    this.isTerminal,
    this.type,
    this.time,
    this.bid,
    this.ask,
    this.high,
    this.low,
    this.askBGColor = AppColors.defaultColor,
    this.askTextColor = AppColors.textColor,
    this.bidBGColor = AppColors.defaultColor,
    this.bidTextColor = AppColors.textColor,
    this.askTradeBGColor = AppColors.primaryColor,
    this.askTradeTextColor = AppColors.textColor,
    this.bidTradeBGColor = AppColors.primaryColor,
    this.bidTradeTextColor = AppColors.textColor,
  });

  dynamic id;
  String? name;
  String? src;
  String? usr;
  bool? isView;
  bool? isTerminal;
  String? type;
  String? time;
  dynamic bid;
  dynamic ask;
  dynamic high;
  dynamic low;
  Color askBGColor;
  Color askTextColor;
  Color bidBGColor;
  Color bidTextColor;
  Color askTradeBGColor;
  Color askTradeTextColor;
  Color bidTradeBGColor;
  Color bidTradeTextColor;

  factory Liverate.fromJson(Map<String, dynamic> json) => Liverate(
        id: json["id"],
        name: json["name"],
        src: json["src"],
        usr: json["usr"],
        isView: json["isView"],
        isTerminal: json["isTerminal"],
        type: json["type"],
        time: json["time"],
        bid: json["bid"],
        ask: json["ask"],
        high: json["high"],
        low: json["low"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "src": src,
        "usr": usr,
        "isView": isView,
        "isTerminal": isTerminal,
        "type": type,
        "time": time,
        "bid": bid,
        "ask": ask,
        "high": high,
        "low": low,
      };
}
