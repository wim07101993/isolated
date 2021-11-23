part of 'isolate_bundle_factory_test.dart';

class _IsolateBundleConfiguration extends IsolateBundleConfiguration {
  const _IsolateBundleConfiguration(this.toCaller);

  @override
  final SendPort toCaller;
}

class _ConfigBuilder {
  const _ConfigBuilder();

  _IsolateBundleConfiguration build(SendPort configSendPort) {
    return _IsolateBundleConfiguration(configSendPort);
  }
}

class _Listener {
  void listen(dynamic value) {}
}

class _MockListener extends Mock implements _Listener {}

class FakeIsolateBundleFactory extends Fake implements IsolateBundleFactory {}
