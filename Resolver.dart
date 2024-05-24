import 'Expr.dart' as Expr;
import 'Interpreter.dart';
import 'Lox.dart';
import 'Stmt.dart' as Stmt;
import 'Token.dart';

enum FunctionType { NONE, FUNCTION }

class Resolver implements Expr.Visitor<void>, Stmt.Visitor<void> {
  final Interpreter _interpreter;
  List<Map<String, bool>> _scopes = [];
  FunctionType _currentFunction = FunctionType.NONE;

  Resolver(this._interpreter) {}

  @override
  void visitAssignExpr(Expr.Assign expr) {
    _resolveOne(expr.value);
    _resolveLocal(expr, expr.name);
  }

  @override
  void visitBinaryExpr(Expr.Binary expr) {
    _resolveOne(expr.left);
    _resolveOne(expr.right);
  }

  @override
  void visitBlockStmt(Stmt.Block stmt) {
    _beginScope();
    resolve(stmt.statements);
    _endScope();
  }

  @override
  void visitBreakStmt(Stmt.Break stmt) {
    // TODO: implement visitBreakStmt
  }

  @override
  void visitCallExpr(Expr.Call expr) {
    _resolveOne(expr.callee);
    for (final argument in expr.arguments) {
      _resolveOne(argument);
    }
  }

  @override
  void visitExpressionStmt(Stmt.Expression stmt) {
    _resolveOne(stmt.expression);
  }

  @override
  void visitFunction_Stmt(Stmt.Function_ stmt) {
    // TODO: will break for anonymous function
    _declare(stmt.name!);
    _define(stmt.name!);

    _resolveFunction(stmt, FunctionType.FUNCTION);
  }

  @override
  void visitGroupingExpr(Expr.Grouping expr) {
    _resolveOne(expr.expression);
  }

  @override
  void visitIfStmt(Stmt.If stmt) {
    _resolveOne(stmt.condition);
    _resolveOne(stmt.thenBranch);
    _resolveOne(stmt.elseBranch);
  }

  @override
  void visitLiteralExpr(Expr.Literal expr) {
    return null;
  }

  @override
  void visitLogicalExpr(Expr.Logical expr) {
    _resolveOne(expr.left);
    _resolveOne(expr.right);
  }

  @override
  void visitPrintStmt(Stmt.Print stmt) {
    _resolveOne(stmt.expression);
  }

  @override
  void visitReturnStmt(Stmt.Return stmt) {
    if (_currentFunction == FunctionType.NONE) {
      Lox.errorByToken(stmt.keyword, "Can't return from top-level code.");
    }
    _resolveOne(stmt.value);
  }

  @override
  void visitTernaryExpr(Expr.Ternary expr) {
    _resolveOne(expr.condition);
    _resolveOne(expr.left);
    _resolveOne(expr.right);
  }

  @override
  void visitUnaryExpr(Expr.Unary expr) {
    _resolveOne(expr.right);
  }

  @override
  void visitVarStmt(Stmt.Var stmt) {
    _declare(stmt.name);
    if (stmt.initializer != null) {
      _resolveOne(stmt.initializer);
    }
    _define(stmt.name);
  }

  @override
  void visitVariableExpr(Expr.Variable expr) {
    if (_scopes.isNotEmpty && _scopes.last[expr.name.lexeme] == false) {
      Lox.errorByToken(
          expr.name, "Can't read local variable in its own initializer.");
    }

    _resolveLocal(expr, expr.name);
  }

  @override
  void visitWhileStmt(Stmt.While stmt) {
    _resolveOne(stmt.condition);
    _resolveOne(stmt.body);
  }

  void resolve(List<Stmt.Stmt?> statements) {
    for (final statement in statements) {
      _resolveOne(statement);
    }
  }

  void _resolveOne(Object? statement) {
    if (statement is Stmt.Stmt) {
      statement.accept(this);
    } else if (statement is Expr.Expr) {
      statement.accept(this);
    }
  }

  void _beginScope() {
    _scopes.add(Map<String, bool>());
  }

  void _endScope() {
    _scopes.removeLast();
  }

  void _declare(Token name) {
    if (_scopes.isEmpty) {
      return;
    }

    final scope = _scopes.last;

    if (scope.containsKey(name.lexeme)) {
      Lox.errorByToken(
          name, "Already a variable with this name in this scope.");
    }

    scope[name.lexeme] = false;
  }

  void _define(Token name) {
    if (_scopes.isEmpty) return;
    _scopes.last[name.lexeme] = true;
  }

  void _resolveLocal(Expr.Expr expr, Token name) {
    for (int i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        _interpreter.resolve(expr, _scopes.length - 1 - i);
        return;
      }
    }
  }

  void _resolveFunction(Stmt.Function_ function, FunctionType functionType) {
    FunctionType enclosingFunction = _currentFunction;
    _currentFunction = functionType;
    _beginScope();
    for (final param in function.params) {
      _declare(param);
      _define(param);
    }
    resolve(function.body);
    _endScope();
    _currentFunction = enclosingFunction;
  }
}
