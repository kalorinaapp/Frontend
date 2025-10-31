import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/theme_helper.dart' show ThemeHelper;

class EditMealNameScreen extends StatefulWidget {
  final String currentName;
  
  const EditMealNameScreen({
    super.key,
    required this.currentName,
  });

  @override
  State<EditMealNameScreen> createState() => _EditMealNameScreenState();
}

class _EditMealNameScreenState extends State<EditMealNameScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: Column(
        children: [
          const SizedBox(height: 50),
          // Header with back button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Text(
                      '←',
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 28,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Title
                  SizedBox(
                    width: 274,
                    child: Text(
                      'Name Change',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 26,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Text Input Field
                  Container(
                    width: 335,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: ThemeHelper.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      shadows: CupertinoTheme.of(context).brightness == Brightness.dark
                          ? []
                          : const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 5,
                                offset: Offset(0, 0),
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Enter meal name',
                      placeholderStyle: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w400,
                      ),
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          // Bottom Update Button
          Container(
            width: 393,
            height: 76,
            decoration: BoxDecoration(
              color: ThemeHelper.background,
              boxShadow: CupertinoTheme.of(context).brightness == Brightness.dark
                  ? []
                  : const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final newName = _nameController.text.trim();
                  if (newName.isNotEmpty) {
                    Navigator.of(context).pop(newName);
                  }
                },
                child: Container(
                  width: 250,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: ThemeHelper.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 73,
                      height: 16,
                      child: Text(
                        'Update',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeHelper.background,
                          fontSize: 14,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

