import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../domain/bot.dart';

class BotDetailScreen extends ConsumerWidget {
  final Bot bot;

  const BotDetailScreen({super.key, required this.bot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    color: AppColors.surface,
                    child: CachedNetworkImage(
                      imageUrl: bot.imageUrl ?? '',
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      placeholder: (context, url) => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.smart_toy_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bot.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.mapCategory(bot.category),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${(bot.priceMonthly ?? 0).toStringAsFixed(0)}/${s.payMonth}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 12),
                        if (bot.description.isNotEmpty) ...[
                          Text(
                            s.catDescription.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bot.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(height: 1.6),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          s.catFunctions.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 12),
                        if (bot.shortFeatures != null)
                          ...bot.shortFeatures!.map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      feature['icon']?.toString() ?? '✨',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        AppStrings.translateFeature(feature['label']?.toString() ?? ''),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final session =
                      ref.read(supabaseClientProvider).auth.currentSession;

                  if (session == null) {
                    context.push('/auth');
                  } else {
                    context.push('/payment', extra: {
                      'botId': bot.id,
                      'botName': bot.name,
                      'botDescription': bot.shortDescription,
                      'priceMonthly': bot.priceMonthly ?? 0.0,
                      'priceYearly': bot.priceYearly ?? 0.0,
                    });
                  }
                },
                child: Text(s.botConnect),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
