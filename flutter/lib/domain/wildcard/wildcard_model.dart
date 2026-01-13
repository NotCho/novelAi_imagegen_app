import 'dart:math';

/// 와일드카드 옵션 (텍스트 + 가중치)
class WildcardOption {
  final String text;
  final int weight;

  const WildcardOption({
    required this.text,
    this.weight = 100, // NAIA 기본값
  });

  /// "option: weight" 형식 파싱
  factory WildcardOption.parse(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      return const WildcardOption(text: '', weight: 0);
    }

    // "option: weight" 형식 확인 (마지막 콜론+숫자)
    final lastColonIndex = trimmed.lastIndexOf(':');
    if (lastColonIndex > 0 && lastColonIndex < trimmed.length - 1) {
      final possibleWeight = trimmed.substring(lastColonIndex + 1).trim();
      final weight = int.tryParse(possibleWeight);
      if (weight != null && weight >= 0) {
        final text = trimmed.substring(0, lastColonIndex).trim();
        return WildcardOption(text: text, weight: weight);
      }
    }

    // 가중치 없음 - 기본값 100
    return WildcardOption(text: trimmed, weight: 100);
  }

  /// JSON 변환
  Map<String, dynamic> toJson() => {'text': text, 'weight': weight};

  factory WildcardOption.fromJson(Map<String, dynamic> json) {
    return WildcardOption(
      text: json['text'] as String,
      weight: json['weight'] as int? ?? 100,
    );
  }

  /// 텍스트 형식으로 변환 (저장용)
  String toText() {
    if (weight == 100) return text;
    return '$text: $weight';
  }

  @override
  String toString() => 'WildcardOption($text, weight: $weight)';
}

/// 와일드카드 데이터 모델
/// 하나의 와일드카드 파일(예: hair_color.txt)을 나타냄
class WildcardModel {
  /// 와일드카드 이름 (예: "hair_color")
  /// 프롬프트에서 __hair_color__로 사용됨
  final String name;

  /// 선택 가능한 옵션 목록 (가중치 포함)
  final List<WildcardOption> weightedOptions;

  /// 파일 경로 (앱 문서 디렉토리 내 상대 경로)
  final String? filePath;

  /// 생성 날짜
  final DateTime createdAt;

  /// 마지막 수정 날짜
  final DateTime updatedAt;

  /// 활성화 여부
  final bool isEnabled;

  /// 전체 가중치 합계 (캐시)
  int get totalWeight => weightedOptions.fold(0, (sum, o) => sum + o.weight);

  /// 옵션 텍스트만 추출 (하위 호환)
  List<String> get options => weightedOptions.map((o) => o.text).toList();

  WildcardModel({
    required this.name,
    required this.weightedOptions,
    this.filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isEnabled = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 하위 호환용 생성자 (options만 받음)
  factory WildcardModel.fromOptions({
    required String name,
    required List<String> options,
    String? filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isEnabled = true,
  }) {
    return WildcardModel(
      name: name,
      weightedOptions: options.map((o) => WildcardOption(text: o)).toList(),
      filePath: filePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEnabled: isEnabled,
    );
  }

  /// JSON에서 모델 생성
  factory WildcardModel.fromJson(Map<String, dynamic> json) {
    // 새 형식 (weightedOptions 있음)
    if (json.containsKey('weightedOptions')) {
      return WildcardModel(
        name: json['name'] as String,
        weightedOptions: (json['weightedOptions'] as List)
            .map((o) => WildcardOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        filePath: json['filePath'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
    }

    // 구 형식 (options만 있음) - 마이그레이션
    return WildcardModel(
      name: json['name'] as String,
      weightedOptions: (json['options'] as List)
          .map((o) => WildcardOption(text: o as String))
          .toList(),
      filePath: json['filePath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weightedOptions': weightedOptions.map((o) => o.toJson()).toList(),
      'options': options, // 하위 호환
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEnabled': isEnabled,
    };
  }

  /// 텍스트 파일 내용에서 모델 생성
  /// 각 줄을 하나의 옵션으로 처리, "option: weight" 형식 지원
  factory WildcardModel.fromText(String name, String textContent) {
    final weightedOptions = textContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#')) // 빈 줄, 주석 제외
        .map((line) => WildcardOption.parse(line))
        .where((o) => o.text.isNotEmpty)
        .toList();

    return WildcardModel(
      name: name,
      weightedOptions: weightedOptions,
    );
  }

  /// 텍스트 파일 형식으로 변환
  String toText() {
    return weightedOptions.map((o) => o.toText()).join('\n');
  }

  /// 옵션 개수
  int get optionCount => weightedOptions.length;

  /// 가중치 기반 랜덤 옵션 선택
  String getRandomOption() {
    if (weightedOptions.isEmpty) return '';

    final total = totalWeight;
    if (total <= 0) return weightedOptions.first.text;

    final random = Random();
    int value = random.nextInt(total);

    for (final option in weightedOptions) {
      value -= option.weight;
      if (value < 0) {
        return option.text;
      }
    }

    return weightedOptions.last.text;
  }

  /// copyWith
  WildcardModel copyWith({
    String? name,
    List<WildcardOption>? weightedOptions,
    List<String>? options,
    String? filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEnabled,
  }) {
    List<WildcardOption> newOptions = weightedOptions ?? this.weightedOptions;
    
    // options가 제공되면 weightedOptions로 변환
    if (options != null) {
      newOptions = options.map((o) => WildcardOption.parse(o)).toList();
    }

    return WildcardModel(
      name: name ?? this.name,
      weightedOptions: newOptions,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  String toString() {
    return 'WildcardModel(name: $name, optionCount: $optionCount, totalWeight: $totalWeight, isEnabled: $isEnabled)';
  }
}
