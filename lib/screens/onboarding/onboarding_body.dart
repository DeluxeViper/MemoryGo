import 'package:MemoryGo/screens/onboarding/default_button.dart';
import 'package:MemoryGo/values/constants.dart';
import 'package:flutter/material.dart';

import 'onboard_content.dart';

class OnboardingBody extends StatefulWidget {
  @override
  _OnboardingBodyState createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<OnboardingBody> {
  int currentPage = 0;
  PageController controller;
  var currentPageValue = 0.0;
  List<Map<String, String>> onboardData = [
    {
      'text': 'Welcome to MemoryGo, Your perfect study comrade!',
      'image': 'assets/icons/app_icon.png'
    },
    {
      'text': 'Create your own study sets!',
      'image': 'assets/gifs/study_sets_gif.gif'
    },
    {
      'text': 'Add your list of customized notes to each study set!',
      'image': 'assets/gifs/notes_gif.gif'
    },
    {
      'text': 'Customize your experience!',
      'image': 'assets/gifs/settings_gif.gif'
    },
    {
      'text': 'Press play and ace those tests!',
      'image': 'assets/gifs/press_play.gif'
    }
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController()
      ..addListener(() {
        setState(() {
          currentPageValue = controller.page;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: controller,
                physics: BouncingScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: onboardData.length,
                itemBuilder: (context, position) {
                  if (position == currentPageValue.floor()) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..rotateX(currentPageValue - position),
                      child: OnboardContent(
                        text: onboardData[position]['text'],
                        image: onboardData[position]['image'],
                        currentPage: position,
                      ),
                    );
                  } else if (position == currentPageValue.floor() + 1) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..rotateX(currentPageValue - position),
                      child: OnboardContent(
                        text: onboardData[position]['text'],
                        image: onboardData[position]['image'],
                        currentPage: position,
                      ),
                    );
                  } else {
                    return OnboardContent(
                      text: onboardData[position]['text'],
                      image: onboardData[position]['image'],
                      currentPage: position,
                    );
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardData.length,
                          (index) => buildDot(index: index)),
                    ),
                    Spacer(),
                    DefaultButton(
                      text: currentPage == onboardData.length - 1
                          ? 'Done'
                          : 'Skip',
                      press: () {
                        Navigator.pushNamed(context, '/homepage');
                      },
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
          color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(3)),
    );
  }
}
