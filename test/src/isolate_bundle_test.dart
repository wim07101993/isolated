import 'dart:async';
import 'dart:isolate';

import 'package:faker/faker.dart';
import 'package:isolated/isolated.dart';
import 'package:isolated/src/isolate_bundle.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

part 'isolate_bundle_test.types.dart';

void main() {
  // ignore: cancel_subscriptions
  late MockStreamSubscription mockListeningSubscription;
  late String fakeId;
  late Isolate mockIsolate;
  late IsolateBundleConfiguration mockConfig;
  late void Function(dynamic message) fakeSend;
  late MockStream mockMessages;

  late IsolateBundle<IsolateBundleConfiguration, dynamic, dynamic>
      isolateBundle;

  setUp(() {
    mockListeningSubscription = MockStreamSubscription();
    fakeId = faker.guid.guid();
    mockIsolate = MockIsolate();
    mockConfig = MockIsolateBundleConfiguration();
    fakeSend = (message) {};
    mockMessages = MockStream();

    isolateBundle = IsolateBundle(
      listeningSubscription: mockListeningSubscription,
      id: fakeId,
      isolate: mockIsolate,
      config: mockConfig,
      send: fakeSend,
      messages: mockMessages,
    );
  });

  group('constructor', () {
    test('should set all fields', () {
      // assert
      expect(isolateBundle.id, fakeId);
      expect(isolateBundle.isolate, mockIsolate);
      expect(isolateBundle.config, mockConfig);
      expect(isolateBundle.send, fakeSend);
      expect(isolateBundle.messages, mockMessages);
    });
  });

  group('close', () {
    test('should cancel listening subscription', () async {
      // assert
      when(() => mockListeningSubscription.cancel())
          .thenAnswer((i) => Future.value());

      // act
      await isolateBundle.close();

      // assert
      verify(() => mockListeningSubscription.cancel());
    });
  });
}
