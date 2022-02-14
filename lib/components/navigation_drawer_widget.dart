import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/Styles.dart';
import 'package:notes/Controller/authController.dart';
import 'package:notes/Controller/navigation_provider.dart';
import 'package:notes/Controller/userController.dart';
import 'package:notes/Home.dart';
import 'package:notes/Screens/About%20Us/about_us.dart';
import 'package:notes/Screens/Feedback/feedback.dart';
import 'package:notes/Screens/profile/myProfile.dart';
import 'package:notes/components/drawer_items.dart';
import 'package:notes/models/drawer_item.dart';

class NavigationDrawerWidget extends StatefulWidget {
  @override
  _NavigationDrawerWidgetState createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);

    final provider = Get.put(NavigationController());
    final isCollapsed = provider.isCollapsed.value;
    bool isdrag = false;
    return Container(
      width: isCollapsed ? MediaQuery.of(context).size.width * 0.2 : null,
      child: Drawer(
        child: Container(
          color: Get.isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.deepPurple,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 24).add(safeArea),
                width: double.infinity,
                color: Colors.white12,
                child: buildHeader(isCollapsed),
              ),
              const SizedBox(height: 24),
              StatefulBuilder(builder: (context, snapshot) {
                return buildList(items: [
                  DrawerItem(title: 'Dashboard', icon: Icons.notes_rounded),
                  DrawerItem(
                      title: 'My Profile', icon: Icons.emoji_people_outlined),
                  !Get.isDarkMode
                      ? DrawerItem(
                          title: 'Dark Mode',
                          icon: (Icons.wb_sunny),
                        )
                      : DrawerItem(
                          title: 'Light Mode',
                          icon: (Icons.nights_stay_outlined),
                        ),
                  //DrawerItem(title: 'Performance & Optimization', icon: Icons.build),
                ], isCollapsed: isCollapsed);
              }),
              const SizedBox(height: 24),
              Divider(color: Colors.white70),
              const SizedBox(height: 24),
              buildList(
                indexOffset: itemsFirst.length,
                items: itemsSecond,
                isCollapsed: isCollapsed,
              ),
              Spacer(),
              buildCollapseIcon(context, isCollapsed),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildList({
    bool isCollapsed,
    List<DrawerItem> items,
    int indexOffset = 0,
  }) =>
      ListView.separated(
        padding: isCollapsed ? EdgeInsets.zero : padding,
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          DrawerItem item = items[index];

          return buildMenuItem(
            isCollapsed: isCollapsed,
            text: item.title,
            icon: item.icon,
            onClicked: () => selectItem(context, indexOffset + index),
          );
        },
      );

  void selectItem(BuildContext context, int index) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        Get.to(Home());
        break;
      case 1:
        Get.to(MyProfileScreen());
        break;
      case 2:
        Get.changeTheme(Styles.themeData(!Get.isDarkMode, context));
        setState(() {
          debugPrint('Darrk' + (!Get.isDarkMode).toString());
        });
        break;
      case 3:
        Get.to(FeedbackForm());
        break;
      case 4:
        Get.to(AboutUs());
        break;
      case 5:
        Get.find<AuthController>().signOut();
        break;
    }
  }

  Widget buildMenuItem({
    bool isCollapsed,
    String text,
    IconData icon,
    VoidCallback onClicked,
  }) {
    final color = Colors.white;
    final leading = Icon(icon, color: color);

    return Material(
      color: Colors.transparent,
      child: isCollapsed
          ? ListTile(
              title: leading,
              onTap: onClicked,
            )
          : ListTile(
              leading: leading,
              title: Text(text, style: TextStyle(color: color, fontSize: 16)),
              onTap: onClicked,
            ),
    );
  }

  Widget buildCollapseIcon(BuildContext context, bool isCollapsed) {
    final double size = 52;
    final icon = isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
    final alignment = isCollapsed ? Alignment.center : Alignment.centerRight;
    final margin = isCollapsed ? null : EdgeInsets.only(right: 16);
    final width = isCollapsed ? double.infinity : size;

    return Container(
      alignment: alignment,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Container(
            width: width,
            height: size,
            child: Icon(icon, color: Colors.white),
          ),
          onTap: () {
            final provider = Get.put(NavigationController());

            provider.toggleIsCollapsed();
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget buildHeader(bool isCollapsed) => isCollapsed
      ? Get.put(UserController()).userModel.profilePic != null &&
              Get.put(UserController()).userModel.name.isNotEmpty
          ? CircleAvatar(
              radius: 28,
              backgroundImage:
                  NetworkImage(Get.put(UserController()).userModel.profilePic),
            )
          : CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('assets/images/blankpp.png'),
            )
      : Row(
          children: [
            const SizedBox(width: 24),
            Get.put(UserController()).userModel.profilePic != null &&
                    Get.put(UserController()).userModel.name.isNotEmpty
                ? CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(
                        Get.put(UserController()).userModel.profilePic),
                  )
                : CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage('assets/images/blankpp.png'),
                  ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                '${Get.put(UserController()).userModel.name.toString() ?? 'User'}',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        );
}
