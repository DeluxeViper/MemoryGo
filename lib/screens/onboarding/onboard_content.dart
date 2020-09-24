import 'package:MemoryGo/values/constants.dart';
import 'package:flutter/material.dart';

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    Key key,
    this.text,
    this.image,
    this.currentPage,
  }) : super(key: key);
  final String text, image;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 8),
          child: Text(
            'MemoryGo',
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: getProportionateScreenWidth(context, 36),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Spacer(),
        Image.asset(
          image,
          height: currentPage != 0 ? 350 : 350,
          width: currentPage != 0 ? 300 : 350,
        ),
      ],
    );
  }
}
