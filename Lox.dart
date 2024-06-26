import 'dart:io';

import 'Interpreter.dart';
import 'Parser.dart';
import 'Resolver.dart';
import 'RuntimeError.dart';
import 'Scanner/Scanner.dart';
import 'Stmt.dart';
import 'Token.dart';
import 'TokenType.dart';

class Lox {
  static bool hadError = false;
  static bool _hadRuntimeError = false;
  static List<String> _history = [];
  static final Interpreter _interpreter = new Interpreter();

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

  static runtimeError(RuntimeError error) {
    print("${error.message} \n[line ${error.token.line}]");
    _hadRuntimeError = true;
  }

  static _runFile(String path) {
    var file = File(path);
    var source = file.readAsStringSync();
    _run(source);

    if (hadError) exit(65);
    if (_hadRuntimeError) exit(70);
  }

  static _runPrompt() {
    while (true) {
      stdout.write('> ');
      var line = stdin.readLineSync();
      if (line == null) break;
      var result = _run(line, isRepl: true);
      if (result != null) {
        print(result);
      }
      _history.add(line);
      hadError = false;
    }
  }

  static Object? _run(String source, {isRepl = false}) {
    Scanner scanner = Scanner(source);
    List<Token> tokens = scanner.scanTokens();

    Parser parser = new Parser(tokens);
    List<Stmt?> statements = parser.parse();

    // Stop if there was a syntax error.
    if (hadError) return null;

    Resolver resolver = Resolver(_interpreter);
    resolver.resolve(statements);

    if (hadError) return null;

    List<Stmt> valid = statements.map((e) => e as Stmt).toList();

    return _interpreter.interpret(valid, isRepl: isRepl);
  }

  static error(int line, String message) {
    _report(line, '', message);
  }

  static errorByToken(Token token, String message) {
    if (token.type == TokenType.EOF) {
      _report(token.line, " at end", message);
    } else {
      _report(token.line, " at '" + token.lexeme + "'", message);
    }
  }

  static _report(int line, String where, String message) {
    print("[line " + line.toString() + "] Error" + where + ": " + message);
    hadError = true;
  }
}

void main(List<String> args) {
  Lox.main(args);
}
