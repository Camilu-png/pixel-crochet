import '../models/crochet_project.dart';

class PlatformStorage {
  static Future<List<CrochetProject>> loadAll() =>
      throw UnsupportedError('Not supported on this platform');

  static Future<CrochetProject?> load(String id) =>
      throw UnsupportedError('Not supported on this platform');

  static Future<void> save(CrochetProject project) =>
      throw UnsupportedError('Not supported on this platform');

  static Future<void> delete(String id) =>
      throw UnsupportedError('Not supported on this platform');
}
