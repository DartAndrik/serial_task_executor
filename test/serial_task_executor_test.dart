import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:serial_task_executor/serial_task_executor.dart';

void main() {
  group('SerialTaskExecutor tests', () {
    late SerialTaskExecutor executor;
    late Completer<void> executionCompleter;

    setUp(() {
      executor = SerialTaskExecutor();
      executionCompleter = Completer();
    });

    test('Serial tasks async executions result returns', () async {
      final resultList = <int>[];

      for (var counter = 0; counter < 5; counter++) {
        final value = await executor.executeTask<int>(
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));

            return counter;
          },
        );
        resultList.add(value);
      }

      expect(resultList.toString(), '[0, 1, 2, 3, 4]');
    });

    test('Serial tasks sync executions sequence', () async {
      final resultList = <int>[];

      for (var counter = 0; counter < 5; counter++) {
        unawaited(
          executor.executeTask(
            () async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              resultList.add(counter);

              if (counter == 4) {
                executionCompleter.complete();
              }
            },
          ),
        );
      }

      await executionCompleter.future;
      expect(resultList.toString(), '[0, 1, 2, 3, 4]');
    });

    test('Exception while execution process does not imply on sequence',
        () async {
      final resultList = <int>[];
      runZonedGuarded(
        () {
          for (var counter = 0; counter < 5; counter++) {
            unawaited(
              executor.executeTask<int>(
                () async {
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                  resultList.add(counter);
                  if (counter < 4) {
                    throw TestFailure('$counter');
                  }
                  executionCompleter.complete();
                  return counter;
                },
              ),
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

      await executionCompleter.future;
      expect(resultList.toString(), '[0, 1, 2, 3, 4]');
    });
  });
}
