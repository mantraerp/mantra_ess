import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'constant.dart';


Widget mantraLabel(String str, double fontSize, Color colour,TextAlign align,FontWeight weight, int maxLines) {
  return Text(str,
      textAlign: align,
      softWrap: true, // allows wrapping to the next line
      maxLines: maxLines,
      style: TextStyle(
          fontFamily: '', fontSize: fontSize, color: colour));
}

Widget optionTilesHeader(String title, String imageName, double height, double padding) {
  return Container(
      padding: EdgeInsets.only(top: padding),
      height: height,
      child: Center(
          child: Column(
        children: <Widget>[
          Image.asset(imageName, width: 53.0, height: 47.0),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontFamily: "",
                  fontSize: 18,
                  color: appGray)),
          const SizedBox(height: 10),
          Container(
            color: appGray,
            height: 0.5,
            width: 100,
          )
        ],
      )));
}

Widget optionTiles(String title,String description, String imageName) {
  return SizedBox(
      height: 120,
      child: Center(
          child: Column(
        children: <Widget>[
          Image.asset(imageName, width: 50.0, height: 50.0, fit: BoxFit.contain,),
          const SizedBox(height: 10),
          mantraLabel(title, 18,appGray, TextAlign.left, FontWeight.w500, 1),
          mantraLabel(description,18, appGray, TextAlign.center, FontWeight.w400, 1),
          const SizedBox(height: 10),
          Container(
            color: appGrayDark,
            height: 0.5,
            width: 100,
          )
        ],
      )));
}


String stringRemoveNull(var object) {

  if(object.runtimeType == Null) {
    return "";
  } else if(object == "null") {
    return "";
  } else if(object == "Null") {
    return "";
  }else if(object == "NULL") {
    return "";
  }

  return object.toString();
}

Widget showLoaderText(String loadingMessage){

  return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            IMGLoader,
            height: 100.0,
            width: 100.0,
          ),
          mantraLabel(loadingMessage, 18,appGray, TextAlign.left, FontWeight.w500, 1)
        ],
      )
  );
}

Widget imageLoading(String imageLink) {

  if(["",BASE_URL].contains(stringRemoveNull(imageLink))){
    return Container();
  }

  return CachedNetworkImage(
      imageUrl: imageLink,
      placeholder: (context, url) => showLoaderText(""),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.contain,
      useOldImageOnUrlChange:true
  );
}
Widget imageLoadingHeightWidth(String imageLink, double height, double width) {

  if(["",BASE_URL].contains(stringRemoveNull(imageLink))){
    return Container();
  }

  return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageLink,
      placeholder: (context, url) => showLoaderText(""),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.contain,
      useOldImageOnUrlChange:true
  );
}



void showAlert(String title, String message) {

  var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle:const TextStyle(
          fontFamily: '',
          fontSize: 17,
          color: appGray
      ),
      descTextAlign: TextAlign.center,
      animationDuration: const Duration(milliseconds: 250),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: appMantraBlue,
        ),
      ),
      titleStyle: const TextStyle(
        fontFamily: '',
        fontSize: 14,
        color: appGray,
      ),
      alertAlignment: Alignment.center,
      constraints: const BoxConstraints(
        minHeight: 50.0,
      )
  );

  Alert(
    context: navigatorKey.currentContext!,
    type: AlertType.none,
    style:alertStyle,
    title: title,
    desc: message,
    buttons: [
      DialogButton(
          color:appMantraBlue,
          onPressed: () {
            Navigator.pop(navigatorKey.currentContext!);
          },
          width: 100,
          child: mantraLabel('ok', 18,appGray, TextAlign.left, FontWeight.w500, 1)
      )
    ],
  ).show();
}

Widget appButtonGray(String title, VoidCallback? onPressed,AlignmentGeometry alignment, double width, double height){
  return Container(
    padding: const EdgeInsets.only(left: 0,right: 0),
    height: height,
    width: width,
    child: TextButton(
      clipBehavior: Clip.none,
      style: ButtonStyle(
        alignment: alignment,
        backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(0,0, 0, 0)),
        foregroundColor:WidgetStateProperty.all<Color>(const Color.fromARGB(0,0, 0, 0)),
        overlayColor:WidgetStateProperty.all<Color>(const Color.fromARGB(0,0, 0, 0)),
        shadowColor:WidgetStateProperty.all<Color>(const Color.fromARGB(0,0, 0, 0)),
        surfaceTintColor:WidgetStateProperty.all<Color>(const Color.fromARGB(0,0, 0, 0)),
      ),
      onPressed: onPressed,
      child: mantraLabel(title, 14,appGray, TextAlign.center, FontWeight.w500, 1)
    ),
  );
}