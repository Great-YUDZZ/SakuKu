class AppDimensions {
  AppDimensions._();

  // Breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;

  // Sidebar Layout
  static const double sidebarWidthExpanded = 240.0;
  static const double sidebarWidthCollapsed = 84.0;

  // Radiuses (Neumorphism Light signature)
  static const double radiusCard = 14.0;
  static const double radiusButton = 10.0;
  static const double radiusInput = 10.0;
  static const double radiusPill = 999.0;
  static const double radiusModal = 20.0;

  // Card Left Accent Stripe
  static const double cardStripeWidth = 3.5;

  // Padding & Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 20.0;
  static const double paddingXL = 28.0;

  // Durations (Smooth responsive micro-animations)
  static const Duration durationMicro = Duration(milliseconds: 150);
  static const Duration durationUI = Duration(milliseconds: 240);
  static const Duration durationPage = Duration(milliseconds: 280);
  static const Duration durationSidebar = Duration(milliseconds: 260);
}
