import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class UiHelper {
  static Widget CumtomImg(String img) {
    return Image.asset(
      "assets/images/${img}",
      fit: BoxFit.contain,
    );
  }

  static CustomText(
      {required String text,
        required double fontSize,
        required FontWeight fontWeight,
        required Color color,
        required TextAlign textAlign,
        String? fontFamily}) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFamily: "regular",
      ),
    );
  }

  static customTextField(
      {required TextEditingController controller,
        required String? hint,
        required String? label,
        required String? Function(String?)? validator,
        bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiHelper.CustomText(
            text: label!,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            textAlign: TextAlign.start),
        SizedBox(
          height: 8,
        ),
        TextFormField(
          validator: validator,
          controller: controller,

          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  static customButton({required Text text,required Color color,required Color textColor,required VoidCallback  onPressed }){

    return  ElevatedButton.icon(
      onPressed: onPressed,


      label: text,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
        ),
        textStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,),
        backgroundColor: color,
        minimumSize: Size(double.infinity, 55),


      ),
    );
  }
}
