// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:terminal_demo/Services/deletelimit_service.dart';

import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/loginData.dart';
import '../Services/openorder_service.dart';
import '../Services/updatelimit_service.dart';
import '../Utils/shared.dart';
import 'custom_text.dart';

class OrderStatus_Widget extends StatefulWidget {
  bool isEdit = false;
  OpenOrderElement dataList;
  Function? openOrder;
  Function? update;

  OrderStatus_Widget(
      {super.key,
      required this.isEdit,
      required this.dataList,
      required this.openOrder,
      required this.update});

  @override
  State<OrderStatus_Widget> createState() => _OrderStatus_WidgetState();
}

class _OrderStatus_WidgetState extends State<OrderStatus_Widget> {
  late TextEditingController _priceController = TextEditingController();
  final Shared shared = Shared();
  LoginData? userData;
  OpenorderService openorderService = OpenorderService();

  // int dealNum = 0;
  DeletelimitService deletelimitService = DeletelimitService();
  UpdatelimitService updatelimitService = UpdatelimitService();
  bool isVisible = false;
  bool isLimitClickable = true;
  bool isUpdateClickable = true;

  @override
  void initState() {
    super.initState();
    // getLoginData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      // shadowColor: AppColors.hintColorLight,
      color: AppColors.defaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: widget.dataList.symbolName!.isEmpty
                      ? ''
                      : widget.dataList.symbolName!.toUpperCase(),
                  textColor: AppColors.primaryColor,
                  size: 16.0,
                  fontWeight: FontWeight.bold,
                ),

                Visibility(
                  visible: widget.isEdit,
                  child: GestureDetector(
                    onTap: () {
                      openEditLimitPopup(
                          widget.dataList.symbolName!,
                          widget.dataList.dealNo!,
                          widget.dataList.volume!,
                          widget.dataList.source!.toLowerCase().trim() ==
                                      "gold" ||
                                  widget.dataList.source!
                                          .toLowerCase()
                                          .trim() ==
                                      "goldnext"
                              ? 'gm'
                              : widget.dataList.source!
                                              .toLowerCase()
                                              .trim() ==
                                          "silver" ||
                                      widget.dataList.source!
                                              .toLowerCase()
                                              .trim() ==
                                          "silvernext"
                                  ? ' kg '
                                  : 'Unknown',
                          widget.dataList.rate!);
                    },
                    child: const Image(
                      image: AssetImage(AppImagePath.edit),
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CustomText(
                  text: widget.dataList.tradeType == '1'
                      ? 'Buy'
                      : widget.dataList.tradeType == '2'
                          ? 'Sell'
                          : widget.dataList.tradeType == '3'
                              ? 'Buy Limit'
                              : widget.dataList.tradeType == '4'
                                  ? 'Sell Limit'
                                  : 'Unknown',
                  textColor: widget.dataList.tradeType == '1' ||
                          widget.dataList.tradeType == '3'
                      ? AppColors.green
                      : AppColors.red,
                  size: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                const SizedBox(
                  width: 3,
                ),
                CustomText(
                  text: widget.dataList.source!.toLowerCase().trim() ==
                              "gold" ||
                          widget.dataList.source!.toLowerCase().trim() ==
                              "goldnext"
                      ? '(${widget.dataList.volume!} gm) : ${widget.dataList.rate.toStringAsFixed(0)} -> ${widget.dataList.total==null?widget.dataList.total:widget.dataList.total.toStringAsFixed(0)}'
                      : widget.dataList.source!.toLowerCase().trim() ==
                                  "silver" ||
                              widget.dataList.source!.toLowerCase().trim() ==
                                  "silvernext"
                          ? '(${widget.dataList.volume!} kg) : ${widget.dataList.rate.toStringAsFixed(0)} -> ${widget.dataList.total==null?widget.dataList.total:widget.dataList.total.toStringAsFixed(0)}'
                          : 'Unknown',
                  textColor: AppColors.textColor,
                  size: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
            CustomText(
              text: Functions.formateDate(widget.dataList.openTradeDateTime!),
              textColor: AppColors.textColor,
              size: 14.0,
              fontWeight: FontWeight.normal,
            ),
            CustomText(
              text: 'Deal No : ${widget.dataList.dealNo}',
              textColor: AppColors.textColor,
              size: 14.0,
              fontWeight: FontWeight.normal,
            ),
            // SizedBox(
            //   height: size.height * .01,
            // ),
            // const Divider(
            //   thickness: 1,
            //   height: 1,
            //   color: AppColors.primaryColor,
            // )
          ],
        ),
      ),
    );
  }

