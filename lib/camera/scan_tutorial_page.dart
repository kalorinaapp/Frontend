import 'package:flutter/cupertino.dart';

class ScanTutorialPage extends StatelessWidget {
  const ScanTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            weight: 30.0,
            CupertinoIcons.xmark_circle,
            color: CupertinoColors.black,
            size: 24,
          ),
        ),
      ),
      ),
      backgroundColor: CupertinoColors.systemBackground,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              
              const SizedBox(height: 120),
              
              // Title
              const Center(
                child: Text(
                  'How to scan properly',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Phone examples row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Correct example
                  Column(
                    children: [
                      // Tick mark asset - you will provide this
                      Image.asset('assets/icons/tick.png', height: 30, width: 30,),
                      
                      const SizedBox(height: 20),
                      
                      // Phone mockup - correct (your asset)
                      Image.asset('assets/images/mockup-1.png', height: 300, width: 160,),
                    ],
                  ),
                  
                  // Incorrect example
                  Column(
                    children: [
                      // X mark asset - you will provide this
                      Image.asset('assets/icons/xmark.png', height: 30, width: 30,),
                      
                      const SizedBox(height: 20),
                      
                      // Phone mockup - incorrect (your asset)
                      Image.asset('assets/images/mockup-2.png', height: 300, width: 160,),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Instructions in light container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InstructionItem(
                        text: 'Keep food fully inside the frame',
                      ),
                      SizedBox(height: 16),
                      _InstructionItem(
                        text: 'Hold your phone steady for a clear photo',
                      ),
                      SizedBox(height: 16),
                      _InstructionItem(
                        text: 'Take the picture straight, not at an angle',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.black,
                    borderRadius: BorderRadius.circular(25),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Nastavi',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String text;

  const _InstructionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8, right: 16),
          decoration: const BoxDecoration(
            color: CupertinoColors.systemGrey2,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey2,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  _CornerBracketsPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Top-left
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
