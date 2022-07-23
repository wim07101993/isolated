import 'dart:async';

import 'package:isolated/src/isolate_bundle.dart';
import 'package:isolated/src/isolate_bundle_configuration.dart';
import 'package:isolated/src/isolate_bundle_factory.dart';

/// Base message for a [PingPongIsolateBundle].
///
/// Contains an [id] to identify the 'session'. This id is generated when
/// sending the message to the isolate. When a message is received from that
/// isolate, the id is checked to know whether the [pingPong] method should
/// return.
///
/// The [value] is the actual payload for the receiving isolate.
class PingPongMessage<T> {
  /// Base message for a [PingPongIsolateBundle].
  ///
  /// Contains an [id] to identify the 'session'. This id is generated when
  /// sending the message to the isolate. When a message is received from that
  /// isolate, the id is checked to know whether the [pingPong] method should
  /// return.
  ///
  /// The [value] is the actual payload for the receiving isolate.
  const PingPongMessage(this.id, this.value);

  /// Used to identify the 'session'.
  ///
  /// This id is generated when sending the message to the isolate. When a
  /// message is received from that isolate, the id is checked to know whether
  /// the [pingPong] method should return.
  final String id;

  /// The the actual payload for the receiving isolate.
  final T value;
}

/// Wraps an [IsolateBundle] to make it 'request-response'.
///
/// With the [pingPong] method it is possible to send a message (ping) and waits
/// for a response message (pong).
class PingPongIsolateBundle<TConfig extends IsolateBundleConfiguration, TSend,
    TReceive> {
  /// Wraps an [IsolateBundle] to make it 'request-response'.
  ///
  /// With the [pingPong] method it is possible to send a message (ping) and waits
  /// for a response message (pong).
  PingPongIsolateBundle(this._isolateBundle) {
    _subscription = _isolateBundle.messages.listen(_onReceiveFromIsolate);
  }

  final IsolateBundle<TConfig, PingPongMessage<TSend>,
      PingPongMessage<TReceive>> _isolateBundle;

  late final StreamSubscription _subscription;
  final _callCompleters = <String, Completer<TReceive>>{};

  /// Sends [ping] to the isolate and waits for a response (pong) which is
  /// returned in the [Future].
  Future<TReceive> pingPong(TSend ping) async {
    final id = uuid.v1();
    final completer = Completer<TReceive>();
    _callCompleters[id] = completer;
    _isolateBundle.send(PingPongMessage(id, ping));
    final pong = await completer.future;
    _callCompleters.remove(id);
    return pong;
  }

  void _onReceiveFromIsolate(PingPongMessage<TReceive> message) {
    final completer = _callCompleters[message.id];
    if (completer != null) {
      completer.complete(message.value);
      _callCompleters.remove(message.id);
    }
  }

  /// Cancels the isolate bundle.
  ///
  /// [cancelMessage] can be used to give information about why the bundle
  /// should be stopped.
  ///
  /// Stops listening to the ReceivePort from the isolate and sends the cancel
  /// signal through the SendPort.
  Future<void> cancel([
    CancelMessage cancelMessage = const CancelMessage(),
  ]) async {
    await _isolateBundle.cancel(cancelMessage);
    await _subscription.cancel();
  }
}
