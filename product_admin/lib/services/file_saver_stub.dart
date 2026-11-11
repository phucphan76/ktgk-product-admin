/// On mobile there is no download folder access without extra plugins;
/// the caller falls back to copying the JSON to the clipboard.
Future<bool> saveTextFile(String filename, String content) async => false;
