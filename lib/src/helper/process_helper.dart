import 'dart:async';
import 'dart:io';

import 'package:mypl/src/helper/helper.dart';
import 'package:mypl/src/helper/logger.dart';

class ProcessHelper extends Helper {
  ProcessHelper._();
  static final ProcessHelper instance = ProcessHelper._();

  Future<void> activateGetCli() async {
    var result = false;
    try {
      result = await runProcessWithoutInteractive('get help', isSilence: true);
    } catch (throwable) {
      result = false;
    }

    if (!result) {
      Logger.info('Not found get cli, start activate');
      await runProcess('flutter pub global activate get_cli');
    }
  }

  Future<bool> runProcessWithoutInteractive(
    String cmd, {
    bool isSilence = false,
  }) async {
    if (!isSilence) {
      Logger.info('Execute shell $cmd');
    }

    final args = cmd.split(' ');
    final executable = args.first;
    args.removeAt(0);
    final process = await Process.run(
      executable,
      args,
    );

    if (!isSilence) {
      Logger.info(process.stdout as String);
      Logger.info(process.stderr as String);
    }

    final exitCode = process.exitCode;
    return exitCode == 0 || exitCode == 5;
  }

  Future<bool> runProcess(
    String cmd, {
    bool isSilence = false,
  }) async {
    if (!isSilence) {
      Logger.info('Execute shell $cmd');
    }

    final args = cmd.split(' ');
    final executable = args.first;
    args.removeAt(0);
    final process = await Process.start(executable, args);
    if (stdin.hasTerminal) {
      stdin.lineMode = false;
      unawaited(stdin.pipe(process.stdin));
    }
    if (!isSilence) {
      process.stdout.listen((event) {
        final message = String.fromCharCodes(event).trim();
        final messages = message.split('\n');
        messages
            .map((message) => message.trim())
            .where((message) => message.isNotEmpty)
            .forEach((message) => Logger.info(message.trim()));
      });

      process.stderr.listen((event) {
        final message = String.fromCharCodes(event).trim();
        final messages = message.split('\n');
        messages
            .map((message) => message.trim())
            .where((message) => message.isNotEmpty)
            .forEach((message) => Logger.info(message.trim()));
      });
    }

    final exitCode = await process.exitCode;
    return exitCode == 0 || exitCode == 5;
  }

  @override
  Future<void> onInit() async {
    // TODO: implement init
  }
}
