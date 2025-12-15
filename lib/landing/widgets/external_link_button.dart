import 'package:flutter/material.dart';
import 'package:app/utilities/url_launcher.dart';

class ExternalLinkButton extends StatelessWidget {
  final String? url;
  final String label;
  final IconData iconData;
  final bool enabled;

  const ExternalLinkButton({
    this.url,
    required this.label,
    required this.iconData,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && url != null && url!.isNotEmpty;
    final color = isEnabled ? Colors.white : Colors.white38;
    
    return TextButton(
      onPressed: isEnabled
          ? () {
              launchUrl(url!);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(
              iconData,
              color: color,
            ),
            const SizedBox(width: 24.0),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
