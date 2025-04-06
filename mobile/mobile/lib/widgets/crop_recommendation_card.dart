import 'package:flutter/material.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/crop_recommendation.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:provider/provider.dart';

class CropRecommendationCard extends StatefulWidget {
  final CropRecommendation recommendation;
  
  const CropRecommendationCard({
    Key? key,
    required this.recommendation,
  }) : super(key: key);

  @override
  State<CropRecommendationCard> createState() => _CropRecommendationCardState();
}

class _CropRecommendationCardState extends State<CropRecommendationCard> {
  bool _expanded = false;
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildCropIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recommendation.cropName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.recommendation.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              
              // Quick info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      Icons.account_balance_wallet,
                      '₹${widget.recommendation.estimatedProfit.toStringAsFixed(0)}',
                      isHindi ? 'अनुमानित लाभ' : 'Est. Profit',
                    ),
                    _buildInfoChip(
                      Icons.water_drop,
                      _getWaterRequirementText(widget.recommendation.waterRequirement, isHindi),
                      isHindi ? 'पानी की आवश्यकता' : 'Water Req.',
                    ),
                  ],
                ),
              ),
              
              // Expanded details
              if (_expanded) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection(
                        isHindi ? 'फायदे' : 'Advantages',
                        widget.recommendation.advantages,
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        isHindi ? 'सिंचाई के टिप्स' : 'Irrigation Tips',
                        widget.recommendation.irrigationTips,
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        isHindi ? 'उन्नत खेती तकनीक' : 'Advanced Farming Techniques',
                        widget.recommendation.farmingTechniques,
                        Icons.agriculture,
                        Colors.brown,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCropIcon() {
    final cropName = widget.recommendation.cropName.toLowerCase();
    IconData iconData;
    Color iconColor;
    
    if (cropName.contains('rice') || cropName.contains('wheat') || cropName.contains('barley')) {
      iconData = Icons.grass;
      iconColor = Colors.green.shade700;
    } else if (cropName.contains('cotton')) {
      iconData = Icons.scatter_plot;
      iconColor = Colors.white;
    } else if (cropName.contains('soybean') || cropName.contains('pulse') || cropName.contains('lentil')) {
      iconData = Icons.grain;
      iconColor = Colors.amber.shade800;
    } else if (cropName.contains('sugar')) {
      iconData = Icons.candlestick_chart;
      iconColor = Colors.brown.shade300;
    } else if (cropName.contains('vegetable') || cropName.contains('tomato') || cropName.contains('potato')) {
      iconData = Icons.eco;
      iconColor = Colors.green;
    } else {
      iconData = Icons.spa;
      iconColor = Colors.green.shade600;
    }
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 30,
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 26, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
  
  String _getWaterRequirementText(int requirement, bool isHindi) {
    if (requirement <= 3) {
      return isHindi ? 'कम' : 'Low';
    } else if (requirement <= 7) {
      return isHindi ? 'मध्यम' : 'Medium';
    } else {
      return isHindi ? 'उच्च' : 'High';
    }
  }
} 