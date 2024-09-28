import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mypl/src/helper/logger.dart';

class CreatePageCommand extends Command<int> {
  CreatePageCommand() {
    argParser.addOption('feature', abbr: 'f', help: 'The feature name for the new page.');
  }

  @override
  String get description => 'Create a new feature structure with specified feature name.';

  @override
  String get name => 'create_page';

  @override
  Future<int> run() async {
    final featureName = (argResults?['feature'] as String?) ?? '';

    if (featureName.isEmpty) {
      Logger.error('Feature name is required.');
      return 1;
    }

    try {
      Logger.info('Creating feature structure for: $featureName');
      await _createFeatureStructure(featureName);
      return 0;
    } catch (e) {
      Logger.error('Error creating feature structure: $e');
      return 1;
    }
  }

  Future<void> _createFeatureStructure(String featureName) async {
    final baseDir = Directory('lib/features/$featureName');

    // Create base directory
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
      Logger.info('Created feature directory: ${baseDir.path}');
    } else {
      Logger.info('Feature directory already exists: ${baseDir.path}');
    }

    // Create subdirectories
    await _createSubDirectory(baseDir, 'data/models');
    await _createSubDirectory(baseDir, 'domain/repository');
    await _createSubDirectory(baseDir, 'presentation/blocs');
    await _createSubDirectory(baseDir, 'presentation/pages');
    await _createSubDirectory(baseDir, 'presentation/widgets');

    // Create files with modified names
    await _createFileWithContent('${baseDir.path}/data/models/${_convertToSnakeCase(featureName)}_model.dart', _modelFileContent(featureName));
    await _createFileWithContent('${baseDir.path}/domain/repository/${_convertToSnakeCase(featureName)}_repository.dart', _repositoryFileContent(featureName));
    await _createFileWithContent('${baseDir.path}/presentation/blocs/${_convertToSnakeCase(featureName)}_bloc.dart', _blocFileContent(featureName));
    await _createFileWithContent('${baseDir.path}/presentation/pages/${_convertToSnakeCase(featureName)}_page.dart', _pageFileContent(featureName));
    await _createFileWithContent('${baseDir.path}/presentation/widgets/${_convertToSnakeCase(featureName)}_widget.dart', _widgetFileContent(featureName));
  }

  Future<void> _createSubDirectory(Directory baseDir, String subDir) async {
    final dir = Directory('${baseDir.path}/$subDir');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      Logger.info('Created subdirectory: ${dir.path}');
    }
  }

  Future<void> _createFileWithContent(String filePath, String content) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      file.writeAsStringSync(content.trim());
      Logger.info('Created file: $filePath');
    } else {
      Logger.info('File already exists: $filePath');
    }
  }

  String _modelFileContent(String featureName) {
    return '''
class ${_capitalize(featureName)}Model {
  // TODO: Define model properties
}
''';
  }

  String _repositoryFileContent(String featureName) {
    return '''
class ${_capitalize(featureName)}Repository {
  // TODO: Define repository methods
}
''';
  }

  String _blocFileContent(String featureName) {
    return '''
import 'package:bloc/bloc.dart';

class ${_capitalize(featureName)}Bloc {
  // TODO: Implement Bloc logic
}
''';
  }

  String _pageFileContent(String featureName) {
    return '''
import 'package:flutter/material.dart';

class ${_capitalize(featureName)}Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_capitalize(featureName)} Page'),
      ),
      body: Center(
        child: Text('Welcome to ${_capitalize(featureName)} Page'),
      ),
    );
  }
}
''';
  }

  String _widgetFileContent(String featureName) {
    return '''
import 'package:flutter/material.dart';

class ${_capitalize(featureName)}Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: Define widget layout
    );
  }
}
''';
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String _convertToSnakeCase(String featureName) {
    final buffer = StringBuffer();
    for (int i = 0; i < featureName.length; i++) {
      final char = featureName[i];
      if (i > 0 && char.toUpperCase() == char) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }
}
