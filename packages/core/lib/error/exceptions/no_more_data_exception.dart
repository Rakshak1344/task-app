import 'package:core/error/exceptions/interfaces/renderable_exception.dart';
import 'package:core/error/exceptions/interfaces/reportable_exception.dart';
import 'package:flutter/material.dart';

class NoMoreDataException with RenderableException, ReportableException {
  @override
  Widget render() => const SizedBox.shrink();

  @override
  bool shouldReport() => false;
}
