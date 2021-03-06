/*
 * @Author: zhengzeqin
 * @Date: 2022-07-17 22:49:40
 * @LastEditTime: 2022-07-28 22:45:38
 * @Description: your project
 */
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:tw_step_counter/tw_colors.dart';
import 'package:tw_step_counter/tw_step_counter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = TWStepCounterController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KeyboardDismissOnTap(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('example app'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('失去焦点'),
                  onPressed: () {
                    controller.unFocus();
                  },
                ),
                TextButton(
                  child: const Text('获取焦点'),
                  onPressed: () {
                    controller.getFocus();
                  },
                ),
                TextButton(
                  child: const Text('是否输入'),
                  onPressed: () {
                    print('最后是否输入 ${controller.isInputModify}');
                  },
                ),
                SizedBox(
                  width: 323,
                  child: TWStepCounter(
                    unit: '元/天',
                    currentValue: 130,
                    mixValue: 75,
                    maxValue: 250,
                    onTap: (value) {
                      print('点击回调===>$value');
                    },
                    inputTap: (value) {
                      print('输入回调===>$value');
                    },
                    controller: controller,
                    defaultColor: TWColors.tw999999,
                    highlightColor: Colors.yellow,
                    borderLineColor: Colors.orange,
                    // decimal: true,
                    // decimalsCount: 2,
                    valuePadding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
