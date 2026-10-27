/// Spacing scale used across the app.
///
/// The scale is 4, 8, 12, 16, 24, 32 (PLAN §8.2). Widgets must use these
/// constants instead of literal paddings so that rhythm stays consistent.
abstract final class AppSpacing {
  const AppSpacing._();

  /// 4dp — hairline gaps between tightly related elements.
  static const double xxs = 4;

  /// 8dp — gap between related elements.
  static const double xs = 8;

  /// 12dp — gap inside compact containers.
  static const double sm = 12;

  /// 16dp — default padding for cards and list items.
  static const double md = 16;

  /// 24dp — gap between grouped sections.
  static const double lg = 24;

  /// 32dp — gap between major sections.
  static const double xl = 32;
}
