import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final horizontalPadding = Responsive.getHorizontalPadding(context);
    final isMobile = Responsive.isMobile(context);
    final headerHeight = isMobile ? 200.0 : 240.0;

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.getSpacing(context) / 2),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: headerHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const NetworkImage(
                  'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1400&q=80',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.white.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.2),
                        ]
                      : [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                        ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding.left),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.primary.withOpacity(0.16)
                              : colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.movie_filter_outlined,
                          color: isDark ? colors.onPrimary : colors.primary,
                          size: isMobile ? 24 : 28,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Movie discovery app',
                              style: TextStyle(
                                color: colors.onBackground,
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.headerSubtitle,
                              style: TextStyle(
                                color: colors.onBackground.withOpacity(0.7),
                                fontSize: isMobile ? 13 : 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.headerDescription,
                          style: TextStyle(
                            color: colors.onBackground.withOpacity(0.9),
                            height: 1.35,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: isDark
                              ? colors.onPrimary
                              : Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 14 : 18,
                            vertical: isMobile ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppConstants.searchRoute),
                        icon: const Icon(Icons.explore),
                        label: Text(
                          AppLocalizations.of(context)!.explore,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
