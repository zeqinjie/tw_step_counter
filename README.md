<!--
 * @Author: zhengzeqin
 * @Date: 2022-07-18 11:14:42
 * @LastEditTime: 2022-07-18 11:48:36
 * @Description: your project
-->
# tw_step_counter

A Simple step caculator 

## introduce

![](https://github.com/zeqinjie/tw_step_counter/blob/main/assets/1.gif)

## Use
```
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
```

```dart
 TWStepCounter(
              unit: '元/天',
              currentValue: 100,
              mixValue: 75,
              maxValue: 250,
              defaultColor: Colors.red,
              highlightColor: Colors.yellow,
              borderLineColor: Colors.orange,
              valuePadding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            )
```

