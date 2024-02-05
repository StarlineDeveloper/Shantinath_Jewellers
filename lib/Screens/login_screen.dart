// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terminal_demo/Constants/images.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/loginData.dart';
import '../Routes/page_route.dart';
import '../Services/login_service.dart';
import '../Services/register_service.dart';
import '../Services/socket_service.dart';
import '../Utils/shared.dart';
import '../Widgets/custom_text.dart';
import 'home_screen.dart';

class Login_Screen extends StatefulWidget {
  static const String routeName = PageRoutes.Login_Screen;

  const Login_Screen({super.key, required this.isFromSplash});

  final bool isFromSplash;

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  GlobalKey<FormState> _loginFormKey = GlobalKey();
  GlobalKey<FormState> _registerFormKey = GlobalKey();

  final Shared shared = Shared();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _firmNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();

  bool isUsernameValidate = false;
  bool isPasswordValidate = false;
  bool isRegisterClickable = true;
  bool isLoginClickable = true;
  bool isLoadingRegister = false;
  bool isLoadingLogin = false;

  bool isLoginRemember = false;
  bool isLoginSelected = true;
  String headerName = 'Login';
  RegisterService register = RegisterService();
  LoginService login = LoginService();
  late Image myImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myImage = Image.asset(AppImagePath.loginillu);

