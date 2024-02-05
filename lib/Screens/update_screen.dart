// ignore_for_file: camel_case_types, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Services/update_service.dart';

import '../Constants/app_colors.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Widgets/custom_text.dart';

class Update_Screen extends StatefulWidget {
  const Update_Screen({super.key});

  @override
  State<Update_Screen> createState() => Update_ScreenState();
}

class Update_ScreenState extends State<Update_Screen> {
  String selectedFromDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String selectedToDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  bool isLoading = false;
  bool isLoadingProg = true;
  late List<UpdateList> updateList = [];
  UpdateService updateService = UpdateService();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    callUpdateApi();
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: 'From',
                  size: 15.0,
                  fontWeight: FontWeight.normal,
                  textColor: AppColors.defaultColor,
                  align: TextAlign.start,
                ),
                GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Functions.calenderStyle(context),
                          child: child!,
                        );
                      },
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          selectedFromDate =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      }
                    });
                  },
                  child: Container(
                      width: size.width * 0.25,
                      height: 25.0,
                      // color: AppColors.primaryColor,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.defaultColor)),
                      alignment: Alignment.center,
                      child: CustomText(
                          text: selectedFromDate,
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.defaultColor,
                          size: 13.0)),
                ),
                const CustomText(
                  text: 'To',
                  size: 15.0,
                  fontWeight: FontWeight.normal,
                  textColor: AppColors.defaultColor,
                  align: TextAlign.start,
                ),
                GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Functions.calenderStyle(context),
                          child: child!,
                        );
                      },
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          selectedToDate =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      }
                    });
                  },
                  child: Container(
                      width: size.width * 0.25,
                      height: 25.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.defaultColor)),
                      alignment: Alignment.center,
                      child: CustomText(
                          text: selectedToDate,
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.defaultColor,
                          size: 13.0)),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint(
                        "startDate->$selectedFromDate/endDate->$selectedToDate");
                    setState(() {
                      isLoading = true;
                    });
                    callUpdateApi();
                  },
                  child: Container(
                    height: 25.0,
                    width: size.width * 0.25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Stack(
                      children: [
                        Visibility(
                          visible: !isLoading,
                          child: CustomText(
                            text: 'Search',
                            size: 15.0,
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.primaryColor,
                            align: TextAlign.start,
                          ),
                        ),
                        Visibility(
                          visible: isLoading,
                          child: SizedBox(
                            height: 20.0,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.defaultColor,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: AppColors.defaultColor,
            thickness: 1,
          ),
          Expanded(
            child: updateList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Updates Not Available',
                          textColor: AppColors.defaultColor,
                          size: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                        Visibility(
                          visible: isLoadingProg,
                          child: SizedBox(
                            height: 15.0,
                            width: 15,
                            child: CircularProgressIndicator(
                              color: AppColors.defaultColor,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: updateList.length,
                    itemBuilder: (builder, index) {
                      return buildUpdateContainer(size, updateList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  buildUpdateContainer(Size size, UpdateList updateList) {
    var size = MediaQuery.of(context).size;
    return Card(
      elevation: 4,
      shadowColor: AppColors.hintColorLight,
      // color: AppColor.defaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      // decoration: ShapeDecoration(
      //   color: Colors.white,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   shadows: [AppColors.boxShadow],
      // ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:   CustomText(
                    text: updateList.title!.isNotEmpty ? updateList.title! : '',
                    textColor: AppColors.primaryColor,
                    size: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomText(
                  text: updateList.time!.isNotEmpty ? updateList.time! : '',
                  textColor: AppColors.secondaryColor,
                  size: 14.0,
                  fontWeight: FontWeight.bold,
                )
              ],
            ),
            SizedBox(height: size.height * 0.01),
            CustomText(
              text: updateList.description!.isNotEmpty
                  ? updateList.description!
                  : '',
              textColor: AppColors.secondaryTextColor,
              size: 14.0,
              fontWeight: FontWeight.normal,
            ),

            SizedBox(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  text: updateList.day.toString(),
                  textColor: AppColors.secondaryTextColor,
                  size: 16.0,
                  fontWeight: FontWeight.normal,
                ),
                CustomText(
                  text: " ${updateList.month} ${updateList.year}",
                  textColor: AppColors.secondaryTextColor,
                  size: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void callUpdateApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        var objVariable = updateToJson(UpdateRequest(
            startDate: selectedFromDate,
            endDate: selectedToDate,
            client: Constants.clientId));
        updateService.update(objVariable).then((response) {
          if (response.data != '[]') {
            List<dynamic> dataList = jsonDecode(response.data!);
            if (_isMounted) {
              setState(() {
                isLoading = false;
                isLoadingProg = false;
                updateList =
                    dataList.map((item) => UpdateList.fromJson(item)).toList();
              });
            }
            // setState(() {
            //   isLoading = false;
            //   updateList =
            //       dataList.map((item) => UpdateList.fromJson(item)).toList();
            // });
          } else {
            if (_isMounted) {
              setState(() {
                updateList = [];
                isLoading = false;
                isLoadingProg = false;
              });
            }
            // setState(() {
            //   updateList =[];
            //   isLoading = false;
            // });
          }
        });
      } else {
        if (_isMounted) {
          setState(() {
            // updateList =[];
            isLoading = false;
            isLoadingProg = false;
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
