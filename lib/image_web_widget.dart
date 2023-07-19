// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui' as ui;

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/image_size_getter.dart' as sizegetter;
import 'package:provider/provider.dart';
import 'package:image_web_app/flutter_drawing_board/src/drawing_controller.dart';
import 'package:image_web_app/provider.dart';
import 'flutter_drawing_board/src/drawing_board.dart';

class ImageWebWidget extends StatefulWidget {
  const ImageWebWidget({
    Key? key,
    this.initialData,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonColor,
    this.buttonText,
    this.buttonBorderRadius,
    this.buttonTextStyle,
    this.buttonAndListSpacing,
    this.noUploadedImagesWidget,
    this.noUploadedImagestextTextStyle,
    this.dialogBackGroundColor,
    this.circularProgressIndicatorColor,
    this.dialogButtonText,
    this.dialogbuttonHeight,
    this.dialogbuttonWidth,
    this.dialogbuttonColor,
    this.dialogCancelIconColor,
    this.dialogbuttonBorderRadius,
    this.dialogbuttonTextStyle,
  }) : super(key: key);
  final List<String>? initialData;
  final double? buttonHeight;
  final double? buttonWidth;
  final Color? buttonColor;
  final String? buttonText;
  final double? buttonBorderRadius;
  final TextStyle? buttonTextStyle;
  final double? buttonAndListSpacing;
  final Widget? noUploadedImagesWidget;
  final TextStyle? noUploadedImagestextTextStyle;
  final Color? dialogBackGroundColor;
  final Color? circularProgressIndicatorColor;
  final String? dialogButtonText;
  final double? dialogbuttonHeight;
  final double? dialogbuttonWidth;
  final Color? dialogbuttonColor;
  final double? dialogbuttonBorderRadius;
  final TextStyle? dialogbuttonTextStyle;
  final Color? dialogCancelIconColor;

  @override
  State<ImageWebWidget> createState() => _ImageWebWidgetState();
}

