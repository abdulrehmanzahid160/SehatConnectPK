import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String valueLabel;
  final String advice;
  final String tip;
  final IconData? icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.valueLabel,
    required this.advice,
    required this.tip,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: const Color(0xFF01411C).withOpacity(0.2),
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of the card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF01411C).withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF01411C).withOpacity(0.1),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon ?? Icons.analytics_outlined,
                  color: const Color(0xFF01411C),
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF01411C),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary Result display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      valueLabel,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF01411C),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1.0, thickness: 0.5),
                ),
                
                // Official Advice Section
                Text(
                  'Official Advice',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  advice,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                
                const SizedBox(height: 16.0),
                
                // Enriched Health Tip Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF01411C).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: const Color(0xFF01411C).withOpacity(0.15),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF01411C),
                            size: 16.0,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Government Health Tip',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF01411C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFF01411C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
