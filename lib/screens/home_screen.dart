import 'package:calctraining/screens/test_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DropdownMenuItem<int>> _menuItems = List(); //クラスの中で使うitemリストのコンストラクタ
  int _numberOfQuestions = 0; //なるべく変数初期値はアプリ落ちないために入れること

  @override
  void initState() {
    //10,20,30はhome画面で１度選んだら変わらないので、initStateに設置(buildの前)
    super.initState();
    setMenuItems(); //メソッド作った
    _numberOfQuestions =
        _menuItems[0].value; //選択肢初期値をmenuItems内の値.valueとしないとエラー（この場合10を選択初期値）
  }

  void setMenuItems() {
    //itemリスト(_menuItems)へ値を追加

    //1~3はどれも一緒

    //1. addメソッド（普通）
//    _menuItems.add(DropdownMenuItem(value: 10, child: Text(10.toString()),));
//    _menuItems.add(DropdownMenuItem(value: 20, child: Text(20.toString()),));
//    _menuItems.add(DropdownMenuItem(value: 30, child: Text(30.toString()),));

    //2.addメソッド (Cascade Notation)
    _menuItems //Cascade Notationの書き方
      //DropdownMenuItemのプロパティは、valueに選択肢の値そのものを入れてはchildには表示させるものを入れる
      //Text内の数値を文字列にしないとエラー
      ..add(DropdownMenuItem(
        value: 10,
        child: Text(10.toString()),
      ))
      ..add(DropdownMenuItem(
        value: 20,
        child: Text(20.toString()),
      ))
      ..add(DropdownMenuItem(
        value: 30,
        child: Text(30.toString()),
      ));

    //通常のListの書き方
//    _menuItems =
//    [ DropdownMenuItem(value: 10, child: Text(10.toString()),),
//      DropdownMenuItem(value: 20, child: Text(20.toString()),),
//      DropdownMenuItem(value: 20, child: Text(20.toString()),)];
  }

  @override
  Widget build(BuildContext context) {
//    var screenWidth = MediaQuery.of(context).size.width;
//    var screenHeight = MediaQuery.of(context).size.height;
//    print("横幅の論理ピクセル：$screenWidth");
//    print("タテ幅の論理ピクセル：$screenHeight");

    return Scaffold(
      body: SafeArea(
        child: Padding(
          //画面全体に余白を付けたい場合
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/image_title.png"),
                const SizedBox(
                  height: 20.0,
                ),
                const Text("問題数を選択して「スタート」ボタンを押してください"),
                const SizedBox(
                  height: 75.0,
                ),
                DropdownButton(
                  items: _menuItems,
                  value: _numberOfQuestions,
                  onChanged: (selectedValue) {
                    setState(() {
                      //選んでもsetStateしないと反映されない
                      _numberOfQuestions = selectedValue; //選択した値をvalue属性へ設定
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: RaisedButton.icon(
                      color: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      onPressed: () => startTestScreen(context),
                      label: Text("スタート"),
                      icon: Icon(Icons.skip_next),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  startTestScreen(BuildContext context) {
    //buildに書いてあるcontextと同じ
    //MaterialPageRouteとbuilderは公式リファレンスそのまま
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                //受け取る側でNamedparameters設定していると、numberOfQuestions属性が予測変換で出てくる
                TestScreen(
                  numberOfQuestions: _numberOfQuestions,
                )));
  }
}
