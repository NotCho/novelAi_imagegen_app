import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:naiapp/view/core/util/design_system.dart';
import 'package:naiapp/view/setting/app_info_page.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../application/setting/setting_page_controller.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScaffold(
      appBar: const SkeletonAppBar(
        backgroundColor: SkeletonColorScheme.backgroundColor,
        titleText: "설정",
      ),
      backgroundColor: SkeletonColorScheme.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildListTile(
              onTap: controller.togglePngMode,
              title: '저장타입',
              icon: Icons.save,
              trailing: Obx(() => AnimatedContainer(
                    duration: SkeletonSpacing.animationDuration,
                    child: Text(
                        "${(controller.pngMode.value) ? "PNG" : "WEBP"}로 저장 중",
                        style: SkeletonTextTheme.body2Long
                            .copyWith(color: SkeletonColorScheme.newG600)),
                  ))),
          _buildListTile(
              onTap: () => controller.setImageGenerationStreamingMode(
                  !controller.imageGenerationStreamingMode.value),
              title: '이미지 생성 스트리밍',
              subtitle: '생성 중간 결과를 실시간 미리보기로 표시합니다.',
              icon: Icons.stream,
              trailing: Obx(() => Switch(
                    value: controller.imageGenerationStreamingMode.value,
                    onChanged: controller.setImageGenerationStreamingMode,
                    activeThumbColor: SkeletonColorScheme.primaryColor,
                  ))),
          _buildListTile(
              onTap: controller.toggleLiquidGlassMode,
              title: '울트라 액체 유리 (실시간 셰이더)',
              icon: Icons.opacity,
              trailing: Obx(() => Switch(
                    value: controller.liquidGlassMode.value,
                    onChanged: (_) => controller.toggleLiquidGlassMode(),
                    activeColor: SkeletonColorScheme.primaryColor,
                  ))),
          Obx(() {
            if (!controller.liquidGlassMode.value)
              return const SizedBox.shrink();
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.cardColor.withOpacity(0.5),
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius),
                  border: Border.all(
                    color:
                        SkeletonColorScheme.textSecondaryColor.withOpacity(0.1),
                  ),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 실시간 유리 미리보기 카드 배치
                    _buildLivePreviewCard(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.blur_on, color: Colors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '액체 유리 블러 강도',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.liquidGlassBlur.value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyan,
                        inactiveTrackColor: SkeletonColorScheme
                            .textSecondaryColor
                            .withOpacity(0.2),
                        thumbColor: Colors.cyan,
                        overlayColor: Colors.cyan.withOpacity(0.2),
                        valueIndicatorColor: Colors.cyan,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: controller.liquidGlassBlur.value,
                        min: 0.0,
                        max: 30.0,
                        divisions: 300,
                        label:
                            controller.liquidGlassBlur.value.toStringAsFixed(1),
                        onChanged: (val) {
                          controller.setLiquidGlassBlur(val);
                        },
                      ),
                    ),
                    const Text(
                      '블러가 낮을수록 맑은 물방울처럼 선명하고, 높을수록 서리 낀 유리처럼 뽀얗게 굴절됩니다.',
                      style: TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.looks_one, color: Colors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '액체 유리 굴절률 (돋보기 왜곡)',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.liquidGlassRefraction.value
                              .toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyan,
                        inactiveTrackColor: SkeletonColorScheme
                            .textSecondaryColor
                            .withOpacity(0.2),
                        thumbColor: Colors.cyan,
                        overlayColor: Colors.cyan.withOpacity(0.2),
                        valueIndicatorColor: Colors.cyan,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: controller.liquidGlassRefraction.value,
                        min: 1.0,
                        max: 2.0,
                        divisions: 100,
                        label: controller.liquidGlassRefraction.value
                            .toStringAsFixed(2),
                        onChanged: (val) {
                          controller.setLiquidGlassRefraction(val);
                        },
                      ),
                    ),
                    const Text(
                      '값이 1.0에 가까우면 왜곡이 없으며, 2.0에 가까울수록 가장자리 굴절과 돋보기 왜곡 효과가 극대화됩니다.',
                      style: TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lens_blur, color: Colors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '액체 유리 굴절 색수차 강도',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.liquidGlassAberration.value
                              .toStringAsFixed(3),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyan,
                        inactiveTrackColor: SkeletonColorScheme
                            .textSecondaryColor
                            .withOpacity(0.2),
                        thumbColor: Colors.cyan,
                        overlayColor: Colors.cyan.withOpacity(0.2),
                        valueIndicatorColor: Colors.cyan,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: controller.liquidGlassAberration.value,
                        min: 0.0,
                        max: 0.1,
                        divisions: 100,
                        label: controller.liquidGlassAberration.value
                            .toStringAsFixed(3),
                        onChanged: (val) {
                          controller.setLiquidGlassAberration(val);
                        },
                      ),
                    ),
                    const Text(
                      '유리 경계 엣지면에서 빛이 갈라져 나타나는 3D 무지개빛(빨강/파랑) 색상 번짐 강도를 결정합니다.',
                      style: TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.line_weight,
                                color: Colors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '액체 유리 두께',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.liquidGlassThickness.value
                              .toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyan,
                        inactiveTrackColor: SkeletonColorScheme
                            .textSecondaryColor
                            .withOpacity(0.2),
                        thumbColor: Colors.cyan,
                        overlayColor: Colors.cyan.withOpacity(0.2),
                        valueIndicatorColor: Colors.cyan,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: controller.liquidGlassThickness.value,
                        min: 10.0,
                        max: 100.0,
                        divisions: 180,
                        label: controller.liquidGlassThickness.value
                            .toStringAsFixed(1),
                        onChanged: (val) {
                          controller.setLiquidGlassThickness(val);
                        },
                      ),
                    ),
                    const Text(
                      '액체 유리의 물리적인 두께입니다. 두꺼울수록 굴절이 맺히는 테두리 왜곡의 곡률 범위가 넓어집니다.',
                      style: TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.light_mode,
                                color: Colors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '유리 반사 광택 세기',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.liquidGlassLightIntensity.value
                              .toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyan,
                        inactiveTrackColor: SkeletonColorScheme
                            .textSecondaryColor
                            .withOpacity(0.2),
                        thumbColor: Colors.cyan,
                        overlayColor: Colors.cyan.withOpacity(0.2),
                        valueIndicatorColor: Colors.cyan,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: controller.liquidGlassLightIntensity.value,
                        min: 0.0,
                        max: 2.0,
                        divisions: 200,
                        label: controller.liquidGlassLightIntensity.value
                            .toStringAsFixed(2),
                        onChanged: (val) {
                          controller.setLiquidGlassLightIntensity(val);
                        },
                      ),
                    ),
                    const Text(
                      '유리 표면에 맺히는 3D 스펙큘러 조명 광택 및 빛 반사의 반짝임 강도를 제어합니다.',
                      style: TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.palette, color: Colors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '유리 내부 배경 채도 증폭',
                              style: TextStyle(
                                color: SkeletonColorScheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.liquidGlassSaturation.value
                              .toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyan,
                        inactiveTrackColor: SkeletonColorScheme
                            .textSecondaryColor
                            .withOpacity(0.2),
                        thumbColor: Colors.cyan,
                        overlayColor: Colors.cyan.withOpacity(0.2),
                        valueIndicatorColor: Colors.cyan,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: controller.liquidGlassSaturation.value,
                        min: 0.5,
                        max: 3.0,
                        divisions: 250,
                        label: controller.liquidGlassSaturation.value
                            .toStringAsFixed(2),
                        onChanged: (val) {
                          controller.setLiquidGlassSaturation(val);
                        },
                      ),
                    ),
                    const Text(
                      '유리를 통과해 굴절되는 이미지의 색상을 더 선명하고 쨍하게 증폭시켜 몽환적인 틴트감을 줍니다.',
                      style: TextStyle(
                        color: SkeletonColorScheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          _buildListTile(
              onTap: controller.selectSaveDirectory,
              title: '저장 경로',
              icon: Icons.folder_open,
              trailing: Obx(() {
                final path = controller.saveDirectoryPath.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        path.isEmpty ? '기본 갤러리' : path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: SkeletonTextTheme.body2Long
                            .copyWith(color: SkeletonColorScheme.newG600),
                      ),
                    ),
                    if (path.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: SkeletonColorScheme.textSecondaryColor,
                        ),
                        onPressed: controller.clearSaveDirectory,
                      ),
                    ] else
                      const Icon(
                        Icons.chevron_right,
                        color: SkeletonColorScheme.textSecondaryColor,
                      ),
                  ],
                );
              })),
          _buildListTile(
              title: "앱 정보",
              icon: Icons.info,
              onTap: () {
                Get.to(() => const AppInfoPage());
              },
              trailing: Text(
                controller.global.currentClientVersion.value,
                style: SkeletonTextTheme.body2Long
                    .copyWith(color: SkeletonColorScheme.newG600),
              )),
          _buildListTile(
              title: "와일드카드 관리",
              icon: Icons.shuffle,
              onTap: () {
                Get.toNamed('/home/wildcard');
              },
              trailing: const Icon(
                Icons.chevron_right,
                color: SkeletonColorScheme.textSecondaryColor,
              )),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: SkeletonColorScheme.textSecondaryColor,
            ),
          ),
          _buildListTile(
              title: '로그아웃',
              icon: Icons.logout,
              onTap: () {
                logoutDialog();
              }),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 화사한 네온 그라데이션 및 입체 구체 배경
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF007F), // Neon Pink
                    Color(0xFF7B2CBF), // Deep Purple
                    Color(0xFF00F5D4), // Neon Cyan
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // 굴절 왜곡 체감을 극대화하기 위한 네온 원형 그래픽 구체들
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.8),
                    Colors.amber.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.8),
                    Colors.cyanAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepOrangeAccent.withOpacity(0.8),
                    Colors.deepOrangeAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // 굴절을 극대화하여 보여줄 텍스트 레이아웃
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Glass Preview",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.95),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "REALTIME GPU SHADER",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          // 액체 유리 렌더러
          Positioned.fill(
            child: LiquidGlassLayer(
              settings: LiquidGlassSettings(
                thickness: controller.liquidGlassThickness.value,
                blur: controller.liquidGlassBlur.value,
                glassColor: const Color(0x0AFFFFFF),
                chromaticAberration: controller.liquidGlassAberration.value,
                refractiveIndex: controller.liquidGlassRefraction.value,
                lightIntensity: controller.liquidGlassLightIntensity.value,
                saturation: controller.liquidGlassSaturation.value,
              ),
              child: const LiquidGlass(
                shape: LiquidRoundedRectangle(borderRadius: 20),
                child: SizedBox.expand(),
              ),
            ),
          ),
          // 유리 테두리 하이라이트
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: SkeletonTextTheme.body2Long),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(
                color: SkeletonColorScheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
      leading: Icon(icon, color: SkeletonColorScheme.textColor),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void logoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SkeletonColorScheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkeletonSpacing.borderRadius),
        ),
        title: const Text(
          '로그아웃 하시겠습니까?',
          style: TextStyle(
              color: SkeletonColorScheme.textColor,
              fontWeight: FontWeight.normal,
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              controller.logout();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
