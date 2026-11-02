import 'package:daily_care/domain/models/guardian.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/models/post_audience.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/domain/repositories/account_activation_repository.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/domain/use_cases/activate_account.dart';
import 'package:daily_care/domain/use_cases/create_child.dart';
import 'package:daily_care/domain/value_objects/child_draft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountActivationRepository implements AccountActivationRepository {
  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    return const Success(null);
  }
}

class _FakeKidsRepository implements KidsRepository {
  final List<Child> children = <Child>[];

  @override
  Future<Result<List<Child>>> loadChildren() async =>
      Success(List.unmodifiable(children));

  @override
  Future<Result<Child?>> loadChild(String id) async => const Success(null);

  @override
  Future<Result<Child>> addChild(Child child) async {
    children.add(child);
    return Success(child);
  }
  @override
  Future<Result<Guardian>> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async {
    return Success(
      Guardian(
        id: 'mock-id',
        firstName: fullName,
        lastName: '',
        email: email,
        relationship: relationship,
        status: GuardianStatus.invited,
        colorToken: 'blue',
        invitationCode: invitationCode,
      ),
    );
  }
}

void main() {
  test('sessionUserProvider expone el usuario de demostración', () {
    final container = ProviderContainer.test();

    final user = container.read(sessionUserProvider);

    expect(user.fullName, 'Caro Giménez');
    expect(container.read(sessionUserProvider), same(user));
  });

  test('todayProvider can be overridden with a fixed date', () {
    final fixed = DateTime(2026, 10, 24);
    final container = ProviderContainer.test(
      overrides: [todayProvider.overrideWithValue(() => fixed)],
    );

    expect(container.read(todayProvider)(), fixed);
  });

  test('activateAccountUseCaseProvider usa el repositorio sobrescrito', () async {
    final fake = _FakeAccountActivationRepository();
    final container = ProviderContainer.test(
      overrides: [
        accountActivationRepositoryProvider.overrideWithValue(fake),
      ],
    );

    final result = await container.read(activateAccountUseCaseProvider).execute(
      invitation: null,
      code: '7K4P9',
      email: 'lucia.fernandez@gmail.com',
      password: 'secreto123',
      photoConsent: true,
    );

    expect(result, isA<ActivationRejected>());
    expect((result as ActivationRejected).error, ActivationError.invalidCode);
  });

  test('createChildUseCaseProvider usa el repositorio y la fecha sobrescritos', () async {
    final fake = _FakeKidsRepository();
    final fixed = DateTime(2026, 10, 24);
    final container = ProviderContainer.test(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(fake),
        todayProvider.overrideWithValue(() => fixed),
      ],
    );

    final result = await container
        .read(createChildUseCaseProvider)
        .execute(
          const ChildDraft(
            fullName: 'Martina López',
            birthDateText: '12/03/2023',
            room: 'Soles',
          ),
        );

    expect(result, isA<ChildCreated>());
    expect((result as ChildCreated).child.enrolledAt, fixed);
    expect(fake.children, hasLength(1));
  });

  test('feedDataSourceProvider no comparte publicaciones entre contenedores', () async {
    final first = ProviderContainer.test();
    final second = ProviderContainer.test();
    const post = Post(
      id: 'post-new',
      childName: 'Toda la sala',
      childInitial: null,
      childColorToken: 'announcement',
      timeLabel: '09:05',
      audience: PostAudience.room,
      type: PostType.food,
      body: 'Almorzaron guiso',
      likes: 0,
      comments: 0,
    );

    final created = await first.read(feedRepositoryProvider).createPost(post);
    final firstPosts = await first.read(feedRepositoryProvider).loadPosts();
    final secondPosts = await second.read(feedRepositoryProvider).loadPosts();

    expect(created, isA<Success<Post>>());
    expect((firstPosts as Success<List<Post>>).value.first.id, post.id);
    expect((secondPosts as Success<List<Post>>).value, hasLength(3));
    expect(
      identical(
        first.read(feedDataSourceProvider),
        second.read(feedDataSourceProvider),
      ),
      isFalse,
    );
  });
}
