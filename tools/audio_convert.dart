// tools/audio_convert.dart
import 'dart:io';
import 'package:path/path.dart' as p;

class AudioConvert {
  /// Converts an input audio file (mp3/m4a) into OGG Opus with loudness normalization + gain.
  static Future<File> toOpus(File input) async {
    final dir = input.parent.path;
    final name = p.basenameWithoutExtension(input.path);
    final output = File('$dir/$name.opus');

    final result = await Process.run('ffmpeg', [
      '-i', input.path,

      // Loudness normalization + gain boost
      '-filter:a', 'loudnorm=I=-16:TP=-1.5:LRA=11,volume=1.5',

      '-c:a', 'libopus',
      '-b:a', '64k',
      output.path,
      '-y'
    ]);

    if (result.exitCode != 0) {
      throw Exception('Conversion failed: ${result.stderr}');
    }

    return output;
  }
}