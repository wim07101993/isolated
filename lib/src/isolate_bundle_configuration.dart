import 'dart:async';
import 'dart:isolate';

import 'isolate_bundle_factory.dart';

abstract class IsolateBundleConfiguration {
  const IsolateBundleConfiguration();

  SendPort get toCaller;

  void activateOnCurrentIsolate<TFromCaller>(
    void Function(TFromCaller message) messageHandler,
    void Function(CancelMessage cancelMessage) cancel,
  ) {
    final fromCaller = ReceivePort();
    final toIsolate = fromCaller.sendPort;

    late final StreamSubscription subscription;
    subscription = fromCaller.listen((message) {
      if (message is CancelMessage) {
        subscription.cancel();
        cancel(message);
      } else if (message is TFromCaller) {
        messageHandler(message);
      }
    });

    toCaller.send(toIsolate);
  }
}
