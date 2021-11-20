import 'dart:async';
import 'dart:isolate';

import 'isolate_bundle.dart';
import 'isolate_bundle_configuration.dart';
import 'isolate_bundle_factory.dart';

class PingPongMessage<T> {
  const PingPongMessage(this.id, this.value);

  final String id;
  final T value;
}

class PingPongIsolateBundle<TSend, TReceive,
        TConfig extends IsolateBundleConfiguration>
    extends IsolateBundle<TConfig, PingPongMessage<TSend>,
        PingPongMessage<TReceive>> {
  PingPongIsolateBundle({
    required StreamSubscription listeningSubscription,
    required String id,
    required Isolate isolate,
    required TConfig config,
    required void Function(PingPongMessage<TSend> message) send,
    required Stream<PingPongMessage<TReceive>> messages,
  }) : super(
          listeningSubscription: listeningSubscription,
          id: id,
          isolate: isolate,
          config: config,
          send: send,
          messages: messages,
        ) {
    subscription = messages.listen(_onReceiveFromIsolate);
  }

  late final StreamSubscription subscription;
  final _callCompleters = <String, Completer<TReceive>>{};

  Future<TReceive> pingPong(TSend ping) async {
    final id = uuid.v1();
    final completer = Completer<TReceive>();
    _callCompleters[id] = completer;
    send(PingPongMessage(id, ping));
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

  @override
  Future<void> close() async {
    await super.close();
    await subscription.cancel();
  }
}
