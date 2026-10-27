/// Formats a scaled ingredient amount for display, snapping to the nearest
/// quarter and preferring unicode fractions (e.g. 2.5 -> "2½", 0.75 -> "¾").
String formatAmount(double value) {
  if (value <= 0) return '0';
  final quarter = (value * 4).round();
  final whole = quarter ~/ 4;
  final frac = quarter % 4;
  const fracSymbols = {1: '¼', 2: '½', 3: '¾'};
  final buffer = StringBuffer();
  if (whole > 0 || frac == 0) buffer.write(whole);
  if (fracSymbols.containsKey(frac)) buffer.write(fracSymbols[frac]);
  final text = buffer.toString();
  return text.isEmpty ? '0' : text;
}

/// Builds a human-readable ingredient label with its scaled amount,
/// e.g. "2½ cups all-purpose flour" or "3 ripe avocados".
String ingredientLabel(String name, String unit, double scaledAmount) {
  final amount = formatAmount(scaledAmount);
  return unit.isEmpty ? '$amount $name' : '$amount $unit $name';
}
