import 'dart:async';
import 'dart:isolate';

import 'package:uuid/uuid.dart';

import 'isolate_bundle.dart';
import 'isolate_bundle_configuration.dart';
import 'ping_pong_isolate_bundle.dart';

/// Global instance of [Uuid].
///
/// Just to not declare it locally...
const uuid = Uuid();

/// Creates instances of [IsolateBundle]s.
class IsolateBundleFactory {
  /// Creates instances of [IsolateBundle]s.
  const IsolateBundleFactory();

  /// Spawns a new isolate using the given parameters and initializes it for
  /// bidirectional communication.
  ///
  /// The argument [entryPoint] specifies the initial function to call
  /// in the spawned isolate.
  /// The entry-point function is invoked in the new isolate with result of the
  /// [configBuilder] as the only argument.
  ///
  /// In the [entryPoint] function, the
  /// [IsolateBundleConfiguration.activateOnCurrentIsolate] should be called to
  /// initialize the isolate. If this is not called, this function will not
  /// return since it waits for a response from that method.
  ///
  /// [name] is the name of the isolate. If no [name] is provided, one is
  /// generated in the format of a uuid.
  ///
  /// For the other parameters of this method, look at the documentation of the
  /// [Isolate.spawn] method.
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
      } else {
        throw Exception(
            'Received message $message of type ${message.runtimeType} while expecting $TReceive');
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
      id: id,
      isolate: isolate,
      config: config,
      send: toIsolatePort.send,
      messages: fromIsolateStreamController.stream,
      cancel: (cancelMessage) async {
        await subscription.cancel();
        toIsolatePort.send(cancelMessage);
      },
    );
  }

  /// Starts a new isolate which can send a 'ping' message after which it waits
  /// for a 'pong' response.
  ///
  /// For documentation of the parameters look at [startNew].
  Future<PingPongIsolateBundle<TConfig, TSend, TReceive>> startNewPingPong<
      TConfig extends IsolateBundleConfiguration, TSend, TReceive>(
    void Function(TConfig message) entryPoint,
    TConfig Function(SendPort toCaller) configBuilder, {
    bool paused = false,
    bool errorsAreFatal = true,
    SendPort? onExit,
    SendPort? onError,
    String? name,
  }) async {
    return startNew<TConfig, PingPongMessage<TSend>, PingPongMessage<TReceive>>(
      entryPoint,
      configBuilder,
      paused: paused,
      errorsAreFatal: errorsAreFatal,
      onExit: onExit,
      onError: onError,
      name: name,
    ).then((isolateBundle) => PingPongIsolateBundle(isolateBundle));
  }
}

/// Message which stops an [IsolateBundle].
class CancelMessage {
  /// Message which stops an [IsolateBundle].
  const CancelMessage();
}