  void openEditLimitPopup(
    String symbolName,
    int dealNo,
    dynamic volume,
    String gmKg,
    dynamic rate,
  ) {
    setState(() {
      _priceController.text = rate.toStringAsFixed(0).toString();
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: const EdgeInsets.only(left: 20, right: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)), //this right here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size.width,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomText(
                    text: 'Update AND DELETE LIMIT',
                    textColor: AppColors.defaultColor,
                    size: 15.0,
                    fontWeight: FontWeight.bold,
                    align: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryColor,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            CustomText(
                              text: 'Symbol Name',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: 'Deal No',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: 'Quantity',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: 'Price',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            CustomText(
                              text: '-',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: '-',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: '-',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: '-',
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomText(
                              text: symbolName,
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: dealNo.toString(),
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 8),
                            CustomText(
                              text: volume.toString() + gmKg,
                              textColor: AppColors.textColor,
                              size: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(
                              height: 35,
                              width: size.width / 3.5,
                              child: TextField(
                                cursorColor: AppColors.primaryColor,
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 1.0),
                                  ),
                                  counterText: '',
                                  labelText: 'Price',
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      color: AppColors.hintColor,
                                      fontSize: 16.0),
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                onChanged: (value) {
                                  setState(() {
                                    _priceController.text = value;
                                    _priceController.selection =
                                        TextSelection.collapsed(
                                            offset:
                                            _priceController.text.length);
                                  });
                                }, // Only numbers can be entered
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('Update limit');
                          // setState(() {
                          //   dealNum = dealNo;
                          // });
                          openUpdateLimitPopup();
                        },
                        child: Container(
                          width: size.width / 2,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            color: AppColors.primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              'Update limit',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.defaultColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          openDeleteLimitPopup();
                          // setState(() {
                          //   dealNum = dealNo;
                          // });
                          debugPrint('Delete limit');
                        },
                        child: Container(
                          width: size.width / 2,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            color: AppColors.primaryColor,
                          ),
                          alignment: Alignment.center,
                          child: Center(
                            child: Text(
                              'Delete limit',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.defaultColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: size.width,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      color: AppColors.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            color: AppColors.defaultColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  openUpdateLimitPopup() {
    if (_priceController.text.isNotEmpty) {
      _showDialog(
        'Ok',
        'Are you sure you want to update Deal ${widget.dataList.dealNo}?',
        () {
          setState(() {
            isVisible = true;
          });
          callUpdateLimitApi();
        },
      );
    } else {
      Functions.showToast('Please enter price.');
    }
  }

  openDeleteLimitPopup() {
    // Navigator.pop(context);
    return _showDialog(
      'Delete',
      'Are you sure you want to delete Deal ${widget.dataList.dealNo}?',
      () {
        setState(() {
          isVisible = true;
        });
        callDeleteLimitApi();
      },
    );
  }

  callDeleteLimitApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        if (isLimitClickable) {
          setState(() {
            isLimitClickable = false;
          });
        }
        var objVariable = deleteLimitReqToJson(DeleteLimitRequest(
          loginid: Constants.loginId,
          dealNo: widget.dataList.dealNo,
          clientId: int.parse(Constants.clientId),
          token: Constants.token,
        ));
        deletelimitService.delLimitObj(objVariable).then((response) {
          if (response.data != null) {
            setState(() {
              isVisible = false;
              isLimitClickable = true;
              callGetOpenOrderDetailsApi();
              // widget.openOrder;
            });
            Navigator.pop(context);
            debugPrint(response.data);
          } else {
            setState(() {
              isVisible = false;
              isLimitClickable = true;
            });
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          isVisible = false;
          isLimitClickable = true;
        });
        Navigator.pop(context);
        Functions.showToast(Constants.noInternet);
      }
    });

    debugPrint('deleteApi');
  }

  callUpdateLimitApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        if (isUpdateClickable) {
          setState(() {
            isUpdateClickable = false;
          });
        }
        var objVariable = updateLimitReqToJson(UpdateLimitRequest(
          dealNo: widget.dataList.dealNo!.toString(),
          volume: widget.dataList.volume!.toInt().toString(),
          rate: _priceController.text,
          token: Constants.token,
          openOrderId: widget.dataList.openOrderId!.toString(),
          symbolId: widget.dataList.symbolId!.toString(),
          tradeType: widget.dataList.tradeType!,
        ));

        updatelimitService.updtLimitObj(objVariable).then((response) {
          if (response.data != null) {
            setState(() {
              isVisible = false;
              isUpdateClickable = true;
              callGetOpenOrderDetailsApi();
            });
            Navigator.pop(context);
            debugPrint(response.data);
          } else {
            setState(() {
              isVisible = false;
              isUpdateClickable = true;
            });
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          isVisible = false;
          isUpdateClickable = true;
        });
        Navigator.pop(context);
        Functions.showToast(Constants.noInternet);
      }
    });
    debugPrint('updateApi');
  }

  void callGetOpenOrderDetailsApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        var objVariable = openOrderReqToJson(OpenOrderRequest(
            loginid: Constants.loginId,
            firmname: Constants.projectName,
            clientId: int.parse(Constants.clientId),
            fromdate: Constants.startDate,
            todate: Constants.endDate));
        openorderService.openOrdObj(objVariable, context).then((response) {
          if (response.data != null) {
            // List<dynamic> accountDetailsList = jsonDecode(response.data!);
            // List<Accountdetails> accountDetails = accountDetailsList
            //     .map((item) => Accountdetails.fromJson(item))
            //     .toList();
            // if (_isMounted) {
            //   setState(() {
            //     isLoading = false;
            //     firstAccountDetails =
            //     accountDetails.isNotEmpty ? accountDetails[0] : null;
            //   });
            // }
            // // setState(() {
            // //   isLoading = false;
            // //   firstAccountDetails =
            // //       accountDetails.isNotEmpty ? accountDetails[0] : null;
            // // });
            // debugPrint('ACC-------DETAIL------List--${accountDetails.length}');
          } else {
            // if (_isMounted) {
            //   setState(() {
            //     isLoading = false;
            //   });
            // }
            // setState(() {
            //   isLoading = false;
            // });
            Functions.showToast(Constants.noData);
          }
        });
      } else {
        // if (_isMounted) {
        //   setState(() {
        //     isLoading = false;
        //   });
        // }
        // setState(() {
        //   isLoading = false;
        // });
        Functions.showToast(Constants.noInternet);
      }
    });
  }

  void _showDialog(String title, String content, VoidCallback onConfirm) {
    Navigator.pop(context);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        var size = MediaQuery.of(context).size;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: size.width * 0.11,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Constants.alertAndCnfTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          color: AppColors.defaultColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            content,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: InkWell(
                            child: Container(
                              margin: EdgeInsets.only(right: 5),
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Visibility(
                                    visible: !isVisible,
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0,
                                        color: AppColors.defaultColor,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isVisible,
                                    child: SizedBox(
                                      height: 20.0,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.defaultColor,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                isVisible = true;
                              });
                              onConfirm();
                            },
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            child: Container(
                              margin: EdgeInsets.only(left: 5),
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15.0,
                                  color: AppColors.defaultColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
