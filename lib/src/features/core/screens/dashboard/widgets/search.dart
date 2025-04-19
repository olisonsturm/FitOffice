import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import '../../../../../constants/text_strings.dart';

class DashboardSearchBox extends StatefulWidget {
  const DashboardSearchBox({
    super.key,
    required this.txtTheme,
    required this.onSearchSubmitted,
  });

  final TextTheme txtTheme;
  final void Function(String) onSearchSubmitted;

  @override
  _DashboardSearchBoxState createState() => _DashboardSearchBoxState();
}

class _DashboardSearchBoxState extends State<DashboardSearchBox> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  DbController dbController = DbController();
  List<String> _allExercises = [];
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    dbController.getAllExerciseNames().then((names) {
      setState(() {
        _allExercises = names;
      });
    });

    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final input = _controller.text.toLowerCase();
    setState(() {
      _suggestions = _allExercises
          .where((name) =>
              name.toLowerCase().contains(input) ||
              name.similarityTo(input) > 0.4)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: tDashboardSearch,
                    hintStyle: widget.txtTheme.displayMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _controller.clear();
                                _focusNode.unfocus();
                                _suggestions.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  autofocus: false,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onSearchSubmitted(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (_controller.text.isNotEmpty && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _suggestions[index],
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  onTap: () {
                    _controller.text = _suggestions[index];
                    widget.onSearchSubmitted(_suggestions[index]);
                    setState(() {
                      _suggestions.clear();
                      _focusNode.unfocus();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
