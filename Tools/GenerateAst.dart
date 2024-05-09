import 'dart:io';

void main(List<String> args) {
  if (args.length > 1) {
    print('Usage: generate_ast <output directory>');
    exit(64);
  }

  String outputDir = args[0];

  GenerateAst().run(outputDir);
}

class GenerateAst {
  String contents = "";

  run(String outputDir) {
    _defineAst(
        outputDir,
        "Expr",
        List.of([
          "Binary   : Expr left, Token operator, Expr right",
          "Grouping : Expr expression",
          "Literal  : Object value",
          "Unary    : Token operator, Expr right"
        ]));
  }

  void _defineAst(String outputDir, String baseName, List<String> types) {
    String path = "$outputDir/$baseName.dart";
    File file = File(path);
    contents += "import 'Token.dart';\n\n";
    _defineBaseClass(baseName);

    _defineVisitor(baseName, types);

    for (final type in types) {
      var className = type.split(":")[0].trim();
      var fields = type.split(":")[1].trim();
      _defineType(baseName, className, fields);
    }

    file.writeAsStringSync(contents);
    contents = "";
  }

  void _defineType(String baseName, String className, String fieldsRaw) {
    contents += "class $className extends $baseName {\n";

    final fields = fieldsRaw
        .split(", ")
        .map((e) => ({'typeName': e.split(" ")[0], 'name': e.split(" ")[1]}))
        .toList();

    // Declare fields
    for (final field in fields) {
      contents += "  final ${field['typeName']} ${field['name']};\n";
    }

    contents += "\n";

    // Constructor
    contents += "  $className(";
    for (final field in fields) {
      contents += "this.${field['name']}";
      contents += ", ";
    }
    contents += ");\n\n";

    // Accept method
    contents += "  @override\n";
    contents += "  R accept<R>(Visitor<R> visitor) {\n";
    contents += "    return visitor.visit$className$baseName(this);\n";
    contents += "  }\n";

    // Close class
    contents += "}\n";
  }

  void _defineVisitor(String baseName, List<String> types) {
    contents += "abstract class Visitor<R> {\n";
    for (final type in types) {
      var typeName = type.split(":")[0].trim();
      contents +=
          "  R visit$typeName$baseName($typeName ${baseName.toLowerCase()});\n";
    }

    contents += "}\n";
  }

  _defineBaseClass(String baseName) {
    contents += "abstract class $baseName {\n";

    contents += "  R accept<R>(Visitor<R> visitor);\n";

    contents += "}\n\n";
  }
}
