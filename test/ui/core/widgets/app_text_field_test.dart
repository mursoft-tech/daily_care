import 'package:daily_care/app/theme/app_colors.dart';
import 'package:daily_care/app/theme/app_typography.dart';
import 'package:daily_care/ui/core/widgets/app_text_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildField({
  String? errorText,
  TextEditingController? controller,
  int maxLines = 1,
  List<TextInputFormatter>? inputFormatters,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AppTextField(
          label: 'EMAIL',
          fieldKey: const Key('app-text-field-input'),
          controller: controller,
          hintText: 'tu@correo.com',
          errorText: errorText,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the label, value and hint', (tester) async {
    final controller = TextEditingController(text: 'lucia@correo.com');
    addTearDown(controller.dispose);

    await tester.pumpWidget(_buildField(controller: controller));

    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('lucia@correo.com'), findsOneWidget);
    expect(find.byKey(const Key('app-text-field-input')), findsOneWidget);

    final label = tester.widget<Text>(find.text('EMAIL'));
    expect(label.style?.fontSize, 12);
    expect(label.style?.fontWeight, FontWeight.w700);
    expect(label.style?.letterSpacing, 0.7);
    expect(label.style?.color, AppColors.textMuted);
  });

  testWidgets('renders the error message in coral', (tester) async {
    await tester.pumpWidget(_buildField(errorText: 'Email inválido'));

    expect(find.text('Email inválido'), findsOneWidget);

    final error = tester.widget<Text>(find.text('Email inválido'));
    expect(error.style?.color, AppColors.primaryDark);
    expect(error.style?.fontSize, 12.5);
  });

  testWidgets('uses the template border and fill', (tester) async {
    await tester.pumpWidget(_buildField());

    final field = tester.widget<TextField>(find.byType(TextField));
    final decoration = field.decoration!;

    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, AppColors.white);
    expect(decoration.contentPadding, const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ));

    final border = decoration.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.width, 1.5);
    expect(border.borderSide.color, AppColors.loginBorder);
    expect(border.borderRadius, BorderRadius.circular(14));
    expect(field.style?.fontFamily, AppTypography.nunitoFamily);
  });

  testWidgets('supports multiline fields and input formatters', (tester) async {
    await tester.pumpWidget(
      _buildField(
        maxLines: 4,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 4);
    expect(field.inputFormatters, hasLength(1));
  });
}
