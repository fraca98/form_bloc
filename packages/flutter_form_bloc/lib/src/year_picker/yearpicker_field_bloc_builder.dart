import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/src/fields/simple_field_bloc_builder.dart';
import 'package:flutter_form_bloc/src/suffix_buttons/clear_suffix_button.dart';
import 'package:flutter_form_bloc/src/theme/field_theme_resolver.dart';
import 'package:flutter_form_bloc/src/theme/form_bloc_theme.dart';
import 'package:flutter_form_bloc/src/theme/suffix_button_themes.dart';
import 'package:flutter_form_bloc/src/utils/utils.dart';
import 'package:form_bloc/form_bloc.dart';

/// A material design year picker.
class YearPickerFieldBlocBuilder<T> extends StatefulWidget {
  const YearPickerFieldBlocBuilder({
    Key? key,
    required this.yearPickerFieldBloc,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.decoration = const InputDecoration(),
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.useRootNavigator = false,
    this.routeSettings,
    this.animateWhenCanShow = true,
    this.showClearIcon,
    this.clearIcon,
    this.nextFocusNode,
    this.focusNode,
    this.textStyle,
    this.textColor,
    this.textAlign,
  }) : super(key: key);

  /// {@macro flutter_form_bloc.FieldBlocBuilder.fieldBloc}
  final InputFieldBloc<T, dynamic> yearPickerFieldBloc;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.errorBuilder}
  final FieldBlocErrorBuilder? errorBuilder;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.enableOnlyWhenFormBlocCanSubmit}
  final bool enableOnlyWhenFormBlocCanSubmit;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.isEnabled}
  final bool isEnabled;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.decoration}
  final InputDecoration decoration;

  /// {@macro  flutter_form_bloc.FieldBlocBuilder.animateWhenCanShow}
  final bool animateWhenCanShow;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.nextFocusNode}
  final FocusNode? nextFocusNode;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.textAlign}
  final TextAlign? textAlign;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.style}
  final TextStyle? textStyle;

  final MaterialStateProperty<Color?>? textColor;

  /// Defaults `true`
  final bool? showClearIcon;

  /// Defaults `Icon(Icons.clear)`
  final Widget? clearIcon;

  /// The initial date to center the year display around
  final DateTime? initialDate;

  /// The earliest date the user is permitted to pick
  final DateTime firstDate;

  /// The latest date the user is permitted to pick
  final DateTime lastDate;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;

  @override
  _YearPickerFieldBlocBuilderState createState() =>
      _YearPickerFieldBlocBuilderState();

  YearPickerFieldTheme themeStyleOf(BuildContext context) {
    final theme = Theme.of(context);
    final formTheme = FormTheme.of(context);
    final fieldTheme = formTheme.dateTimeTheme;
    final resolver = FieldThemeResolver(theme, formTheme, fieldTheme);
    final cleanTheme = fieldTheme.clearSuffixButtonTheme;

    return YearPickerFieldTheme(
      decorationTheme: resolver.decorationTheme,
      textStyle: textStyle ?? resolver.textStyle,
      textColor: textColor ?? resolver.textColor,
      textAlign: textAlign ?? fieldTheme.textAlign ?? TextAlign.start,
      showClearIcon: showClearIcon ?? fieldTheme.showClearIcon ?? true,
      clearSuffixButtonTheme: ClearSuffixButtonTheme(
        visibleWithoutValue: cleanTheme.visibleWithoutValue ??
            formTheme.clearSuffixButtonTheme.visibleWithoutValue ??
            false,
        appearDuration: cleanTheme.appearDuration,
        // ignore: deprecated_member_use_from_same_package
        icon: clearIcon ?? cleanTheme.icon ?? fieldTheme.clearIcon,
      ),
    );
  }
}

