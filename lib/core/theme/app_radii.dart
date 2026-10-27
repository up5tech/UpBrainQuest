/// Corner radius scale used across the app.
///
/// 12 for inputs, 16 for standard cards, 24 for large hero cards
/// (PLAN §8.2).
abstract final class AppRadii {
  const AppRadii._();

  /// Radius for text inputs and small controls.
  static const double input = 12;

  /// Radius for standard cards.
  static const double card = 16;

  /// Radius for large hero cards.
  static const double hero = 24;

  /// Radius for pill-shaped chips and badges.
  static const double pill = 999;
}
