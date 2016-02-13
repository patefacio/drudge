library drudge.drudge;

import 'dart:async';
import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('drudge');

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

class Runnable extends Object with Dependencies, Identifiable {
  // custom <class Runnable>

  Future<List> run() async {
    return Future
        .wait(dependencies.map((d) => d.run()))
        .then((Iterable results) {
      _logger.info(
          "DEPS($id) complete (${dependencies.length}:${results.length}) (${id.snake}:${runtimeType})");
      return concat(results);
    });
  }

  // end <class Runnable>

}

class Command extends Runnable {
  String exe;
  List<String> args = [];

  // custom <class Command>

  Command(id, [this.exe, this.args = const <String>[]]) {
    this.id = getOrCreateId(id);
  }

  toString() => brCompact([
        'command($id)',
        dependencies.isEmpty
            ? null
            : brCompact(['dependencies', indentBlock(brCompact(dependencies))])
      ]);

  Future run() async => super.run().then((Iterable results) {
        _logger.info('COMMAND: ($exe ${args.join(" ")})');
        return Process.run(exe, args).then((ProcessResult processResult) {
          return new List.from(results)..add(processResult);
        });
      });

  // end <class Command>

}

class Recipe extends Runnable {
  List<Runnable> runnables = [];
  ParallelPolicy parallelPolicy;

  // custom <class Recipe>

  Recipe(id, runnables, [this.parallelPolicy])
      : runnables = new List.from(runnables) {
    this.id = getOrCreateId(id);
  }

  toString() => brCompact([
        'recipe($id)',
        indentBlock(brCompact([runnables, 'parallelPolicy($parallelPolicy)',])),
        dependencies.isEmpty
            ? null
            : brCompact(['dependencies', indentBlock(brCompact(dependencies))])
      ]);

  Future run() async => super.run().then((Iterable results) {
        return Future
            .wait(runnables.map((var _) => _.run()))
            .then((Iterable moreResults) {
          _logger.fine('RECIPE($id) ${moreResults.length} complete');
          return concat([results, concat(moreResults)]);
        });
      });

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
class FileSystemEventRunner extends Runnable {
  ChangeSpec changeSpec;
  Recipe recipe;
  List<Stream<FileSystemEvent>> eventStreams = [];

  // custom <class FileSystemEventRunner>

  FileSystemEventRunner([this.changeSpec, this.recipe]) {
    id = new Id('drudge_file_system_event_runner');
    eventStreams = changeSpec.watchTargets
      .map((FileSystemEntity fse) {
        _logger.info('Listening for events(${changeSpec.fileSystemEvent}) on ${fse.path}');
        return fse.watch(events: changeSpec.fileSystemEvent);
      }).toList();
  }

  toString() => brCompact([
        'FileSystemEventRunner',
        indentBlock(changeSpec.toString()),
        indentBlock(recipe.toString())
      ]);

  Future run() async => super.run().then((Iterable results) {
        _logger.fine(
            "Finished FSR deps (${dependencies.length}:${results.length}), running file runner recipe $id");
        return recipe
            .run()
            .then((Iterable moreResults) => concat([results, moreResults]));
      });

  _listenOnStreams() =>
    eventStreams.forEach((Stream stream) {
      stream.listen((_) => run());
    });

  // end <class FileSystemEventRunner>

}

class Driver extends Runnable {
  List<FileSystemEventRunner> get fileSystemEventRunners =>
      _fileSystemEventRunners;

  // custom <class Driver>

  Driver(this._fileSystemEventRunners) {
    id = new Id('drudge_driver');
  }

  toString() =>
      brCompact(['driver', indentBlock(brCompact(_fileSystemEventRunners))]);

  Future run() async {
    _logger.info('Running $this');
    return super.run().then((Iterable results) {
        _logger
            .info("Finished Driver($id) deps ${results.length}, running FSRs");
        _fileSystemEventRunners.forEach((fser) => fser._listenOnStreams());
      });
  }

  // end <class Driver>

  List<FileSystemEventRunner> _fileSystemEventRunners = [];
}

// custom <library drudge>

command(id, [String exe, List<String> args = const <String>[]]) =>
    new Command(id, exe, args);

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
