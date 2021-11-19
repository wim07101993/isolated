part of 'isolate_bundle_test.dart';

class MockSender<T> extends Mock implements Sender<T> {}

abstract class Sender<T> {
  void send(T message);
}
