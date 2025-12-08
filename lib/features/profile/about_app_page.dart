import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = Responsive.isDesktop(context);
              final isTablet = Responsive.isTablet(context);
              final horizontalPadding = Responsive.getHorizontalPadding(context);
              final verticalPadding = Responsive.getVerticalPadding(context);
              final spacing = Responsive.getSpacing(context);
              final maxFormWidth = Responsive.getMaxFormWidth(context);

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding.left,
                      verticalPadding.top,
                      horizontalPadding.right,
                      verticalPadding.bottom,
                    ),
                    child: Row(
                      mainAxisAlignment: isDesktop || isTablet
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.primary,
                          size: isDesktop ? 28 : 24,
                        ),
                        SizedBox(width: spacing * 0.6),
                        Text(
                          'Про застосунок',
                          style: TextStyle(
                            color: colors.onBackground,
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding.left,
                          0,
                          horizontalPadding.right,
                          verticalPadding.bottom * 2,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop || isTablet ? maxFormWidth : double.infinity,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              isDesktop ? 32 : isTablet ? 24 : 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Адаптивна сітка для контенту на десктопі
                                if (isDesktop)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Movie Discovery App',
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: colors.onBackground,
                                              ),
                                            ),
                                            SizedBox(height: spacing * 1.5),
                                            Text(
                                              'У цьому застосунку ви можете знаходити нові фільми та серіали, '
                                              'керувати вибраним та переглядати персональні добірки.',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: colors.onSurfaceVariant,
                                                height: 1.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: spacing * 2),
                                      Container(
                                        padding: EdgeInsets.all(spacing * 2),
                                        decoration: BoxDecoration(
                                          color: theme.cardColor,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: colors.outlineVariant.withOpacity(0.8),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                theme.brightness == Brightness.light ? 0.08 : 0.25,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.movie,
                                              size: 64,
                                              color: colors.primary,
                                            ),
                                            SizedBox(height: spacing),
                                            Text(
                                              'Версія: 1.0.0',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colors.onBackground,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Movie Discovery App',
                                        style: TextStyle(
                                          fontSize: isTablet ? 28 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: colors.onBackground,
                                        ),
                                      ),
                                      SizedBox(height: spacing),
                                      Text(
                                        'У цьому застосунку ви можете знаходити нові фільми та серіали, '
                                        'керувати вибраним та переглядати персональні добірки.',
                                        style: TextStyle(
                                          fontSize: isTablet ? 17 : 16,
                                          color: colors.onSurfaceVariant,
                                          height: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: spacing * 1.5),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(spacing * 1.5),
                                        decoration: BoxDecoration(
                                          color: theme.cardColor,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: colors.outlineVariant.withOpacity(0.8),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                theme.brightness == Brightness.light ? 0.08 : 0.25,
                                              ),
                                              blurRadius: 14,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.movie,
                                              size: isTablet ? 48 : 40,
                                              color: colors.primary,
                                            ),
                                            SizedBox(width: spacing),
                                            Text(
                                              'Версія: 1.0.0',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colors.onBackground,
                                                fontSize: isTablet ? 17 : 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

