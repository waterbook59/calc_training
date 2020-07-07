import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class TestScreen extends StatefulWidget {
  final numberOfQuestions; //varはダメでfinalに

  //データを前の画面から受けるためのコンストラクタを自作
  TestScreen(
      {this.numberOfQuestions}); //引数付きのコンストラクを作る場合は受け取る方でNamed parametersを使うのに{}で囲む

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int numberOfRemaining=0;
  int numberOfCorrect=0;
  int correctRate=0;

  int questionLeft=0;
  int questionRight=0;
  String operator="";
  String answerString="";

  Soundpool _soundpool;//Soundpoolクラスは_TestScreenState全体で使うので、プロパティとしてセット
  int soundIdCorrect=0;
  int soundIdInCorrect=0;

  //bool型はisXXXから名付けるのが慣例
  bool isCalcButtonsEnabled = false;//計算ボタンを使えるかどうか
  bool isAnswerCheckButtonEnabled = false;//答えあわせボタン使えるかどうか
  bool isBackButtonEnabled = false;//戻るボタン
  bool isCorrectInCorrectImageEnabled = false;//まるペケボタン画像
  bool isEndMessageEnabled =false;
  bool isCorrect =false; //入力値が答えとあってるかどうか

  @override
  void initState() {//initStateのホットリロードは反映されない
    super.initState();//super.initStateは継承元のStateクラス内のinitStateメソッドでこの処理は残しておく
    numberOfCorrect=0;
    correctRate=0;
    numberOfRemaining=widget.numberOfQuestions;//前の画面から引き継いだnumberOfQuestionsを代入

    initSounds();// 効果音の準備 soundpool非同期処理外だし（initStateにasync付けられないので）
    setQuestion();//問題を出すメソッド
  }

  void initSounds() async{
  try{

    _soundpool=Soundpool();//soundpool初期化
    soundIdCorrect= await loadSound("assets/sounds/sound_correct.mp3");//さらにloadSoundメソッドを作って外だし、ここで非同期で読み込むのでawait
    soundIdInCorrect= await loadSound("assets/sounds/sound_incorrect.mp3");//さらにloadSoundメソッドを作って外だし

    /*音を非同期処理するためにinitSoundsをinitStateから外に出したが、そのままinitState->buildの流れだと、initSoundsの結果が反映されないため、
    *initState->initSounds内で音データロード->setState->buildで反映させる
     */
    setState(() {
    });

  } on IOException catch(error){
    print("エラーの内容は：$error");
  }

  }

  Future<int>loadSound(String soundPath) {//awaitの戻り値となるので、Futureの型を入れる、soundPathは自分で名付けた引数
  return rootBundle.load(soundPath).then((value) =>_soundpool.load(value));

  }

  //破棄メソッド "dis"と打てばdisposeメソッド出てくる
  @override
  void dispose() {
    super.dispose();
    _soundpool.release();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                //List内にWidget羅列すると長くなるのでメソッドで外だしにする
                //1.スコア表示
                _scorePart(),
                //2.問題表示部分
                _questionPart(), //呼び出す方は頭に型いらない
                //3.電卓ボタン部分
                _calcButtons(),
                //4.答えあわせボタン
                _answerCheckButton(),
                //5.戻るボタン
                _backButton(),
              ],
            ),
             _correctIncorrectImage(),//マルペケ画像メソッド
            //テスト終了メッセージ
             _endMessage(),
          ],
        ),
      ),
    );
  }

  // 1.スコア表示部分 外だしする関数の戻り値はWidgetで良い
  Widget _scorePart() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 9.0),
      child: Table(
        children: [
          TableRow(//1行目、文字だけ
              children: [
            Center(child: Text("残り問題数", style: TextStyle(fontSize: 10.0),),),
            Center(child: Text("正解数", style: TextStyle(fontSize: 10.0),),),
            Center(child: Text("正答率", style: TextStyle(fontSize: 10.0),),),
          ]),
          TableRow(//残り問題数や正解数の数は変化するので、変数入れる
              children: [
            Center(
              child: Text(
                numberOfRemaining.toString(),
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Center(
              child: Text(
                numberOfCorrect.toString(),
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Center(
              child: Text(
                correctRate.toString(),
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ])
        ],
      ),
    );
  }

  //2. 問題表示部分
  Widget _questionPart() {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0, top:80.0),
      child: Row(
        children: <Widget>[
          Expanded(flex:2,child: Center(child: Text(questionLeft.toString(),style: TextStyle(fontSize: 36.0),))),
          Expanded(flex:1, child: Center(child: Text(operator,style: TextStyle(fontSize: 30.0),))),
          Expanded(flex:2,child: Center(child: Text(questionRight.toString(),style: TextStyle(fontSize: 36.0),))),
          Expanded(flex:1,child: Center(child: Text("=",style: TextStyle(fontSize: 30.0),))),
          Expanded(flex:3,child: Center(child: Text(answerString,style: TextStyle(fontSize: 60.0),))),
        ],
      ),
    );
  }

  //TODO 電卓ボタン部分
  Widget _calcButtons() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left:8.0,right: 8.0,top:50.0),
        child: Table(
          children: [
            TableRow(//1行目
              children: [
                _calcButton("7"),//番号7
                _calcButton("8"),//番号8
                _calcButton("9"),//番号9
              ]
            ),
            TableRow(//2行目
                children: [
                  _calcButton("4"),//番号7
                  _calcButton("5"),//番号8
                  _calcButton("6"),//番号9
                ]
            ),
            TableRow(//3行目
                children: [
                  _calcButton("1"),//番号7
                  _calcButton("2"),//番号8
                  _calcButton("3"),//番号9
                ]
            ),
            TableRow(//4行目
                children: [
                  _calcButton("0"),//番号7
                  _calcButton("-"),//番号8
                  _calcButton("C"),//番号9
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcButton(String numString) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: RaisedButton(
        color: Colors.lightGreenAccent,
        textColor: Colors.black87,
        //isCalcButtonsEnabled（計算ボタン）が?(true)の場合はanswerCheckできて(押せて)、それ以外(:)の時は押せない(null)
        //押したら問題表示部分の後ろに数字を出していく
        onPressed: isCalcButtonsEnabled ? ()=>inputAnswer(numString):null,
        child: Text(numString,style: TextStyle(fontSize: 24.0),),
      ),
    );
  }

  //4. 答えあわせボタン部分
  Widget _answerCheckButton() {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right: 8.0,),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: Colors.deepPurpleAccent,
          // 答えあわせボタン部分
          //isCalcButtonsEnabled（計算ボタン）が?(true)の場合はanswerCheckできて(押せて)、それ以外(:)の時は押せない(null)
          onPressed: isCalcButtonsEnabled ? ()=>answerCheck() : null,
          child: Text("こたえあわせ",style: TextStyle(fontSize: 14.0),),
        ),
      ),
    );
  }

  //5.戻るボタン
  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right: 8.0,bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: Colors.deepPurpleAccent,
          onPressed: isBackButtonEnabled ? ()=> closeTestScreen() : null,// 戻るボタン部分
          child: Text("戻る", style: TextStyle(fontSize:14.0 ),),
        ),
      ),
    );
  }

  //TODO マル・ペケ画像
  Widget _correctIncorrectImage() {
    if(isCorrectInCorrectImageEnabled){
      if(isCorrect){//正解してたらの条件を追加
        return Center(child: Image.asset("assets/images/pic_correct.png"));
      }else{
        return Center(child: Image.asset("assets/images/pic_incorrect.png"));
      }

    }else {
      return Container();
    }

  }

  //TODO 終了メッセージ
  Widget _endMessage() {
    if(isEndMessageEnabled){
      return Center(child: Text("テスト終了",style: TextStyle(fontSize: 70.0),),);
    }else{
      return Container();
    }

  }

  //TODO 問題を出す
  void setQuestion() {//ボタンを出す・出さない、画像出す出さないなどを管理する=>boolメソッド
    answerString = "";

  isCalcButtonsEnabled = true;
  isAnswerCheckButtonEnabled= true;
  isBackButtonEnabled = false;
  isCorrectInCorrectImageEnabled = false;
  isEndMessageEnabled = false;
  isCorrect = false;//問題出すときは不正解にしておいた方が良い
//出す、出さないに応じて上の各widgetの戻り値変えてやったほうが良いのではないか=>各widget内にif文設置

  Random random = Random();

  questionLeft = random.nextInt(100)+ 1;
  questionRight = random.nextInt(100)+ 1;

    if(random.nextInt(2)+1 == 1){
      operator = "+";
    }else{
      operator = "-";
    }
    setState(() {//2問目以降もbuild回すため

    });

  }

  inputAnswer(String numString) {
    setState(() {//画面更新するときはsetState入れないとbuild回らないので注意
   //処理が１行の場合はif文の条件()の後の{}は省略できる
      if (numString == "C" ){
        answerString = "";
        return;//returnがあったらif(条件)に合致したものはサヨナラ〜
      }

      if(numString == "-") {// -を押すときは
        if (answerString == "") answerString = "-";//解答欄が空の時だけ入力できる
        return;//解答欄が空の時以外の条件はなく、numString=="-"が終わるので、解答欄が空以外の時に-押しても反映されない
      }
      if(numString == "0") {// 0を押すときは、解答欄が0じゃないかつ、-じゃない
        if(answerString != "0" && answerString != "-")
          answerString = answerString + numString;
        return;
      }

      if(answerString == "0"){//解答欄に0が入ってるときは置き換える
        answerString = numString;
        return;
      }

      answerString = answerString + numString;//基本は後ろにnumStringを表示していく形で良い、前に例外をかく
    });

  }

  answerCheck() {//答えあわせ時
    if(answerString == "" || answerString == "-"){
      return;//空か-なら
    }
    //answerStringが空ではない、または-ではないとき
    isCalcButtonsEnabled = false;//電卓ボタン
    isAnswerCheckButtonEnabled= true;//答えあわせボタン
    isBackButtonEnabled = false;//戻るボタン
    isCorrectInCorrectImageEnabled = true;//マルペケ画像
    isEndMessageEnabled = false;//終了メッセージ

    numberOfRemaining -= 1;

    //計算ボタンで入力した回答をStringからintへ変換する
    var myAnswer = int.parse(answerString).toInt();//intへ変換したものを変数格納
    var realAnswer =0;

    if(operator == "+"){
      realAnswer = questionLeft + questionRight;
    }else{
      realAnswer = questionLeft - questionRight;
    }

    if(myAnswer==realAnswer){
      isCorrect = true;
      _soundpool.play(soundIdCorrect);
      numberOfCorrect += 1;
    }else{
      isCorrect = false;
      _soundpool.play(soundIdInCorrect);
    }

    //widgetの考え方は復習 chapter162 右辺が計算の結果、double型になってしまうのでint型へ変換
    correctRate = ((numberOfCorrect/(widget.numberOfQuestions-numberOfRemaining))*100).toInt();

    if(numberOfRemaining == 0){
    //TODO 残り問題数がないとき
      isCalcButtonsEnabled = false;
      isAnswerCheckButtonEnabled= false;
      isBackButtonEnabled = true;
      isCorrectInCorrectImageEnabled = true;
      isEndMessageEnabled = true;

    }else{
      //TODO 残り問題数があるとき
      //1秒後にクイズを出す
      Timer(Duration(seconds: 1),()=>setQuestion());

    }

    setState(() {

    });

  }

  closeTestScreen() {
    Navigator.pop(context);
  }






}
