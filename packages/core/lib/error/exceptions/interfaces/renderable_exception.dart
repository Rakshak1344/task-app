import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin RenderableException implements Exception {
  Widget render();

  static bool showStackTrace = kDebugMode;

  static Widget renderAny(Object e, [StackTrace? stackTrace]) {
    if (e is RenderableException) {
      return e.render();
    }

    if (stackTrace != null && showStackTrace) {
      return _buildStacktraceWidget(e, stackTrace);
    }

    return Center(child: Text(e.toString(), textAlign: TextAlign.center));
  }

  static Widget _buildStacktraceWidget(Object e, StackTrace stackTrace) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Builder(builder: (context) {
        return Column(
          children: [
            Text(e.toString()),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _buildStacktraceDialog(e, stackTrace),
                );
              },
              child: const Text('Show Stacktrace'),
            ),
          ],
        );
      }),
    );
  }

  static Widget _buildStacktraceDialog(Object e, StackTrace stackTrace) {
    return AlertDialog(
      title: Text(e.toString()),
      content: SizedBox(
        height: 400,
        child: Column(
          children: [
            Expanded(child: Text(stackTrace.toString())),
          ],
        ),
      ),
    );
  }
}
