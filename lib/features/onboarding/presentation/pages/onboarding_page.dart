import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../../core/widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  final _items = const [
    (
      icon: Icons.receipt_long_rounded,
      title: 'سجّل مصروفاتك بسرعة',
      subtitle: 'أضف أي مصروف في ثوانٍ مع تصنيف واضح وتاريخ وملاحظة.',
    ),
    (
      icon: Icons.pie_chart_rounded,
      title: 'اعرف فلوسك بتروح فين',
      subtitle: 'تابع توزيع الإنفاق على التصنيفات بشكل بسيط وسهل القراءة.',
    ),
    (
      icon: Icons.savings_rounded,
      title: 'تحكم في صرفك كل شهر',
      subtitle: 'أنشئ الشهور، راقب الميزانية، وخذ قرارات أهدأ وأذكى.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('تخطي'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 58,
                          child: Icon(item.icon, size: 56),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          item.title,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _index == index ? 28 : 8,
                    decoration: BoxDecoration(
                      color: _index == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _index == _items.length - 1 ? 'ابدأ الآن' : 'التالي',
                icon: _index == _items.length - 1
                    ? Icons.check_circle_rounded
                    : Icons.arrow_back_rounded,
                onPressed: () {
                  if (_index == _items.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await context.read<SettingsCubit>().markOnboardingDone();
    if (!mounted) {
      return;
    }
    context.go('/auth');
  }
}
