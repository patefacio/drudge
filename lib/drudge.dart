library drudge.drudge;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

enum LoggingPolicy { commandStart, commandCompletion, commandAll }

enum ParallelPolicy { serial, parallel, parallelConstrained }

enum InterruptPolicy { restartCommand, queueCommand }

/// Reference to runnable that must be run before another
class Dependencies {
  List<Runnable> dependencies = [];

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

  run();

  // end <class Runnable>

}

class Command extends Object
    with Identifiable, Dependencies
    implements Runnable {
  String commandLine;

  // custom <class Command>

  Command(id) {
    this.id = getOrCreateId(id);
  }

  toString() => brCompact([
        'command($id)',
        dependencies.isEmpty
            ? null
            : brCompact(['dependencies', indentBlock(brCompact(dependencies))])
      ]);

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
        dependencies.isEmpty
            ? null
            : brCompact(['dependencies', indentBlock(brCompact(dependencies))])
      ]);

  // end <class Recipe>

}

class ChangeSpec {
  int fileSystemEvent;
  List<FileSystemEntity> get watchTargets => _watchTargets;

  // custom <class ChangeSpec>

  ChangeSpec([this.fileSystemEvent, watchTargets]) {
    this._watchTargets =
        watchTargets == null ? [] : new List.from(watchTargets);
  }

  toString() => brCompact([
        'changeSpec(on:${fileSystemEvent})',
        indentBlock(brCompact(watchTargets)),
      ]);

  // end <class ChangeSpec>

  List<FileSystemEntity> _watchTargets = [];
}

/// Runs commands on file system events
class FileSystemEventRunner extends Object with Identifiable, Dependencies {
  ChangeSpec changeSpec;
  Recipe recipe;

  // custom <class FileSystemEventRunner>

  FileSystemEventRunner([this.changeSpec, this.recipe]);

  toString() => brCompact([
        'FileSystemEventRunner',
        indentBlock(changeSpec.toString()),
        indentBlock(recipe.toString())
      ]);

  // end <class FileSystemEventRunner>

}

class Driver implements Runnable {
  List<FileSystemEventRunner> get fileSystemEventRunners =>
      _fileSystemEventRunners;

  // custom <class Driver>

  Driver(this._fileSystemEventRunners);

  toString() =>
      brCompact(['driver', indentBlock(brCompact(_fileSystemEventRunners))]);

  // end <class Driver>

  List<FileSystemEventRunner> _fileSystemEventRunners = [];
}

// custom <library drudge>

command(id) => new Command(id);

recipe(id, Iterable<Runnable> runnables,
        [ParallelPolicy parallelPolicy = ParallelPolicy.serial]) =>
    new Recipe(id, runnables, parallelPolicy);

changeSpec([int fileSystemEvent, Iterable watchTargets]) =>
    new ChangeSpec(fileSystemEvent, watchTargets);

fileSystemEventRunner([ChangeSpec changeSpec, Recipe recipe]) =>
    new FileSystemEventRunner(changeSpec, recipe);

driver(List<FileSystemEventRunner> fileSystemEventRunners) =>
    new Driver(fileSystemEventRunners);

// end <library drudge>
