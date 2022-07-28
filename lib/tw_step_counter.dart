/*
 * @Author: zhengzeqin
 * @Date: 2022-07-17 10:51:23
 * @LastEditTime: 2022-07-28 19:17:54
 * @Description: 计数步进器封装
 */
import 'package:flutter/material.dart';
import 'package:tw_step_counter/tw_colors.dart';

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

  late AnimationController _controller;
  final textController = TextEditingController();

  FocusNode focusNode = FocusNode();

  late final Animation _scaleAnimation =
      Tween(begin: 1.2, end: 1.0).animate(_controller);
  bool isFirst = true;
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  @override
  void initState() {
    super.initState();
    currentValue = widget.currentValue ?? 0;
    forbiddenAdd = currentValue >= widget.maxValue;
    forbiddenReduce = currentValue <= widget.mixValue;
    _controller = AnimationController(
      vsync: this, // 垂直同步
      duration: const Duration(milliseconds: 300),
    );
    textController.value = TextEditingValue(
        text: currentValue.toStringAsFixed(widget.decimalsCount));
  }

  @override
  void dispose() {
    _controller.dispose();
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
      animation: _controller,
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
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        controller: textController,
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
          final _value = double.parse(value);
          currentValue = _value;
          _animation();
        },
        onSubmitted: ((value) => print('onSubmitted ===> $value')),
      ),
    );
  }

  /// Priavte Method **/
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
    if (isAdd) {
      vaule = currentValue + widget.differValue;
      if (vaule <= widget.maxValue) {
        currentValue = vaule;
        _animation();
      }
    } else {
      vaule = currentValue - widget.differValue;
      if (vaule >= widget.mixValue) {
        currentValue = vaule;
        _animation();
      }
    }

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

  void _animation() {
    _controller.reset();
    _controller.forward();
    isFirst = false;
    textController.value = TextEditingValue(
        text: currentValue.toStringAsFixed(widget.decimalsCount));
  }
}
