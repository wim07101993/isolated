part of 'isolate_bundle_configuration_test.dart';

class _IsolateBundleConfiguration extends IsolateBundleConfiguration {
  const _IsolateBundleConfiguration({
    required this.toCaller,
  });

  @override
  final SendPort toCaller;
}

class _MockListener extends Mock implements _Listener {}

class _Listener {
  void handler(dynamic message) {}
}
