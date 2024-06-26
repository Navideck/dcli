/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';
import 'package:path/path.dart' as p;

import 'my_yaml.dart';

/// not currently used.
/// idea was to keep a hash of files so we can tell if they have changed.
class HashesYaml {
  ///
  HashesYaml(String scriptCachePath) {
    final cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    _hashes = MyYaml.fromFile(p.join(scriptCachePath, _fileName));
  }

  final String _fileName = 'hashes.yaml';

  /// ignore: unused_field
  late final MyYaml _hashes;

  ///
  static void create(String projectRootPath) {}
}
