import 'package:logging/logging.dart';
import 'test_command_spec.dart' as test_command_spec;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_command_spec.main();
}
