import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/services/localization_service.dart';

class RecommendationCard extends StatelessWidget {
  final String recommendation;
  final int index;
  final bool? isHindi;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    required this.index,
    this.isHindi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get isHindi from context if not provided
    final isHindiFromContext = isHindi ?? Provider.of<LocalizationService>(context).isHindi;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _getColorForIndex(index),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final List<Color> colors = [
      AppTheme.primaryColor,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
    ];
    
    return colors[index % colors.length];
  }
} 