import 'dart:async';

import 'isolate_bundle.dart';
import 'isolate_bundle_configuration.dart';
import 'isolate_bundle_factory.dart';

class PingPongMessage<T> {
  const PingPongMessage(this.id, this.value);

  final String id;
  final T value;
}

class PingPongIsolateBundle<TConfig extends IsolateBundleConfiguration, TSend,
    TReceive> {
  PingPongIsolateBundle(this._isolateBundle) {
    _subscription = _isolateBundle.messages.listen(_onReceiveFromIsolate);
  }

  final IsolateBundle<TConfig, PingPongMessage<TSend>,
      PingPongMessage<TReceive>> _isolateBundle;

  late final StreamSubscription _subscription;
  final _callCompleters = <String, Completer<TReceive>>{};

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

  Future<void> cancel(CancelMessage cancelMessage) async {
    await _isolateBundle.cancel(cancelMessage);
    await _subscription.cancel();
  }
}
