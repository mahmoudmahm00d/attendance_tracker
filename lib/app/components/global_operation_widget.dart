import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GlobalOperationWidget extends StatefulWidget {
  final String image;
  final String title;
  final String subTitle;
  final Function()? operation;
  const GlobalOperationWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.operation,
  });

  @override
  State<GlobalOperationWidget> createState() => _GlobalOperationWidgetState();
}

class _GlobalOperationWidgetState extends State<GlobalOperationWidget> {
  bool loading = true;

  exec() async {
    var result = await widget.operation!();
    setState(() {
      loading = false;
    });

    Future.delayed(const Duration(seconds: 1));
    Get.toNamed(Routes.home);
    if (result == null) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Error",
        message: "Something went wrong",
      );
    } else {
      CustomSnackBar.showCustomSnackBar(
        title: "Exported",
        message: result,
      );
    }
  }

  @override
  void initState() {
    exec();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 160),
            SizedBox(
              width: 240,
              height: 240,
              child: SvgPicture.asset(widget.image),
            ),
            const Spacer(),
            if (loading)
              Center(
                child: CupertinoActivityIndicator(
                  radius: 16,
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              const Center(
                child: Icon(
                  PhosphorIconsBold.checkCircle,
                  color: Colors.green,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: context.theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32)
          ],
        ),
      ),
    );
  }
}
