import 'package:flutter/material.dart';

class ToolCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Function function;
  const ToolCard(
      {Key key, @override this.icon, this.color, this.label, this.function})
      : super(key: key);
  @override
  _ToolCard createState() => _ToolCard();
}

class _ToolCard extends State<ToolCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        onTap: widget.function,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.color,
              size: 60,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
