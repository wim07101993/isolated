import 'dart:async';

import 'package:faker/faker.dart';
import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

part 'ping_pong_isolate_bundle_test.types.dart';

void main() {
  // ignore: cancel_subscriptions
  late StreamSubscription<PingPongMessage> mockMessagesSubscription;
  late MockIsolateBundle<IsolateBundleConfiguration, PingPongMessage,
      PingPongMessage> mockIsolateBundle;
  late MockSender mockSender;
  late Stream<PingPongMessage> mockMessages;

  late PingPongIsolateBundle isolateBundle;

  setUpAll(() {
    registerFallbackValue(const CancelMessage());
  });

  setUp(() {
    mockMessagesSubscription = MockStreamSubscription();
    mockIsolateBundle = MockIsolateBundle();
    mockSender = MockSender();
    mockMessages = MockStream();

    when(() => mockMessages.listen(any())).thenReturn(mockMessagesSubscription);
    when(() => mockIsolateBundle.messages).thenAnswer((i) => mockMessages);
    when(() => mockIsolateBundle.send).thenReturn(mockSender.send);

    isolateBundle = PingPongIsolateBundle(mockIsolateBundle);
  });

  group('pingPong', () {
    late StreamController<PingPongMessage> messagesController =
        StreamController();
    late String fakePing;

    setUp(() {
      messagesController = StreamController();
      fakePing = faker.lorem.sentence();

      when(() => mockIsolateBundle.messages)
          .thenAnswer((i) => messagesController.stream);

      isolateBundle = PingPongIsolateBundle(mockIsolateBundle);
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
    late CancelMessage fakeCancelMessage;

    setUp(() {
      fakeCancelMessage = const CancelMessage();
    });

    test('should cancel listening subscription', () async {
      // assert
      final mockCanceler = MockCanceler();
      when(() => mockCanceler.cancel(any())).thenAnswer((i) => Future.value());
      when(() => mockIsolateBundle.cancel)
          .thenAnswer((i) => mockCanceler.cancel);
      when(() => mockMessagesSubscription.cancel())
          .thenAnswer((i) => Future.value());

      // act
      await isolateBundle.cancel(fakeCancelMessage);

      // assert
      verify(() => mockCanceler.cancel(fakeCancelMessage));
      verify(() => mockMessagesSubscription.cancel());
    });
  });
}
