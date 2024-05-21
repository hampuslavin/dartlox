import "Expr.dart";
import "Lox.dart";
import "Stmt.dart" as Stmt;
import "Token.dart";
import "TokenType.dart";

class ParseError implements Exception {}

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens) {}

  List<Stmt.Stmt?> parse() {
    List<Stmt.Stmt?> statements = [];

    while (!_isAtEnd()) {
      final declaration = _declaration();
      statements.add(declaration);
    }

    return statements;
  }

  Stmt.Stmt? _declaration() {
    try {
      if (_match([TokenType.VAR])) return _varDeclaration();

      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    }
  }

  Stmt.Stmt _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect variable name.");

    Expr? initializer = null;

    if (_match([TokenType.EQUAL])) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, "Expect ';' after variable declaration.");
    return Stmt.Var(name, initializer);
  }

  Stmt.Stmt _statement() {
    if (_match([TokenType.FOR])) return _forStatement();
    if (_match([TokenType.IF])) return _ifStatement();
    if (_match([TokenType.PRINT])) return _printStatement();
    if (_match([TokenType.WHILE])) return _whileStatement();
    if (_match([TokenType.LEFT_BRACE])) return Stmt.Block(_block());
    return _expressionStatement();
  }

  Stmt.Stmt _forStatement() {
    _consume(TokenType.LEFT_PAREN, "Expect '(' after 'for'.");

    Stmt.Stmt? initializer;
    if (_match([TokenType.SEMICOLON])) {
      initializer = null;
    } else if (_match([TokenType.VAR])) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    Expr? condition;
    if (!_check(TokenType.SEMICOLON)) {
      condition = _expression();
    }
    _consume(TokenType.SEMICOLON, "Expect ';' after loop condition");

    Expr? increment;
    if (!_check(TokenType.RIGHT_PAREN)) {
      increment = _expression();
    }
    _consume(TokenType.RIGHT_PAREN, "Expect ')' after for clauses");

    Stmt.Stmt body = _statement();

    if (increment != null) {
      body = Stmt.Block([body, Stmt.Expression(increment)]);
    }

    if (condition == null) condition = Literal(true);

    body = Stmt.While(condition, body);

    if (initializer != null) {
      body = Stmt.Block([initializer, body]);
    }

    return body;
  }

  Stmt.Stmt _ifStatement() {
    _consume(TokenType.LEFT_PAREN, "Expect '(' after 'if'.");
    Expr condition = _expression();
    _consume(TokenType.RIGHT_PAREN, "Expect ')' after if condition.");

    Stmt.Stmt thenBranch = _statement();
    Stmt.Stmt? elseBranch = null;
    if (_match([TokenType.ELSE])) {
      elseBranch = _statement();
    }

    return new Stmt.If(condition, thenBranch, elseBranch);
  }

  Stmt.Stmt _printStatement() {
    Expr value = _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after value.");
    return new Stmt.Print(value);
  }

  Stmt.Stmt _whileStatement() {
    _consume(TokenType.LEFT_PAREN, "Expect '(' after 'while'.");
    Expr condition = _expression();
    _consume(TokenType.RIGHT_PAREN, "Expect ')' after condition.");
    Stmt.Stmt body = _statement();

    return Stmt.While(condition, body);
  }

  Stmt.Stmt _expressionStatement() {
    Expr expression = _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after expression.");
    return Stmt.Expression(expression);
  }

  Expr _expression() {
    return _assignment();
  }

  Expr _assignment() {
    Expr expression = _ternary();

    if (_match([TokenType.EQUAL])) {
      Token equals = _previous();
      Expr value = _assignment();

      if (expression is Variable) {
        Token name = expression.name;
        return Assign(name, value);
      }

      _error(equals, "Invalid assignment target.");
    }

    return expression;
  }

  Expr _ternary() {
    Expr expression = _or();
    if (_match([
      TokenType.QUESTION_MARK,
    ])) {
      Expr left = _equality();
      _consume(TokenType.COLON, "Expect ':' after ternary expression.");
      Expr right = _equality();
      return Ternary(expression, left, right);
    }

    return expression;
  }

  Expr _or() {
    Expr expr = _and();
    while (_match([TokenType.OR])) {
      Token operator = _previous();
      Expr right = _and();
      expr = Logical(expr, operator, right);
    }

    return expr;
  }

  Expr _and() {
    Expr expr = _equality();

    while (_match([TokenType.AND])) {
      Token operator = _previous();
      Expr right = _equality();
      expr = Logical(expr, operator, right);
    }

    return expr;
  }

  Expr _equality() {
    Expr expression = _comparison();

    while (_match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      Token operator = _previous();
      Expr right = _comparison();
      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expr _comparison() {
    Expr expression = _term();

    while (_match([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL
    ])) {
      Token operator = _previous();
      Expr right = _term();
      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expr _term() {
    Expr expression = _factor();
    while (_match([
      TokenType.MINUS,
      TokenType.PLUS,
    ])) {
      Token operator = _previous();
      Expr right = _term();
      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expr _factor() {
    Expr expression = _unary();
    while (_match([
      TokenType.SLASH,
      TokenType.STAR,
    ])) {
      Token operator = _previous();
      Expr right = _term();
      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expr _unary() {
    if (_match([
      TokenType.BANG,
      TokenType.MINUS,
    ])) {
      Token operator = _previous();
      Expr right = _unary();
      return Unary(operator, right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.FALSE])) return Literal(false);
    if (_match([TokenType.TRUE])) return Literal(true);
    if (_match([TokenType.NIL])) return Literal(null);

    if (_match([TokenType.NUMBER, TokenType.STRING])) {
      return Literal(_previous().literal);
    }

    if (_match([TokenType.IDENTIFIER])) {
      return Variable(_previous());
    }

    if (_match([TokenType.LEFT_PAREN])) {
      Expr expr = _expression();
      _consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.");
      return Grouping(expr);
    }

    throw _error(_peek(), "Expected expression");
  }

  Token _previous() {
    assert(_current > 0);
    return _tokens[_current - 1];
  }

  bool _match(List<TokenType> tokenTypes) {
    for (final tokenType in tokenTypes) {
      if (_check(tokenType)) {
        _advance();
        return true;
      }
    }

    return false;
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.EOF;
  }

  bool _check(TokenType tokenType) {
    if (_isAtEnd()) return false;

    return _peek().type == tokenType;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Token _peek() {
    return _tokens[_current];
  }

  Token _consume(TokenType tokenType, String errorMessage) {
    if (_check(tokenType)) return _advance();

    throw _error(_peek(), errorMessage);
  }

  ParseError _error(Token token, String errorMessage) {
    Lox.errorByToken(token, errorMessage);
    return ParseError();
  }

  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.SEMICOLON) return;

      switch (_peek().type) {
        case TokenType.CLASS:
        case TokenType.FUN:
        case TokenType.VAR:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.PRINT:
        case TokenType.RETURN:
          return;
        default:
          break;
      }

      _advance();
    }
  }

  List<Stmt.Stmt?> _block() {
    List<Stmt.Stmt?> statements = [];
    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd()) {
      statements.add(_declaration());
    }

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after block.");

    return statements;
  }
}
