import 'package:fit_office/global_overlay.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/l10n/app_localizations.dart';

class DashboardSearchBox extends StatefulWidget {
  const DashboardSearchBox({
    super.key,
    required this.txtTheme,
    required this.onSearchSubmitted,
    required this.onTextChanged,
    required this.onFocusChanged,
  });

  final TextTheme txtTheme;
  final void Function(String) onSearchSubmitted;
  final void Function(String) onTextChanged;
  final void Function(bool) onFocusChanged;

  @override
  DashboardSearchBoxState createState() => DashboardSearchBoxState();
}

class DashboardSearchBoxState extends State<DashboardSearchBox> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late FocusNode _redirectFocusNode;

  void requestFocus() {
    _focusNode.requestFocus();
  }

  void removeFocus() {
    _focusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus(); // <-- Ergänzen!
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _redirectFocusNode = FocusNode(); // ⬅️ NEU

    _focusNode.addListener(() {
      final hasFocus = _focusNode.hasFocus;

      if (!hasFocus && !GlobalExerciseOverlay().isDialogOpen) {
        widget.onFocusChanged(false);
        FocusScope.of(context).requestFocus(_redirectFocusNode);
      } else if (hasFocus) {
        widget.onFocusChanged(true);
      }
    });
  }

//   State<DashboardSearchBox> createState() => _DashboardSearchBoxState();
// }

// class _DashboardSearchBoxState extends State<DashboardSearchBox> {
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = widget.txtTheme.displayMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 50,
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
                focusNode: _focusNode,
                controller: _controller,
                textAlignVertical: TextAlignVertical.center,
                style: baseStyle,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: AppLocalizations.of(context)!.tDashboardSearch,
                  hintStyle: baseStyle?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            widget.onTextChanged(''); // dynamisch leeren
                            _focusNode.requestFocus();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  widget.onTextChanged(value);
                  setState(() {});
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    widget.onSearchSubmitted(value.trim());
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) _focusNode.unfocus();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context)!.tDashboardExerciseSearchNoInput)),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
