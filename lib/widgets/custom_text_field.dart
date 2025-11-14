import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        enabled: enabled,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
    );
  }
}

// Phone number input field
class PhoneNumberField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneNumberField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'Phone Number',
      hint: '+250 XXX XXX XXX',
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
      ],
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            final cleaned = value.replaceAll(RegExp(r'\D'), '');
            if (cleaned.length < 9 || cleaned.length > 12) {
              return 'Invalid phone number';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

// Email input field
class EmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'Email',
      hint: 'example@email.com',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Invalid email format';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

// Password input field
class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label ?? 'Password',
      prefixIcon: Icons.lock,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      obscureText: _obscureText,
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
      onChanged: widget.onChanged,
    );
  }
}

// Number input field
class NumberField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffix;
  final double? min;
  final double? max;
  final int? decimals;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const NumberField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.min,
    this.max,
    this.decimals = 0,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffix != null ? Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Center(
          widthFactor: 1,
          child: Text(suffix!, style: const TextStyle(fontSize: 16)),
        ),
      ) : null,
      keyboardType: TextInputType.numberWithOptions(decimal: decimals! > 0),
      inputFormatters: [
        if (decimals == 0)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,' + decimals.toString() + r'}')),
      ],
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            final number = double.tryParse(value);
            if (number == null) {
              return 'Invalid number';
            }
            if (min != null && number < min!) {
              return 'Minimum value is $min';
            }
            if (max != null && number > max!) {
              return 'Maximum value is $max';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

// Text area (multiline)
class TextAreaField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TextAreaField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.maxLines = 4,
    this.maxLength,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

// Date picker field
class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? Function(String?)? validator;
  final void Function(DateTime)? onDateSelected;

  const DatePickerField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.validator,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.calendar_today,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );

        if (date != null) {
          controller.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          onDateSelected?.call(date);
        }
      },
      validator: validator,
    );
  }
}