class _ImageWebWidgetState extends State<ImageWebWidget> {
  Uint8List? pickedImage;
  Uint8List? editedImage;
  ImageWebProvider? _imageWebProvider;
  ui.Image? myImage;
  var pickedImageName;
  final DrawingController _drawingController = DrawingController();
  bool _isLeftArrowDisabled = true;
  bool _isRightArrowDisabled = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _imageWebProvider
        ?.setUploadedImagesListWithInitialList(widget.initialData ?? []);
    FastCachedImageConfig.init();
    _scrollController.addListener(_updateArrowVisibility);
  }

  Future<void> _pickImageFromDevice() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          dialogTitle: 'Pick an image to edit',
          allowMultiple: false,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
          allowCompression: true);
    } on PlatformException catch (e) {
      print("$e");
    }
    if (result != null) {
      pickedImage = result.files.first.bytes;
      pickedImageName = result.files.first.name;
      //setBackground();
      setState(() {});
      await imageEditDialog(pickedImage: pickedImage!);
    }
  }

  // Dialog which displays image with editing tools
  Future<void> imageEditDialog({
    required Uint8List pickedImage,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        var height = MediaQuery.sizeOf(context).height;
        var width = MediaQuery.sizeOf(context).width;
        bool smallScreen = width < 600;
        bool mediumScreen = width < 896 && width > 600;
        final memoryImageSize = sizegetter.ImageSizeGetter.getSize(
            sizegetter.MemoryInput(pickedImage));
        // print(
        //     'memoryImageSize = $memoryImageSize, height: ${memoryImageSize.height},width: ${memoryImageSize.width}');
        // bool largeScreen = width > 896;
        // print("Screen width: $width");
        return Padding(
          padding: smallScreen
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 30)
              : mediumScreen
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                width: 0.3,
                color: widget.dialogCancelIconColor ?? Colors.black,
              ),
            ),
            color: widget.dialogBackGroundColor ?? Colors.white,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _drawingController.clear();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: smallScreen
                          ? width * 0.9
                          : mediumScreen
                              ? width * 0.9
                              : width * 0.9,
                      height: smallScreen
                          ? height * 0.7
                          : mediumScreen
                              ? height * 0.75
                              : height * 0.75,
                      child: DrawingBoard(
                        controller: _drawingController,
                        panAxis: PanAxis.free,
                        background: Image.memory(
                          pickedImage,
                          fit: BoxFit.contain,
                          scale: (memoryImageSize.width > 12000) ? 4 : 2,
                        ),
                        showDefaultActions: true,
                        showDefaultTools: true,
                      ),
                    ),
                    SizedBox(
                      height: smallScreen
                          ? 30
                          : mediumScreen
                              ? 35
                              : 40,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              widget.dialogbuttonColor ??
                                  Colors.orange.shade500),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  widget.dialogbuttonBorderRadius ?? 10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _getImageDataAfterDrawing();
                          _drawingController.clear();
                        },
                        child: SizedBox(
                          height: widget.dialogbuttonHeight ?? 50,
                          width: widget.dialogbuttonWidth ?? 80,
                          child: Center(
                            child: Text(
                              widget.dialogButtonText ?? "Save",
                              style: widget.dialogbuttonTextStyle ??
                                  const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Gets image when save button is clicked from the drawing controller and saves it to storage
  Future<void> _getImageDataAfterDrawing() async {
    _imageWebProvider?.setIsLoading(true);

    editedImage =
        (await _drawingController.getImageData())?.buffer.asUint8List();

    if (editedImage != null) {
      _imageWebProvider?.saveImageToFirebase(editedImage!, pickedImageName);
    } else {
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imageWebProvider = Provider.of(context, listen: false);
  }

  void _updateArrowVisibility() {
    setState(() {
      _isLeftArrowDisabled = _scrollController.position.pixels <= 0;
      _isRightArrowDisabled = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollToPrevious() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToNext() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Consumer<ImageWebProvider>(
            builder: (context, provider, child) => SizedBox(
              height: height * 0.3,
              child: (!provider.isLoading && provider.uploadedImages.isNotEmpty)
                  ? Stack(
                      children: [
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.uploadedImages.length,
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Card(
                                shape: const RoundedRectangleBorder(),
                                elevation: 8,
                                clipBehavior: Clip.none,
                                borderOnForeground: false,
                                child: FastCachedImage(
                                  url: provider.uploadedImages[index],
                                  // loadingBuilder: (p0, p1) => const Center(
                                  //   child: CircularProgressIndicator(
                                  //     color: Colors.black,
                                  //   ),
                                  // ),
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                elevation: 10,
                                child: IconButton(
                                  icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded),
                                  onPressed: _isLeftArrowDisabled
                                      ? null
                                      : _scrollToPrevious,
                                ),
                              ),
                              Material(
                                elevation: 10,
                                child: IconButton(
                                  icon: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                  onPressed: _isRightArrowDisabled
                                      ? null
                                      : _scrollToNext,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: (provider.isLoading)
                          ? CircularProgressIndicator(
                              color: widget.circularProgressIndicatorColor ??
                                  Colors.orange.shade500)
                          : Material(
                              type: MaterialType.transparency,
                              child: widget.noUploadedImagesWidget ??
                                  Text(
                                    "Upload Images to display here",
                                    style:
                                        widget.noUploadedImagestextTextStyle ??
                                            const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                  ),
                            ),
                    ),
            ),
          ),
          SizedBox(height: widget.buttonAndListSpacing ?? 120),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                  widget.buttonColor ?? Colors.orange.shade500),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.buttonBorderRadius ?? 10),
                ),
              ),
              elevation: const MaterialStatePropertyAll(10),
              shadowColor: MaterialStatePropertyAll(Colors.grey.shade500),
            ),
            onPressed: () {
              _pickImageFromDevice();
            },
            child: SizedBox(
              height: widget.buttonHeight ?? height * 0.07,
              width: widget.buttonWidth ?? width * 0.25,
              child: Center(
                child: Text(
                  widget.buttonText ?? "Upload Image",
                  style: widget.buttonTextStyle ??
                      const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 // width: smallScreen
                            //     ? width * 0.85
                            //     : mediumScreen
                            //         ? width * 0.7
                            //         : width * 0.7,
                            // height: smallScreen
                            //     ? height * 0.4
                            //     : mediumScreen
                            //         ? height * 0.6
                            //         : height * 0.6,