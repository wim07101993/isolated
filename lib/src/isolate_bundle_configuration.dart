import 'dart:isolate';

abstract class IsolateBundleConfiguration {
  const IsolateBundleConfiguration();

  SendPort get toCaller;

  void activateOnCurrentIsolate(
    void Function(dynamic message) messageHandler,
  ) {
    final fromCaller = ReceivePort();
    final toIsolate = fromCaller.sendPort;

    fromCaller.listen(messageHandler);
    toCaller.send(toIsolate);
  }
}
