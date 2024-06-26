import 'dart:convert';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart';

import 'callback_string_sync.dart';

class _StopIteration implements Exception {
  const _StopIteration();
}

void linesOf(File file, bool Function(String) cb) {
  final raf = file.openSync();

  try {
    final splitter =
        const LineSplitter().startChunkedConversion(CallbackStringSync((str) {
      if (!cb(str)) {
        throw const _StopIteration();
      }
    }));

    final decoder = const Utf8Decoder().startChunkedConversion(splitter);

    while (true) {
      final bytes = raf.readSync(16 * 1024);
      if (bytes.isEmpty) {
        break;
      }
      decoder.add(bytes);
    }
    verbose(() => '-- closing --');
    decoder.close();
  } on _StopIteration catch (_) {
    // Ignore.
  } finally {
    raf.closeSync();
  }
}

void main() {
  final file = File('pubspec.yaml');

  var count = 0;
  linesOf(file, (v) {
    print(v);
    return ++count < 10;
  });
}
