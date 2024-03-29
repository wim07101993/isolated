import 'dart:async';
import 'dart:isolate';

import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';

class MockIsolateBundleConfiguration extends Mock
    implements IsolateBundleConfiguration {}

class MockSendPort extends Mock implements SendPort {}

class MockReceivePort extends Mock implements ReceivePort {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

class MockStream<T> extends Mock implements Stream<T> {}

class MockIsolateBundle<TConfig extends IsolateBundleConfiguration, TSend,
    TReceive> extends Mock implements IsolateBundle<TConfig, TSend, TReceive> {}
