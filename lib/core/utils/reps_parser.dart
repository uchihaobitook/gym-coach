/// Parses target reps from a template string like `"8-10"` or `"12"`.
///
/// Ranges return the midpoint (rounded). Invalid input falls back to `10`.
int parseTargetReps(String reps) {
  final trimmed = reps.trim();
  if (trimmed.contains('-')) {
    final parts = trimmed.split('-');
    if (parts.length == 2) {
      final low = int.tryParse(parts[0].trim()) ?? 10;
      final high = int.tryParse(parts[1].trim()) ?? low;
      return ((low + high) / 2).round();
    }
  }
  return int.tryParse(trimmed) ?? 10;
}
