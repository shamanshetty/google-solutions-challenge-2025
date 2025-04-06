import 'package:flutter/material.dart';
import 'package:kisan_saathi/config/app_theme.dart';

class ResultCard extends StatelessWidget {
  final String diseaseName;
  final double confidence;
  final String description;
  final List<String> recommendations;
  final bool isHindi;

  const ResultCard({
    Key? key,
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.recommendations,
    required this.isHindi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format confidence as percentage
    final confidencePercent = (confidence * 100).toStringAsFixed(1);
    
    // Determine color based on confidence
    Color confidenceColor;
    if (confidence >= 0.8) {
      confidenceColor = Colors.green;
    } else if (confidence >= 0.6) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result title and confidence
            Row(
              children: [
                Expanded(
                  child: Text(
                    diseaseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: confidenceColor, width: 1),
                  ),
                  child: Text(
                    isHindi 
                        ? 'विश्वास: $confidencePercent%'
                        : 'Confidence: $confidencePercent%',
                    style: TextStyle(
                      color: confidenceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            // Description if available
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Divider
            const Divider(),
            
            const SizedBox(height: 8),
            
            // Recommendations title
            Text(
              isHindi ? 'अनुशंसाएँ:' : 'Recommendations:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Recommendations list
            if (recommendations.isNotEmpty)
              ...recommendations.map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ))
            else
              Text(
                isHindi
                    ? 'कोई विशिष्ट अनुशंसाएँ उपलब्ध नहीं हैं।'
                    : 'No specific recommendations available.',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 