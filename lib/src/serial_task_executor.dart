import 'dart:async';
import 'dart:collection';

import 'package:serial_task_executor/src/task_token.dart';

/// A SerialTaskExecutor is a class that manages the execution of tasks serially
/// in a queue. It ensures that a new task is not started until the previous
/// task is completed. This is useful for scenarios where tasks need to be
/// executed in a specific order without overlapping.
final class SerialTaskExecutor {
  final _executionQueue = Queue<QueuedTaskToken>();
  bool _isImmediateExecution = true;

  /// Creates the next task token which determines the execution behavior
  /// of a task. If immediate execution is possible, it returns
  /// an `ImmediateTaskToken`.Otherwise, it enqueues a `QueuedTaskToken`
  /// and returns it.
  TaskToken _createNextTaskToken() {
    if (_isImmediateExecution) {
      _isImmediateExecution = false;

      return ImmediateTaskToken();
    } else {
      final taskToken = QueuedTaskToken();
      _executionQueue.addLast(taskToken);

      return taskToken;
    }
  }

  /// Releases the given task token after the task execution.
  /// If the task token is a queued one, it is removed from the queue.
  /// If there are no more tasks in the queue, it enables immediate execution
  /// for the next task.
  void _releaseToken(TaskToken taskToken) {
    if (taskToken is QueuedTaskToken) {
      _executionQueue.remove(taskToken);
    }

    if (_executionQueue.isEmpty) {
      _isImmediateExecution = true;
    } else {
      _executionQueue.first.completer.complete();
    }
  }

  /// Waits for the previous task to complete if the current task token
  /// is a queued one.
  Future<void> _waitForPreviousTask(TaskToken taskToken) async {
    if (taskToken is QueuedTaskToken) {
      await taskToken.completer.future;
    }
  }

  /// Executes a given task asynchronously and returns its result.
  /// Tasks are executed in the order they are received without overlapping.
  ///
  /// The method takes a function `task` which is expected
  /// to return a `Future<T>`.
  /// This allows for asynchronous task execution within the executor.
  ///
  /// Example:
  /// ```
  /// final executor = SerialTaskExecutor();
  /// final result = await executor.executeTask(() async {
  ///   return computeExpensiveOperation();
  /// });
  /// ```
  Future<T> executeTask<T>(Future<T> Function() task) async {
    final taskToken = _createNextTaskToken();

    await _waitForPreviousTask(taskToken);

    try {
      final result = await task();

      return result;
    } finally {
      _releaseToken(taskToken);
    }
  }
}
