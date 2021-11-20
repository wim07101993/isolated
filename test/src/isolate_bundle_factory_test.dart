import 'dart:isolate';

import 'package:faker/faker.dart';
import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

part 'isolate_bundle_factory_test.types.dart';

void entryPoint(IsolateBundleConfiguration config) {
  config.activateOnCurrentIsolate((message) {
    config.toCaller.send(message);
  });
}

void main() {
  late _ConfigBuilder configBuilder;

  late IsolateBundleFactory factory;

  setUp(() {
    configBuilder = const _ConfigBuilder();

    factory = const IsolateBundleFactory();
  });

  group('startNew', () {
    test('should create isolate bundle', () async {
      // arrange
      final mockListener = _MockListener();
      final value1 = faker.lorem.sentence();
      final value2 = faker.lorem.sentence();

      // act
      final bundle = await factory.startNew(entryPoint, configBuilder.build);
      final subscription = bundle.messages.listen(mockListener.listen);
      bundle.send(value1);
      bundle.send(value2);
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      verify(() => mockListener.listen(value1));
      verify(() => mockListener.listen(value2));

      // cleanup
      subscription.cancel();
    });
  });
}
