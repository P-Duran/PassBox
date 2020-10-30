import 'package:flutter/material.dart';

class SimpleAccountMenu extends StatefulWidget {
  final List<Icon> icons;
  final List<String> iconText;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final double menuIconSize;
  final double selectorIconSize;
  final ValueChanged<int> onChange;

  const SimpleAccountMenu({
    Key key,
    this.icons,
    this.borderRadius,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.onChange,
    this.iconText,
    this.menuIconSize = 24,
    this.selectorIconSize = 24,
  })  : assert(icons != null),
        super(key: key);
  @override
  _SimpleAccountMenuState createState() => _SimpleAccountMenuState();
}

class _SimpleAccountMenuState extends State<SimpleAccountMenu>
    with SingleTickerProviderStateMixin {
  GlobalKey _key;
  bool isMenuOpen = false;
  Offset buttonPosition;
  Size buttonSize;
  OverlayEntry _overlayEntry;
  BorderRadius _borderRadius;
  AnimationController _animationController;
  int iconIndex = 0;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _borderRadius = widget.borderRadius ?? BorderRadius.circular(20);
    _key = LabeledGlobalKey("button_icon");
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  findButton() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry.remove();
    _animationController.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    _animationController.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry);
    isMenuOpen = !isMenuOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
      ),
      child: Row(
        children: [
          IconButton(
            icon: widget.icons[iconIndex],
            color: widget.iconColor,
            iconSize: widget.selectorIconSize,
            onPressed: () {
              if (isMenuOpen) {
                closeMenu();
              } else {
                openMenu();
              }
            },
          ),
        ],
      ),
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    closeMenu();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Positioned(
              top: buttonPosition.dy + buttonSize.height,
              left: buttonPosition.dx - 100,
              child: Card(
                elevation: 10,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    height: widget.icons.length * buttonSize.height,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: _borderRadius,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.icons.length, (index) {
                        return InkWell(
                          onTap: () {
                            widget.onChange(index);
                            iconIndex = index;
                            closeMenu();
                          },
                          child: Container(
                            height: buttonSize.height,
                            width: 155,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 5, left: 15),
                                  child: widget.iconText[index] == "none"
                                      ? Icon(
                                          Icons.remove,
                                          color: widget.iconColor,
                                        )
                                      : Icon(widget.icons[index].icon,
                                          size: widget.menuIconSize),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5, right: 15),
                                  child: Text(
                                    widget.iconText[index],
                                    style:
                                        TextStyle(color: Colors.blueGrey[700]),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
