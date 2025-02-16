import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  PageController pageViewController = PageController();
  int currentPage = 0;

  nextPage() async {
    currentPage++;
    update();
    await pageViewController.nextPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutExpo,
    );
    update();
  }

  previousPage() async {
    currentPage--;
    update();
    await pageViewController.previousPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutExpo,
    );
    update();
  }

  goTo(int index) async {
    currentPage = index;
    update();
    await pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutExpo,
    );
    update();
  }
}
