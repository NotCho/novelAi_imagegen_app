import 'package:flutter/material.dart';

extension SkeletonColorScheme on ColorScheme {
  static Color get newGreenColor => const Color(0xff44911B);

  static Color get black => const Color(0xff000000);

  static Color get keyColor => const Color(0xff44911B);

  static Color get newG900 => const Color(0xff191919);

  static Color get newG800 => const Color(0xff2d2f34);

  static Color get newG600 => const Color(0xff63666b);

  static Color get newG400 => const Color(0xff9FA4A9);

  static Color get newG300 => const Color(0xffCACDD2);

  static Color get newG200 => const Color(0xffE9EBED);

  static Color get newG120 => const Color(0xfff8f9fd);

  static Color get newG100 => const Color(0xffF7F8F9);

  static Color get body => const Color(0xff000000);

  static Color get title => const Color(0xff000000);

  static Color get kakaoYellow => const Color(0xffFFEB00);

  static const Color primaryColor = Color(0xFF6C5CE7); // 주요 색상: 보라색 계열
  static const Color accentColor = Color(0xFF00B894); // 액센트 색상: 민트 계열
  static const Color negativeColor = Color(0xFFFF7675); // 부정적 프롬프트 색상
  static const Color backgroundColor = Color(0xFF121212); // 배경색
  static const Color cardColor = Color(0xFF1E1E1E); // 카드 배경색
  static const Color surfaceColor = Color(0xFF2D2D2D); // 서피스 색상
  static const Color textColor = Color(0xFFF0F0F0); // 기본 텍스트 색상
  static const Color textSecondaryColor = Color(0xFFAAAAAA); // 보조 텍스트 색상

  // 새로 추가된 컬러 스키마
  static Color get travelBlue => const Color(0xFF3F72AF);

  static Color get travelBlueLight => const Color(0xFFDBE2EF);

  static Color get travelOrange => const Color(0xFFF9B17A);

  // 여행 앱 메인 컬러에 대한 별칭 (쉽게 사용하기 위함)
  static Color get primary => travelBlue;

  static Color get primaryLight => travelBlueLight;

  static Color get secondary => travelOrange;
}

extension SkeletonTextTheme on TextTheme {
  static const defaultFontFamily = "Pretendard";

  static double _getFontHeight(double fontSize, double height) =>
      (height / fontSize);

  static double _getLetterSpace(double fontSize, double percentageValue) =>
      (fontSize * percentageValue / 100);

  static TextStyle _getStyle({
    required double fontSize,
    required double lineHeight,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
    double letterSpacing = -5,
  }) {
    return TextStyle(
        fontFamily: defaultFontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: _getFontHeight(fontSize, lineHeight),
        letterSpacing: _getLetterSpace(fontSize, letterSpacing),
        color: color,
        leadingDistribution: TextLeadingDistribution.even);
  }

  static TextStyle get h0 =>
      _getStyle(fontSize: 22, lineHeight: 32, color: SkeletonColorScheme.title);

  static TextStyle get h1 => _getStyle(
      fontSize: 20,
      lineHeight: 26,
      color: SkeletonColorScheme.title,
      textAlign: TextAlign.left);

  static TextStyle get h1c => _getStyle(
      fontSize: 20,
      lineHeight: 26,
      color: SkeletonColorScheme.title,
      textAlign: TextAlign.center);

  static TextStyle get h3 =>
      _getStyle(fontSize: 18, lineHeight: 26, color: SkeletonColorScheme.title);

  static TextStyle get h4 =>
      _getStyle(fontSize: 17, lineHeight: 22, color: SkeletonColorScheme.title);

  static TextStyle get h5 =>
      _getStyle(fontSize: 15, lineHeight: 20, color: SkeletonColorScheme.title);

  static TextStyle get body0 => _getStyle(
      fontSize: 10, lineHeight: 15, color: SkeletonColorScheme.textColor);

  static TextStyle get body1 => _getStyle(
      fontSize: 14, lineHeight: 21, color: SkeletonColorScheme.textColor);

  static TextStyle get body2 => _getStyle(
      fontSize: 14, lineHeight: 18, color: SkeletonColorScheme.textColor);

  static TextStyle get body2Long => _getStyle(
      fontSize: 14, lineHeight: 22, color: SkeletonColorScheme.textColor);

  static TextStyle get body3 => _getStyle(
      fontSize: 12, lineHeight: 19, color: SkeletonColorScheme.textColor);

  static TextStyle get body4 => _getStyle(
      fontSize: 12,
      lineHeight: 16,
      color: SkeletonColorScheme.body,
      textAlign: TextAlign.start);

  static TextStyle get newBody8 => _getStyle(
      fontSize: 8, lineHeight: 12, color: SkeletonColorScheme.newG800);

  static TextStyle get newBody10 => _getStyle(
      fontSize: 10, lineHeight: 15, color: SkeletonColorScheme.newG800);

  static TextStyle get diaryMemo => _getStyle(
      fontSize: 12, lineHeight: 13, color: SkeletonColorScheme.newG800);

  static TextStyle get newBody10Bold => _getStyle(
      fontSize: 12,
      lineHeight: 15,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.bold);

  static TextStyle get newBody12 => _getStyle(
      fontSize: 12, lineHeight: 18, color: SkeletonColorScheme.newG800);

