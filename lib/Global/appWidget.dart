import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/webService.dart';
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