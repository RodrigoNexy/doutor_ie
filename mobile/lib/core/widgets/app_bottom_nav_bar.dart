import 'package:flutter/material.dart';

enum AppTab {
  home('/home', 'Home', Icons.home_outlined, Icons.home),
  books('/books', 'Livros', Icons.menu_book_outlined, Icons.menu_book),
  authors('/authors', 'Autores', Icons.group_outlined, Icons.group),
  profile('/profile', 'Perfil', Icons.person_outline, Icons.person);

  const AppTab(this.route, this.label, this.icon, this.activeIcon);

  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentTab});

  static const double _activeIconTopOffset = -35;
  static const double _inactiveIconTopOffset = 6;
  static const double _itemHeight = 56;
  static const double _labelBottomOffset = 4;

  final AppTab currentTab;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 224, 224),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x221D1D1F),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          child: Row(
            children: AppTab.values
                .map((tab) {
                  final selected = tab == currentTab;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: selected
                          ? null
                          : () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                tab.route,
                                (route) => false,
                              );
                            },
                      child: SizedBox(
                        height: _itemHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: selected
                                  ? _activeIconTopOffset
                                  : _inactiveIconTopOffset,
                              child: selected
                                  ? Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: background.withValues(
                                          alpha: 0.92,
                                        ),
                                        border: Border.all(
                                          color: background.withValues(
                                            alpha: 0.8,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE96F7A),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x33E96F7A),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          tab.activeIcon,
                                          size: 19,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      tab.icon,
                                      size: 17,
                                      color: const Color(0xFF7D7A73),
                                    ),
                            ),
                            Positioned(
                              bottom: _labelBottomOffset,
                              child: Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? const Color(0xFFE96F7A)
                                      : const Color(0xFF7D7A73),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}
