import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/firebase_options.dart';

class _FakeFirebasePlatform extends FirebasePlatform {
  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _apps[name] ??=
        FirebaseAppPlatform(name, DefaultFirebaseOptions.currentPlatform);
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList(growable: false);

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final firebaseOptions = options ?? DefaultFirebaseOptions.currentPlatform;
    final app = FirebaseAppPlatform(appName, firebaseOptions);
    _apps[appName] = app;
    return app;
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = _FakeFirebasePlatform();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await testMain();
}