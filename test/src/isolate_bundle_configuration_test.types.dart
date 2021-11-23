part of 'isolate_bundle_configuration_test.dart';

class _MockListener extends Mock implements _Listener {}

abstract class _Listener {
  void handler(dynamic message);
  Future<void> cancel(CancelMessage message);
}
