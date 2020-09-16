// import 'package:MemoryGo/model/StudySet.dart';
// import 'package:flutter/material.dart';

// import '../../constants.dart';

// class HeaderWithSearchBox extends StatefulWidget {
//   const HeaderWithSearchBox({Key key, @required this.size, this.studySets})
//       : super(key: key);

//   final Size size;
//   final List<StudySet> studySets;

//   @override
//   _HeaderWithSearchBoxState createState() => _HeaderWithSearchBoxState();
// }

// class _HeaderWithSearchBoxState extends State<HeaderWithSearchBox> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: widget.size.height * 0.2,
//       margin: EdgeInsets.only(bottom: 30),
//       child: Stack(
//         children: [
//           // 0.2 of height blue box
//           Container(
//             padding: EdgeInsets.only(left: 15, right: 15, bottom: 50),
//             height: widget.size.height * 0.2 - 20,
//             decoration: BoxDecoration(
//               color: kPrimaryColor,
//               borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(36),
//                   bottomRight: Radius.circular(36)),
//             ),
//           ),
//           // Title
//           new Container(
//               margin: new EdgeInsets.only(top: 30.0),
//               child: Padding(
//                   padding: EdgeInsets.only(left: 15),
//                   child: Text(
//                     'My Study Sets',
//                     style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ))),
//           // Search bar
//           Positioned(
//               bottom: 0,
//               left: 10,
//               right: 10,
//               child: Container(
//                 alignment: Alignment.center,
//                 height: 50,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                           offset: Offset(0, 10),
//                           blurRadius: 50,
//                           color: kPrimaryColor.withOpacity(0.23))
//                     ]),
//                 child: Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: TextField(
//                         onChanged: (studySetTitle) {},
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.only(left: 15),
//                           hintText: "Search",
//                           hintStyle:
//                               TextStyle(color: kPrimaryColor.withOpacity(0.5)),
//                           enabledBorder: InputBorder.none,
//                           focusedBorder: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Image(
//                           alignment: Alignment.center,
//                           image: AssetImage('assets/icons/search.png')),
//                     )
//                   ],
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }
