import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../application/wildcard/wildcard_controller.dart';
import '../../domain/wildcard/wildcard_model.dart';
import '../core/page.dart';
import '../core/util/app_snackbar.dart';
import '../core/util/design_system.dart';

/// 와일드카드 관리 페이지
class WildcardPage extends GetView<WildcardController> {
  const WildcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScaffold(
      appBar: SkeletonAppBar(
        backgroundColor: SkeletonColorScheme.backgroundColor,
        titleText: "와일드카드 관리",
        customAction: IconButton(
          icon: const Icon(Icons.help_outline,
              color: SkeletonColorScheme.textColor),
          onPressed: _showHelpDialog,
        ),
      ),
      backgroundColor: SkeletonColorScheme.backgroundColor,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 샘플 생성 버튼
          FloatingActionButton.small(
            heroTag: 'sample',
            backgroundColor: SkeletonColorScheme.surfaceColor,
            onPressed: _showCreateSampleDialog,
            child: const Icon(Icons.auto_awesome,
                color: SkeletonColorScheme.accentColor),
          ),
          const SizedBox(height: 8),
          // 파일 임포트 버튼
          FloatingActionButton.small(
            heroTag: 'import',
            backgroundColor: SkeletonColorScheme.surfaceColor,
            onPressed: controller.importFromFilePicker,
            child: const Icon(Icons.file_upload,
                color: SkeletonColorScheme.accentColor),
          ),
          const SizedBox(height: 8),
          // 새로 만들기 버튼
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: SkeletonColorScheme.primaryColor,
            onPressed: _showCreateDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: SkeletonColorScheme.primaryColor,
            ),
          );
        }

        if (controller.wildcards.isEmpty) {
          return _buildEmptyState();
        }

        return _buildWildcardList();
      }),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color:
                SkeletonColorScheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '와일드카드가 없어요',
            style: TextStyle(
              color: SkeletonColorScheme.textSecondaryColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '+ 버튼으로 추가하거나\n샘플을 생성해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SkeletonColorScheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateSampleDialog,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('샘플 와일드카드 생성'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SkeletonColorScheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 와일드카드 목록
  Widget _buildWildcardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wildcards.length,
      itemBuilder: (context, index) {
        final wildcard = controller.wildcards[index];
        return _buildWildcardCard(wildcard);
      },
    );
  }

  /// 개별 와일드카드 카드
  Widget _buildWildcardCard(WildcardModel wildcard) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: wildcard.isEnabled
            ? SkeletonColorScheme.cardColor
            : SkeletonColorScheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        border: Border.all(
          color: wildcard.isEnabled
              ? SkeletonColorScheme.primaryColor.withValues(alpha: 0.3)
              : SkeletonColorScheme.surfaceColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: SkeletonColorScheme.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(SkeletonSpacing.borderRadius - 1),
                topRight: Radius.circular(SkeletonSpacing.borderRadius - 1),
              ),
            ),
            child: Row(
              children: [
                // 활성화 토글
                GestureDetector(
                  onTap: () => controller.toggleWildcard(wildcard.name),
                  child: Icon(
                    wildcard.isEnabled
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: wildcard.isEnabled
                        ? SkeletonColorScheme.accentColor
                        : SkeletonColorScheme.textSecondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // 이름 (복사 가능)
                Expanded(
                  child: GestureDetector(

                    onTap: () => _copyWildcardName(wildcard.name),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '__${wildcard.name}__',
                              style: TextStyle(
                                color: wildcard.isEnabled
                                    ? SkeletonColorScheme.primaryColor
                                    : SkeletonColorScheme.textSecondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'monospace',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.copy,
                            size: 14,
                            color: SkeletonColorScheme.textSecondaryColor
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 옵션 수
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        SkeletonColorScheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${wildcard.optionCount}개',
                    style: const TextStyle(
                      color: SkeletonColorScheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 메뉴
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: SkeletonColorScheme.textSecondaryColor, size: 20),
                  color: SkeletonColorScheme.cardColor,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditDialog(wildcard);
                        break;
                      case 'delete':
                        _showDeleteDialog(wildcard);
                        break;
                      case 'preview':
                        _showPreviewDialog(wildcard);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.visibility,
                              color: SkeletonColorScheme.textColor, size: 18),
                          SizedBox(width: 8),
                          Text('미리보기',
                              style: TextStyle(
                                  color: SkeletonColorScheme.textColor)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              color: SkeletonColorScheme.textColor, size: 18),
                          SizedBox(width: 8),
                          Text('편집',
                              style: TextStyle(
                                  color: SkeletonColorScheme.textColor)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: SkeletonColorScheme.negativeColor,
                              size: 18),
                          SizedBox(width: 8),
                          Text('삭제',
                              style: TextStyle(
                                  color: SkeletonColorScheme.negativeColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 옵션 미리보기 (최대 3개)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: wildcard.options.take(5).map((option) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SkeletonColorScheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: SkeletonColorScheme.textColor,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList()
                ..addAll(wildcard.optionCount > 5
                    ? [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: SkeletonColorScheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '+${wildcard.optionCount - 5}개 더',
                            style: const TextStyle(
                              color: SkeletonColorScheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ]
                    : []),
            ),
          ),
        ],
      ),
    );
  }

  /// 와일드카드 이름 복사
  void _copyWildcardName(String name) {
    Clipboard.setData(ClipboardData(text: '__${name}__'));
    AppSnackBar.show(
      '복사됨',
      '__${name}__ 복사됨',
      backgroundColor: SkeletonColorScheme.cardColor,
      textColor: SkeletonColorScheme.textColor,
    );
  }

  /// 도움말 다이얼로그
  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: const Text(
          '와일드카드 사용법',
          style: TextStyle(
            color: SkeletonColorScheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '와일드카드는 프롬프트에서 랜덤으로 바뀌는 단어 묶음이에요.',
                style: TextStyle(color: SkeletonColorScheme.textColor),
              ),
              SizedBox(height: 16),
              Text(
                '📝 사용 예시',
                style: TextStyle(
                    color: SkeletonColorScheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '프롬프트에 __hair_color__ 를 넣으면\n"black hair", "blonde hair" 등으로\n랜덤 치환됩니다.',
                style: TextStyle(
                    color: SkeletonColorScheme.textSecondaryColor,
                    fontFamily: 'monospace'),
              ),
              SizedBox(height: 16),
              Text(
                '💡 팁',
                style: TextStyle(
                    color: SkeletonColorScheme.accentColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• 카드를 탭하면 이름이 복사돼요\n• 한 줄 = 하나의 옵션\n• 중첩 와일드카드도 지원해요',
                style: TextStyle(color: SkeletonColorScheme.textSecondaryColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 새 와일드카드 생성 다이얼로그
  void _showCreateDialog() {
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: const Text(
          '새 와일드카드',
          style: TextStyle(
            color: SkeletonColorScheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: SkeletonColorScheme.textColor),
                decoration: InputDecoration(
                  labelText: '이름 (영문, 숫자, _만)',
                  labelStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  hintText: 'hair_color',
                  hintStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: const BorderSide(
                        color: SkeletonColorScheme.surfaceColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: const BorderSide(
                        color: SkeletonColorScheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                style: const TextStyle(color: SkeletonColorScheme.textColor),
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: '옵션 (한 줄에 하나씩)',
                  labelStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  hintText: 'black hair\nblonde hair\nsilver hair',
                  hintStyle: const TextStyle(
                      color: SkeletonColorScheme.textSecondaryColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: const BorderSide(
                        color: SkeletonColorScheme.surfaceColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SkeletonSpacing.borderRadius),
                    borderSide: const BorderSide(
                        color: SkeletonColorScheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.createWildcard(
                nameController.text.trim(),
                contentController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SkeletonColorScheme.primaryColor,
            ),
            child: const Text('생성', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 편집 다이얼로그
  void _showEditDialog(WildcardModel wildcard) {
    final contentController =
        TextEditingController(text: wildcard.options.join('\n'));

    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: Text(
          '__${wildcard.name}__ 편집',
          style: const TextStyle(
            color: SkeletonColorScheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: contentController,
            style: const TextStyle(color: SkeletonColorScheme.textColor),
            maxLines: 10,
            decoration: InputDecoration(
              labelText: '옵션 (한 줄에 하나씩)',
              labelStyle: const TextStyle(
                  color: SkeletonColorScheme.textSecondaryColor),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SkeletonSpacing.borderRadius),
                borderSide:
                    const BorderSide(color: SkeletonColorScheme.surfaceColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SkeletonSpacing.borderRadius),
                borderSide:
                    const BorderSide(color: SkeletonColorScheme.primaryColor),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final newOptions = contentController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              controller.updateWildcard(
                wildcard.copyWith(options: newOptions),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SkeletonColorScheme.primaryColor,
            ),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteDialog(WildcardModel wildcard) {
    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: const Text(
          '삭제하시겠어요?',
          style: TextStyle(color: SkeletonColorScheme.textColor),
        ),
        content: Text(
          '__${wildcard.name}__ 와일드카드를 삭제합니다.\n이 작업은 되돌릴 수 없어요.',
          style: const TextStyle(color: SkeletonColorScheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteWildcard(wildcard.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SkeletonColorScheme.negativeColor,
            ),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 미리보기 다이얼로그
  void _showPreviewDialog(WildcardModel wildcard) {
    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: Text(
          '__${wildcard.name}__',
          style: const TextStyle(
            color: SkeletonColorScheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: wildcard.options.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wildcard.options[index],
                        style: const TextStyle(
                            color: SkeletonColorScheme.textColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 샘플 생성 확인 다이얼로그
  void _showCreateSampleDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: const Text(
          '샘플 와일드카드 생성',
          style: TextStyle(color: SkeletonColorScheme.textColor),
        ),
        content: const Text(
          '머리색, 눈색, 복장, 포즈, 표정, 배경 등\n기본 와일드카드를 생성합니다.',
          style: TextStyle(color: SkeletonColorScheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.createDefaultWildcards();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SkeletonColorScheme.primaryColor,
            ),
            child: const Text('생성', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
