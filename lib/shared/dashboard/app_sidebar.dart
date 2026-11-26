import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/dashboard_header.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.width,
    required this.currentPath,
    required this.userName,
    required this.onClose,
    required this.onOpenChat,
    required this.onNewStudy,
  });

  final double width;
  final String currentPath;
  final String userName;
  final VoidCallback onClose;
  final VoidCallback onOpenChat;
  final VoidCallback onNewStudy;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isUserMenuOpen = false;

  void _toggleUserMenu() {
    setState(() => _isUserMenuOpen = !_isUserMenuOpen);
  }

  void _closeUserMenu() {
    setState(() => _isUserMenuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final currentRoute = _selectedRoute(widget.currentPath);

    return SizedBox(
      width: widget.width,
      child: Container(
        color: colors.green,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    child: _SidebarHeader(),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space12,
                        right: AppSpacing.space12,
                        bottom: AppSpacing.drawerListBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _NavItems(
                            currentRoute: currentRoute,
                            onSelect: (context, item) {
                              widget.onClose();
                              context.goNamed(item.routeName);
                            },
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          Text(
                            'Recents',
                            style: AppTextStyles.drawerSectionLabel.copyWith(
                              color: colors.sidebarMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          _RecentChats(onOpenChat: widget.onOpenChat),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: AppSizes.drawerListFadeHeight,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.green.withValues(
                            alpha: AppOpacity.transparent,
                          ),
                          colors.green,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isUserMenuOpen)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _closeUserMenu,
                  ),
                ),
              if (_isUserMenuOpen)
                Positioned(
                  left: AppSpacing.drawerHorizontalMargin,
                  bottom:
                      AppSpacing.drawerBottomMargin +
                      AppSizes.drawerAvatarSize +
                      AppSpacing.space8,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          widget.width - AppSpacing.drawerHorizontalMargin * 2,
                    ),
                    child: _UserMenuPopup(onClose: _closeUserMenu),
                  ),
                ),
              Positioned(
                left: AppSpacing.drawerHorizontalMargin,
                right: AppSpacing.drawerHorizontalMargin,
                bottom: AppSpacing.drawerBottomMargin,
                child: _SidebarFooter(
                  userName: widget.userName,
                  onUserTap: _toggleUserMenu,
                  onNewStudy: widget.onNewStudy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedRoute(String path) {
    if (path.startsWith('/study-profile')) return '/study-profile';
    if (path == '/sidebar-active-chat') return '/chat';
    return path;
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: AppSizes.headerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/vide_wordmark_green.png',
            width: AppSizes.sidebarLogoWidth,
            height: AppSizes.sidebarLogoHeight,
            color: colors.card,
            colorBlendMode: BlendMode.srcIn,
          ),
          HeaderIcon(icon: AppIcons.search, color: colors.card),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.routePath,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final String routePath;
}

class _NavItems extends StatelessWidget {
  const _NavItems({required this.currentRoute, required this.onSelect});

  final String currentRoute;
  final void Function(BuildContext context, _NavItem item) onSelect;

  static const _items = <_NavItem>[
    _NavItem(
      icon: AppIcons.chat,
      label: 'Chat',
      routeName: 'chat',
      routePath: '/chat',
    ),
    _NavItem(
      icon: AppIcons.layers,
      label: 'Flashcards',
      routeName: 'flashcards',
      routePath: '/flashcards',
    ),
    _NavItem(
      icon: AppIcons.clock,
      label: 'Focus timer',
      routeName: 'focus-timer',
      routePath: '/focus-timer',
    ),
    _NavItem(
      icon: AppIcons.person,
      label: 'Study profile',
      routeName: 'study-profile',
      routePath: '/study-profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _items.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.space2),
          _NavRow(
            item: _items[index],
            isSelected: _items[index].routePath == currentRoute,
            onTap: () => onSelect(context, _items[index]),
          ),
        ],
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = isSelected ? colors.card : colors.sidebarMuted;

    return ClipRRect(
      borderRadius: AppRadii.drawerNav,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.drawerNav,
          child: Container(
            height: AppSizes.drawerNavRowHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
            decoration: BoxDecoration(
              color: isSelected ? colors.activeRow : null,
              borderRadius: AppRadii.drawerNav,
            ),
            child: Row(
              children: [
                AppIcon(item.icon, size: AppSizes.iconMenu, color: foreground),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.drawerItem.copyWith(
                      color: foreground,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentChat {
  const _RecentChat({required this.title});

  final String title;
}

class _RecentChats extends StatelessWidget {
  const _RecentChats({required this.onOpenChat});

  final VoidCallback onOpenChat;

  static const List<_RecentChat> _chats = [
    _RecentChat(title: 'Waterfall Model Overview'),
    _RecentChat(title: 'CSC 301: Process Scheduling'),
    _RecentChat(title: 'Binary Search Complexity'),
    _RecentChat(title: 'Renal Clearance Formulas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < _chats.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.space2),
          _RecentChatRow(chat: _chats[index], onTap: onOpenChat),
        ],
      ],
    );
  }
}

class _RecentChatRow extends StatelessWidget {
  const _RecentChatRow({required this.chat, required this.onTap});

  final _RecentChat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: AppSizes.drawerRecentRowHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.row,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          child: Row(
            children: [
              AppIcon(
                AppIcons.chat,
                size: AppSizes.iconAction,
                color: colors.card,
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  chat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.uiBody.copyWith(color: colors.card),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.userName,
    required this.onUserTap,
    required this.onNewStudy,
  });

  final String userName;
  final VoidCallback onUserTap;
  final VoidCallback onNewStudy;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onUserTap,
          borderRadius: AppRadii.pill,
          child: Container(
            width: AppSizes.drawerAvatarSize,
            height: AppSizes.drawerAvatarSize,
            decoration: BoxDecoration(
              color: colors.yellow,
              shape: BoxShape.circle,
              boxShadow: const [AppShadows.drawerFloating],
            ),
            child: Center(
              child: Text(
                userName.isEmpty ? '' : userName.substring(0, 1).toUpperCase(),
                style: AppTextStyles.uiLabel.copyWith(color: colors.onYellow),
              ),
            ),
          ),
        ),
        _NewStudyButton(onTap: onNewStudy),
      ],
    );
  }
}

class _NewStudyButton extends StatefulWidget {
  const _NewStudyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NewStudyButton> createState() => _NewStudyButtonState();
}

class _NewStudyButtonState extends State<_NewStudyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed
            ? AppMotion.buttonPressedScale
            : AppMotion.buttonRestScale,
        duration: AppMotion.buttonPressDuration,
        curve: Curves.easeOut,
        child: Container(
          height: AppSizes.drawerFloatingButtonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          decoration: BoxDecoration(
            color: colors.yellow,
            borderRadius: AppRadii.pill,
            boxShadow: const [AppShadows.drawerFloating],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIcons.plus,
                size: AppSizes.iconMenu,
                color: colors.onYellow,
              ),
              const SizedBox(width: AppSpacing.space8),
              Flexible(
                child: Text(
                  'New study',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.uiButton.copyWith(
                    color: colors.onYellow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMenuPopup extends StatelessWidget {
  const _UserMenuPopup({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarPopupWidth,
      padding: const EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        borderRadius: AppRadii.sidebarPopup,
        border: Border.all(color: AppColors.of(context).line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UserMenuRow(
            icon: AppIcons.sparkle,
            label: 'Upgrade to Pro',
            onTap: () {
              onClose();
            },
          ),
          const SizedBox(height: AppSpacing.space4),
          _UserMenuRow(
            icon: AppIcons.settings,
            label: 'Settings',
            onTap: () {
              onClose();
            },
          ),
          const SizedBox(height: AppSpacing.space4),
          _UserMenuRow(
            icon: AppIcons.moon,
            label: 'Dark theme',
            onTap: () {
              onClose();
            },
          ),
          const SizedBox(height: AppSpacing.space4),
          _UserMenuRow(
            icon: AppIcons.signOut,
            label: 'Sign out',
            isDangerous: true,
            onTap: () {
              onClose();
            },
          ),
        ],
      ),
    );
  }
}

class _UserMenuRow extends StatelessWidget {
  const _UserMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDangerous = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = isDangerous ? colors.error : colors.green;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.sidebarPopupRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        decoration: BoxDecoration(borderRadius: AppRadii.option),
        child: Row(
          children: [
            AppIcon(icon, size: AppSizes.iconAction, color: foreground),
            const SizedBox(width: AppSpacing.space10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.uiButton.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
