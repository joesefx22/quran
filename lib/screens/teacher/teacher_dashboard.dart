import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/islamic_header.dart';
import 'day_session_list.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'لوحة التحكم',
              subtitle: 'أهلاً بك أيها المعلم',
            ).animate().fadeIn(),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DaySessionList()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/quran_icon.svg',
                            width: 40,
                            height: 40,
                            colorFilter: ColorFilter.mode(AppTheme.emeraldGreen, BlendMode.srcIn), // إزالة const
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حلقة اليوم',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'إدارة جلسات الطلاب والتقارير',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.warmGold),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }
}