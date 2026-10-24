import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatters/app_date_formatter.dart';
import '../../../../domain/models/child.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({required this.child, super.key});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _InfoRow(
            label: l10n.childProfileBirthDate,
            value: formatBirthDate(child.birthDate, locale),
          ),
          const _InfoDivider(),
          _InfoRow(label: l10n.childProfileRoom, value: child.room),
          const _InfoDivider(),
          _InfoRow(
            label: l10n.childProfileEnrollment,
            value: formatMonthYear(child.enrolledAt, locale),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.nunito(
                size: 14.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.nunito(
              size: 14.5,
              weight: FontWeight.w800,
              color: AppColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
    );
  }
}
