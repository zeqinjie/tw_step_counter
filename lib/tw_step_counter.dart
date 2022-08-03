/*
 * @Author: zhengzeqin
 * @Date: 2022-07-17 10:51:23
 * @LastEditTime: 2022-08-03 13:50:44
 * @Description: 计数步进器封装
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tw_step_counter/tw_colors.dart';

class TWStepCounterController {
  _TWStepCounterState? _state;
  BuildContext? _context;

  /// 获取焦点
  void getFocus() {
    if (_context != null) {
      _state?.getFocus(_context!);
    }
  }

  /// 失去焦点
  void unFocus() {
    _state?.unFocus();
  }

  /// 隐藏键盘而不丢失文本字段焦点：
  void hideKeyBoard() {
    _state?.hideKeyBoard();
  }

  /// 最好的值是输入还是点击按钮修改
  bool get isInputModify {
    return _state?.isInputModify ?? false;
  }

  /// 手动更新值
  void modifyValue(double value) {
    _state?._modifyValue(value);
  }
}

class TWStepCounter extends StatefulWidget {
  /// 每次按钮点击递增递减值
  final double differValue;

  /// 每次输入倍数，失去焦点时触发
  final double? inputMultipleValue;

  /// 支持最小值
  final double mixValue;

  /// 支持最大值
  final double maxValue;

  /// 按钮宽度
  final double? btnWidth;

  /// 高度
  final double? height;

  /// 值颜色
  final Color? valueColor;

  /// 值字体大小
  final double? valueFontSize;

  /// 单位
  final String? unit;

  /// 单位颜色
  final Color? unitColor;

  /// 单位字体大小
  final double? unitFontSize;

  /// 当前值
  final double? currentValue;

  /// 点击回调
  final void Function(double value)? onTap;

  /// 输入的回调
  final void Function(double value)? inputTap;

  /// 默认颜色
  final Color? iconColor;

  /// 禁止点击颜色
  final Color? forbiddenIconColor;

  /// 保留多少位小数位
  final int decimalsCount;

  /// 高亮颜色
  final Color? highlightColor;

  /// 默认背景色
  final Color? defaultColor;

  /// 边线颜色
  final Color? borderLineColor;

  /// 间隙
  final EdgeInsetsGeometry? padding;

  /// 值的组件间隙
  final EdgeInsetsGeometry? valuePadding;

  /// 控制器
  final TWStepCounterController? controller;

  /// 是否自动限制值范围，默认会
  final bool isUpdateInLimitValue;

  /// 是否支持动画，默认会
  final bool isSupportAnimation;

  /// 是否输入时候更新
  final bool isUpdateInputChange;

  /// 限制输入的长度
  final int? limitLength;

  const TWStepCounter({
    Key? key,
    this.unit,
    this.valueColor,
    this.valueFontSize,
    this.differValue = 5,
    this.inputMultipleValue,
    this.mixValue = 0,
    this.maxValue = 9999999999,
    this.forbiddenIconColor,
    this.iconColor,
    this.btnWidth,
    this.height,
    this.unitColor,
    this.unitFontSize,
    this.padding,
    this.onTap,
    this.inputTap,
    this.currentValue,
    this.decimalsCount = 0,
    this.valuePadding,
    this.defaultColor,
    this.highlightColor,
    this.borderLineColor,
    this.isUpdateInLimitValue = true,
    this.controller,
    this.isSupportAnimation = true,
    this.limitLength,
    this.isUpdateInputChange = true,
  }) : super(key: key);

  @override
  State<TWStepCounter> createState() => _TWStepCounterState();
}

class _TWStepCounterState extends State<TWStepCounter>
    with SingleTickerProviderStateMixin {
  double currentValue = 0.0;

  /// 禁止减
  bool forbiddenAdd = false;

  /// 禁止加
  bool forbiddenReduce = false;

  late AnimationController animationController;
  late TextEditingController textController;

  /// 最好值是输入还是点击修改的
  bool lastIsInput = false;

  FocusNode focusNode = FocusNode();

  late final Animation _scaleAnimation =
      Tween(begin: 1.2, end: 1.0).animate(animationController);
  bool isFirst = true;
  @override
  Widget build(BuildContext context) {
    widget.controller?._context = context;
    return _buildBody();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    currentValue = widget.currentValue ?? 0;
    forbiddenAdd = currentValue >= widget.maxValue;
    forbiddenReduce = currentValue <= widget.mixValue;
    animationController = AnimationController(
      vsync: this, // 垂直同步
      duration: const Duration(milliseconds: 300),
    );
    textController = TextEditingController();
    textController.value = TextEditingValue(
        text: currentValue.toStringAsFixed(widget.decimalsCount));
    focusNode.addListener(
      () {
        if (!focusNode.hasFocus) {
          final res = _handerInputValue(currentValue);
          if (res) {
            _updateValue(isInput: true);
            if (widget.inputTap != null) {
              widget.inputTap!(currentValue);
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildButton(
            isAdd: false,
            onTap: _reduce,
            forbidden: forbiddenReduce,
          ),
          Expanded(
              child: Padding(
            padding: widget.valuePadding ?? EdgeInsets.zero,
            child: _buildContent(),
          )),
          _buildButton(
            onTap: _add,
            forbidden: forbiddenAdd,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    bool isAdd = true,
    GestureTapCallback? onTap,
    bool forbidden = false,
  }) {
    return Material(
      child: Ink(
        width: widget.btnWidth ?? 64,
        height: widget.height ?? 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.5),
          color: widget.defaultColor ?? TWColors.twF5F5F5,
        ),
        child: InkWell(
          onTap: onTap,
          highlightColor: widget.highlightColor ?? TWColors.twE6E6E6,
          child: Icon(
            isAdd ? Icons.add : Icons.remove,
            size: 10,
            color: forbidden
                ? (widget.iconColor ?? TWColors.twCCCCCC)
                : (widget.forbiddenIconColor ?? TWColors.tw4A4A4A),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isSupportAnimation) {
      return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget? child) {
          return _buildValueView(isFirst ? 1.0 : _scaleAnimation.value);
        },
      );
    }
    return _buildValueView(1);
  }

  Container _buildValueView(double scale) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: widget.borderLineColor ?? TWColors.twE6E6E6,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Transform.scale(
              scale: scale,
              child: _buildText(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Text(
              ' ${widget.unit}',
              style: TextStyle(
                fontSize: widget.unitFontSize ?? 16,
                color: widget.unitColor ?? TWColors.tw999999,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildText() {
    return IntrinsicWidth(
      child: Container(
        alignment: Alignment.center,
        height: widget.height ?? 30,
        child: TextField(
          keyboardType: TextInputType.numberWithOptions(
              decimal: widget.decimalsCount > 0),
          textInputAction: TextInputAction.done,
          inputFormatters: <TextInputFormatter>[
            TWStepCounterFormatter(
                decimals: widget.decimalsCount,
                min: widget.mixValue,
                max: widget.maxValue),
            if (widget.limitLength != null)
              LengthLimitingTextInputFormatter(widget.limitLength!) //限制长度
          ],
          maxLines: 1,
          controller: textController,
          focusNode: focusNode,
          autocorrect: false,
          style: TextStyle(
            fontSize: widget.valueFontSize ?? 20,
            fontWeight: FontWeight.bold,
            color: widget.valueColor ?? TWColors.tw333333,
          ),
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              contentPadding: EdgeInsets.only(top: 0, bottom: 0)),
          onChanged: (value) {
            lastIsInput = true;
            final double _value = _fetchValue(value);
            if (currentValue != _value) {
              currentValue = _value;
              if (widget.isUpdateInputChange) {
                _updateValue(isInput: true);
              }
              if (widget.inputTap != null) {
                widget.inputTap!(currentValue);
              }
            }
          },
        ),
      ),
    );
  }

  /* Public Method */
  //获取焦点
  void getFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  //失去焦点
  void unFocus() {
    focusNode.unfocus();
  }

  //隐藏键盘而不丢失文本字段焦点：
  void hideKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  bool get isInputModify {
    return lastIsInput;
  }

  /* Priavte Method */
  double _fetchValue(String txt) {
    try {
      return double.parse(txt);
    } catch (e) {
      return 0;
    }
  }

  /// 相加
  void _add() {
    setState(() {
      _caculator();
    });
  }

  /// 相减
  void _reduce() {
    setState(() {
      _caculator(isAdd: false);
    });
  }

  void _caculator({bool isAdd = true}) {
    var vaule = 0.0;
    lastIsInput = false;
    if (isAdd) {
      vaule = currentValue + widget.differValue;
      if (widget.isUpdateInLimitValue) {
        if (vaule <= widget.maxValue) {
          currentValue = vaule;
        } else {
          currentValue = widget.maxValue;
        }
      } else {
        currentValue = vaule;
      }
    } else {
      vaule = currentValue - widget.differValue;
      if (widget.isUpdateInLimitValue) {
        if (vaule >= widget.mixValue) {
          currentValue = vaule;
        } else {
          currentValue = widget.mixValue;
        }
      } else {
        currentValue = vaule;
      }
    }
    _updateValue(isAdd: isAdd);

    if (vaule < widget.maxValue) {
      forbiddenAdd = false;
    } else {
      forbiddenAdd = true;
    }

    if (vaule > widget.mixValue) {
      forbiddenReduce = false;
    } else {
      forbiddenReduce = true;
    }
    if (widget.onTap != null) {
      widget.onTap!(vaule);
    }
  }

  /// 失去焦点时候处理输入值
  bool _handerInputValue(double vaule) {
    var isModify = false;
    if (widget.isUpdateInLimitValue) {
      if (vaule > widget.maxValue) {
        currentValue = widget.maxValue;
        isModify = true;
      }
      if (vaule < widget.mixValue) {
        currentValue = widget.mixValue;
        isModify = true;
      }
    }

    /// 限制输入倍数
    if (widget.inputMultipleValue != null) {
      if (currentValue % widget.inputMultipleValue! != 0) {
        for (var i = currentValue; i <= widget.maxValue; i++) {
          if (i % widget.inputMultipleValue! == 0) {
            if (currentValue != i) {
              currentValue = i;
              isModify = true;
              return isModify;
            }
          }
        }

        for (var i = currentValue; i >= widget.mixValue; i--) {
          if (i % widget.inputMultipleValue! == 0) {
            if (currentValue != i) {
              currentValue = i;
              isModify = true;
              return isModify;
            }
          }
        }
      }
    }
    return isModify;
  }

  /// 手动更新值
  void _modifyValue(double value) {
    currentValue = value;
    _updateTextFieldValue();
  }

  /// 更新值
  void _updateValue({
    bool isAdd = true,
    bool isInput = false,
  }) {
    isFirst = false;
    if (widget.isSupportAnimation) {
      if (!isInput) {
        if ((isAdd & !forbiddenAdd) || (!isAdd & !forbiddenReduce)) {
          animationController.reset();
          animationController.forward();
        }
      } else {
        animationController.reset();
        animationController.forward();
      }
    }
    _updateTextFieldValue();
  }

  void _updateTextFieldValue() {
    final txt = currentValue.toStringAsFixed(widget.decimalsCount);
    textController.value = TextEditingValue(
      text: txt,
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: txt.length,
        ),
      ),
    );
  }
}

class TWStepCounterFormatter extends TextInputFormatter {
  TWStepCounterFormatter(
      {required this.min, required this.max, required this.decimals});

  final double min;
  final double max;
  final int decimals;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final input = newValue.text;
    if (input.isEmpty) {
      return newValue;
    }

    final minus = input.startsWith('-');
    if (minus && min >= 0) {
      return oldValue;
    }

    final plus = input.startsWith('+');
    if (plus && max < 0) {
      return oldValue;
    }

    if ((minus || plus) && input.length == 1) {
      return newValue;
    }

    if (decimals <= 0 && !_validateValue(int.tryParse(input))) {
      return oldValue;
    }

    if (decimals > 0 && !_validateValue(double.tryParse(input))) {
      return oldValue;
    }

    final dot = input.lastIndexOf('.');
    if (dot >= 0 && decimals < input.substring(dot + 1).length) {
      return oldValue;
    }

    return newValue;
  }

  bool _validateValue(num? value) {
    if (value == null) {
      return false;
    }

    if (value >= min && value <= max) {
      return true;
    }

    if (value >= 0) {
      return value <= max;
    } else {
      return value >= min;
    }
  }
}
