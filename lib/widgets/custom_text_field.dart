import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.showPasswordToggle ? _obscured : widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.obscureText || widget.showPasswordToggle ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscured = !_obscured);
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
