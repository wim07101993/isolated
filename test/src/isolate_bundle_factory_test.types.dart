part of 'isolate_bundle_factory_test.dart';

class _ConfigBuilder {
  const _ConfigBuilder();

  IsolateBundleConfiguration build(SendPort configSendPort) {
    return IsolateBundleConfiguration(configSendPort);
  }
}

class _Listener {
  void listen(dynamic value) {}
}

class _MockListener extends Mock implements _Listener {}

class FakeIsolateBundleFactory extends Fake implements IsolateBundleFactory {}
