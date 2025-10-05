import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart' show ThemeProvider;

class PaywallScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const PaywallScreen({
    super.key,
    required this.themeProvider,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool isYearlySelected = true; // Yearly is selected by default

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Stack(
              children: [
                // Back arrow
                Positioned(
                  left: 21,
                  top: 6,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 24,
                      height: 24,
                      child: Text(
                        '←',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      SizedBox(
                        width: 275,
                        child: Text(
                          isYearlySelected 
                            ? '3 days free, then €39.99 per year.'
                            : 'Your smarter way to track calories starts here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF1E1822),
                            fontSize: 22,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Show benefits only for monthly plan
                      if (!isYearlySelected) ...[
                        _buildBenefits(),
                        const SizedBox(height: 40),
                      ] else ...[
                        // Show timeline for yearly plan
                        _buildTimeline(),
                        const SizedBox(height: 40),
                      ],

                      // Subscription plans
                      _buildSubscriptionPlans(),

                      const SizedBox(height: 20),

                      // Cancel anytime text
                      SizedBox(
                        width: 293,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Otkaži u bilo kojem trenutku',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CTA Button
                      Container(
                        width: 290,
                        height: 50,
                        decoration: ShapeDecoration(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isYearlySelected 
                              ? 'Start My 3-Day Trial For €0.00'
                              : 'Continue',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.90),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dynamic disclaimer text
                      SizedBox(
                        width: 293,
                        child: Text(
                          isYearlySelected 
                            ? 'No Payment Due Now'
                            : 'Start today for only €9.99 – Stop whenever you want',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.70),
                            fontSize: 12,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        // Day 1
        _buildTimelineItem(
          day: 'Day 1',
          description: 'Unlock AI food scanning & all Pro features',
          icon: Icons.lock,
        ),
        

        
        // Day 2
        _buildTimelineItem(
          day: 'Day 2',
          description: 'Get a friendly reminder before your trial ends',
          icon: Icons.notifications,
        ),
        

        
        // Day 3
        _buildTimelineItem(
          day: 'Day 3',
          description: 'Continue with your chosen plan',
          icon: Icons.workspace_premium,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String day,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and circle
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: ShapeDecoration(
                color: const Color(0xFFD47405),
                shape: OvalBorder(),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (day != 'Day 3') // Don't show line after last item
              Container(
                width: 12,
                height: 40,
                color: const Color(0x19D47405),
              ),
          ],
        ),
        
        const SizedBox(width: 15),
        
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
                  fontSize: 15,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
                  fontSize: 10,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: [
        _buildBenefitItem(
          title: 'No more calorie math',
          description: 'We do the numbers, you enjoy the food.',
        ),
        const SizedBox(height: 20),
        _buildBenefitItem(
          title: 'Scan. Track. Done.',
          description: 'Logging food takes seconds.',
        ),
        const SizedBox(height: 20),
        _buildBenefitItem(
          title: 'Stay on top effortlessly',
          description: 'Gentle reminders keep you consistent.',
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 23,
          height: 23,
          decoration: BoxDecoration(
            color: const Color(0xFFD47405),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
                  fontSize: 15,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
                  fontSize: 10,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlans() {
    return Column(
      children: [
        // Yearly plan
        _buildPlanCard(
          title: 'Yearly - 3 Day Free Trial',
          price: '€2.91 /mo',
          isSelected: isYearlySelected,
          onTap: () {
            setState(() {
              isYearlySelected = true;
            });
          },
        ),
        
        const SizedBox(height: 10),
        
        // Monthly plan
        _buildPlanCard(
          title: 'Monthly - No Free Trial',
          price: '€9.99 /mo',
          isSelected: !isYearlySelected,
          onTap: () {
            setState(() {
              isYearlySelected = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 290,
      height: 50,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 0,
            offset: Offset(0, 0),
            spreadRadius: 1,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.80),
                    fontSize: 12,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    ));
  }
}
