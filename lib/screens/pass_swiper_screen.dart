import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:passbox/model/pass_info.dart';
import 'package:passbox/model/provider.dart';
import 'package:passbox/widgets/pass_card.dart';

class PassSwiperScreen extends StatefulWidget {
  final List<PassInfo> list;
  final int currentIndex;
  final SwiperController swiperController;
  const PassSwiperScreen(
      {Key key,
      @required this.list,
      this.currentIndex = 0,
      this.swiperController})
      : super(key: key);
  @override
  _PassSwiperScreen createState() => new _PassSwiperScreen();
}

class _PassSwiperScreen extends State<PassSwiperScreen> {
  SwiperController _swiperController;
  int length;
  @override
  void initState() {
    length = widget.list.length;
    _swiperController = SwiperController();
    super.initState();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: StreamBuilder(
            initialData: widget.list,
            stream: PkpassProvider.of(context).value.passesList,
            builder:
                (BuildContext context, AsyncSnapshot<List<PassInfo>> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.isNotEmpty) {
                return new Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Swiper(
                    loop: false,
                    viewportFraction: 0.9,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PassCard(
                        passInfo: snapshot.data[index],
                      );
                    },
                    index: widget.currentIndex,
                    controller: _swiperController,
                    pagination: new SwiperPagination(
                      alignment: Alignment.topCenter,
                      builder: RectSwiperPaginationBuilder(
                          // activeSize: Size(30, 7),
                          // size: Size(20,7),
                          activeColor: Colors.black,
                          color: Colors.white),
                    ),
                    onIndexChanged: (value) {
                      
                       widget.swiperController.move(value, animation: false);
                      
                    },
                    
                  ),
                );
              }
              Future.delayed(Duration(milliseconds: 500))
                  .then((value) => Navigator.pop(context));
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
