import 'dart:async';
import 'dart:isolate';

import 'package:uuid/uuid.dart';

import 'isolate_bundle.dart';
import 'isolate_bundle_configuration.dart';

const uuid = Uuid();

class IsolateBundleFactory {
  const IsolateBundleFactory();

  Future<IsolateBundle<TConfig, TSend, TReceive>>
      startNew<TConfig extends IsolateBundleConfiguration, TSend, TReceive>(
    void Function(TConfig message) entryPoint,
    TConfig Function(SendPort toCaller) configBuilder, {
    bool paused = false,
    bool errorsAreFatal = true,
    SendPort? onExit,
    SendPort? onError,
    String? name,
  }) async {
    final id = name ?? uuid.v1();

    final toIsolateCompleter = Completer<SendPort>();
    final fromIsolatePort = ReceivePort();
    final config = configBuilder(fromIsolatePort.sendPort);
    final fromIsolateStreamController = StreamController<TReceive>();

    // since subscription is canceled by the [IsolateBundle]
    // ignore: cancel_subscriptions
    final subscription = fromIsolatePort.listen((message) {
      if (message is SendPort) {
        final toIsolate = message;
        toIsolateCompleter.complete(toIsolate);
      } else if (message is TReceive) {
        fromIsolateStreamController.add(message);
      }
    });

    final isolate = await Isolate.spawn(
      entryPoint,
      config,
      paused: paused,
      errorsAreFatal: errorsAreFatal,
      onExit: onExit,
      onError: onError,
      debugName: id,
    );

    final toIsolatePort = await toIsolateCompleter.future;
    return IsolateBundle(
      listeningSubscription: subscription,
      id: id,
      isolate: isolate,
      config: config,
      send: toIsolatePort.send,
      messages: fromIsolateStreamController.stream,
    );
  }
}
