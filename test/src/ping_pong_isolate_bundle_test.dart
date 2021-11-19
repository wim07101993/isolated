import 'dart:async';
import 'dart:isolate';

import 'package:faker/faker.dart';
import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

part 'ping_pong_isolate_bundle_test.types.dart';

void main() {
  // ignore: cancel_subscriptions
  late StreamSubscription mockListeningSubscription;
  // ignore: cancel_subscriptions
  late StreamSubscription<PingPongMessage> mockMessagesSubscription;
  late String fakeId;
  late Isolate mockIsolate;
  late IsolateBundleConfiguration mockConfig;
  late MockSender mockSender;
  late Stream<PingPongMessage> mockMessages;

  late PingPongIsolateBundle isolateBundle;

  setUp(() {
    mockListeningSubscription = MockStreamSubscription();
    mockMessagesSubscription = MockStreamSubscription();
    fakeId = faker.guid.guid();
    mockIsolate = MockIsolate();
    mockConfig = MockIsolateBundleConfiguration();
    mockSender = MockSender();
    mockMessages = MockStream();

    when(() => mockMessages.listen(any())).thenReturn(mockMessagesSubscription);

    isolateBundle = PingPongIsolateBundle(
      listeningSubscription: mockListeningSubscription,
      id: fakeId,
      isolate: mockIsolate,
      config: mockConfig,
      send: mockSender.send,
      messages: mockMessages,
    );
  });

  group('constructor', () {
    test('should set all fields', () {
      // assert
      // assert
      expect(isolateBundle.id, fakeId);
      expect(isolateBundle.isolate, mockIsolate);
      expect(isolateBundle.config, mockConfig);
      expect(isolateBundle.send, mockSender.send);
      expect(isolateBundle.messages, mockMessages);
    });
  });

  group('pingPong', () {
    late StreamController<PingPongMessage> messagesController =
        StreamController();
    late String fakePing;

    setUp(() {
      messagesController = StreamController();
      fakePing = faker.lorem.sentence();

      isolateBundle = PingPongIsolateBundle(
        listeningSubscription: mockListeningSubscription,
        id: fakeId,
        isolate: mockIsolate,
        config: mockConfig,
        send: mockSender.send,
        messages: messagesController.stream,
      );
    });

    test('should send ping the isolate and wait for response', () async {
      // arrange
      final expectedPong = faker.lorem.sentence();
      dynamic receivedPongNested;
      dynamic receivedPongFromFuture;
      String? id;
      when(() => mockSender.send(any())).thenAnswer((i) {
        final message = i.positionalArguments[0] as PingPongMessage;
        id = message.id;
        expect(message.value, fakePing);
      });

      // act
      final future = isolateBundle
          .pingPong(fakePing)
          .then((value) => receivedPongNested = value);
      await Future.delayed(const Duration(milliseconds: 1));

      // assert
      verify(() => mockSender.send(any()));
      expect(id, isNotNull);
      expect(receivedPongNested, isNull);

      // act
      messagesController.add(PingPongMessage(id!, expectedPong));
      receivedPongFromFuture = await future;

      // assert
      expect(receivedPongNested, expectedPong);
      expect(receivedPongFromFuture, expectedPong);
    });
  });

  group('close', () {
    test('should cancel listening subscription', () async {
      // assert
      when(() => mockListeningSubscription.cancel())
          .thenAnswer((i) => Future.value());
      when(() => mockMessagesSubscription.cancel())
          .thenAnswer((i) => Future.value());

      // act
      await isolateBundle.close();

      // assert
      verify(() => mockListeningSubscription.cancel());
      verify(() => mockMessagesSubscription.cancel());
    });
  });
}
