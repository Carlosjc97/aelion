import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static final DotEnv _env = dotenv;

  static String get posthogKey =>
      _read('POSTHOG_KEY', fallback: kReleaseMode ? '' : 'ph_dev_placeholder');

  static String get posthogHost => _read(
        'POSTHOG_HOST',
        fallback: 'https://us.i.posthog.com',
      );

  static String _read(String key, {String fallback = ''}) {
    final value = _env.env[key];
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }
}
