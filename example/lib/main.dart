/*
 * @Author: zhengzeqin
 * @Date: 2022-07-17 22:49:40
 * @LastEditTime: 2022-07-28 15:59:03
 * @Description: your project
 */
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KeyboardDismissOnTap(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('example app'),
          ),
          body:  Center(
            child: SizedBox(
              width: 323,
              child: TWStepCounter(
                unit: '元/天',
                currentValue: 130,
                mixValue: 75,
                maxValue: 250,
                onTap: (value) {
                  print('点击回调===>$value');
                },
                defaultColor: Colors.red,
                highlightColor: Colors.yellow,
                borderLineColor: Colors.orange,
                valuePadding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
