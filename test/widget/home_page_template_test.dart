import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/core/db/database.dart' hide Manual, Step, StepImage, Tag;
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:snapflow/features/manual/domain/manual_repository.dart';
import 'package:snapflow/features/manual/presentation/home_page.dart';
import 'package:snapflow/features/manual/presentation/manual_detail_page.dart';
import 'package:snapflow/shared/providers.dart';
import 'package:snapflow/core/theme.dart';

/// Stub repo that records save calls and returns a mutable list.
class _RecordingRepo implements ManualRepository {
  final List<Manual> manuals;
  final List<Manual> saved = [];
  _RecordingRepo(this.manuals);

  @override
  Future<List<Manual>> listManuals() async => manuals;
  @override
  Future<Manual?> getManual(String id) async =>
      manuals.where((m) => m.id == id).cast<Manual?>().firstOrNull;
  @override
  Future<void> saveManual(Manual manual) async {
    saved.add(manual);
    final i = manuals.indexWhere((m) => m.id == manual.id);
    if (i >= 0) {
      manuals[i] = manual;
    } else {
      manuals.add(manual);
    }
  }
  @override
  Future<void> deleteManual(String id) async {}
  @override
  Future<List<Tag>> listTags() async => [];
  @override
  Future<void> saveTag(Tag tag) async {}
  @override
  Future<void> deleteTag(String id) async {}
  @override
  Future<void> setManualTags(String manualId, Set<String> tagIds) async {}
}

Widget _wrap(Widget child, {required _RecordingRepo repo}) {
  return ProviderScope(
    overrides: [
      manualRepositoryProvider.overrideWith((_) async => repo),
      databaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
    ],
    child: MaterialApp(
      theme: SnapFlowTheme.light(),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Spec: User reported the "从模板新建" button does nothing. Test the
  // full tap-FAB → tap-template → navigate-to-detail flow. If this fails
  // (red) before the fix, it confirms the runtime UI bug; after the fix
  // it must turn green.
  testWidgets('从模板新建 → 选择模板 → 跳转到 detail 页', (tester) async {
    final repo = _RecordingRepo(<Manual>[]);
    await tester.pumpWidget(_wrap(const HomePage(), repo: repo));
    await tester.pump(); // settle provider
    await tester.pump(const Duration(milliseconds: 50));

    // 1. Tap main FAB → 直接打开统一的模板选择 sheet
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // 等 sheet 动画完成

    // 2. Sheet 应出现 "电力巡检" 模板（来自 builtin_templates.json）
    expect(find.text('电力巡检'), findsOneWidget,
        reason: '模板 sheet 应显示内置模板');

    // 3. Tap "电力巡检" ListTile → 触发 saveManual + navigate
    final tplTile = find.widgetWithText(ListTile, '电力巡检');
    expect(tplTile, findsOneWidget);
    await tester.tap(tplTile, warnIfMissed: false);
    // 让 sheet 关闭动画 + toast 插入完成
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 4. Assert: 一个新 manual 被保存，5 步（电力巡检模板有 5 步）
    expect(repo.saved.length, 1, reason: 'saveManual 应被调用一次');
    expect(repo.saved.first.title, '电力巡检');
    expect(repo.saved.first.steps.length, 5);

    // 5. Assert: navigation 到 ManualDetailPage
    expect(find.byType(ManualDetailPage), findsOneWidget,
        reason: '应跳转到手册详情页');

    // 让 SnapToast 隐藏 timer 跑完，避免测试结束时报 pending timer
    await tester.pump(const Duration(milliseconds: 2500));
  });

  // Spec: "全部、最近等按钮布局非常不协调" — 网格按钮应在合理高度内、可点。
  testWidgets('筛选 chip 全部可见且可点击', (tester) async {
    final repo = _RecordingRepo(<Manual>[]);
    await tester.pumpWidget(_wrap(const HomePage(), repo: repo));
    await tester.pump();

    // 4 个筛选按钮 + 模板/标签管理按钮都应可见
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('最近'), findsOneWidget);
    expect(find.text('收藏 ⭐'), findsOneWidget);
    expect(find.text('未完成'), findsOneWidget);
    expect(find.text('模板管理'), findsOneWidget, reason: '模板管理按钮');

    // 点击"收藏 ⭐"应切换 filter（不崩溃）
    await tester.tap(find.text('收藏 ⭐'));
    await tester.pump();
  });
}
