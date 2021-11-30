# Isolated

Provides functionality to easily
use [Isolates](https://api.dart.dev/stable/2.14.4/dart-isolate/Isolate-class.html)
.

## Features

### `IsolateBundle`

An `IsolateBundle` wraps an `Isolate` together with a send-function and a 
message-stream. This bundle can be generated with the `IsolateBundleFactory`.
This factory handles te configuration of the `SendPort` and `ReceivePort` as 
well as the cleanup afterwards.

### `PingPongIsolateBundle`

This is an `IsolateBundle` which implements a request-response pattern. The 
bundle can be used to send a message to the `Isolate`, which will handle the 
message. When the `Isolate` is ready it will respond back to the calling 
`Isolate` and the `pingPong` function will return.

## Usage

1. Create a top-level or static function which will handle the computation. 
**The `config.activateOnCurrentIsolate` must be called to in order to configure
the `Isolate` correctly.**

```dart
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

```
2. Create a bundle with the `IsolateBundleFactory`

```dart
final bundle = await factory
    .startNewPingPong<IsolateBundleConfiguration, String, dynamic>(
  deserialize,
  (toCaller) => IsolateBundleConfiguration(toCaller),
);
```

2. Send a message to the `Isolate`

```dart
final deserialized = await bundle.pingPong('{"Property": "Hello world"}');
```

3. The computed value will be returned.

The complete code example can be found in the [example folder](https://github.com/wim07101993/isolated/blob/master/example/main.dart).
