import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/models/drawer_item.dart';

List<DrawerItem> itemsFirst = [
  DrawerItem(title: 'Notes', icon: Icons.notes_rounded),
  DrawerItem(title: 'My Profile', icon: Icons.emoji_people_outlined),
  Get.isDarkMode
      ? DrawerItem(
          title: 'Dark Mode',
          icon: (Icons.wb_sunny),
        )
      : DrawerItem(
          title: 'Light Mode',
          icon: (Icons.nights_stay_outlined),
        ),
  //DrawerItem(title: 'Performance & Optimization', icon: Icons.build),
];

List<DrawerItem> itemsSecond = [
  DrawerItem(title: 'Feedback', icon: Icons.cloud_upload),
  DrawerItem(title: 'About Us', icon: Icons.extension),
  DrawerItem(title: 'Signout', icon: Icons.exit_to_app_rounded),
];
