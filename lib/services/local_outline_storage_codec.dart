import 'local_outline_storage_codec_stub.dart'
    if (dart.library.io) 'local_outline_storage_codec_io.dart';

List<int>? compressOutlineHistory(List<int> bytes) =>
    compressOutlineHistoryImpl(bytes);

List<int>? decompressOutlineHistory(List<int> bytes) =>
    decompressOutlineHistoryImpl(bytes);
