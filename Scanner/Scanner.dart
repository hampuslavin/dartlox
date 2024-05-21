import '../Lox.dart';
import '../Token.dart';
import '../TokenType.dart';

class Scanner {
  static final Map<String, TokenType> keywords = {
    'and': TokenType.AND,
    'class': TokenType.CLASS,
    'else': TokenType.ELSE,
    'false': TokenType.FALSE,
    'for': TokenType.FOR,
    'fun': TokenType.FUN,
    'if': TokenType.IF,
    'nil': TokenType.NIL,
    'or': TokenType.OR,
    'print': TokenType.PRINT,
    'return': TokenType.RETURN,
    'super': TokenType.SUPER,
    'this': TokenType.THIS,
    'true': TokenType.TRUE,
    'var': TokenType.VAR,
    'while': TokenType.WHILE,
  };

  final String _source;
  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;

  Scanner(this._source) {}

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      // We are at the beginning of the next lexeme.
      _start = _current;
      _scanToken();
    }

    _tokens.add(new Token(TokenType.EOF, "", null, _line));
    return _tokens;
  }

  void _scanToken() {
    String c = _advance();
    switch (c) {
      case '(':
        _addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        _addToken(TokenType.COMMA);
        break;
      case '.':
        _addToken(TokenType.DOT);
        break;
      case '-':
        _addToken(TokenType.MINUS);
        break;
      case '+':
        _addToken(TokenType.PLUS);
        break;
      case ';':
        _addToken(TokenType.SEMICOLON);
        break;
      case '*':
        _addToken(TokenType.STAR);
      case '?':
        _addToken(TokenType.QUESTION_MARK);
      case ':':
        _addToken(TokenType.COLON);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '/':
        if (_match('/')) {
          // Line comment
          _lineComment();
        } else if (_match('*')) {
          _multiLineComment();
        } else {
          _addToken(TokenType.SLASH);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
        _line++;
        break;
      case '"':
        _string();
        break;
      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          Lox.error(_line, "Unexpected character: $c");
        }
        break;
    }
  }

  void _multiLineComment() {
    // Block comment, supports recursive
    var nestedCount = 1;
    while (nestedCount > 0 && !_isAtEnd()) {
      if (_match('*') && _match('/')) {
        nestedCount--;
      } else if (_match('/') && _match('*')) {
        nestedCount++;
      } else {
        if (_peek() == '\n') {
          _line++;
        }
        _advance();
      }
    }
    if (nestedCount > 0) {
      Lox.error(_line, "Unterminated block comment");
    }
  }

  void _lineComment() {
    while (_peek() != '\n' && !_isAtEnd()) _advance();
  }

  bool _isAtEnd() {
    return _current >= _source.length;
  }

  _advance() {
    return _source[_current++];
  }

  void _addToken(TokenType type, {Object? literal}) {
    String text = _source.substring(_start, _current);
    _tokens.add(new Token(type, text, literal, _line));
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (_source[_current] != expected) return false;

    _current++;
    return true;
  }

  String _peek() {
    if (_isAtEnd()) return '\x00';
    return _source[_current];
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd()) {
      Lox.error(_line, "Unterminated string.");
      return;
    }

    // The closing ".
    _advance();

    // Trim the surrounding quotes.
    String value = _source.substring(_start + 1, _current - 1);
    _addToken(TokenType.STRING, literal: value);
  }

  bool _isDigit(String c) {
    return c.compareTo('0') >= 0 && c.compareTo('9') <= 0 && c != '\x00';
  }

  void _number() {
    while (_isDigit(_peek())) _advance();

    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance(); // Consume the "."

      while (_isDigit(_peek())) _advance();
    }

    _addToken(TokenType.NUMBER,
        literal: double.parse(_source.substring(_start, _current)));
  }

  String _peekNext() {
    if (_current + 1 >= _source.length) return '\x00';

    return _source[_current + 1];
  }

  bool _isAlpha(String c) {
    return (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
        (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) ||
        c == '_';
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) _advance();

    String text = _source.substring(_start, _current);
    _addToken(keywords[text] ?? TokenType.IDENTIFIER);
  }

  bool _isAlphaNumeric(String c) {
    return _isAlpha(c) || _isDigit(c);
  }
}
