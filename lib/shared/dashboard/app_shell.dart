import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child, required this.currentPath});

  final Widget child;
  final String currentPath;

  static void openDrawer(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    if (state == null) {
      throw FlutterError('AppShell.openDrawer called outside an AppShell.');
    }
    state.openDrawer();
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  bool _keyboardVisible = false;

  late final AnimationController _drawerController = AnimationController(
    vsync: this,
    duration: AppMotion.drawerDuration,
  );

  void openDrawer() => unawaited(_openDrawerAfterKeyboardDismisses());

  Future<void> _openDrawerAfterKeyboardDismisses() async {
    if (_keyboardVisible) {
      FocusManager.instance.primaryFocus?.unfocus();
      while (mounted && _keyboardVisible) {
        await WidgetsBinding.instance.endOfFrame;
      }
    }
    if (!mounted) return;
    await _drawerController.animateTo(
      1,
      duration: AppMotion.drawerDuration,
      curve: Curves.easeOut,
    );
  }

  void _closeDrawer() {
    _drawerController.animateTo(
      0,
      duration: AppMotion.drawerDuration,
      curve: Curves.easeOut,
    );
  }

  void _startNewStudy() {
    _closeDrawer();
    context.goNamed('chat');
  }

  void _updateDrag(DragUpdateDetails details, double drawerWidth) {
    if (drawerWidth <= 0) return;
    _drawerController.value =
        (_drawerController.value + details.delta.dx / drawerWidth)
            .clamp(0, 1)
            .toDouble();
  }

  void _settleDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen = velocity.abs() >= AppMotion.drawerFlingVelocity
        ? velocity > 0
        : _drawerController.value >= AppMotion.drawerOpenThreshold;
    if (shouldOpen) {
      openDrawer();
    } else {
      _closeDrawer();
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final colors = AppColors.of(context);
    final drawerWidth =
        MediaQuery.sizeOf(context).width * AppSizes.drawerWidthFactor;
    final shellTheme = Theme.of(
      context,
    ).copyWith(scaffoldBackgroundColor: colors.green);

    return AnimatedBuilder(
      animation: _drawerController,
      builder: (context, _) {
        final progress = _drawerController.value;
        final isDrawerOpen = progress > 0;
        final cornerRadius = AppRadii.drawerPageValue * progress;
        final pageBorderRadius = BorderRadius.horizontal(
          left: Radius.circular(cornerRadius),
        );
        final pageShadows = progress == 0
            ? const <BoxShadow>[]
            : AppShadows.pageEdgeShadow
                  .map(
                    (shadow) => shadow.copyWith(
                      color: shadow.color.withValues(
                        alpha: shadow.color.a * progress,
                      ),
                    ),
                  )
                  .toList(growable: false);

        return PopScope<Object?>(
          canPop: !isDrawerOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && isDrawerOpen) _closeDrawer();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) =>
                _updateDrag(details, drawerWidth),
            onHorizontalDragEnd: _settleDrag,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(child: ColoredBox(color: colors.green)),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: Material(
                    type: MaterialType.transparency,
                    child: SizedBox(
                      width: drawerWidth,
                      child: AppSidebar(
                        width: drawerWidth,
                        currentPath: widget.currentPath,
                        userName: 'Muhibudeen',
                        onClose: _closeDrawer,
                        onOpenChat: _closeDrawer,
                        onNewStudy: _startNewStudy,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SizedBox.expand(
                    child: Transform.translate(
                      offset: Offset(drawerWidth * progress, 0),
                      child: SizedBox.expand(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: isDrawerOpen ? _closeDrawer : null,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: pageBorderRadius,
                              boxShadow: pageShadows,
                            ),
                            child: ClipRRect(
                              borderRadius: pageBorderRadius,
                              child: AbsorbPointer(
                                absorbing: isDrawerOpen,
                                child: Theme(
                                  data: shellTheme,
                                  child: widget.child,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
