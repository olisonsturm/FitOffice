import 'package:flutter/material.dart';
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
  DashboardSearchBoxState createState() => DashboardSearchBoxState();
}

class DashboardSearchBoxState extends State<DashboardSearchBox> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: tDashboardSearch,
                    hintStyle: widget.txtTheme.displayMedium?.apply(color: Colors.white),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _focusNode.unfocus();
                        });
                      },
                    )
                        : null,
                  ),
                  autofocus: false,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onSearchSubmitted(value);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte gib einen Suchbegriff ein.')),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
