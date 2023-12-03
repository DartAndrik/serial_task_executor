import 'dart:async';

/// TaskToken is an abstract class representing a token for task execution.
/// It serves as a base class for different types of task execution tokens.
sealed class TaskToken {}

/// ImmediateTaskToken represents a token for tasks that can
/// be executed immediately.
/// This token is used when there are no pending tasks in the queue,
/// allowing the task to be executed without waiting.
class ImmediateTaskToken implements TaskToken {}

/// QueuedTaskToken represents a token for tasks that must be queued
/// for execution.
/// This token is used when there are pending tasks, and the associated
/// task must wait for its turn to be executed.
///
/// It contains a Completer, which is used to await the completion
/// of previous tasks in the queue before starting the execution of
/// the associated task.
class QueuedTaskToken implements TaskToken {
  /// The completer is used to manage the completion state of this task token.
  /// It allows the SerialTaskExecutor to await the completion of previous tasks
  /// in the queue before starting the execution of the task associated
  /// with this token.
  ///
  /// The task associated with this token will commence its execution only when
  /// the `complete` method of this completer is called, indicating that the
  /// preceding tasks in the queue have been completed.
  final completer = Completer<void>();
}
