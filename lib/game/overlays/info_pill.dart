import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    required this.icon,
    this.isSmall = false,
  });

  final String label;
  final IconData icon;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(isSmall ? 14 : 20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: isSmall ? 18 : 22,
          ),
          SizedBox(width: isSmall ? 10 : 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: isSmall ? 14 : 17,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
