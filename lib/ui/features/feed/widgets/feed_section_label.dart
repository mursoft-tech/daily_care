import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

class FeedSectionLabel extends StatelessWidget {
  const FeedSectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.nunito(
              size: 12.5,
              weight: FontWeight.w800,
              color: AppColors.sectionLabel,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: AppColors.sectionDivider),
            ),
          ),
        ],
      ),
    );
  }
}
