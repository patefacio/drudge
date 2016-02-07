library drudge.test_driver;

import 'package:drudge/drudge.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('test_driver');

// custom <library test_driver>
// end <library test_driver>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('sample driver', () {
    var r = recipe('build_and_test', [command('build'), command('test'),]);

    print(r);
  });

// end <main>
}
