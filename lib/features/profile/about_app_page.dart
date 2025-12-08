import 'package:flutter/material.dart';
import 'package:project/core/theme.dart';

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Про застосунок',
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text(
                      'Movie Discovery App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'У цьому застосунку ви можете знаходити нові фільми та серіали, '
                      'керувати вибраним та переглядати персональні добірки.',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Версія: 1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

