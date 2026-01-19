import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EvokeToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isNew;
  final List<Color>? gradient;

  const EvokeToolCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = const Color(0xFF3A86FF),
    required this.onTap,
    this.isNew = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text and icon colors based on whether a gradient is present
    final isGradient = gradient != null;
    final textColor = isGradient ? Colors.white : Colors.black87;
    final subTextColor = isGradient
        ? Colors.white.withOpacity(0.9)
        : Colors.black54; // Assuming standard subtext color
    final iconBgColor = isGradient
        ? Colors.white.withOpacity(0.2)
        : Colors.white;
    final effectiveIconColor = isGradient ? Colors.white : iconColor;
    final borderColor = isGradient
        ? Colors.transparent
        : Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isGradient ? null : Colors.white,
        gradient: isGradient
            ? LinearGradient(
                colors: gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16), // Slightly more rounded
        boxShadow: [
          BoxShadow(
            color: (isGradient ? gradient!.first : Colors.grey).withOpacity(
              0.2,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16), // Increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: title.contains('->')
                          ? _buildArrowTitle(context, textColor)
                          : Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                    ),
                    if (isNew) const Gap(8),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isGradient
                              ? Colors.white
                              : Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "New",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isGradient ? gradient!.first : Colors.purple,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isGradient
                            ? null
                            : Border.all(color: borderColor),
                      ),
                      child: Icon(icon, color: effectiveIconColor, size: 24),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: subTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowTitle(BuildContext context, Color color) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.5,
      ),
    );
  }
}