    if (widget.isFromSplash) {
      setState(() {
        isLoginSelected = false;
        headerName = 'Register';
      });
    }
    getLoginData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.defaultColor,
      appBar: AppBar(
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: AppColors.transparent),
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 50,
        // elevation: .0,
        title: CustomText(
          text: headerName,
          textColor: AppColors.defaultColor,
          size: 16.0,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Visibility(
            visible: !widget.isFromSplash,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.defaultColor,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // color:
          image: DecorationImage(
            image: AssetImage(AppImagePath.bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            color: AppColors.primaryLightColor,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoginSelected
                  ? Form(
                      key: _loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Align(
                          //   alignment: Alignment.center,
                          //   child: CustomText(
                          //     text: headerName,
                          //     textColor: AppColor.defaultColor,
                          //     size: 18.0,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: size.height * 0.02,
                          // ),

                          CustomText(
                            text: 'USER ID :',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.primaryColor,
                            size: 13.0,
                          ),

                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          TextFormField(
                            style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.of(context).textScaleFactor,
                            ),
                            controller: _usernameController,
                            autovalidateMode: isUsernameValidate
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            decoration: getInputBoxDecoration(
                                'Enter User Id', Icons.person),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            cursorColor: AppColors.primaryColor,
                            // onChanged: (String val) {
                            //   if (val.isEmpty) {
                            //     setState(() {
                            //       isUsernameValidate = true;
                            //     });
                            //   }
                            //   if (val.length > 1) {
                            //     setState(() {
                            //       isUsernameValidate = false;
                            //     });
                            //   }
                            // },
                            // validator: (String? val) {
                            //   if (val!.isEmpty) {
                            //     return 'Username is required';
                            //   }
                            //   return null;
                            // },
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          CustomText(
                            text: 'PASSWORD :',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.primaryColor,
                            size: 13.0,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            autovalidateMode: isPasswordValidate
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            decoration: getInputBoxDecoration(
                                'Enter Password', Icons.lock),

                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            cursorColor: AppColors.primaryColor,
                            obscureText: true,
                            // onChanged: (String val) {
                            //   if (val.isEmpty) {
                            //     setState(() {
                            //       isPasswordValidate = true;
                            //     });
                            //   }
                            //   if (val.length > 1) {
                            //     setState(() {
                            //       isPasswordValidate = false;
                            //     });
                            //   }
                            // },
                            // validator: (String? val) {
                            //   if (val!.isEmpty) {
                            //     return 'Password is required';
                            //   }
                            //   return null;
                            // },
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))),
                                      checkColor: AppColors.defaultColor,
                                      value: isLoginRemember,
                                      activeColor: AppColors.primaryColor,
                                      side: BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 1.6,
                                      ),
                                      onChanged: (bool? val) {
                                        setState(() {
                                          isLoginRemember = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  const CustomText(
                                    text: 'Remember Me',
                                    textColor: AppColors.primaryColor,
                                    size: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              CustomText(
                                text: 'Forgot Password?',
                                textColor: AppColors.primaryColor,
                                size: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          InkWell(
                            onTap: () {
                              loginUser();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Visibility(
                                    visible: !isLoadingLogin,
                                    child: CustomText(
                                      text: 'Login',
                                      textColor: AppColors.defaultColor,
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Visibility(
                                    visible: isLoadingLogin,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.defaultColor,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isLoginSelected = !isLoginSelected;
                                  headerName = 'Register';
                                });
                              },
                              child: CustomText(
                                text: 'Or Create New Account',
                                textColor: AppColors.primaryColor,
                                size: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : Form(
                      key: _registerFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // CustomText(
                            //   text: 'Register',
                            //   textColor: AppColor.primaryColor,
                            //   size: 16.0,
                            //   fontWeight: FontWeight.bold,
                            // ),
                            // SizedBox(
                            //   height: size.height * 0.02,
                            // ),
                            TextFormField(
                              controller: _nameController,
                              decoration:
                                  getInputBoxDecoration('NAME', Icons.person),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              cursorColor: AppColors.primaryColor,
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: _firmNameController,
                              decoration: getInputBoxDecoration(
                                  'FIRM NAME', Icons.factory),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                              ],
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              cursorColor: AppColors.primaryColor,
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: _mobileController,
                              decoration: getInputBoxDecoration(
                                  'CONTACT NUMBER', Icons.phone_android_rounded),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              cursorColor: AppColors.primaryColor,
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: getInputBoxDecoration(
                                  'EMAIL ID(optional)', Icons.email),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                              ],
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              cursorColor: AppColors.primaryColor,
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: _cityController,
                              decoration: getInputBoxDecoration(
                                  'CITY', Icons.location_city),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                              ],
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              cursorColor: AppColors.primaryColor,
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: _gstController,
                              decoration: getInputBoxDecoration(
                                  'GST NUMBER', Icons.onetwothree),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              cursorColor: AppColors.primaryColor,
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            InkWell(
                              onTap: () {
                                registerUser();
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.only(bottom: size.height * 0.01),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Visibility(
                                      visible: !isLoadingRegister,
                                      child: CustomText(
                                        text: 'Submit',
                                        textColor: AppColors.defaultColor,
                                        size: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Visibility(
                                      visible: isLoadingRegister,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.defaultColor,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isLoginSelected = true;
                                    headerName = 'Login';
                                  });
                                },
                                child: const CustomText(
                                  text: 'Already Register?Login',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.primaryColor,
                                  size: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  getInputBoxDecoration(String text, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 25,
      ),
      isDense: true,
      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      hintText: text,
      hintStyle: TextStyle(fontSize: 14.0, color: AppColors.primaryColor),
      fillColor: AppColors.defaultColor,
      filled: true,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }

  void registerUser() {
    if (_registerFormKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter your Name.')
            : Functions.showToast('Please enter your name.');
        // Functions.showToast('Please enter your Name.');
      } else if (_firmNameController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter firm Name.')
            : Functions.showToast('Please enter firm name.');
        // Functions.showToast('Please enter firm Name.');
      } else if (_mobileController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter contact  number.')
            : Functions.showToast('Please enter contact number.');
        // Functions.showToast('Please enter your contact number.');
      } else if (_mobileController.text.length != 10) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Enter valid contact number.')
            : Functions.showToast('Enter valid contact number.');
      } else if (_emailController.text.isNotEmpty &&
          !Functions.velidateEmail(_emailController.text)) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter your valid Email.')
            : Functions.showToast('Please enter your valid Email.');
        // Functions.showToast('Please enter your valid Email.');
      } else if (_cityController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter your city.')
            : Functions.showToast('Please enter your city.');
        // Functions.showToast('Please enter your City.');
      } else if (_gstController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter your gst number.')
            : Functions.showToast('Please enter your gst number.');
        // Functions.showToast('Please enter your gst number.');
      } else if (_gstController.text.length != 15) {
        Platform.isIOS
            ? Functions.showSnackBar(
                context, 'GST number cant be less then 15.')
            : Functions.showToast('GST number cant be less then 15.');
        // Functions.showToast('GST number cant be less then 15.');
      } else {
        Functions.checkConnectivity().then((isConnected) {
          if (isConnected) {
            if (isRegisterClickable) {
              setState(() {
                isRegisterClickable = false;
                isLoadingRegister = true;
              });
              var objVariable = registerRequestToJson(RegisterRequest(
                  accountId: 0,
                  name: _nameController.text,
                  firmname: _firmNameController.text,
                  number: _mobileController.text,
                  email: _emailController.text,
                  city: _cityController.text,
                  gst: _gstController.text,
                  flag: 'New',
                  clientId: Constants.clientId));
              register.registerUser(objVariable).then((response) {
                if (response.data != '0') {
                  Platform.isIOS
                      ? Functions.showSnackBar(
                          context, 'Registration Successful!')
                      : Functions.showToast('Registration Successful!');
                  // Functions.showToast('Registration Successful!');
                  setState(() {
                    headerName = 'Login';
                    isRegisterClickable = true;
                    isLoadingRegister = false;
                    // isLoginSelected = true;
                    // shared.setIsFirstTimeRegister(true);
                    Navigator.of(context).pop();
                    // Navigator.of(context) .pushReplacementNamed(HomeScreen.routeName);
                    clearFields();
                  });
                } else {
                  setState(() {
                    isRegisterClickable = true;
                    isLoadingRegister = false;
                  });
                  Platform.isIOS
                      ? Functions.showSnackBar(
                          context, 'Mobile Number Already Exist.')
                      : Functions.showToast('Mobile Number Already Exist.');
                  // Functions.showToast('Mobile Number Already Exist.');
                }
              });
            }
          } else {
            setState(() {
              isRegisterClickable = true;
              isLoadingRegister = false;
            });
            Functions.showToast(Constants.noInternet);
          }
        });
      }
    }
  }

  void loginUser() {
    if (_loginFormKey.currentState!.validate()) {
      if (_usernameController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter your UserId.')
            : Functions.showToast('Please enter your UserId.');
        // Functions.showToast('Please enter your UserId.');
      } else if (_passwordController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter password.')
            : Functions.showToast('Please enter password.');
        // Functions.showToast('Please enter password.');
      } else {
        Functions.checkConnectivity().then((isConnected) {
          if (isConnected) {
            if (isLoginClickable) {
              setState(() {
                isLoginClickable = false;
                isLoadingLogin = true;
              });
            }

            var objVariable = loginRequestToJson(LoginRequest(
                loginid: int.parse(_usernameController.text),
                password: _passwordController.text,
                clientId: int.parse(Constants.clientId),
                firmname: Constants.projectName));
            login.loginUser(objVariable, context).then((response) {
              if (response.data == '200') {
                SocketService.getLiveRateData(context);
                if (isLoginRemember) {
                  shared.setIsRemember(true);
                } else {
                  shared.setIsRemember(false);
                }
                Navigator.of(context).pop();
                setState(() {
                  isLoginClickable = true;
                  isLoadingLogin = false;
                });

                Functions.showToast('Login has been Successfully');
              } else {
                setState(() {
                  isLoginClickable = true;
                  isLoadingLogin = false;
                });
                // Functions.showToast('Login Fail');
              }
            });
          } else {
            setState(() {
              isLoginClickable = true;
              isLoadingLogin = false;
            });
            Functions.showToast(Constants.noInternet);
          }
        });
      }
    }
  }

  void clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _nameController.clear();
    _mobileController.clear();
    _firmNameController.clear();
    _emailController.clear();
    _cityController.clear();
    _gstController.clear();
  }

  void getLoginData() async {
    bool isRemember = await shared.getIsRemember();
    shared.getLoginData().then((loginData) {
      if (loginData.isNotEmpty) {
        LoginData userData = LoginData.getJson(json.decode(loginData));
        if (isRemember) {
          setState(() {
            isLoginRemember = isRemember;
            _usernameController.text = userData.data[0].loginId!;
            _passwordController.text = userData.data[0].password!;
          });
        }
      }
    });
  }
}
