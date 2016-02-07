import 'package:logging/logging.dart';
import 'test_driver.dart' as test_driver;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_driver.main();
}
