import 'dart:async';
import 'dart:isolate';

import 'package:isolated/isolated.dart';
import 'package:mocktail/mocktail.dart';

class MockIsolate extends Mock implements Isolate {}

class MockIsolateBundleConfiguration extends Mock
    implements IsolateBundleConfiguration {}

class MockSendPort extends Mock implements SendPort {}

class MockReceivePort extends Mock implements ReceivePort {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

class MockStream<T> extends Mock implements Stream<T> {}
