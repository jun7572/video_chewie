import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      home: Page1(),
    )
  );
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            Navigator.push<void>(context, CupertinoPageRoute(builder: (_) => ChewieDemo()));
          },
        )
    );
  }

}

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = 'Chewie Demo'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  VideoPlayerController _videoPlayerController2;
  ChewieController _chewieController;
  double aspectRatio=1;
  CartoonMaterialControls _i2materialControls;
  List<MoreVideo> lists = [];
  int currentVideoIndex=0;
  Future<void> _initializeVideoPlayerFuture;
  bool _disposed = false;
  var _isPlaying = false;
  var _isEndPlaying = false;
  bool _firstFullScreen = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000))
        .then((_){
      setState(() {
        lists.addAll([
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "http://vod.cdn.i2edu.net/eschool/dubit/upload/cartoon/file/2019/12/10/0744228f-98bf-4255-8adc-c04c34b486d6.mp4",  Duration(seconds: 1200), true),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "https://v-cdn.zjol.com.cn/276985.mp4", Duration(seconds: 1200), false),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "http://vod.cdn.i2edu.net/eschool/dubit/upload/cartoon/file/2019/12/10/0744228f-98bf-4255-8adc-c04c34b486d6.mp4",  Duration(seconds: 1200), false),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "https://v-cdn.zjol.com.cn/276985.mp4", Duration(seconds: 1200), false),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "http://vod.cdn.i2edu.net/eschool/dubit/upload/cartoon/file/2019/12/10/0744228f-98bf-4255-8adc-c04c34b486d6.mp4",  Duration(seconds: 1200), false),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "https://v-cdn.zjol.com.cn/276985.mp4", Duration(seconds: 1200), false),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "http://vod.cdn.i2edu.net/eschool/dubit/upload/cartoon/file/2019/12/10/0744228f-98bf-4255-8adc-c04c34b486d6.mp4",  Duration(seconds: 1200), false),
          MoreVideo("0", "http://www.i2edu.cn/images/pic04.png", "https://v-cdn.zjol.com.cn/276985.mp4", Duration(seconds: 1200), false),
        ]);
      });
      _i2materialControls = CartoonMaterialControls(
        enableQuickControl: true,
        moreVideo: lists,
        onTapMoreVideo: (index) {
          print("onTapMoreVideo $index");
          _startPlay(index);
        },
        onTapPrevious: () {
          if (currentVideoIndex - 1 < 0) return;
          _startPlay(currentVideoIndex - 1);
        },
        onTapNext: () {
          if (currentVideoIndex + 1 >= lists.length) return;
          _startPlay(currentVideoIndex + 1);
        },
        onTapLove: () {

        },
      );
      _initializePlay(0);
    });

    _videoPlayerController2 = VideoPlayerController.network(
        'https://v-cdn.zjol.com.cn/276985.mp4')
    ..initialize().then((_){
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void delayEnterFullScreen() async {
    Future.delayed(Duration(milliseconds: 100))
        .then((_){
      _chewieController.toggleFullScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
//                  constraints: BoxConstraints(maxHeight: 200),
                  child: _playView(),
                  color: Colors.black,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _clearPrevious() async {
    await _videoPlayerController1?.pause();
    _videoPlayerController1?.removeListener(_controllerListener);
    return true;
  }

  // tracking status
  void _controllerListener() {
    if (_videoPlayerController1 == null || _disposed) {
      return;
    }
    if (!_videoPlayerController1.value.initialized) {
      return;
    }
    final position =  _videoPlayerController1.value.position;
    final duration = _videoPlayerController1.value.duration;
    if (duration != null && position != null) {
      final isPlaying = position.inMilliseconds < duration.inMilliseconds;
      final isEndPlaying = position.inMilliseconds > 0 &&
          position.inSeconds == duration.inSeconds;

      if (_isPlaying != isPlaying || _isEndPlaying != isEndPlaying) {
        _isPlaying = isPlaying;
        _isEndPlaying = isEndPlaying;
        print(
            "$currentVideoIndex -----> isPlaying=$isPlaying / isCompletePlaying=$isEndPlaying");
        if (isEndPlaying) {
          final isComplete = currentVideoIndex == lists.length - 1;
          if (isComplete) {
            print("played all!!");
          } else {
            _startPlay(currentVideoIndex + 1);
          }
        }
      }
    }
  }

  Future<void> _startPlay(int index) async {
    print("play ---------> $index");
    setState(() {
      _initializeVideoPlayerFuture = null;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_){
        _initializePlay(index);
      });
    });
  }

  Future<void> _initializePlay(int index) async {
    _videoPlayerController1 = VideoPlayerController.network(lists[index].videoUrl);
    _videoPlayerController1.addListener(_controllerListener);

    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        customControls: _i2materialControls,
        fullScreenByDefault: true,
        forceFullScreen: true,
        allowedScreenSleep: false,
        showControls: true,
//        showControlsOnInitialize: true,
    );
    _chewieController?.addListener((){
      if (_videoPlayerController1 != null && !_chewieController.isFullScreen) {
        Navigator.of(context).maybePop();
      }
    });
    _initializeVideoPlayerFuture = _videoPlayerController1.initialize();

    setState(() {
      currentVideoIndex = index;
      for (int i = 0; i < lists.length; i++) {
        lists[i].isSelect = (i == index);
      }
    });
  }

  // play view area
  Widget _playView() {
    // FutureBuilder to display a loading spinner until finishes initializing
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _chewieController.play();
          return AspectRatio(
            aspectRatio: _videoPlayerController1.value.aspectRatio,
            child: Chewie(controller: _chewieController),
          );
        } else {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }


}
