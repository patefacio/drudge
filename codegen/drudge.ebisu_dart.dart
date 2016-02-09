#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>
final _logger = new Logger('drudgeEbisuDart');

main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  useDartFormatter = true;
  String here = absolute(Platform.script.toFilePath());
  // custom <drudgeEbisuDart main>

  final drudge = system('drudge')
    ..rootPath = dirname(dirname(absolute(Platform.script.toFilePath())))
    ..includesHop = true
    ..testLibraries = [
      library('test_driver')
        ..imports = ['package:id/id.dart', 'package:drudge/drudge.dart']
    ]
    ..libraries = [
      library('drudge')
        ..imports = ['package:id/id.dart', 'package:ebisu/ebisu.dart', 'io']
        ..enums = [
          enum_('logging_policy')
            ..values = ['command_start', 'command_completion', 'command_all',],
          enum_('parallel_policy')
            ..values = ['serial', 'parallel', 'parallel_constrained'],
          enum_('interrupt_policy')
            ..values = ['restart_command', 'queue_command',]
        ]
        ..classes = [
          /// Dependency
          class_('dependencies')
            ..doc = 'Reference to runnable that must be run before another'
            ..members = [
              member('dependencies')
                ..type = 'List<Runnable>'
                ..classInit = [],
            ],

          /// Identifiable
          class_('identifiable')..members = [member('id')..type = 'Id',],

          /// Runnable
          class_('runnable')..isAbstract = true,

          /// Command
          class_('command')
            ..implement = ['Runnable']
            ..mixins = ['Identifiable', 'Dependencies']
            ..members = [member('command_line'),],

          /// Recipe
          class_('recipe')
            ..implement = ['Runnable']
            ..mixins = ['Identifiable', 'Dependencies']
            ..members = [
              member('runnables')
                ..type = 'List<Runnable>'
                ..classInit = [],
              member('parallel_policy')..type = 'ParallelPolicy',
            ],

          class_('change_spec')
            ..members = [
              member('file_system_event')..type = 'int',
              member('watch_targets')
                ..type = 'List<FileSystemEntity>'
                ..classInit = []
                ..access = RO,
            ],

          class_('file_system_event_runner')
            ..doc = 'Runs commands on file system events'
            ..mixins = ['Identifiable', 'Dependencies']
            ..members = [
              member('change_spec')..type = 'ChangeSpec',
              member('recipe')..type = 'Recipe',
            ],

          /// Drive the commands
          class_('driver')
            ..implement = ['Runnable']
            ..members = [
              member('file_system_event_runners')
                ..type = 'List<FileSystemEventRunner>'
                ..classInit = []
                ..access = RO,
            ]
        ]
    ];

  drudge.generate();

  // end <drudgeEbisuDart main>
}

// custom <drudgeEbisuDart global>
// end <drudgeEbisuDart global>
