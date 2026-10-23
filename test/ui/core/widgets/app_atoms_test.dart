import 'package:daily_care/app/theme/app_colors.dart';
import 'package:daily_care/ui/core/widgets/app_avatar.dart';
import 'package:daily_care/ui/core/widgets/dashed_box.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders the dashed photo placeholder and the avatar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              DashedBox(child: const Text('Foto')),
              const AppAvatar(
                label: 'M',
                backgroundColor: AppColors.avatarBlueBackground,
                foregroundColor: AppColors.avatarBlueForeground,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Foto'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppAvatar),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, AppColors.avatarBlueBackground);
  });
}
