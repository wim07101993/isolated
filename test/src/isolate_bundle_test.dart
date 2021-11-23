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
  late String fakeId;
  late Isolate mockIsolate;
  late IsolateBundleConfiguration mockConfig;
  late void Function(dynamic message) fakeSend;
  late Future<void> Function(CancelMessage cancelMessage) fakeCancel;
  late MockStream mockMessages;

  late IsolateBundle<IsolateBundleConfiguration, dynamic, dynamic>
      isolateBundle;

  setUp(() {
    fakeId = faker.guid.guid();
    mockIsolate = MockIsolate();
    mockConfig = MockIsolateBundleConfiguration();
    fakeSend = (message) {};
    fakeCancel = (cancelMessage) => Future.value();
    mockMessages = MockStream();

    isolateBundle = IsolateBundle(
      id: fakeId,
      isolate: mockIsolate,
      config: mockConfig,
      send: fakeSend,
      messages: mockMessages,
      cancel: fakeCancel,
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
}
