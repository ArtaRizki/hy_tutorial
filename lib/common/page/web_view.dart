import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/utils.dart';
import '../helper/constant.dart';


class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  WebViewPage(this.title, this.url);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: CustomAppBar.appBar(context, widget.title,
      //     isCenter: true, isLeading: true, color: Colors.black),
      appBar: (widget.title != "Panduan Pengguna")
          ? Utils.appBar(widget.title)
          : null,
      body: InkWell(
        onDoubleTap: () {
          ////
        },
        onLongPress: () {
          /////
        },
        child: (widget.title != "Panduan Pengguna")
            ? WebViewWidget(controller: controller)
            : Container(
                color: Constant.primaryColor,
                child: SafeArea(
                  left: false,
                  right: false,
                  bottom: false,
                  child: WebViewWidget(controller: controller),
                ),
              ),
      ),
    );
  }
}
