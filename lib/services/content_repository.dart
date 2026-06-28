import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// The bundled content sets the player can choose from.
enum ContentSet {
  easyWords('assets/content/words_easy.json', 'Easy words'),
  mediumWords('assets/content/words_medium.json', 'Medium words'),
  phrases('assets/content/phrases.json', 'Phrases');

  const ContentSet(this.assetPath, this.label);
  final String assetPath;
  final String label;
}

/// Loads word/phrase lists bundled as JSON assets. Results are cached.
class ContentRepository {
  final Map<ContentSet, List<String>> _cache = {};

  Future<List<String>> load(ContentSet set) async {
    final cached = _cache[set];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(set.assetPath);
    final list = (json.decode(raw) as List).map((e) => e as String).toList();
    _cache[set] = list;
    return list;
  }
}
