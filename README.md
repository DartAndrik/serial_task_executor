<h2 align="center">SerialTaskExecutor</h2>
A Dart package providing a simple and efficient way to execute tasks serially, ensuring that each task is completed before the next one begins. `SerialTaskExecutor` is useful for scenarios where tasks need to be executed in order without overlapping, such as sync operations sequence, networking or file operations.

<p align="center">
<a href="https://pub.dev/packages/serial_task_executor"><img src="https://img.shields.io/pub/v/serial_task_executor.svg" alt="Pub"></a>
<a href="https://codecov.io/gh/DartAndrik/serial_task_executor"><img src="https://codecov.io/gh/DartAndrik/serial_task_executor/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/passsy/dart-lint"><img src="https://img.shields.io/badge/style-lint-40c4ff.svg" alt="style: lint"></a>
</p>
<p align="center">

## Features

- Ensures serial execution of asynchronous tasks.
- Maintains task order, executing tasks in the sequence they were added.
- Tasks exceptions don't blocking the entire execution queue.
- Supports returning results from tasks.

## Getting Started

To use `SerialTaskExecutor` in your Dart project, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  serial_task_executor: ^1.0.0
```
Then import the package in your Dart code:

```dart
import 'package:serial_task_executor/serial_task_executor.dart';

```

## Usage

Create an instance of SerialTaskExecutor:
```dart
final executor = SerialTaskExecutor();

Future<SomeOperationResult> runSyncOperationSequence() {
  return executor.executeTask(_runSyncOperationSequence);
}

Future<SomeOperationResult> _runSyncOperationSequence() async {
  await _upSyncOperation();
  await _downSyncOperation();
  return _getSyncResult();
}
```
Each task will be executed in the order they were added, and the next task will not start until the current one is completed.

## Handling Errors

Errors in tasks can be handled using standard try-catch blocks or Future error handling mechanisms:
```dart
executor.executeTask(() async {
  try {
    // Task code that might throw
  } catch (e) {
    // Error handling
  }
});
```
Notably, an unhandled error will not affect the sequential execution of other tasks in the queue. All tasks in the queue will be executed in the order they were added, even if one or more tasks throw an unhandled exception.
