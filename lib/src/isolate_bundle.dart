import 'dart:async';
import 'dart:isolate';

import 'isolate_bundle_configuration.dart';

class IsolateBundle<TConfig extends IsolateBundleConfiguration, TSend,
    TReceive> {
  IsolateBundle({
    required StreamSubscription listeningSubscription,
    required this.id,
    required this.isolate,
    required this.config,
    required this.send,
    required this.messages,
  }) : _listeningSubscription = listeningSubscription;

  final StreamSubscription _listeningSubscription;

  final String id;
  final Isolate isolate;
  final TConfig config;
  final void Function(TSend message) send;
  final Stream<TReceive> messages;

  Future<void> close() {
    return _listeningSubscription.cancel();
  }
}
