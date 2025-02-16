import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';

class MyWidgetsAnimator extends StatelessWidget {
  final DatabaseExecutionStatus dbExecutionStatus;
  final Widget Function() successWidget;
  final Widget Function()? loadingWidget;
  final Widget Function()? errorWidget;
  final Duration? animationDuration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;
  final bool hideSuccessWidgetWhileRefreshing;

  const MyWidgetsAnimator({
    Key? key,
    required this.dbExecutionStatus,
    required this.successWidget,
    this.loadingWidget,
    this.errorWidget,
    this.animationDuration,
    this.transitionBuilder,
    this.hideSuccessWidgetWhileRefreshing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration ?? const Duration(milliseconds: 300),
      child: switch (dbExecutionStatus) {
        (DatabaseExecutionStatus.success) => successWidget,
        (DatabaseExecutionStatus.error) => errorWidget ??
            () {
              return const SizedBox();
            },
        (DatabaseExecutionStatus.loading) => loadingWidget ??
            () => Center(
                  child: CupertinoActivityIndicator(
                    radius: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
      }(),
      transitionBuilder:
          transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
    );
  }
}
