import 'dart:async';
import 'dart:isolate';

import 'package:isolated/isolated.dart';

import 'isolate_bundle_configuration.dart';

/// Wraps an isolate together with an id, config and channels to send and
/// receive messages between them.
///
/// Sending messages can be done with the [send] property. All messages which
/// come from the isolate are streamed in the [messages] property.
///
/// To release all resources of an instance the [cancel] method should be called.
class IsolateBundle<TConfig extends IsolateBundleConfiguration, TSend,
    TReceive> {
  /// Wraps an isolate together with an id, config and channels to send and
  /// receive messages between them.
  ///
  /// Sending messages can be done with the [send] property. All messages which
  /// come from the isolate are streamed in the [messages] property.
  ///
  /// To release all resources of an instance the [cancel] property should be
  /// invoked.
  IsolateBundle({
    required this.id,
    required this.isolate,
    required this.config,
    required this.send,
    required this.messages,
    required this.cancel,
  });

  /// The id/name of the [isolate].
  final String id;

  /// The isolate with which this bundle communicates.
  final Isolate isolate;

  /// The configuration which was used to initialize the [isolate].
  final TConfig config;

  /// Sends a message to the [isolate].
  final void Function(TSend message) send;

  /// Streams the messages which are received from the [isolate].
  final Stream<TReceive> messages;

  /// Cancels the isolate bundle.
  ///
  /// Stops listening to the ReceivePort from the isolate and sends the cancel
  /// signal through the SendPort.
  final Future<void> Function(CancelMessage cancelMessage) cancel;
}
