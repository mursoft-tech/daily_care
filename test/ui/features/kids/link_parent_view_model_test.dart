import 'dart:math';

import 'package:daily_care/app/providers.dart';
import 'package:daily_care/data/datasources/local/demo_kids_data_source.dart';
import 'package:daily_care/data/repositories/kids_repository_impl.dart';
import 'package:daily_care/domain/use_cases/generate_invitation_code.dart';
import 'package:daily_care/ui/features/kids/view_models/link_parent_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates a different invitation code on each opening', () async {
    final container = ProviderContainer.test(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(
          KidsRepositoryImpl(DemoKidsDataSource()),
        ),
        generateInvitationCodeProvider.overrideWithValue(
          GenerateInvitationCode(random: Random(7)),
        ),
      ],
    );

    final provider = linkParentViewModelProvider('mateo-fernandez');
    final first = await container.read(provider.future);

    container.invalidate(provider);
    final second = await container.read(provider.future);

    expect(first.invitationCode, hasLength(GenerateInvitationCode.length));
    expect(second.invitationCode, hasLength(GenerateInvitationCode.length));
    expect(second.invitationCode, isNot(first.invitationCode));
  });
}
