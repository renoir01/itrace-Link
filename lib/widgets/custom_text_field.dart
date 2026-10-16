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
  final String? hint;
  final bool enabled;

  const PhoneNumberField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onChanged,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'Phone Number',
      hint: hint ?? '+250 XXX XXX XXX',
      enabled: enabled,
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

  final String? hint;
  final bool enabled;
  final bool required; // when false, an empty value is accepted

  const EmailField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onChanged,
    this.hint,
    this.enabled = true,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'Email',
      hint: hint ?? 'example@email.com',
      enabled: enabled,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return required ? 'Please enter email' : null;
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
  final double? minValue; // alias of min
  final bool? allowDecimal; // true -> up to 2 decimals (unless decimals set), false -> integers only
  final bool enabled;
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
    this.minValue,
    this.allowDecimal,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int digits = allowDecimal == null
        ? (decimals ?? 0)
        : (allowDecimal! ? ((decimals ?? 0) > 0 ? decimals! : 2) : 0);
    final double? lowest = min ?? minValue;

    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      enabled: enabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffix != null ? Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Center(
          widthFactor: 1,
          child: Text(suffix!, style: const TextStyle(fontSize: 16)),
        ),
      ) : null,
      keyboardType: TextInputType.numberWithOptions(decimal: digits > 0),
      inputFormatters: [
        if (digits == 0)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,' + digits.toString() + r'}')),
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
            if (lowest != null && number < lowest) {
              return 'Minimum value is $lowest';
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
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TextAreaField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.maxLines = 4,
    this.maxLength,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      enabled: enabled,
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