class _YearPickerFieldBlocBuilderState<T>
    extends State<YearPickerFieldBlocBuilder<T>> {
  final FocusNode _focusNode = FocusNode();

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    _effectiveFocusNode.addListener(_onFocusRequest);
    super.initState();
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusRequest);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusRequest() {
    if (_effectiveFocusNode.hasFocus) {
      _showPicker(context);
    }
  }

  void _showPicker(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    dynamic result;

    result = await _showYearPicker(context);

    if (result != null) {
      fieldBlocBuilderOnChange<T>(
        isEnabled: widget.isEnabled,
        nextFocusNode: widget.nextFocusNode,
        onChanged: (value) {
          widget.yearPickerFieldBloc.changeValue(value);
          // Used for hide keyboard
          // FocusScope.of(context).requestFocus(FocusNode());
        },
      )!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldTheme = widget.themeStyleOf(context);

    return Focus(
      focusNode: _effectiveFocusNode,
      child: SimpleFieldBlocBuilder(
        singleFieldBloc: widget.yearPickerFieldBloc,
        animateWhenCanShow: widget.animateWhenCanShow,
        builder: (_, __) {
          return BlocBuilder<InputFieldBloc<T, dynamic>,
              InputFieldBlocState<T, dynamic>>(
            bloc: widget.yearPickerFieldBloc,
            builder: (context, state) {
              final isEnabled = fieldBlocIsEnabled(
                isEnabled: widget.isEnabled,
                enableOnlyWhenFormBlocCanSubmit:
                    widget.enableOnlyWhenFormBlocCanSubmit,
                fieldBlocState: state,
              );

              Widget child;

              if (state.value == null && widget.decoration.hintText != null) {
                child = Text(
                  widget.decoration.hintText!,
                  maxLines: widget.decoration.hintMaxLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: fieldTheme.textAlign,
                  style: Style.resolveTextStyle(
                    isEnabled: isEnabled,
                    style: widget.decoration.hintStyle ?? fieldTheme.textStyle!,
                    color: fieldTheme.textColor!,
                  ),
                );
              } else {
                child = Text(
                  state.value != null
                      ? (state.value as DateTime).year.toString()
                      : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: fieldTheme.textAlign,
                  style: Style.resolveTextStyle(
                    isEnabled: isEnabled,
                    style: fieldTheme.textStyle!,
                    color: fieldTheme.textColor!,
                  ),
                );
              }

              return DefaultFieldBlocBuilderPadding(
                padding: widget.padding,
                child: GestureDetector(
                  onTap: !isEnabled ? null : () => _showPicker(context),
                  child: InputDecorator(
                    decoration:
                        _buildDecoration(context, fieldTheme, state, isEnabled),
                    isEmpty: state.value == null &&
                        widget.decoration.hintText == null,
                    child: child,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<DateTime?> _showYearPicker(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a year'),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
                initialDate:
                    widget.yearPickerFieldBloc.state.value as DateTime? ??
                        widget.initialDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedDate: widget.yearPickerFieldBloc.state.value != null
                    ? widget.yearPickerFieldBloc.state.value as DateTime
                    : DateTime.now(),
                onChanged: (value) {
                  Navigator.pop(
                      context, value); //pop the dialog and return the value
                }),
          ),
        );
      },
      useRootNavigator: widget.useRootNavigator,
    );
  }

  InputDecoration _buildDecoration(
    BuildContext context,
    YearPickerFieldTheme fieldTheme,
    InputFieldBlocState<T, dynamic> state,
    bool isEnabled,
  ) {
    InputDecoration decoration = widget.decoration;

    decoration = decoration.copyWith(
      enabled: isEnabled,
      errorText: Style.getErrorText(
        context: context,
        errorBuilder: widget.errorBuilder,
        fieldBlocState: state,
        fieldBloc: widget.yearPickerFieldBloc,
      ),
      suffixIcon: decoration.suffixIcon ??
          (fieldTheme.showClearIcon!
              ? _buildClearSuffixButton(fieldTheme.clearSuffixButtonTheme)
              : null),
    );

    return decoration;
  }

  Widget _buildClearSuffixButton(ClearSuffixButtonTheme buttonTheme) {
    return ClearSuffixButton(
      singleFieldBloc: widget.yearPickerFieldBloc,
      isEnabled: widget.isEnabled,
      appearDuration: buttonTheme.appearDuration,
      visibleWithoutValue: buttonTheme.visibleWithoutValue,
      icon: buttonTheme.icon,
    );
  }
}
