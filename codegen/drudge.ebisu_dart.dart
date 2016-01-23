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
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  useDartFormatter = true;
  String here = absolute(Platform.script.toFilePath());
  // custom <drudgeEbisuDart main>

  final drudge = system('drudge')
    ..rootPath = dirname(dirname(absolute(Platform.script.toFilePath())))
    ..includesHop = true
    ..testLibraries = [
      library('test_command_spec')
    ]
    ..libraries = [
      library('drudge')
      ..classes = [
        class_('fse_bundle')
        ..doc = 'Groups files and directories to watch for events'
        ..members = [
          member('file_system_entities')..type = 'List<FileSystemEntity>'..classInit = [],
        ],

        class_('command_spec')
        ..doc = 'Specifies a command to run'
        ..members = [

        ],

        class_('command_set')
        ..doc = 'Groups commands to run when any fse in a bundle changes'
        ..members = [
          member('command_mapping')..type = 'Map<FseBundle, CommandSpec>'..classInit = {}
        ],

        class_('driver')
        ..doc = '''
Given a set of files, directories and commands, sets up watchers and commands'''
        ..members = [

        ]
      ]
    ];

  drudge.generate();

  // end <drudgeEbisuDart main>
}

// custom <drudgeEbisuDart global>
// end <drudgeEbisuDart global>
