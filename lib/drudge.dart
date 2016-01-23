library drudge.drudge;

// custom <additional imports>
// end <additional imports>

/// Groups files and directories to watch for events
class FseBundle {
  List<FileSystemEntity> fileSystemEntities = [];

  // custom <class FseBundle>
  // end <class FseBundle>

}

/// Specifies a command to run
class CommandSpec {
  // custom <class CommandSpec>
  // end <class CommandSpec>

}

/// Groups commands to run when any fse in a bundle changes
class CommandSet {
  Map<FseBundle, CommandSpec> commandMapping = {};

  // custom <class CommandSet>
  // end <class CommandSet>

}

/// Given a set of files, directories and commands, sets up watchers and commands
class Driver {
  // custom <class Driver>
  // end <class Driver>

}

// custom <library drudge>
// end <library drudge>
