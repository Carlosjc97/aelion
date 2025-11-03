import 'dart:io';

final GZipCodec _codec = GZipCodec();

List<int>? compressOutlineHistoryImpl(List<int> bytes) {
  try {
    return _codec.encode(bytes);
  } catch (_) {
    return null;
  }
}

List<int>? decompressOutlineHistoryImpl(List<int> bytes) {
  try {
    return _codec.decode(bytes);
  } catch (_) {
    return null;
  }
}
