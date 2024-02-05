// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:terminal_demo/Constants/images.dart';

import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Services/bankdetails_service.dart';
import '../Widgets/custom_text.dart';

class BankDetail_Screen extends StatefulWidget {
  const BankDetail_Screen({super.key});

  @override
  State<BankDetail_Screen> createState() => _BankDetail_ScreenState();
}

class _BankDetail_ScreenState extends State<BankDetail_Screen>
    with AutomaticKeepAliveClientMixin<BankDetail_Screen> {
  @override
  bool get wantKeepAlive => true;

  bool isLoading = true;
  late List<BankList> bankList = [];
  BankService bankService = BankService();
  bool _isMounted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;

    callBankDetailsApi();
  }

  @override
  void dispose() {
    _isMounted = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: bankList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Bank Not Available',
                    textColor: AppColors.defaultColor,
                    size: 20.0,
                    fontWeight: FontWeight.normal,
                  ),
                  Visibility(
                    visible: isLoading,
                    child: SizedBox(
                      height: 15.0,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: AppColors.defaultColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bankList.length,
              itemBuilder: (builder, index) {
                return buildBankDetailContainer(size, bankList[index]);
              },
            ),
    );
  }

  Widget buildBankDetailContainer(Size size, BankList bankList) {
    return


      Card(
        elevation: 4,
        shadowColor: AppColors.hintColorLight,
        // color: AppColor.defaultColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      // margin: EdgeInsets.only(left: 4.0,right: 4.0,top: 4.0),
      // decoration: ShapeDecoration(
      //   color: Colors.white,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   shadows: [AppColors.boxShadow],
      // ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CachedNetworkImage(
              imageUrl: bankList.bankLogo!.isNotEmpty ? bankList.bankLogo! : '',
              fit: BoxFit.contain,
              errorWidget: (context, url, error) {
                return Image.asset(AppImagePath.splashImage);
              },
              placeholder: (context, url) {
                return const CupertinoActivityIndicator();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Bank Name',
                      textColor: AppColors.primaryColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Account Name',
                      textColor: AppColors.primaryColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Account No',
                      textColor: AppColors.primaryColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'IFSC Code',
                      textColor: AppColors.primaryColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Branch Name',
                      textColor: AppColors.primaryColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomText(
                        text: ':: ${bankList.bankName}',
                        textColor: AppColors.textColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: ':: ${bankList.accountName}',
                        textColor: AppColors.textColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: ':: ${bankList.accountNo}',
                        textColor: AppColors.textColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: ':: ${bankList.ifsc}',
                        textColor: AppColors.textColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: ':: ${bankList.branchName}',
                        textColor: AppColors.textColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void callBankDetailsApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        bankService.bankDet(int.parse(Constants.clientId)).then((response) {
          if (response.data != '[]') {
            List<dynamic> dataList = jsonDecode(response.data!);
            if (_isMounted) {
              setState(() {
                isLoading = false;
                bankList =
                    dataList.map((item) => BankList.fromJson(item)).toList();
              });
            }
            // setState(() {
            //   isLoading = false;
            //   bankList =
            //       dataList.map((item) => BankList.fromJson(item)).toList();
            // });
            // Functions.showToast(response.data!);
          } else {
            if (_isMounted) {
              setState(() {
                bankList = [];
                isLoading = false;
              });
            }
            // setState(() {
            //   bankList = [];
            //   isLoading = false;
            // });
          }
        });
      } else {
        if (_isMounted) {
          setState(() {
            isLoading = false;
          });
        }
        // setState(() {
        //   isLoading = false;
        // });
        Functions.showToast(Constants.noInternet);
      }
    });
  }
}
