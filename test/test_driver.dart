library drudge.test_driver;

import 'package:drudge/drudge.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'dart:io';

// end <additional imports>

final _logger = new Logger('test_driver');

// custom <library test_driver>
// end <library test_driver>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  Logger.root.level = Level.FINE;
  test('sample driver', () {
    var clean = command('clean', 'echo', ['TESTING', 'cleaning', 'up', 'stuff']);

    var buildAndTest = recipe('build_and_test', [
      command('list_stuff', 'echo', ['TESTING', 'listing stuff']),
      command('build', 'echo', ['TESTING', 'building suff now'])..dependencies = [clean],
      command('test', 'echo', ['TESTING', 'testing stuff now']),
    ]);

    var fauxBuild = driver(
        [fileSystemEventRunner(changeSpec(FileSystemEvent.ALL), buildAndTest)]);

    print(fauxBuild);

    fauxBuild.run().then((Iterable results) {
      for (ProcessResult result in results) {
        print('drudge finished ${result.stdout}');
      }
    });
  });

// end <main>
}
