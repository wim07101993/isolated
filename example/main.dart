import 'dart:convert';
import 'dart:developer';

import 'package:isolated/isolated.dart';

const factory = IsolateBundleFactory();

Future<void> main() async {
  log('Start');
  final bundle = await factory
      .startNewPingPong<IsolateBundleConfiguration, String, Object>(
    deserialize,
    (toCaller) => IsolateBundleConfiguration(toCaller),
  );

  final deserialized = await bundle.pingPong('{"Property": "Hello world"}');
  log(deserialized.toString());
}

void deserialize(IsolateBundleConfiguration config) {
  config.activateOnCurrentIsolate<PingPongMessage<String>>(
    (message) {
      config.toCaller.send(PingPongMessage(
        message.id,
        jsonDecode(message.value),
      ));
    },
    (cancelMessage) {},
  );
  log('here');
}
