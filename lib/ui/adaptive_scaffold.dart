import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/widgets/ambient_background.dart';
import '../core/widgets/animated_page_transition.dart';
import 'features/backup/views/backup_restore_view.dart';
import 'features/dashboard/views/dashboard_view.dart';
import 'features/portfolio/views/portfolio_view.dart';
import 'features/transactions/views/transaction_list_view.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<String> _navTitles = [
    'Dasbor & Ringkasan',
    'Catatan Transaksi',
    'Portofolio & Hutang',
    'Cadangan & Privasi',
  ];

  final List<IconData> _navIcons = [
    Icons.dashboard_rounded,
    Icons.receipt_long_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.settings_backup_restore_rounded,
  ];

  void _onNavigate(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return DashboardView(
          onNavigateToTransactions: () => _onNavigate(1),
        );
      case 1:
        return const TransactionListView();
      case 2:
        return const PortfolioView();
      case 3:
        return BackupRestoreView(
          onDataRestored: () => _onNavigate(0),
        );
      default:
        return DashboardView(
          onNavigateToTransactions: () => _onNavigate(1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppDimensions.mobileBreakpoint;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: AmbientBackground(
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
          bottomNavigationBar: isDesktop ? null : _buildMobileBottomBar(),
        );
      },
    );
  }

  // --- DESKTOP LAYOUT WITH NEUMORPHISM LIGHT SIDEBAR ---
  Widget _buildDesktopLayout() {
    final sidebarWidth = _isSidebarCollapsed
        ? AppDimensions.sidebarWidthCollapsed
        : AppDimensions.sidebarWidthExpanded;

    return Row(
      children: [
        // Collapsible Sidebar with Neumorphism Light aesthetic
        AnimatedContainer(
          duration: AppDimensions.durationSidebar,
          curve: Curves.easeOutCubic,
          width: sidebarWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.backgroundSidebar,
            border: Border(
              right: BorderSide(color: Color(0xFFD6E2F0), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A94A3B8),
                offset: Offset(2, 0),
                blurRadius: 8,
              ),
            ],
          ),
          child: _buildSidebarContent(),
        ),

        // Animated Page Content Area
        Expanded(
          child: AnimatedPageSwitch(
            pageKey: ValueKey<int>(_currentIndex),
            child: _buildCurrentPage(),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingM,
          horizontal: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Brand Pill Badge & Subtitle (matching IT-Toolbox screenshot)
            if (!_isSidebarCollapsed) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Blue Capsule Brand Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x332563EB),
                          offset: Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'FINANCE TOOLBOX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Version Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF93C5FD), width: 1),
                    ),
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'FINANCIAL WORKBENCH',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ] else ...[
              // Collapsed Brand Icon
              Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Collapse / Expand Toggle Button
            Align(
              alignment: _isSidebarCollapsed
                  ? Alignment.center
                  : Alignment.centerRight,
              child: GestureDetector(
                onTap: () => setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                }),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderMedium,
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.neuLightHighlight,
                          offset: Offset(-1, -1),
                          blurRadius: 3,
                        ),
                        BoxShadow(
                          color: AppColors.neuDarkShadow,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        turns: _isSidebarCollapsed ? 0.5 : 0.0,
                        duration: AppDimensions.durationSidebar,
                        curve: Curves.easeOutCubic,
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section Label
            if (!_isSidebarCollapsed) ...[
              const Padding(
                padding: EdgeInsets.only(left: 6.0, bottom: 8.0),
                child: Text(
                  'ALAT & KEUANGAN',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],

            // Navigation Items
            Expanded(
              child: ListView.separated(
                itemCount: _navTitles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final isSelected = _currentIndex == index;
                  return _buildSidebarNavItem(
                    index: index,
                    title: _navTitles[index],
                    icon: _navIcons[index],
                    isSelected: isSelected,
                  );
                },
              ),
            ),

            // Bottom Footer Section (matching IT-Toolbox screenshot)
            if (!_isSidebarCollapsed) ...[
              // Theme indicator pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(color: AppColors.borderMedium, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.neuLightHighlight,
                      offset: Offset(-1, -1),
                      blurRadius: 3,
                    ),
                    BoxShadow(
                      color: AppColors.neuDarkShadow,
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Text('🎨', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 6),
                    Text(
                      'Neumorphism Light',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Active Screen Indicator Pill with Green Dot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _navTitles[_currentIndex],
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tech stack info
              const Center(
                child: Text(
                  'Flutter • SQLite • 100% Offline',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ] else ...[
              // Collapsed status dots
              Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required int index,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onNavigate(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppDimensions.durationMicro,
          padding: EdgeInsets.symmetric(
            horizontal: _isSidebarCollapsed ? 12 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            color: isSelected ? const Color(0xFFDBEAFE) : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFF93C5FD) : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x262563EB),
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: _isSidebarCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout() {
    return AnimatedPageSwitch(
      pageKey: ValueKey<int>(_currentIndex),
      child: _buildCurrentPage(),
    );
  }

  Widget _buildMobileBottomBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderMedium, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.neuLightHighlight,
            offset: Offset(-2, -2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: AppColors.neuDarkShadow,
            offset: Offset(2, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navTitles.length, (index) {
            final isSelected = _currentIndex == index;
            final icon = _navIcons[index];
            final title = _navTitles[index];

            return GestureDetector(
              onTap: () => _onNavigate(index),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: AppDimensions.durationMicro,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFDBEAFE)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF93C5FD)
                          : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
