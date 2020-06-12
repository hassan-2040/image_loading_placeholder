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

class _ImageLoaderState extends State<ImageLoader> {
  Image _image;
  ImageStream _imageStream;
  ImageStreamListener _imageStreamListener;
  bool _loading = true;

  @override
  void initState() {
    _image = Image.network(
      'https://images.unsplash.com/photo-1591879647848-598422afbc6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1879&q=80',
      fit: BoxFit.cover,
    );

    //changing loading state to false once streamListener finishes
    _imageStreamListener = ImageStreamListener(
      (_, __) {
        setState(() {
          _loading = false;
        });
      },
    );
    _imageStream = _image.image.resolve(ImageConfiguration()); //assigning stream of the image

    //assigning listener to the stream
    _imageStream.addListener(
      _imageStreamListener,
    );
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
        child: _loading ? LoadingWidget() : _image,
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
        color: Colors.blue,
        size: 60,
      ),
    );
  }
}
