import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService{

  final storage = GetStorage();

  bool getThemeFromStorage(){
    return storage.read('isDark') ?? false;
  }

  void setThemeFromStorage(bool isDark){

    storage.write('isDark', isDark);
  }

  ThemeMode getCurrentThemeMode(){
    return getThemeFromStorage() ? ThemeMode.dark : ThemeMode.light;
  }

  void changeCurrentTheme(){
    Get.changeThemeMode(getThemeFromStorage() ? ThemeMode.light : ThemeMode.dark);
    setThemeFromStorage(!getThemeFromStorage());
  }

}


  final darkTheme = ThemeData(
    
    primaryColor: Colors.black, 
    brightness: Brightness.dark,
    accentColor: Color(0xff323232 ),
    accentIconTheme: IconThemeData(color: Colors.black),
    cardColor: Color(0xff323232 ),
    toggleableActiveColor: Color(0xff5458e1),
    canvasColor: Colors.black,

    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Color(0xff323232 ),
      selectionHandleColor: Color(0xff323232 ),
      cursorColor: Color(0xff757575)
    ),

  );

  final lightTheme = ThemeData(
   
    brightness: Brightness.light,
    accentIconTheme: IconThemeData(color: Colors.white),
    cardColor: Colors.white,
    canvasColor: Colors.white,
    toggleableActiveColor: Color(0xff5458e1),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Color(0xff5458e1),
      selectionHandleColor: Color(0xff5458e1),
      cursorColor: Color(0xff757575)
    ),
         
    accentColor: Color(0xff5458e1),
    primaryColor: Color(0xff5458e1),
  
  );