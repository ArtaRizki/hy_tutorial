import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../helper/constant.dart';
import '../helper/dropdown_search.dart';

class CustomDropdown {
  static Widget normalDropdown({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = true,
    bool enabled = true,
    bool isDense = false,
    Color? fillColor,
    Color? borderColor,
    Color? hintColor,
    String? selectedItem,
    Function(String?)? onChanged,
    required List<DropdownMenuItem<String>> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? iconPadding,
    double? labelFontSize,
    Widget? suffixIcon,
    FormFieldValidator? validator,
    OutlineInputBorder? customBorder,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    labelText,
                    style: Constant.primaryTextStyle.copyWith(
                      fontSize: labelFontSize ?? 14,
                      fontWeight: Constant.medium,
                    ),
                  ),
                  required
                      ? Text(
                          '*',
                          style: Constant.primaryTextStyle.copyWith(
                            fontSize: labelFontSize ?? 14,
                            fontWeight: Constant.medium,
                            color: Colors.red,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          DropdownButtonFormField(
            isDense: isDense,
            elevation: 0,
            padding: EdgeInsets.zero,
            items: readOnly ? null : list,
            onChanged: readOnly ? null : onChanged,
            onSaved: (val) => FocusManager.instance.primaryFocus?.unfocus(),
            icon: suffixIcon != null
                ? Padding(
                    padding:
                        iconPadding ?? const EdgeInsets.fromLTRB(16, 0, 12, 0),
                    child: Row(
                      children: [
                        suffixIcon,
                        Constant.xSizedBox8,
                        Icon(Icons.keyboard_arrow_down,
                            color: Constant.textHintColor2, size: 24),
                      ],
                    ),
                  )
                : Padding(
                    padding:
                        iconPadding ?? const EdgeInsets.fromLTRB(16, 0, 12, 0),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: Constant.textHintColor2, size: 24),
                  ),
            // style: Constant.primaryTextStyle,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: contentPadding ?? EdgeInsets.zero,
              hintText: hintText ?? "",
              isDense: isDense,
              hintStyle: TextStyle(color: hintColor ?? Constant.textHintColor2),
              filled: true,
              enabled: enabled,
              fillColor: fillColor ??
                  (enabled ? Colors.white : Constant.textHintColor),
              suffixIconColor: Constant.primaryColor,
              hoverColor: Constant.primaryColor,
              focusColor: Constant.primaryColor,
              prefix: SizedBox(width: 12),
              border: customBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: borderColor ?? Constant.borderSearchColor,
                      style: BorderStyle.solid,
                    ),
                  ),
              enabledBorder: customBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: borderColor ?? Constant.borderSearchColor,
                      style: BorderStyle.solid,
                    ),
                  ),
              focusedBorder: customBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: borderColor ?? Constant.primaryColor,
                      style: BorderStyle.solid,
                    ),
                  ),
            ),
            hint: Text(hintText ?? ""),
            value: selectedItem,
            validator: (value) {
              if (validator != null) {
                if (required && value?.isNotEmpty != true) {
                  return 'Harap isi $labelText';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  static Widget filterDropdown({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = false,
    String? selectedItem,
    Function(String?)? onChanged,
    required List<DropdownMenuItem<String>> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    double? labelFontSize,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                labelText,
                style: Constant.primaryTextStyle.copyWith(
                  fontSize: labelFontSize ?? 14,
                  fontWeight: Constant.medium,
                ),
              ),
            ),
          CustomDropdownSearch().dropdownFilter(
            label: labelText,
            hint: hintText ?? "",
            list: list,
            onChanged: onChanged,
            required: required,
            selectedItem: selectedItem,
          ),
        ],
      ),
    );
  }

  static Widget searchDropdown({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = true,
    bool enabled = true,
    bool isDense = false,
    Color? fillColor,
    Color? borderColor,
    String? selectedItem,
    Function(String?)? onChanged,
    required List<String> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? iconPadding,
    double? labelFontSize,
    Widget? suffixIcon,
    Color? hintColor,
    FormFieldValidator? validator,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    labelText,
                    style: Constant.primaryTextStyle.copyWith(
                      fontSize: labelFontSize ?? 14,
                      fontWeight: Constant.medium,
                    ),
                  ),
                  required
                      ? Text(
                          '*',
                          style: Constant.primaryTextStyle.copyWith(
                            fontSize: labelFontSize ?? 14,
                            fontWeight: Constant.medium,
                            color: Colors.red,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          DropdownSearch<String>(
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              // title: Text('fit to a specific max height'),
              constraints: BoxConstraints(maxHeight: 300),
              showSelectedItems: true,
            ),
            items: list,
            onChanged: onChanged,
            selectedItem: selectedItem,
            dropdownButtonProps: DropdownButtonProps(
              icon: suffixIcon != null
                  ? Row(
                      children: [
                        suffixIcon,
                        Constant.xSizedBox8,
                        Padding(
                          padding: iconPadding ??
                              const EdgeInsets.fromLTRB(16, 0, 12, 0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Constant.textHintColor2, size: 24),
                        ),
                      ],
                    )
                  : Padding(
                      padding: iconPadding ??
                          const EdgeInsets.fromLTRB(16, 0, 12, 0),
                      child: Icon(Icons.keyboard_arrow_down,
                          color: Constant.textHintColor2, size: 24),
                    ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                contentPadding: contentPadding ?? EdgeInsets.zero,
                hintText: hintText ?? "",
                isDense: isDense,
                hintStyle:
                    TextStyle(color: hintColor ?? Constant.textHintColor2),
                filled: true,
                enabled: enabled,
                fillColor: fillColor ??
                    (enabled ? Colors.white : Constant.textHintColor),
                suffixIconColor: Constant.primaryColor,
                hoverColor: Constant.primaryColor,
                focusColor: Constant.primaryColor,
                prefix: SizedBox(width: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 0.3,
                    color: borderColor ?? Constant.borderSearchColor,
                    style: BorderStyle.solid,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 0.3,
                    color: borderColor ?? Constant.borderSearchColor,
                    style: BorderStyle.solid,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 0.5,
                    color: borderColor ?? Constant.primaryColor,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (validator != null) {
                if (required && value?.isNotEmpty != true) {
                  return 'Harap isi $labelText';
                }
              }
              return null;
            },
            clearButtonProps: ClearButtonProps(
              icon: Icon(Icons.clear, size: 17, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
