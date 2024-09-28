import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class UpdateCommand extends Command<int> {
  UpdateCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get description => 'Update the CLI to the latest version from GitHub.';

  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final latestVersion = await _fetchLatestVersion();
    if (latestVersion == null) {
      _logger.err('Failed to fetch the latest version.');
      return ExitCode.software.code;
    }

    _logger.info('Updating to version: $latestVersion');

    try {
      final result = await Process.run(
        'git',
        ['pull'],
        runInShell: true,
      );
      if (result.exitCode != 0) {
        _logger.err('Error updating repository: ${result.stderr}');
        return ExitCode.software.code;
      }

      _logger.info('Successfully updated to $latestVersion');
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Error during update: $e');
      return ExitCode.software.code;
    }
  }

  Future<String?> _fetchLatestVersion() async {
    // Use the GitHub API endpoint for releases
    const url = 'https://api.github.com/repos/phuclh1406/MyPLCLI/releases/latest';

    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'mypl'); // Set User-Agent header

      final responseBody = await request.close();

      if (responseBody.statusCode != 200) {
        _logger.err('Failed to fetch release information from GitHub: ${responseBody.statusCode}');
        return null;
      }

      // Read the response and decode JSON
      final jsonResponse = await responseBody.transform(utf8.decoder).join();
      final data = jsonDecode(jsonResponse);

      // Return the latest version tag
      return data['tag_name'] as String?;
    } catch (e) {
      _logger.err('Exception occurred while fetching the latest version: $e');
      return null;
    }
  }

}
