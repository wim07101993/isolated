import 'dart:async';
import 'dart:isolate';

import 'isolate_bundle_factory.dart';

/// Base configuration for creating an isolate bundle.
///
/// The [IsolateBundleFactory] will send this configuration to the isolate when
/// it is spawned. The [toCaller] is used to send a [SendPort] back to the
/// caller.
///
/// In the entry-point of the isolate the [activateOnCurrentIsolate] should
/// be called to set up the [SendPort] and [ReceivePort].
class IsolateBundleConfiguration {
  /// Base configuration for creating an isolate bundle.
  ///
  /// The [IsolateBundleFactory] will send this configuration to the isolate when
  /// it is spawned. The [toCaller] is used to send a [SendPort] back to the
  /// caller.
  ///
  /// In the entry-point of the isolate the [activateOnCurrentIsolate] should
  /// be called to set up the [SendPort] and [ReceivePort].
  const IsolateBundleConfiguration(this.toCaller);

  /// [SendPort] with which messages can be sent to the isolate which spawned
  /// the isolate.
  final SendPort toCaller;

  /// Activates the current configuration on the current isolate.
  ///
  /// In the entry-point of the isolate this method should be called to set up
  /// the [SendPort] and [ReceivePort].
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
