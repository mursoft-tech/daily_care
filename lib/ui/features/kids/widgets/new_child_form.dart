import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/use_cases/create_child.dart';
import '../../../../domain/value_objects/child_draft.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/formatters/birth_date_input_formatter.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../view_models/new_child_view_model.dart';

class NewChildForm extends ConsumerStatefulWidget {
  const NewChildForm({
    required this.initialDraft,
    required this.isSaving,
    required this.onSubmit,
    required this.onCancel,
    this.errors = const [],
    super.key,
  });

  final ChildDraft initialDraft;
  final bool isSaving;
  final List<RegistrationError> errors;
  final Future<void> Function(ChildDraft draft) onSubmit;
  final VoidCallback onCancel;

  @override
  ConsumerState<NewChildForm> createState() => _NewChildFormState();
}

class _NewChildFormState extends ConsumerState<NewChildForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _medicalNotesController;
  late String _room;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _nameController = TextEditingController(text: draft.fullName);
    _birthDateController = TextEditingController(text: draft.birthDateText);
    _allergiesController = TextEditingController(
      text: draft.allergyLabels.join(', '),
    );
    _medicalNotesController = TextEditingController(text: draft.medicalNotes);
    _room = kRooms.contains(draft.room) ? draft.room : kRooms.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(newChildViewModelProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _allergiesController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  void _clearError() =>
      ref.read(newChildViewModelProvider.notifier).clearErrors();

  Future<void> _submit() async {
    if (widget.isSaving) return;

    await widget.onSubmit(
      ChildDraft(
        fullName: _nameController.text,
        birthDateText: _birthDateController.text,
        room: _room,
        allergyLabels: _allergiesController.text.split(','),
        medicalNotes: _medicalNotesController.text,
      ),
    );
  }

  String? _nameError(AppLocalizations l10n) {
    return widget.errors.contains(RegistrationError.nameRequired)
        ? l10n.childFormNameRequiredError
        : null;
  }

  String? _birthDateError(AppLocalizations l10n) {
    for (final error in widget.errors) {
      final message = switch (error) {
        RegistrationError.birthDateRequired =>
          l10n.childFormBirthDateRequiredError,
        RegistrationError.birthDateInvalid =>
          l10n.childFormBirthDateInvalidError,
        RegistrationError.birthDateFuture => l10n.childFormBirthDateFutureError,
        RegistrationError.birthDateTooOld =>
          l10n.childFormBirthDateTooOldError,
        _ => null,
      };
      if (message != null) return message;
    }
    return null;
  }

  String? _roomError(AppLocalizations l10n) {
    return widget.errors.contains(RegistrationError.roomRequired)
        ? l10n.childFormRoomRequiredError
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stacked = MediaQuery.sizeOf(context).width < 600;

    final birthDateField = AppTextField(
      label: l10n.childFormBirthDateLabel,
      fieldKey: const Key('child-form-birth-date'),
      controller: _birthDateController,
      hintText: l10n.childFormBirthDateHint,
      keyboardType: TextInputType.number,
      inputFormatters: const [BirthDateInputFormatter()],
      onChanged: (_) => _clearError(),
      errorText: _birthDateError(l10n),
    );
    final roomField = AppSelectField(
      label: l10n.childFormRoomLabel,
      fieldKey: const Key('child-form-room'),
      value: _room,
      items: kRooms,
      onChanged: (value) {
        setState(() => _room = value);
        _clearError();
      },
      errorText: _roomError(l10n),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.loginBackground,
        border: Border.all(color: AppColors.loginBorder),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 50,
            offset: Offset(0, 20),
            spreadRadius: -24,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormHeader(
            isSaving: widget.isSaving,
            onCancel: widget.onCancel,
            onSave: _submit,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.childFormNameLabel,
                  fieldKey: const Key('child-form-name'),
                  controller: _nameController,
                  hintText: l10n.childFormNameHint,
                  onChanged: (_) => _clearError(),
                  errorText: _nameError(l10n),
                ),
                const SizedBox(height: 18),
                if (stacked) ...[
                  birthDateField,
                  const SizedBox(height: 18),
                  roomField,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: birthDateField),
                      const SizedBox(width: 14),
                      Expanded(child: roomField),
                    ],
                  ),
                const SizedBox(height: 18),
                AppTextField(
                  label: l10n.childFormAllergiesLabel,
                  fieldKey: const Key('child-form-allergies'),
                  controller: _allergiesController,
                  hintText: l10n.childFormAllergiesHint,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: l10n.childFormMedicalNotesLabel,
                  fieldKey: const Key('child-form-notes'),
                  controller: _medicalNotesController,
                  hintText: l10n.childFormMedicalNotesHint,
                  maxLines: 4,
                  onChanged: (_) => _clearError(),
                ),
                if (widget.errors.contains(RegistrationError.saveFailed)) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.childFormSaveError,
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  static const _padding = EdgeInsets.symmetric(horizontal: 26, vertical: 20);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.loginBorder)),
      ),
      padding: _padding,
      child: Row(
        children: [
          AppLink(
            key: const Key('child-form-cancel'),
            onTap: onCancel,
            borderRadius: BorderRadius.circular(8),
            child: Text(
              l10n.childFormCancel,
              style: AppTypography.nunito(
                size: 15,
                weight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.childFormTitle,
                textAlign: TextAlign.center,
                style: AppTypography.fredoka(size: 18),
              ),
            ),
          ),
          if (isSaving)
            Semantics(
              label: l10n.childFormSaving,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryDark,
                ),
              ),
            )
          else
            AppLink(
              key: const Key('child-form-save'),
              onTap: onSave,
              borderRadius: BorderRadius.circular(8),
              child: Text(
                l10n.childFormSave,
                style: AppTypography.nunito(
                  size: 15,
                  weight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
