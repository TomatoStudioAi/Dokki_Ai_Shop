import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/bot.dart';

class BotCard extends StatelessWidget {
  final Bot bot;
  final VoidCallback onConnect;

  const BotCard({
    super.key,
    required this.bot,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: SizedBox(
          width: 80,
          height: 80,
          child: bot.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: bot.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.smart_toy_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                )
              : const Icon(
                  Icons.smart_toy_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
        ),
        title: Text(
          bot.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            bot.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onConnect,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Подключить'),
        ),
      ),
    );
  }
}
