import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class ExclusiveOfferPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String headerAssetPath; // You will provide this asset

  const ExclusiveOfferPage({
    super.key,
    required this.themeProvider,
    this.headerAssetPath = 'assets/images/exclusive_offer_header.png',
  });

  @override
  State<ExclusiveOfferPage> createState() => _ExclusiveOfferPageState();
}

class _ExclusiveOfferPageState extends State<ExclusiveOfferPage> {
  bool isFreeTrialEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, _) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Exclusive Offer',
                    textAlign: TextAlign.center,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.title1,
                      ThemeHelper.textPrimary,
                      28,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 48),
                  // Top graphic (you will supply the final asset)
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Image.asset(
                      widget.headerAssetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 120),
                  // Free trial toggle row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Free Trial',
                          style: ThemeHelper.textStyleWithColorAndSize(
                            ThemeHelper.body1,
                            ThemeHelper.textPrimary,
                            16,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      CupertinoSwitch(
                        value: isFreeTrialEnabled,
                        activeColor: Colors.black,
                        onChanged: (v) => setState(() => isFreeTrialEnabled = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Plan card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: ThemeHelper.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ThemeHelper.divider, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yearly + 3 Day Free Trial',
                                style: ThemeHelper.textStyleWithColorAndSize(
                                  ThemeHelper.body1,
                                  ThemeHelper.textPrimary,
                                  15,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '34.99 €',
                                    style: ThemeHelper.textStyleWithColorAndSize(
                                      ThemeHelper.title2,
                                      ThemeHelper.textSecondary,
                                      13,
                                    ).copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '€1.90 /mo',
                              style: ThemeHelper.textStyleWithColorAndSize(
                                ThemeHelper.body1,
                                ThemeHelper.textPrimary,
                                15,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black,
                      onPressed: () {},
                      child: Text(
                        'Take The Offer - €22.99',
                        style: ThemeHelper.textStyleWithColorAndSize(
                          ThemeHelper.body1,
                          Colors.white,
                          16,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No payment due now – (This offer ends\nonce you close it)',
                    textAlign: TextAlign.center,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.title2,
                      ThemeHelper.textSecondary,
                      12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


