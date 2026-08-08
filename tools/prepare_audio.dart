// tools/prepare_audio.dart
import 'dart:io';
import 'audio_convert.dart';

Future<void> main() async {
  final folders = ['assets/messages', 'assets/sermons', 'assets/songs'];

  for (final path in folders) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      print('⚠️ Skipping missing folder: $path');
      continue;
    }

    final files = dir.listSync().whereType<File>();
    for (final file in files) {
      if (file.path.endsWith('.mp3') || file.path.endsWith('.m4a')) {
        print('Converting ${file.path}...');
        final out = await AudioConvert.toOpus(file);
        print('→ ${out.path}');
      }
    }
  }

  print('✅ All conversions complete.');
}