  static TextStyle get newBody12Bold => _getStyle(
      fontSize: 12,
      lineHeight: 18,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.bold);

  static TextStyle get newBody14 => _getStyle(
      fontSize: 14, lineHeight: 21, color: SkeletonColorScheme.newG800);

  static TextStyle get newBody14Bold => _getStyle(
      fontSize: 14,
      lineHeight: 21,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.bold);

  static TextStyle get newBody14Medium => _getStyle(
      fontSize: 14,
      lineHeight: 21,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.w500);

  static TextStyle get newBody16Bold => _getStyle(
      fontSize: 16,
      lineHeight: 24,
      color: SkeletonColorScheme.textColor,
      fontWeight: FontWeight.bold);

  static TextStyle get newBody18Bold => _getStyle(
      fontSize: 18,
      lineHeight: 24,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.bold);

  static TextStyle get newBody20Bold => _getStyle(
      fontSize: 20,
      lineHeight: 30,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.bold);

  static TextStyle get newBody24 => _getStyle(
        fontSize: 24,
        lineHeight: 36,
        color: SkeletonColorScheme.newG800,
      );

  static TextStyle get newBody24Bold => _getStyle(
      fontSize: 24,
      lineHeight: 36,
      color: SkeletonColorScheme.newG800,
      fontWeight: FontWeight.bold);

  static TextStyle get timestamp => _getStyle(
        fontSize: 12,
        lineHeight: 12,
        color: SkeletonColorScheme.newG400,
      );

  static TextStyle get listTitle => _getStyle(
      fontSize: 14,
      lineHeight: 18,
      color: SkeletonColorScheme.newG100,
      fontWeight: FontWeight.w700,
      letterSpacing: 10);

  static TextStyle get content => _getStyle(
      fontSize: 14, lineHeight: 18, color: SkeletonColorScheme.newG600);
}

class SkeletonSpacing {
  // 애니메이션 지속 시간
  static const Duration animationDuration = Duration(milliseconds: 150);
  static const double borderRadius = 12.0;

  // 공통 간격 정의
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;

  /// 4
  static double xTiny = 4;

  /// 8
  static double tiny = 8;

  /// 10
  static double tiny2 = 10;

  /// 12
  static double xSmall = 12;

  /// 16
  static double small = 16;

  /// 20
  static double xBase = 20;

  /// 24
  static double base = 24;

  /// 32
  static double medium = 32;

  /// 40
  static double xMedium = 40;

  /// 48
  static double large = 48;

  /// 64
  static double xLarge = 64;

  /// 0
  static SizedBox get none => const SizedBox();

  /// 2
  static SizedBox get hXTiny2 => const SizedBox(width: 2);

  /// 4
  static SizedBox get hXTiny => const SizedBox(width: 4);

  /// 5
  static SizedBox get hXTiny5 => const SizedBox(width: 5);

  /// 6
  static SizedBox get hxTiny6 => const SizedBox(width: 6);

  /// 8
  static SizedBox get hTiny => const SizedBox(width: 8);

  /// 10
  static SizedBox get hTiny10 => const SizedBox(width: 10);

  /// 12
  static SizedBox get hXSmall => const SizedBox(width: 12);

  /// 14
  static SizedBox get hXSmall14 => const SizedBox(width: 14);

  /// 16
  static SizedBox get hSmall => const SizedBox(width: 16);

  /// 20
  static SizedBox get hXBase => const SizedBox(width: 20);

  /// 22
  static SizedBox get hXBase22 => const SizedBox(width: 22);

  /// 24
  static SizedBox get hBase => const SizedBox(width: 24);

  /// 32
  static SizedBox get hMedium => const SizedBox(width: 32);

  /// 40
  static SizedBox get hXMedium => const SizedBox(width: 40);

  /// 48
  static SizedBox get hLarge => const SizedBox(width: 48);

  /// 64
  static SizedBox get hXLarge => const SizedBox(width: 64);

  ///2
  static SizedBox get vXTiny2 => const SizedBox(height: 2);

  ///3
  static SizedBox get vXTiny3 => const SizedBox(height: 3);

  /// 4
  static SizedBox get vXTiny => const SizedBox(height: 4);

  static SizedBox get vTiny6 => const SizedBox(height: 6);

  /// 8
  static SizedBox get vTiny => const SizedBox(height: 8);

  static SizedBox get vTiny9 => const SizedBox(height: 9);

  static SizedBox get vTiny10 => const SizedBox(height: 10);

  /// 12
  static SizedBox get vXSmall => const SizedBox(height: 12);

  /// 14
  static SizedBox get vXSmall14 => const SizedBox(height: 14);

  /// 16
  static SizedBox get vSmall => const SizedBox(height: 16);

  /// 19
  static SizedBox get vSmall19 => const SizedBox(height: 19);

  /// 20
  static SizedBox get vXBase => const SizedBox(height: 20);

  /// 24
  static SizedBox get vBase => const SizedBox(height: 24);

  /// 24
  static SizedBox get vBase30 => const SizedBox(height: 30);

  /// 32
  static SizedBox get vMedium => const SizedBox(height: 32);

  /// 40
  static SizedBox get vXMedium => const SizedBox(height: 40);

  /// 48
  static SizedBox get vLarge => const SizedBox(height: 48);

  /// 64
  static SizedBox get vXLarge => const SizedBox(height: 64);
}
