/*
 * @Author: zhengzeqin
 * @Date: 2022-07-17 10:51:23
 * @LastEditTime: 2022-07-28 22:43:48
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
}

class TWStepCounter extends StatefulWidget {
  /// 每次递增递减值
  final double differValue;

  /// 支持最小值
  final double mixValue;

  /// 支持最大值
  final double maxValue;

  /// 按钮宽度
  final double? btnWidth;

  /// 按钮高度
  final double? btnHeight;

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

  /// 多少位小数位
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

  final TWStepCounterController? controller;

  final bool? decimal;

  const TWStepCounter({
    Key? key,
    this.unit,
    this.valueColor,
    this.valueFontSize,
    this.differValue = 5,
    this.mixValue = 0,
    this.maxValue = 9999999999,
    this.forbiddenIconColor,
    this.iconColor,
    this.btnWidth,
    this.btnHeight,
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
    this.controller,
    this.decimal = false,
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
          _handerValue(currentValue);
          _updateValue();
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
        height: widget.btnHeight ?? 30,
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
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: isFirst ? 1.0 : _scaleAnimation.value,
                child: _buildText(),
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                ' ${widget.unit}',
                style: TextStyle(
                  fontSize: widget.unitFontSize ?? 16,
                  color: widget.unitColor ?? TWColors.tw999999,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return IntrinsicWidth(
      child: TextField(
        keyboardType:
            TextInputType.numberWithOptions(decimal: widget.decimal ?? false),
        textInputAction: TextInputAction.done,
        maxLines: 1,
        controller: textController,
        focusNode: focusNode,
        style: TextStyle(
          fontSize: widget.valueFontSize ?? 20,
          fontWeight: FontWeight.bold,
          color: widget.valueColor ?? TWColors.tw333333,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          lastIsInput = true;
          final double _value = _fetchValue(value);
          currentValue = _value;
          _updateValue(isInput: true);
          if (widget.inputTap != null) {
            widget.inputTap!(currentValue);
          }
        },
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
      if (vaule <= widget.maxValue) {
        currentValue = vaule;
      } else {
        currentValue = widget.maxValue;
      }
    } else {
      vaule = currentValue - widget.differValue;
      if (vaule >= widget.mixValue) {
        currentValue = vaule;
      } else {
        currentValue = widget.mixValue;
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

  void _handerValue(double vaule) {
    if (vaule > widget.maxValue) {
      currentValue = widget.maxValue;
    }
    if (vaule < widget.mixValue) {
      currentValue = widget.mixValue;
    }
  }

  /// 更新值
  void _updateValue({
    bool isAdd = true,
    bool isInput = false,
  }) {
    isFirst = false;
    if (!isInput) {
      if ((isAdd & !forbiddenAdd) || (!isAdd & !forbiddenReduce)) {
        animationController.reset();
        animationController.forward();
      }
    } else {
      animationController.reset();
      animationController.forward();
    }

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
