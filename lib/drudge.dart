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

  Future<List> run() {
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
  String outputPath;
  String latestStdout;
  String latestStderr;
  int iteration = 0;

  // custom <class Command>

  Command(id, [this.exe, this.args = const <String>[]]) {
    this.id = getOrCreateId(id);
    outputPath = '/tmp/driver/${this.id.snake}';
    new Directory(outputPath)..createSync(recursive: true);
    latestStdout = '$outputPath/latest.stdout';
    latestStderr = '$outputPath/latest.stderr';
  }

  toString() => brCompact([
        'command($id)',
        dependencies.isEmpty
            ? null
            : brCompact(['dependencies', indentBlock(brCompact(dependencies))])
      ]);

  Future run() => super.run().then((Iterable results) {
        _logger.info('COMMAND: ($exe ${args.join(" ")})');
        return Process.run(exe, args).then((ProcessResult processResult) {
          final bool success = processResult.exitCode == 0;
          final fileBasename = success ? ".success.stdout" : ".fail.stdout";
          final fileName = '$outputPath/$iteration$fileBasename';
          new File(fileName).writeAsStringSync(processResult.stdout);
          _createOrUpdateLink(latestStdout, fileName);
          _logger.fine('($exe ${args.join(" ")})\n'
              '---------------------------------\n${processResult.stdout}');
          if (!success) {
            final stdErrFileBasename = '$iteration.fail.stderr';
            final fileName = '$outputPath/$stdErrFileBasename';
            new File(fileName).writeAsStringSync(processResult.stderr);
            _createOrUpdateLink(latestStderr, fileName);
          }
          iteration++;
          return new List.from(results)..add(processResult);
        });
      });

  _createOrUpdateLink(linkPath, targetPath) {
    final link = new Link(linkPath);
    if (link.existsSync()) {
      link.update(targetPath);
    } else {
      link.createSync(targetPath);
    }
  }

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

  Future run() => super.run().then((Iterable results) {
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
  StreamController<Iterable<ProcessResult>> streamController =
      new StreamController<Iterable<ProcessResult>>();

  // custom <class FileSystemEventRunner>

  FileSystemEventRunner([this.changeSpec, this.recipe]) {
    id = new Id('drudge_file_system_event_runner');
    eventStreams = changeSpec.watchTargets.map((FileSystemEntity fse) {
      _logger.info(
          'Listening for events(${changeSpec.fileSystemEvent}) on ${fse.path}');
      return fse.watch(events: changeSpec.fileSystemEvent);
    }).toList();
  }

  toString() => brCompact([
        'FileSystemEventRunner',
        indentBlock(changeSpec.toString()),
        indentBlock(recipe.toString())
      ]);

  Future run() => super.run().then((Iterable results) {
        if (results.length > 0)
          _logger.fine(
              "Finished FSR deps (${dependencies.length}:${results.length}), running file runner recipe $id");
        return recipe
            .run()
            .then((Iterable moreResults) => concat([results, moreResults]));
      });

  _listenOnStreams() {
    eventStreams.forEach((Stream stream) {
      stream.listen((_) =>
          run().then((Iterable results) => streamController.add(results)));
    });
  }

  // end <class FileSystemEventRunner>

}

class Driver {
  List<FileSystemEventRunner> get fileSystemEventRunners =>
      _fileSystemEventRunners;

  // custom <class Driver>

  Driver(this._fileSystemEventRunners);

  toString() =>
      brCompact(['driver', indentBlock(brCompact(_fileSystemEventRunners))]);

  run() {
    _logger.info('Running $this');

    _fileSystemEventRunners.forEach((var fser) {
      fser._listenOnStreams();
      fser.streamController.stream.listen((var results) {
        _logger.info('Driver got results $results');
      });
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
