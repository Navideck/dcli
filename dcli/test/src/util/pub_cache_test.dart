import 'package:dcli/dcli.dart' hide equals;
import 'package:pub_semver/pub_semver.dart';
import 'package:scope/scope.dart';
import 'package:test/test.dart';

import 'test_scope.dart';

void main() {
  test(
    'PubCache',
    () {
      if (Settings().isWindows) {
        expect(
          PubCache().pathToBin,
          equals(join(env['LocalAppData']!, 'Pub', 'Cache', 'bin')),
        );
      } else {
        expect(
          PubCache().pathToBin,
          equals(join(env['HOME']!, '.pub-cache', 'bin')),
        );
      }
    },
    skip: false,
  );

  test(
    'PubCache - from ENV',
    () {
      withTestScope((outerTempDir) {
        withEnvironment(() {
          /// create a pub-cache using the test scope's HOME
          Scope()
            ..value(PubCache.scopeKey, PubCache.forScope())
            ..runSync(() {
              if (Settings().isWindows) {
                expect(
                    PubCache().pathToBin,
                    equals(
                        join(outerTempDir, 'test_cache', '.pub_cache', 'bin')));
              } else {
                expect(
                  PubCache().pathToBin,
                  equals(join(outerTempDir, 'test_cache', '.pub_cache', 'bin')),
                );
              }
            });
        }, environment: {
          'PUB_CACHE': join(outerTempDir, 'test_cache', '.pub_cache')
        });
      });
    },
    skip: false,
  );

  test('PubCache - primaryVersion', () {
    withTestScope((tempDir) {
      withEnvironment(() {
        /// create a pub-cache using the test scope's HOME
        Scope()
          ..value(PubCache.scopeKey, PubCache.forScope())
          ..runSync(() {
            final pubCache = PubCache();
            createDir(pubCache.pathToDartLang, recursive: true);
            createDir(join(pubCache.pathToDartLang, 'dcli-1.0.0-beta.1'));

            var primary = PubCache().findPrimaryVersion('dcli');
            expect(primary, isNotNull);
            expect(primary, equals(Version.parse('1.0.0-beta.1')));
            expect(primary!.isPreRelease, isTrue);

            createDir(join(pubCache.pathToDartLang, 'dcli-1.0.0'));

            primary = PubCache().findPrimaryVersion('dcli');
            expect(primary, isNotNull);
            expect(primary, equals(Version.parse('1.0.0')));
            expect(primary!.isPreRelease, isFalse);

            createDir(join(pubCache.pathToDartLang, 'dcli-1.0.1'));
            primary = PubCache().findPrimaryVersion('dcli');
            expect(primary, isNotNull);
            expect(primary, equals(Version.parse('1.0.1')));
            expect(primary!.isPreRelease, isFalse);

            createDir(join(pubCache.pathToDartLang, 'dcli-2.0.0'));
            createDir(join(pubCache.pathToDartLang, 'dcli-2.0.0-beta.1'));
            primary = PubCache().findPrimaryVersion('dcli');

            expect(primary, equals(Version.parse('2.0.0')));
            expect(primary!.isPreRelease, isFalse);
          });
      }, environment: {'PUB_CACHE': join(tempDir, '.pub-cache')});
    });
  });

  test('isRunning from Source', () {
    if (PubCache().isGloballyActivated('general')) {
      PubCache().globalDeactivate('general');
    }
    expect(PubCache().isGloballyActivatedFromSource('general'), isFalse);
    PubCache().globalActivateFromSource(join('test', 'test_script', 'general'));
    expect(PubCache().isGloballyActivatedFromSource('general'), isTrue);

    /// cleanup
    PubCache().globalDeactivate('general');
  });
}
