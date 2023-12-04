import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:serial_task_executor/serial_task_executor.dart';

void main() {
  group('SerialTaskExecutor Functionality', () {
    const maxCounterValue = 2;
    late SerialTaskExecutor executor;

    late Completer<void> firstExecutionCompleter;
    late Completer<void> secondExecutionCompleter;

    late Future<int> Function(int) taskWithReturningResult;

    late Future<int> Function(int) firstTaskWithCompletion;
    late Future<int> Function(int) secondTaskWithCompletion;

    late Future<int> Function(int) taskWithException;

    final resultList = <int>[];

    setUp(() {
      executor = SerialTaskExecutor();
      resultList.clear();
      firstExecutionCompleter = Completer();
      secondExecutionCompleter = Completer();
      taskWithReturningResult = (counter) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));

        return counter;
      };
      firstTaskWithCompletion = (counter) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        resultList.add(counter);
        if (counter == maxCounterValue) {
          firstExecutionCompleter.complete();
        }
        return counter;
      };
      secondTaskWithCompletion = (counter) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        resultList.add((counter + 1) * 10);
        if (counter == maxCounterValue) {
          secondExecutionCompleter.complete();
        }
        return counter;
      };
      taskWithException = (counter) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        resultList.add(counter);
        if (counter < maxCounterValue) {
          throw TestFailure('$counter');
        }
        firstExecutionCompleter.complete();
        return counter;
      };
    });

    test('Serial tasks async executions result returns', () async {
      final expectedResult = [0, 1, 2];
      for (var counter = 0; counter <= maxCounterValue; counter++) {
        final value = await executor.executeTask<int>(
          () => taskWithReturningResult(counter),
        );
        resultList.add(value);
      }

      expect(resultList, expectedResult);
    });

    test('Serial tasks sync executions sequence', () async {
      final expectedResult = [0, 10, 1, 20, 2, 30];
      for (var counter = 0; counter <= maxCounterValue; counter++) {
        unawaited(
          executor.executeTask(() => firstTaskWithCompletion(counter)),
        );
        unawaited(
          executor.executeTask(() => secondTaskWithCompletion(counter)),
        );
      }

      await firstExecutionCompleter.future;
      await secondExecutionCompleter.future;
      expect(resultList, expectedResult);
    });

    test('Exceptions in tasks execution do not disrupt the overall sequence',
        () async {
      final expectedResult = [0, 1, 2];
      runZonedGuarded(
        () {
          for (var counter = 0; counter <= maxCounterValue; counter++) {
            unawaited(
              executor.executeTask<int>(() => taskWithException(counter)),
            );
          }
        },
        (error, s) {
          expect(error is TestFailure, true);
          expect(
            int.tryParse('${(error as TestFailure).message}') != null,
            true,
          );
        },
      );

      await firstExecutionCompleter.future;
      expect(resultList, expectedResult);
    });
  });
}
