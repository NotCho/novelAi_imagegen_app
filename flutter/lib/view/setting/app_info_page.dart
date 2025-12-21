import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naiapp/view/core/page.dart';
import 'package:naiapp/view/core/util/design_system.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScaffold(
      appBar: const SkeletonAppBar(
        backgroundColor: SkeletonColorScheme.backgroundColor,
        titleText: '앱 정보',
      ),
      backgroundColor: SkeletonColorScheme.backgroundColor,
      body: FutureBuilder<List<_ReleaseEntry>>(
        future: _loadReleaseEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? const <_ReleaseEntry>[];
          if (entries.isEmpty) {
            return Center(
              child: Text(
                '변경사항을 불러오지 못했습니다.',
                style: SkeletonTextTheme.body2Long
                    .copyWith(color: SkeletonColorScheme.textSecondaryColor),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final e = entries[index];
              return Container(
                decoration: BoxDecoration(
                  color: SkeletonColorScheme.cardColor,
                  borderRadius:
                      BorderRadius.circular(SkeletonSpacing.borderRadius),
                  border: Border.all(
                    color: SkeletonColorScheme.surfaceColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: ExpansionTile(
                  collapsedIconColor: SkeletonColorScheme.textSecondaryColor,
                  iconColor: SkeletonColorScheme.textSecondaryColor,
                  title: Text(
                    e.versionLabel,
                    style: SkeletonTextTheme.newBody16Bold
                        .copyWith(color: SkeletonColorScheme.textColor),
                  ),
                  subtitle: Text(
                    e.date ?? '',
                    style: SkeletonTextTheme.newBody12
                        .copyWith(color: SkeletonColorScheme.textSecondaryColor),
                  ),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    for (final c in e.changes) ...[
                      const SizedBox(height: 8),
                      Text(
                        '• ${c.description}',
                        style: SkeletonTextTheme.body2Long
                            .copyWith(color: SkeletonColorScheme.textColor),
                      ),
                      if (c.details.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        for (final d in c.details)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 2),
                            child: Text(
                              '- $d',
                              style: SkeletonTextTheme.newBody12.copyWith(
                                color: SkeletonColorScheme.textSecondaryColor,
                              ),
                            ),
                          ),
                      ],
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<_ReleaseEntry>> _loadReleaseEntries() async {
    final raw = await rootBundle.loadString('assets/changes.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return const [];

    final entries = <_ReleaseEntry>[];
    decoded.forEach((key, value) {
      if (value is! Map<String, dynamic>) return;
      final versionLabel = (value['version'] as String?) ?? key;
      final date = value['date'] as String?;
      final rawChanges = value['changes'];
      final changes = <_ChangeEntry>[];
      if (rawChanges is List) {
        for (final item in rawChanges) {
          if (item is! Map<String, dynamic>) continue;
          final desc = (item['description'] as String?)?.trim() ?? '';
          final detailsRaw = item['details'];
          final details = <String>[];
          if (detailsRaw is List) {
            for (final d in detailsRaw) {
              if (d is String && d.trim().isNotEmpty) details.add(d.trim());
            }
          }
          if (desc.isNotEmpty) {
            changes.add(_ChangeEntry(description: desc, details: details));
          }
        }
      }
      entries.add(_ReleaseEntry(
        key: key,
        versionLabel: versionLabel,
        date: date,
        changes: changes,
      ));
    });

    entries.sort((a, b) => _compareVersionDesc(a.key, b.key));
    return entries;
  }

  int _compareVersionDesc(String a, String b) {
    final pa = _parseSemver(a);
    final pb = _parseSemver(b);
    for (var i = 0; i < 3; i++) {
      final diff = pb[i] - pa[i];
      if (diff != 0) return diff;
    }
    return b.compareTo(a);
  }

  List<int> _parseSemver(String s) {
    final core = s.split('+').first;
    final parts = core.split('.');
    int p(int i) => (i < parts.length) ? int.tryParse(parts[i]) ?? 0 : 0;
    return [p(0), p(1), p(2)];
  }
}

class _ReleaseEntry {
  final String key;
  final String versionLabel;
  final String? date;
  final List<_ChangeEntry> changes;

  const _ReleaseEntry({
    required this.key,
    required this.versionLabel,
    required this.date,
    required this.changes,
  });
}

class _ChangeEntry {
  final String description;
  final List<String> details;

  const _ChangeEntry({required this.description, required this.details});
}


