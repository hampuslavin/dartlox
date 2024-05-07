import 'dart:io';

import 'Scanner.dart';
import 'Token.dart';

class Lox {
  static bool hadError = false;
  static List<String> _history = [];

  static main(List<String> args) {
    if (args.length > 1) {
      print('Usage: jlox [script]');
      exit(64);
    } else if (args.length == 1) {
      _runFile(args[0]);
    } else {
      _runPrompt();
    }
  }

  static _runFile(String path) {
    var file = File(path);
    var source = file.readAsStringSync();
    _run(source);

    if (hadError) exit(65);
  }

  static _runPrompt() {
    while (true) {
      stdout.write('> ');
      var line = stdin.readLineSync();
      if (line == null) break;
      _run(line);
      _history.add(line);
      hadError = false;
    }
  }

  static _run(String source) {
    Scanner scanner = Scanner(source);
    List<Token> tokens = scanner.scanTokens();

    for (final token in tokens) {
      print(token);
    }
  }

  static error(int line, String message) {
    _report(line, '', message);
  }

  static _report(int line, String where, String message) {
    print("[line " + line.toString() + "] Error" + where + ": " + message);
    hadError = true;
  }
}

void main(List<String> args) {
  Lox.main(args);
}
