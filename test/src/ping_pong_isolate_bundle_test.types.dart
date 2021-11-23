part of 'ping_pong_isolate_bundle_test.dart';

class MockSender<T> extends Mock implements _Sender<T> {}

class MockCanceler extends Mock implements _Canceler {}

abstract class _Sender<T> {
  void send(T message);
}

abstract class _Canceler {
  Future<void> cancel(CancelMessage cancelMessage);
}
