import 'package:flutter/material.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/utils/toast.dart';

class MyFeedback extends StatefulWidget {
  MyFeedback({Key key}) : super(key: key);

  @override
  _MyFeedbackState createState() {
    return _MyFeedbackState();
  }
}

class _MyFeedbackState extends State<MyFeedback> {
  String _feedback;
  String _contact;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('留言反馈'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Container(
                  height: 30,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '请留下您的意见：',
                    textAlign: TextAlign.left,
                  ),
                ),
                TextField(
                  maxLines: 8,
                  maxLength: 500,
                  keyboardAppearance: Brightness.light,
                  decoration: InputDecoration(
//                labelText: '请留下您的意见：',
//                helperText: '请留下您的意见：',
                    hintText: '您的意见',
                    border: OutlineInputBorder(),
                  ),
                  //监听文字改变
                  onChanged: (val) {
                    print(val);
                    this._feedback = val;
                  },
                  //点击确认
                  onSubmitted: (val) {
                    print("点击确认 ：${val}");
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                ),
                Container(
                  height: 30,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '您的联系方式：',
                    textAlign: TextAlign.left,
                  ),
                ),
                TextField(
                  maxLength: 30,
                  keyboardAppearance: Brightness.light,
                  decoration: InputDecoration(
//                labelText: '您的联系方式：',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    hintText: 'QQ / 邮箱 / 手机号',
                    border: OutlineInputBorder(),
                  ),
                  //监听文字改变
                  onChanged: (val) {
                    print(val);
                    this._contact = val;
                  },
                  //点击确认
                  onSubmitted: (val) {
                    print("点击确认 ：${val}");
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                Container(
                  height: 40,
                  width: Adapt.screenW() - 20,
                  child: RaisedButton(
                    child: Text('提交'),
                    color: Colors.yellow.shade600,
                    textColor: Colors.white,
                    splashColor: Colors.yellow.shade300,
                    onPressed: () {
                      if (this._feedback.length == 0) {
                        Toast.show('请输入您的意见');
                        return;
                      } else {
                        Global.uploadFeedback(this._feedback, this._contact)
                            .then((value) {
                          if (value == true) {
                            Toast.show('提交成功');
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
