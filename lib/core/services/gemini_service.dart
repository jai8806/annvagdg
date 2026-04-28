import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyDPEa3bDcsXG6dWI33C_v2dpDwEMqcS45s';
  
  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  // Cache so we only call API once per listing per session
  static final Map<String, Map<String, String>> _cache = {};

  static Future<Map<String, String>> generateSmartRescueCard({
    required String listingId,
    required String dishName,
    required String vertical,
    required String diet,
    required bool isRefrigerated,
  }) async {
    // Return cached result if available
    if (_cache.containsKey(listingId)) return _cache[listingId]!;

    final prompt = '''
Analyze the Indian dish "$dishName" served in a $vertical.
Diet: $diet. Refrigerated: $isRefrigerated.

Return ONLY a valid JSON object with these exact keys:
{
  "safeWindow": "X hours at room temp — one sentence reason based on ingredients (dairy-based dishes shorter window, acidic/tamarind/dry dishes longer)",
  "calories": "~XXX kcal",
  "protein": "Xg",
  "carbs": "Xg",
  "fat": "Xg",
  "allergens": "comma-separated e.g. Dairy, Gluten — or None",
  "dietaryFlags": "e.g. Jain-friendly, Halal, Vegan, Gluten-free — or Not applicable",
  "bestFor": "2-3 short audience types e.g. Family dinner, Office lunch, Post-gym",
  "funFact": "One interesting fact about this dish under 12 words"
}
Return only the JSON. No markdown. No backticks. No explanation.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final clean = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
      final result = Map<String, String>.from(jsonDecode(clean));
      _cache[listingId] = result;
      return result;
    } catch (e) {
      final fallback = {
        'safeWindow': 'Up to 4 hours at room temperature.',
        'calories': '~350 kcal',
        'protein': '12g', 'carbs': '48g', 'fat': '9g',
        'allergens': 'Check with seller',
        'dietaryFlags': diet.isNotEmpty ? diet : 'Check with seller',
        'bestFor': 'Family, Office, Any occasion',
        'funFact': 'Every rescue saves food from landfill.',
      };
      _cache[listingId] = fallback;
      return fallback;
    }
  }
}
