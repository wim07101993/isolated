import 'dart:convert';

import 'package:isolated/isolated.dart';

const factory = IsolateBundleFactory();

Future<void> main() async {
  final bundle = await factory
      .startNewPingPong<IsolateBundleConfiguration, String, dynamic>(
    deserialize,
    (toCaller) => IsolateBundleConfiguration(toCaller),
  );

  final deserialized = await bundle.pingPong('{"Property": "Hello world"}');
  // ignore:avoid_print
  print(deserialized.toString());
  bundle.cancel();
}

void deserialize(IsolateBundleConfiguration config) {
  config.activateOnCurrentIsolate<PingPongMessage<String>>(
    (message) {
      config.toCaller.send(PingPongMessage<dynamic>(
        message.id,
        jsonDecode(message.value),
      ));
    },
    (cancelMessage) {},
  );
}
