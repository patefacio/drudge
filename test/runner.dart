import 'package:logging/logging.dart';
import 'test_driver.dart' as test_driver;

void main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_driver.main(null);
}
