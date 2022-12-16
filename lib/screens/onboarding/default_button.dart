import 'package:MemoryGo/values/constants.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: getProportionateScreenHeight(context, 56),
        child: TextButton(
          style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
          // color: kPrimaryColor,
          onPressed: () => press(),
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
