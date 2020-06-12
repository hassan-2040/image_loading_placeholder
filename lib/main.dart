import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Loading Placeholder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body: ImageLoader()),
    );
  }
}

class ImageLoader extends StatefulWidget {
  @override
  _ImageLoaderState createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader>
    with SingleTickerProviderStateMixin {
  Image _image;
  ImageStream _imageStream;
  ImageStreamListener _imageStreamListener;
  bool _loading = true;

  AnimationController _fadeInController;
  Animation<double> _fadeInValue;

  @override
  void initState() {
    _image = Image.network(
      'https://images.unsplash.com/photo-1591879647848-598422afbc6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1879&q=80',
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace stackTrace) {
        return Text(
          'Could not load image',
          textAlign: TextAlign.center,
        );
      },
    );

    //changing loading state to false once streamListener finishes and fading in the image
    _imageStreamListener = ImageStreamListener(
      (_, __) {
        setState(() {
          _loading = false;
          _fadeInController.forward();
        });
      },
    );
    _imageStream = _image.image
        .resolve(ImageConfiguration()); //assigning stream of the image

    //assigning listener to the stream
    _imageStream.addListener(
      _imageStreamListener,
    );

    _fadeInController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    final _curve = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    );

    _fadeInValue = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_curve)
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    _imageStream.removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200,
        width: 300,
        color: Colors.grey,
        child: _loading
            ? LoadingWidget()
            : FadeTransition(
                opacity: _fadeInValue,
                child: _image,
              ),
      ),
    );
  }
}

class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool _visible = false;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      _callSetState();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _callSetState() {
    setState(() {
      _visible = !_visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.1,
      duration: Duration(milliseconds: 500),
      child: Icon(
        Icons.image,
        color: Colors.white,
        size: 60,
      ),
    );
  }
}
