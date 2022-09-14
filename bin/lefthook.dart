import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:system_info/system_info.dart';

const String _downloadBase =
    'https://github.com/evilmartians/lefthook/releases/download';
const String _lefthookVersion = '1.1.1';

final Logger logger = Logger.standard();

void main(List<String> args) async {
  final String executablePath =
      Platform.script.resolve('../.exec/lefthook').toFilePath();
  await _ensureExecutable(executablePath);
  final ProcessResult result = await Process.run(executablePath, args);
  if (result.exitCode != 0) {
    logger.stderr(result.stderr);
  } else {
    logger.stdout(result.stdout);
  }
}

Future<void> _ensureExecutable(String targetPath, {bool force = false}) async {
  if (await File(targetPath).exists() && !force) return;

  final String url = _resolveDownloadUrl();
  logger.stdout('\nDownload executable for lefthook from $url');
  final List<int> fileData = await _downloadFile(url);
  logger.stdout('Download complete\n');

  logger.stdout('Extracting.');
  final extracted = GZipDecoder().decodeBytes(fileData);

  await _saveFile(targetPath, extracted);
  logger.stdout('Executable saved to ${targetPath}');

  await _installLefthook(targetPath);

  logger.stdout('Done.');
}

Future<List<int>> _downloadFile(String url) async {
  final HttpClient client = HttpClient();
  final HttpClientRequest request = await client.getUrl(Uri.parse(url));
  final HttpClientResponse response = await request.close();

  final List<int> data = [];
  final Completer completer = Completer();
  response.listen((d) => data.addAll(d), onDone: completer.complete);
  await completer.future;

  return data;
}

Future<void> _installLefthook(String executablePath) async {
  final ProcessResult result =
      await Process.run(executablePath, ["install", '-f']);
  if (result.exitCode != 0) {
    logger.stderr(result.stderr);
    throw Exception(result.stderr);
  }
  logger.stdout(result.stdout);
}

String _resolveDownloadUrl() {
  String getOS() {
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'MacOS';
    if (Platform.isWindows) return 'Windows';

    throw Error();
  }

  String getArchitecture() {
    final String arch = SysInfo.kernelArchitecture;
    if (arch == 'x86_64') return arch;
    // TODO: check for i386

    throw Error();
  }

  return '$_downloadBase/v${_lefthookVersion}/lefthook_${_lefthookVersion}_${getOS()}_${getArchitecture()}.gz';
}

Future<void> _saveFile(String targetPath, List<int> data) async {
  /// Write file
  final File executableFile = File(targetPath);
  await executableFile.create(recursive: true);
  await executableFile.writeAsBytes(data);

  /// Make file executable
  if (Platform.isWindows) {
    // TODO: Write code for Windows case
    throw Exception("Can' t set executable persmissions on Windows");
  }
  final ProcessResult result =
      await Process.run("chmod", ["u+x", executableFile.path]);
  if (result.exitCode != 0) throw Exception(result.stderr);
}
