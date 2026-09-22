import 'package:core/error/exceptions/no_more_data_exception.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

typedef RetryCallback = FutureOr Function()?;
typedef DataCallback<T> = Widget Function(T data);
typedef ErrorCallback = Widget Function(Object error, StackTrace stackTrace);

extension AsyncValueExt<T extends Object> on AsyncValue<T?> {
  /* A convenient extension method for handling various states of an AsyncValue.
   This method allows you to define callbacks for data, error, and loading states,
   as well as customize the behavior when the data is null or empty.
  */
  Widget whenDataWithErrorFallback({
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    RetryCallback onRetry,
    required DataCallback<T> data,
    required ErrorCallback error,
    required ValueGetter<Widget> loading,
    ValueGetter<Widget>? emptyOrNull,
  }) {
    return when(
      skipError: skipError,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipLoadingOnReload: skipLoadingOnReload,
      data: (value) {
        // Check if data is null or empty
        if (value == null || (value is Iterable && value.isEmpty)) {
          // Return the custom empty data widget if provided, otherwise use SizedBox.shrink()
          return _buildNoDataWidget(emptyOrNull);
        }

        return data(value);
      },
      error: (errorObj, stackTrace) {
        final value = this.value;

        /// If there is no data
        if ((value == null || (value is Iterable && value.isEmpty))) {
          // If Data is Empty with NoMoreDataException, build Empty Widget
          if (errorObj is NoMoreDataException) {
            return _buildNoDataWidget(emptyOrNull);
          }

          /// build Error Widget with optional retry handling
          return _buildErrorWidget(error, errorObj, stackTrace, onRetry);
        }

        return data(value);
      },
      loading: loading,
    );
  }

  Widget _buildErrorWidget(
      ErrorCallback error,
      Object errorObj,
      StackTrace stackTrace,
      RetryCallback onRetry,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        error(errorObj, stackTrace),
        const SizedBox(height: 10),
        if (onRetry != null)
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
      ],
    );
  }

  Widget _buildNoDataWidget(ValueGetter<Widget>? noDataWidget) =>
      noDataWidget == null ? const SizedBox.shrink() : noDataWidget();
}

extension AsyncValueStateExt on BuildContext {
  bool didFinishLoading<T>(AsyncValue<T>? previous, AsyncValue<T> next) =>
      previous?.isLoading == true && !next.isLoading;

  bool didStateGetNewData<T>(
      AsyncValue<T>? previous,
      AsyncValue<T> next, {
        bool checkWithPrev = false,
      }) {
    if (checkWithPrev) {
      return didFinishLoading<T>(previous, next) &&
          next.hasValue &&
          previous?.value != next.value;
    }

    return didFinishLoading<T>(previous, next) && next.hasValue;
  }

  bool didStateGetNewError<T>(AsyncValue<T>? previous, AsyncValue<T> next) =>
      didFinishLoading<T>(previous, next) && next.hasError;

  bool didNewErrorOccur<T>(AsyncValue<T>? previous, AsyncValue<T> next) {
    if (previous?.error == next.error) {
      return false;
    }

    if (next.error == null) {
      return false;
    }

    return true;
  }
}