import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class GuestIdStore {
  GuestIdStore._();

  static final GuestIdStore _instance = GuestIdStore._();

  factory GuestIdStore() => _instance;

  static const _guestIdKey = 'guest_id';
  static final Random _rng = _buildRandom();

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_guestIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final uuid = _generateUuidV4();
    await prefs.setString(_guestIdKey, uuid);
    return uuid;
  }

  String _generateUuidV4() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i++) {
      final byte = bytes[i];
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
      if (i == 3 || i == 5 || i == 7 || i == 9) {
        buffer.write('-');
      }
    }
    return buffer.toString();
  }

  static Random _buildRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }
}
