import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:get/get.dart';

class HasAnyGroupMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    var database = await DatabaseHelper().database;
    var result = await database.rawQuery("SELECT id FROM Groups Where id > 1");

    if (result.isNotEmpty) {
      return super.redirectDelegate(route);
    } else {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "No groups found",
        message: "Add a group first",
      );
      return null;
    }
  }
}
