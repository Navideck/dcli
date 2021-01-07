import 'dart:async';

import 'dart:cli';

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/stack_trace_impl.dart';

void main() {
  var future = startProcess();

  print('****************waitforMe *****************');
  waitForMe(future);

  future = startProcess();

  waitForEx(future);
}

Future<Process> startProcess() {
  return Process.start(
    'invalidcommandname',
    [],
  );
}

void waitForMe(Future future) {
  try {
    future
        //ignore: avoid_types_on_closure_parameters
        .catchError((Object e, StackTrace st) => print('onError: $e'))
        .whenComplete(() => print('future completed'));
    // print(waitFor<Process>(future));
    print(waitFor(future));
  } // on AsyncError
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    if (e is AsyncError) {
      print('Rethrowing a non DCliException $e');
      rethrow;
    } else {
      print('Rethrowing a non DCliException $e');
      rethrow;
    }
  } finally {
    print('waitForEx finally');
  }
}

T? waitForEx<T>(Future<T> future) {
  Object? exception;
  T? value;
  try {
    // catch any unhandled exceptions
    //ignore: avoid_types_on_closure_parameters
    future.catchError((Object e, StackTrace st) {
      print('catchError called');
      exception = e;
    }).whenComplete(() => print('future completed'));

    runZonedGuarded(() {
      value = waitFor<T>(future);
    }, (Object error, StackTrace st) {
      exception = error;
    });
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    exception = e.error;
  } finally {
    print('existing try');
  }

  if (exception != null) {
    // recreate the exception so we have a full
    // stacktrace rather than the microtask
    // stacktrace the future leaves us with.
    final stackTrace = StackTraceImpl(skipFrames: 2);

    if (exception is DCliException) {
      throw (exception as DCliException).copyWith(stackTrace);
    } else {
      throw DCliException.from(exception, stackTrace);
    }
  }
  return value;
}

Future<int> throwExceptionV3() {
  final complete = Completer<int>();
  try {
    final future =
        Future.delayed(const Duration(seconds: 2), () => throw Exception());
    //ignore: avoid_types_on_closure_parameters
    future.catchError((Object e) {
      print('caught 1');
      complete.completeError('caught ');
    });
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    print('e');
  }
  return complete.future;
}
