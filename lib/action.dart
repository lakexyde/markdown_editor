import 'dart:async';

import 'package:flutter/material.dart';

///  Action image button of markdown editor.
class ActionImage extends StatefulWidget {
  ActionImage({
    Key key,
    this.type,
    this.tap,
    this.imageSelect,
    this.color,
    this.getCursorPosition,
  })  : assert(color != null),
        super(key: key);

  final ActionType type;
  final TapFinishCallback tap;
  final ImageSelectCallback imageSelect;
  final GetCursorPosition getCursorPosition;

  final Color color;

  @override
  ActionImageState createState() => ActionImageState();
}

class ActionImageState extends State<ActionImage> {
  int _getImageIconCode() {
    return _defaultImageAttributes
        .firstWhere((img) => img.type == widget.type)
        ?.iconCode;
  }

  void _disposeAction() {
    var firstWhere =
        _defaultImageAttributes.firstWhere((img) => img.type == widget.type);
    if (widget.tap != null && firstWhere != null) {
      if (firstWhere.type == ActionType.image) {
        var cursorPosition = widget?.getCursorPosition();
        if (widget.imageSelect != null) {
          widget.imageSelect().then(
            (str) {
              debugPrint('Image select $str');
              if (str != null && str.isNotEmpty) {
                // 延迟执行它，等待TextFiled获取焦点
                // 否则将无法成功插入文本
                Timer(const Duration(milliseconds: 200), () {
                  widget.tap(widget.type, '![]($str)', 0, cursorPosition);
                });
              }
            },
            onError: print,
          );
          return;
        }
      }
      widget.tap(widget.type, firstWhere.text, firstWhere.positionReverse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: _defaultImageAttributes
          .firstWhere((img) => img.type == widget.type)
          ?.tip,
      child: IconButton(
        icon: Icon(
          IconData(
            _getImageIconCode(),
            fontFamily: 'MyIconFont',
            fontPackage: 'markdown_editor',
          ),
          color: widget.color,
        ),
        onPressed: _disposeAction,
      ),
    );
  }
}

const _defaultImageAttributes = <ImageAttributes>[
  ImageAttributes(
    type: ActionType.undo,
    iconCode: 0xe907,
    tip: '撤销',
  ),
  ImageAttributes(
    type: ActionType.redo,
    iconCode: 0xe874,
    tip: '恢复',
  ),
  ImageAttributes(
    type: ActionType.image,
    iconCode: 0xe7ac,
    text: '![]()',
    tip: '图片',
    positionReverse: 3,
  ),
  ImageAttributes(
    type: ActionType.link,
    iconCode: 0xe7d8,
    text: '[]()',
    tip: '链接',
    positionReverse: 3,
  ),
  ImageAttributes(
    type: ActionType.fontBold,
    iconCode: 0xe757,
    text: '****',
    tip: '加粗',
    positionReverse: 2,
  ),
  ImageAttributes(
    type: ActionType.fontItalic,
    iconCode: 0xe762,
    text: '**',
    tip: '斜体',
    positionReverse: 1,
  ),
  ImageAttributes(
    type: ActionType.textQuote,
    iconCode: 0xe768,
    text: '\n>',
    tip: '文字引用',
    positionReverse: 0,
  ),
  ImageAttributes(
    type: ActionType.list,
    iconCode: 0xe764,
    text: '\n- ',
    tip: '无序列表',
    positionReverse: 0,
  ),
  ImageAttributes(
    type: ActionType.h4,
    iconCode: 0xe75e,
    text: '\n#### ',
    tip: '四级标题',
    positionReverse: 0,
  ),
  ImageAttributes(
    type: ActionType.h5,
    iconCode: 0xe75f,
    text: '\n##### ',
    tip: '五级标题',
    positionReverse: 0,
  ),
  ImageAttributes(
    type: ActionType.h1,
    iconCode: 0xe75b,
    text: '\n# ',
    tip: '一级标题',
    positionReverse: 0,
  ),
  ImageAttributes(
    type: ActionType.h2,
    iconCode: 0xe75c,
    text: '\n## ',
    tip: '二级标题',
    positionReverse: 0,
  ),
  ImageAttributes(
    type: ActionType.h3,
    iconCode: 0xe75d,
    text: '\n### ',
    tip: '三级标题',
    positionReverse: 0,
  ),
];

enum ActionType {
  undo,
  redo,
  image,
  link,
  fontBold,
  fontItalic,
  fontDeleteLine,
  textQuote,
  list,
  h1,
  h2,
  h3,
  h4,
  h5,
}

class ImageAttributes {
  const ImageAttributes({
    this.tip = '',
    this.text,
    this.positionReverse,
    @required this.type,
    @required this.iconCode,
  })  : assert(iconCode != null),
        assert(type != null);

  final ActionType type;
  final int iconCode;
  final String tip;
  final String text;
  final int positionReverse;
}

/// Call this method after clicking the [ActionImage] and completing a series of actions.
/// [text] Adding text.
/// [position] Cursor position that reverse order.
/// [cursorPosition] Will start insert text at this position.
typedef void TapFinishCallback(
  ActionType type,
  String text,
  int positionReverse, [
  int cursorPosition,
]);

/// Call this method after clicking the ImageAction.
/// return your select image path.
typedef Future<String> ImageSelectCallback();

/// Get the current cursor position.
typedef int GetCursorPosition();
