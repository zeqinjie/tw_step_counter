/*
 * @Author: zhengzeqin
 * @Date: 2022-07-17 22:49:40
 * @LastEditTime: 2022-08-03 16:14:10
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
                TextButton(
                  child: const Text('更新值为 100'),
                  onPressed: () {
                    controller.modifyValue(100);
                  },
                ),
                SizedBox(
                  width: 300,
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
                    addForbiddenIcon: 'assets/forbidden_add.png',
                    addIcon: 'assets/add.png',
                    reduceForbiddenIcon: 'assets/forbidden_reduce.png',
                    reduceIcon: 'assets/reduce.png',
                    defaultColor: TWColors.twF5F5F5,
                    highlightColor: Colors.yellow,
                    borderLineColor: Colors.red,
                    inputMultipleValue: 5,
                    // limitLength: 8,
                    // height: 70,
                    // isUpdateInLimitValue: false,
                    // isSupportAnimation: false,
                    decimalsCount: 2,
                    btnWidth: 64,
                    height: 30,
                    isUpdateInputChange: false,
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
