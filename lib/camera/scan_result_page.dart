import 'dart:io' show File;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show  Icons;

class ScanResultPage extends StatelessWidget {
  final Map<String, dynamic> result;
  final String? imagePath;
  final String? rawResponse;
  final int? statusCode;
  final String? requestInfo;

  const ScanResultPage({super.key, required this.result, this.imagePath, this.rawResponse, this.statusCode, this.requestInfo});

  @override
  Widget build(BuildContext context) {
    final scan = result['scanResult'] as Map<String, dynamic>?;
    final items = (scan?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalCalories = scan?['totalCalories'];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Icon(Icons.arrow_back),
        middle: const Text('Scan Result'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            if (totalCalories != null) ...[
              const SizedBox(height: 12),
              Text(
                'Total: $totalCalories kcal',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (final item in items) _buildItem(item),
            const SizedBox(height: 16),
            const Text('Debug', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (requestInfo != null)
              Text('Request: $requestInfo', style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
            if (statusCode != null)
              Text('Status: $statusCode', style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
            const SizedBox(height: 6),
            if (rawResponse != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CupertinoColors.systemGrey3),
                ),
                child: Text(
                  rawResponse!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final name = item['name'] ?? '';
    final portion = item['portion'] ?? '';
    final calories = item['calories']?.toString() ?? '';
    final macros = (item['macros'] as Map<String, dynamic>?) ?? {};
    final carbs = macros['carbs'] ?? 0;
    final protein = macros['protein'] ?? 0;
    final fat = macros['fat'] ?? 0;
    final confidence = item['confidence'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text('$calories kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(portion, style: const TextStyle(color: CupertinoColors.systemGrey)),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip('Carbs: $carbs g'),
              const SizedBox(width: 8),
              _chip('Protein: $protein g'),
              const SizedBox(width: 8),
              _chip('Fat: $fat g'),
            ],
          ),
          if (confidence != null) ...[
            const SizedBox(height: 8),
            Text('Confidence: ${(confidence * 100).toStringAsFixed(0)}%'),
          ]
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}
