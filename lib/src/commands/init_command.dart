import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mypl/src/helper/logger.dart';

class InitCommand extends Command<int> {
  InitCommand() {
    argParser.addOption('name', abbr: 'n', help: 'The name of the project');
  }

  @override
  String get description => 'Initialize a new project with Bloc pattern.';

  @override
  String get name => 'init';

  @override
  Future<int> run() async {
    final projectName = (argResults?['name'] as String?) ?? 'default_app_name';

    try {
      Logger.info('Initializing project: $projectName');
      await _createProjectStructure(projectName);
      await _addBlocDependencies(projectName);
      // Remove GetX structure creation
      return 0;
    } catch (e) {
      Logger.error('Error initializing project: $e');
      return 1;
    }
  }

  Future<void> _createProjectStructure(String projectName) async {
    try {
      // Check if Flutter is installed
      final flutterCheck = await Process.run(
        'flutter',
        ['--version'],
        runInShell: true,
      );
      if (flutterCheck.exitCode != 0) {
        throw Exception('Flutter is not installed or not found in PATH.');
      }

      Logger.info('Creating Flutter project...');
      final result = await Process.run(
        'flutter',
        ['create', projectName],
        runInShell: true,
      );
      Logger.info(result.stdout as String);

      // Create assets directory with subdirectories
      final assetsDir = Directory('$projectName/assets');
      if (!assetsDir.existsSync()) {
        assetsDir.createSync(recursive: true);
        Logger.info('Created assets directory at $projectName/assets');

        // Create subdirectories for assets
        final iconsDir = Directory('${assetsDir.path}/icons');
        final svgsDir = Directory('${assetsDir.path}/svgs');
        final imagesDir = Directory('${assetsDir.path}/images');

        iconsDir.createSync();
        svgsDir.createSync();
        imagesDir.createSync();

        Logger.info('Created subdirectories: icons, svgs, images');
      }

      // Create features directory
      final featuresDir = Directory('$projectName/lib/features');
      if (!featuresDir.existsSync()) {
        featuresDir.createSync(recursive: true);
        Logger.info('Created features directory at $projectName/lib/features');
      }

      // Update pubspec.yaml to include assets
      await _updatePubspecWithAssets(projectName);
    } catch (e) {
      Logger.error('Error creating project structure: $e');
      rethrow; // To propagate the error up if needed
    }
  }



  Future<void> _updatePubspecWithAssets(String projectName) async {
    try {
      final pubspec = File('$projectName/pubspec.yaml');
      var content = pubspec.readAsStringSync();

      // Update pubspec.yaml to include assets correctly
      content = content.replaceFirst(
        ' uses-material-design: true',
        '''
  uses-material-design: true

  # Add assets to your application
   assets:
    - assets/icons/
    - assets/svgs/
    - assets/images/
''',
        2, // Replace only the second occurrence of 'flutter:'
      );

      pubspec.writeAsStringSync(content);
      Logger.info('Updated pubspec.yaml to include assets.');
    } catch (e) {
      Logger.error('Error updating pubspec.yaml: $e');
      rethrow;
    }
  }

  Future<void> _addBlocDependencies(String projectName) async {
    try {
      Logger.info('Adding flutter_bloc dependency...');
      final pubspec = File('$projectName/pubspec.yaml');
      var content = pubspec.readAsStringSync();
      content = content.replaceFirst('dependencies:', '''
dependencies:
  flutter_bloc: ^8.0.1
  equatable: ^2.0.3
  ''');

      pubspec.writeAsStringSync(content);

      // Run flutter pub get to fetch dependencies
      await Process.run(
        'flutter',
        ['pub', 'get'],
        runInShell: true,
        workingDirectory: projectName,
      );
      Logger.info('Dependencies added and fetched.');
    } catch (e) {
      Logger.error('Error adding Bloc dependencies: $e');
      rethrow;
    }
  }

  void _createFileWithContent(String filePath, String content) {
    try {
      final file = File(filePath);
      file.writeAsStringSync(content);
      Logger.info('Created: $filePath');
    } catch (e) {
      Logger.error('Error creating file $filePath: $e');
    }
  }

  String _blocFileContent(String blocName) {
    return '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart'; // Add this import if you use Flutter widgets
import '${blocName}_event.dart';
import '${blocName}_state.dart';

class ${_capitalize(blocName)}Bloc extends Bloc<${_capitalize(blocName)}Event, ${_capitalize(blocName)}State> {
  ${_capitalize(blocName)}Bloc() : super(${_capitalize(blocName)}Initial()) {
    on<${_capitalize(blocName)}Event>((event, emit) {
      // TODO: Implement event handler
    });
  }
}
''';
  }

  String _blocEventFileContent(String blocName) {
    return '''
import 'package:flutter/material.dart'; // Add this import if you plan to use Flutter widgets in events

abstract class ${_capitalize(blocName)}Event {}

class ${_capitalize(blocName)}Started extends ${_capitalize(blocName)}Event {}
''';
  }

  String _blocStateFileContent(String blocName) {
    return '''
import 'package:flutter/material.dart'; // Add this import if you plan to use Flutter widgets in states

abstract class ${_capitalize(blocName)}State {}

class ${_capitalize(blocName)}Initial extends ${_capitalize(blocName)}State {}
''';
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
