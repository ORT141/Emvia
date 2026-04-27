import 'package:flutter/material.dart';
import '../overlays/glass_ui.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

class UIUtils {
  static Future<void> showWarningDialog(BuildContext context, String message) {
    final l = AppLocalizationsGen.of(context)!;
    return showDialog(
      context: context,
      builder: (ctx) => GlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            GlassButton(
              label: l.continueLabel,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
