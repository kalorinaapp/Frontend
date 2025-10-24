import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../utils/theme_helper.dart';

class EditMacroScreen extends StatefulWidget {
  final String macroName;
  final String iconAsset;
  final Color color;
  final int initialValue;
  final Function(int) onValueChanged;

  const EditMacroScreen({
    super.key,
    required this.macroName,
    required this.iconAsset,
    required this.color,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  State<EditMacroScreen> createState() => _EditMacroScreenState();
}

class _EditMacroScreenState extends State<EditMacroScreen> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue.toString());
    _focusNode = FocusNode();
    
    // Auto-focus the text field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onUndo() {
    setState(() {
      _textController.text = widget.initialValue.toString();
    });
  }

  void _onDone() {
    final value = int.tryParse(_textController.text) ?? widget.initialValue;
    widget.onValueChanged(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        _focusNode.unfocus();
      },
      child: CupertinoPageScaffold(
        backgroundColor: ThemeHelper.background,
        resizeToAvoidBottomInset: true,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/icons/back.svg',
                        width: 24,
                        height: 24,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.macroName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Value Display Card with TextField
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ThemeHelper.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeHelper.divider,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.textPrimary.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: ThemeHelper.textPrimary.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          widget.iconAsset,
                          width: 24,
                          height: 24,
                          color: widget.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content with TextField
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeHelper.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CupertinoTextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: ThemeHelper.textPrimary,
                            ),
                            decoration: const BoxDecoration(),
                            padding: EdgeInsets.zero,
                            onSubmitted: (_) => _onDone(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons (positioned above keyboard when active)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    // Undo Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _onUndo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ThemeHelper.cardBackground,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: ThemeHelper.textPrimary,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Undo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Done Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _onDone,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ThemeHelper.textPrimary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Done',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.background,
                            ),
                          ),
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
    );
  }

}
