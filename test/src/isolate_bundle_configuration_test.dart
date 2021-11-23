import 'dart:isolate';

import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

part 'isolate_bundle_configuration_test.types.dart';

void main() {
  late MockSendPort toCaller;

  late IsolateBundleConfiguration isolateBundleConfiguration;

  setUp(() {
    toCaller = MockSendPort();

    isolateBundleConfiguration = _IsolateBundleConfiguration(
      toCaller: toCaller,
    );
  });

  group('activateOnCurrentIsolate', () {
    late _MockListener mockListener;

    setUp(() {
      mockListener = _MockListener();
    });

    test('should wire up receive port', () async {
      // act
      isolateBundleConfiguration.activateOnCurrentIsolate(
        mockListener.handler,
        mockListener.cancel,
      );
      await Future.value(const Duration(milliseconds: 1));

      // assert
      verify(() => toCaller.send(any()));
    });

    test('should cancel subscriptions when [CancelMessage] is received', () {
      // TODO test with multiple isolates
    });
  });
}
