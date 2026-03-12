

import 'package:flutter/cupertino.dart';

import '../ui/home.dart';
import '../ui/login/login.dart';
import '../ui/splash.dart';

class AppRoutes {
  static const String ROUTE_SPLASH = '/';
  static const String ROUTE_LOGIN = 'login';
  static const String ROUTE_SIGNUP = 'signUp';
  static const String ROUTE_HOME = 'home';

  static Map<String, WidgetBuilder> getRoutes() => {
    ROUTE_SPLASH: (context) => Splash(),
    ROUTE_LOGIN: (context) => Login(),
   // ROUTE_SIGNUP: (context) => Signup(),
    ROUTE_HOME: (context) => Home(),
  };
}