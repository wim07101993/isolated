import 'dart:isolate';

import 'package:faker/faker.dart';
import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

part 'isolate_bundle_factory_test.types.dart';

void entryPoint(IsolateBundleConfiguration config) {
  config.activateOnCurrentIsolate(
    config.toCaller.send,
    config.toCaller.send,
  );
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

    test('should cancel subscription and if cancel of bundle is called',
        () async {
      // arrange
      final mockListener = _MockListener();
      final bundle = await factory.startNew(entryPoint, configBuilder.build);
      final value1 = faker.lorem.sentence();
      final subscription = bundle.messages.listen(mockListener.listen);

      // act
      await bundle.cancel(const CancelMessage());
      bundle.send(value1);
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      verifyNever(() => mockListener.listen(value1));

      // cleanup
      subscription.cancel();
    });
  });
}
