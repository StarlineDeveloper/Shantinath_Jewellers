// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Models/loginData.dart';
import 'package:terminal_demo/Screens/home_screen.dart';
import 'package:terminal_demo/Services/deleteAccount_Service.dart';
import 'package:terminal_demo/Widgets/custom_text.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Popup/alert_confirm_popup.dart';
import '../Providers/liveRate_Provider.dart';
import '../Routes/page_route.dart';
import '../Services/updatePassword_Service.dart';
import '../Utils/shared.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = PageRoutes.profilescreen;

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController passwordController = TextEditingController();
  ProfileDetails accountDetails = ProfileDetails();

  late LiveRateProvider liveRateProvider;
  Shared shared = Shared();
  List<Group> groupList = [];
  UpdatePasswordService updatePassword = UpdatePasswordService();
  DeleteAccountService deleteAcc = DeleteAccountService();
  bool isLoadingPass = false;
  bool isLoadingDeleteAcc = false;
  bool isPasswordClickable = true;
  bool isDeleteClickable = true;

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    NotifySocketUpdate.controllerAccountDetails = StreamController();
    liveRateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    if (!mounted) {
      return;
    }
    loadData();
    getGroupData();

    NotifySocketUpdate.controllerAccountDetails!.stream
        .asBroadcastStream()
        .listen(
      (event) {
        loadData();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    NotifySocketUpdate.controllerAccountDetails!.close();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: AppColors.defaultColor),
          backgroundColor: AppColors.primaryColor,
          toolbarHeight: 50,
          elevation: 0.0,
          title: Image.asset(
            AppImagePath.headerLogo,
            scale: 8,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.defaultColor,
            ),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImagePath.bg),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildProfileContainer(),
              ),
            )),
      ),
    );
  }

  getInputBoxDecoration(String text) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.all(10.0),
      hintText: text,
      hintStyle: TextStyle(fontSize: 14.0, color: AppColors.primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  buildTradePermissionContainer(Size size, int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * .2,
            child: CustomText(
              text: groupList[index].symbolName!,
              size: 12.0,
              fontWeight: FontWeight.bold,
              textColor: AppColors.primaryColor,
              align: TextAlign.start,
            ),
          ),
          CustomText(
            text: '${groupList[index].oneClick}',
            size: 12.0,
            fontWeight: FontWeight.bold,
            textColor: AppColors.primaryColor,
          ),
          CustomText(
            text: '${groupList[index].inTotal}',
            size: 12.0,
            fontWeight: FontWeight.bold,
            textColor: /*liveRatesDetail[index].mcxTextColor*/
                AppColors.primaryColor,
            align: TextAlign.start,
          )
        ],
      ),
    );
  }

  loadData() {
    setState(() {
      accountDetails = liveRateProvider.getAccountData();
    });
  }

  void getGroupData() {
    shared.getLoginData().then((loginData) {
      if (loginData.isNotEmpty) {
        LoginData userData = LoginData.getJson(json.decode(loginData));
        setState(() {
          groupList = userData.group;
        });
      }
    });
  }

  buildProfileContainer() {
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        Card(
          elevation: 4,
          shadowColor: AppColors.hintColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Container(
                width: size.width,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  // color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    text: 'Profile',
                    textColor: AppColors.primaryColor,
                    size: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 10.0, top: size.height * 0.01),
                    child:

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Flexible(
                        //       flex: 1,
                        //       child:     Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           CustomText(
                        //             text: 'USER ID',
                        //             textColor: AppColors.primaryColor,
                        //             size: 13.0,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: 'AUTHORISED PERSON NAME',
                        //             textColor: AppColors.primaryColor,
                        //             size: 13.0,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: 'FIRM NAME',
                        //             textColor: AppColors.primaryColor,
                        //             size: 13.0,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: 'CONTACT NO',
                        //             textColor: AppColors.primaryColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: 'EMAIL ID',
                        //             textColor: AppColors.primaryColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: 'ADDRESS',
                        //             textColor: AppColors.primaryColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Flexible(
                        //       flex: 1,
                        //       child:Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           CustomText(
                        //             text: accountDetails.loginId == null
                        //                 ? ' : '
                        //                 : ' : ${accountDetails.loginId!}',
                        //             textColor: AppColors.textColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: accountDetails.name == null
                        //                 ? ' : '
                        //                 : ' : ${accountDetails.name!}',
                        //             textColor: AppColors.textColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: accountDetails.firmname == null
                        //                 ? ' : '
                        //                 : ' : ${accountDetails.firmname!}',
                        //             textColor: AppColors.textColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: accountDetails.number == null
                        //                 ? ' : '
                        //                 : ' : ${accountDetails.number!}',
                        //             textColor: AppColors.textColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: accountDetails.email == null
                        //                 ? ' : '
                        //                 : ' : ${accountDetails.email!}',
                        //             textColor: AppColors.textColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           SizedBox(
                        //             height: size.height * 0.01,
                        //           ),
                        //           CustomText(
                        //             text: accountDetails.city == null
                        //                 ? ' : '
                        //                 : ' : ${accountDetails.city!}',
                        //             textColor: AppColors.textColor,
                        //             size: 13,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'USER ID',
                                textColor: AppColors.primaryColor,
                                size: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: 'AUTHORISED PERSON NAME',
                                textColor: AppColors.primaryColor,
                                size: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: 'FIRM NAME',
                                textColor: AppColors.primaryColor,
                                size: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: 'CONTACT NO',
                                textColor: AppColors.primaryColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: 'EMAIL ID',
                                textColor: AppColors.primaryColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: 'ADDRESS',
                                textColor: AppColors.primaryColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: accountDetails.loginId == null
                                    ? ' : '
                                    : ' : ${accountDetails.loginId!}',
                                textColor: AppColors.textColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: accountDetails.name == null
                                    ? ' : '
                                    : ' : ${accountDetails.name!}',
                                textColor: AppColors.textColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: accountDetails.firmname == null
                                    ? ' : '
                                    : ' : ${accountDetails.firmname!}',
                                textColor: AppColors.textColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: accountDetails.number == null
                                    ? ' : '
                                    : ' : ${accountDetails.number!}',
                                textColor: AppColors.textColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: accountDetails.email == null
                                    ? ' : '
                                    : ' : ${accountDetails.email!}',
                                textColor: AppColors.textColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              CustomText(
                                text: accountDetails.city == null
                                    ? ' : '
                                    : ' : ${accountDetails.city!}',
                                textColor: AppColors.textColor,
                                size: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'PASSWORD',
                          textColor: AppColors.primaryColor,
                          size: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          width: size.height * 0.02,
                        ),
                        SizedBox(
                          width: size.width / 2.5,
                          child: TextFormField(
                            style: TextStyle(color: AppColors.primaryColor),
                            controller: passwordController,
                            cursorColor: AppColors.primaryColor,
                            decoration: getInputBoxDecoration('New Password'),
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (passwordController.text.isEmpty) {
                                  Functions.showToast('Please enter password.');
                                } else {
                                  openUpdatePasswordPopup();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: Stack(
                                  children: [
                                    Visibility(
                                      visible: !isLoadingPass,
                                      child: CustomText(
                                        text: 'Update',
                                        textColor: AppColors.defaultColor,
                                        size: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Visibility(
                                      visible: isLoadingPass,
                                      child: const Center(
                                        child: SizedBox(
                                          height: 20.0,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: AppColors.defaultColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: size.height * 0.01,
                  // ),
                  Visibility(
                    visible:
                        accountDetails.firmname!.toLowerCase() == 'starline' ||
                                accountDetails.firmname!.toLowerCase() == 'sl'
                            ? true
                            : false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          openDeleteAccountPopup();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          alignment: Alignment.center,
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Stack(
                            children: [
                              Visibility(
                                visible: !isLoadingDeleteAcc,
                                child: CustomText(
                                  text: 'Delete Account',
                                  textColor: AppColors.primaryColor,
                                  size: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Visibility(
                                visible: isLoadingDeleteAcc,
                                child: const Center(
                                  child: SizedBox(
                                    height: 20.0,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.defaultColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Card(
          elevation: 4,
          shadowColor: AppColors.hintColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Container(
                width: size.width,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  // color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    text: 'TRADE PERMISSION',
                    textColor: AppColors.primaryColor,
                    size: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: size.height * 0.01,
                    left: size.height * 0.01,
                    right: size.height * 0.01),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Symbol',
                          textColor: AppColors.secondaryColor,
                          size: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          text: 'One Click',
                          textColor: AppColors.secondaryColor,
                          size: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          text: 'In Total',
                          textColor: AppColors.secondaryColor,
                          size: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: groupList.length,
                      itemBuilder: (context, index) =>
                          buildTradePermissionContainer(
                        size,
                        index,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void openUpdatePasswordPopup() {
    return DialogUtil.showConfirmDialog(context,
        title: 'Update Password',
        content: 'Are you sure you want to update password?',
        okBtnText: 'Update',
        cancelBtnText: 'Cancel',
        okBtnFunctionConfirm: onUpdate,
        isVisible: false);
  }

  void openDeleteAccountPopup() {
    return DialogUtil.showConfirmDialog(context,
        title: 'Delete Account',
        content: 'Are you sure you want to delete account?',
        okBtnText: 'Delete',
        cancelBtnText: 'Cancel',
        okBtnFunctionConfirm: onDelete,
        isVisible: false);
  }

  onDelete() {
    Navigator.of(context).pop();

    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        if (isDeleteClickable) {
          setState(() {
            isDeleteClickable = false;
            isLoadingDeleteAcc = true;
          });
        }

        var objVariable = deleteAccRequestToJson(DeleteAccRequest(
          clientId: int.parse(Constants.clientId),
          loginid: int.parse(accountDetails.loginId!),
        ));
        deleteAcc.deleteUser(objVariable, context).then((response) {
          if (int.parse(response.data.toString()) > 0) {
            Navigator.of(context).pop();
            setState(() {
              Constants.isLogin = false;
              shared.setIsLogin(false);
              isDeleteClickable = true;
              isLoadingDeleteAcc = false;
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            });

            Functions.showToast('Account Deleted Successfully');
          } else {
            setState(() {
              isDeleteClickable = true;
              isLoadingDeleteAcc = false;
            });
            Functions.showToast('Something Went Wrong');
          }
        });
      } else {
        setState(() {
          isDeleteClickable = true;
          isLoadingDeleteAcc = false;
        });
        Functions.showToast(Constants.noInternet);
      }
    });
  }

  onUpdate() {
    Navigator.of(context).pop();

    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        if (isPasswordClickable) {
          setState(() {
            isPasswordClickable = false;
            isLoadingPass = true;
          });
        }
        updatePassword
            .updatePass(
                int.parse(Constants.clientId),
                int.parse(accountDetails.loginId!),
                passwordController.text,
                context)
            .then((response) {
          if (int.parse(response.data.toString()) > 0) {
            Navigator.of(context).pop();
            setState(() {
              Constants.isLogin = false;
              shared.setIsLogin(false);
              isPasswordClickable = true;
              isLoadingPass = false;
            });

            Functions.showToast('Password Updated Successfully');
          } else {
            setState(() {
              isPasswordClickable = true;
              isLoadingPass = false;
            });
            Functions.showToast('Something Went Wrong');
          }
        });
      } else {
        setState(() {
          isPasswordClickable = true;
          isLoadingPass = false;
        });
        Functions.showToast(Constants.noInternet);
      }
    });
  }
}
