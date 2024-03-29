import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:notes/components/navigation_drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> with SingleTickerProviderStateMixin {
  Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  AnimationController controller;
  Animation<Offset> offset;
  sentEmail(email) async {
    String encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '$email',
      query: encodeQueryParameters(
          <String, String>{'subject': 'Concern/Feedback from Mobile App.'}),
    );

    launch(emailLaunchUri.toString());
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('About Us'),
      ),
      drawer: NavigationDrawerWidget(),
      body: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            // image: DecorationImage(
            //     image: AssetImage(
            //       'assets/images/bga.jpg',
            //     ),
            //     fit: BoxFit.cover),
            ),
        child: Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Get.isDarkMode ? Colors.black : Colors.white),
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our mission is what drives us to do everything possible to expand notes taking possibilities. We do that by creating groundbreaking text editor, by building a creative and user friendly tool which can be used by any user. Making a positive impact in communities where we live and work.\nBased in Canada, United Arab Emirates, India etc.',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: Get.height * 0.050,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'WORK ANYWHERE',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.030,
                  ),
                  Text(
                    'Keep important info handy—your notes sync automatically to all your devices.',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: Get.height * 0.030,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'TURN TO-DO INTO DONE',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.030,
                  ),
                  Text(
                    'Bring your notes, tasks, and schedules together to get things done more easily.',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\n\nDeveloped by\t\n\n',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        TextSpan(
                          text: 'Hasan Abbas Sorathiya\n',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        TextSpan(
                          text: 'hasanabbassorathiya@gmail.com\n',
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () async {
                              await sentEmail("hasanabbassorathiya@gmail.com");
                            },
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.blue,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.050,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//RichText(
//                 text: TextSpan(
//                   text: 'Notes App by Hasan\n',
//                   style: TextStyle(
//                       color: Colors.pinkAccent,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold),
//                   children: <TextSpan>[
//                     TextSpan(
//                         text:
//                             'Notes App by Hasan gives you everything you need to keep life organized—great note taking, and easy ways to find what you need, when you need it.\n\n',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             // open desired screen
//                           }),
//                     TextSpan(
//                         text: 'Published by \n',
//                         style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500)),
//                     TextSpan(
//                         text: 'Theme Consultancy\n',
//                         style: TextStyle(
//                           color: Colors.pinkAccent,
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             // open desired screen
//                           }),
//                     TextSpan(
//                         text:
//                             'and subtitled ‘proudly notes taking app\'. It is evocative and enticing.\n\n',
//                         style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500)),
//                     // TextSpan(
//                     //   text:
//                     //       'Our Mother was born in Zanzibar to Muslim parents and grew up in Zanzibar and then moved to Tanzania and Mombasa. In her cooking, she has taken traditional and regional home cooking which she transposed to her family where local availability of ingredients influence a recipe. She termed it loosely as',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text: '‘Notes App by Hasan’.\n\n',
//                     //   style: TextStyle(
//                     //     color: Colors.pinkAccent,
//                     //     fontSize: 26,
//                     //     fontWeight: FontWeight.bold,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text:
//                     //       'Maa (which means Mother in Kishwali) spent her early years in Zanzibar & Kenya.\n\n',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text:
//                     //       'Our Mother have taught us to cook fantastic recipes which she has passed along to her daughters, daughters in law and grand children to follow. ',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text:
//                     //       '\n\nThe family was quite large and during her childhood, there were often up to twenty-five people in the house at once. That is a lot of mouths to feed and all the women and girls had to help. Recipes were passed along the generations through experience rather than written down.',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text: '\n\nWith',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text: '\ \'Maa\'s kitchen\'',
//                     //   style: TextStyle(
//                     //     color: Colors.pinkAccent,
//                     //     fontSize: 26,
//                     //     fontWeight: FontWeight.bold,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text:
//                     //       ', we aim to retrace and keep a record of all those recipes for the generations to come. So that the memory of our Maa stays with our children, grand children and more in the community.',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//                     // TextSpan(
//                     //   text:
//                     //       'We Miss you our Lovely Maa and pray we all follow your foot steps of a such a lovely and caring Mother to all.',
//                     //   style: TextStyle(
//                     //     color: Colors.blue,
//                     //     fontSize: 20,
//                     //     fontWeight: FontWeight.w500,
//                     //   ),
//                     // ),
//
//                     TextSpan(
//                       text: '\n\n\nThis app is organized by',
//                       style: TextStyle(
//                         color: Colors.pinkAccent,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '\nHasan Abbas Sorathiya',
//                       style: TextStyle(
//                         color: Colors.pinkAccent,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '\n(India / Dubai / Canada )',
//                       style: TextStyle(
//                         color: Colors.pinkAccent,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '\nand developed by\t\n',
//                       style: TextStyle(
//                         color: Colors.pinkAccent,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     TextSpan(
//                       text: 'Hasan Abbas Sorathiya\n',
//                       style: TextStyle(
//                         color: Colors.pinkAccent,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '+917021707223\n',
//                       recognizer: new TapGestureRecognizer()
//                         ..onTap = () async {
//                           await launchInBrowser("tel:+917021707223");
//                         },
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: 'hasanabbassorathiya@gmail.com\n',
//                       recognizer: new TapGestureRecognizer()
//                         ..onTap = () async {
//                           await sentEmail("hasanabbassorathiya@gmail.com");
//                         },
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
