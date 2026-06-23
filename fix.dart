import 'dart:io';

void main() {
  final file = File('pubspec.yaml');
  final lines = file.readAsLinesSync();
  int firstIndex = lines.indexOf('name: puzzle');
  int secondIndex = lines.lastIndexOf('name: puzzle');
  if (secondIndex > firstIndex) {
    final newLines = lines.sublist(0, secondIndex);
    while (newLines.isNotEmpty && newLines.last.trim().isEmpty) {
      newLines.removeLast();
    }
    newLines.add('flutter_launcher_icons:');
    newLines.add('  android: true');
    newLines.add('  ios: true');
    newLines.add('  image_path: "assets/fav icon.png"');
    file.writeAsStringSync(newLines.join('\n'));
  }
}
