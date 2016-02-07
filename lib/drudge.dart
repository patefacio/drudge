library drudge.drudge;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

enum LoggingPolicy { commandStart, commandCompletion, commandAll }

enum ParallelPolicy { serial, parallel, parallelConstrained }

enum InterruptPolicy { restartCommand, queueCommand }

/// Reference to runnable that must be run before another
class Dependencies {
  // custom <class Dependencies>
  // end <class Dependencies>

}

class Identifiable {
  Id id;

  // custom <class Identifiable>
  // end <class Identifiable>

}

abstract class Runnable {
  // custom <class Runnable>
  // end <class Runnable>

}

class Command extends Object
    with Identifiable, Dependencies
    implements Runnable {
  String commandLine;
  String exe;
  String args;

  // custom <class Command>

  Command(id) {
    this.id = getOrCreateId(id);
  }

  toString() => brCompact('''
command($id)
''');

  // end <class Command>

}

class Recipe extends Object
    with Identifiable, Dependencies
    implements Runnable {
  List<Runnable> runnables = [];
  ParallelPolicy parallelPolicy;

  // custom <class Recipe>

  Recipe(id, runnables, [this.parallelPolicy])
      : runnables = new List.from(runnables) {
    this.id = getOrCreateId(id);
  }

  toString() => brCompact([
        'recipe(id)',
        indentBlock(brCompact([runnables, 'parallelPolicy($parallelPolicy)',])),
      ]);

  // end <class Recipe>

}

class Driver {
  List<Runnable> runnables;

  // custom <class Driver>
  // end <class Driver>

}

// custom <library drudge>

command(id) => new Command(id);

recipe(id, Iterable<Runnable> runnables,
        [ParallelPolicy parallelPolicy = ParallelPolicy.serial]) =>
    new Recipe(id, runnables, parallelPolicy);

// end <library drudge>
