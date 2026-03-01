 
import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart'; 
import 'package:intl/intl.dart';

class AppHelperFunctions {
  static Color? getColor(String color) {
    switch (color) {
      case 'primary':
        return AppColors.primaryColor;
      case 'secondary':
        return AppColors.secondaryColor;
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      case 'light':
        return AppColors.light;
      case 'dark':
        return AppColors.dark;
      default:
        return null;
    }
  }

  static void showSnackBar(String message, BuildContext context ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showAlert(String title, String message, BuildContext context) {
    showDialog(
      context: context ,
       builder: (BuildContext context) {
         return AlertDialog(
           title: Text(title),
           content: Text(message),
           actions: [
             TextButton( 
               onPressed: () =>  Navigator.of(context).pop(),
               child: Text('OK'),
             ),
           ],
         );
       }
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static String truncateText(String text, int length) {
    if (text.length > length) {
      return '${text.substring(0, length)}...';
    } else {
      return text;
    }
  }


  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return  DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
   final wrappedList = <Widget>[];
   for (int i = 0; i < widgets.length; i += rowSize) {
     final rowChildren = widgets.sublist(i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
     wrappedList.add(Row(children: rowChildren));
   }
   return wrappedList;
  }

  
}