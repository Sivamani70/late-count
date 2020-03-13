import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data/dataManager.dart';
import 'data_Viewer.dart';

List<Map> _list;

class HomeExtended extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == Color(0xfffafafa)
              ? Colors.white
              : Colors.black,
      body: _HomeExtended(),
    );
  }
}

class _HomeExtended extends StatefulWidget {
  @override
  _HomeExtendedState createState() => _HomeExtendedState();
}

class _HomeExtendedState extends State<_HomeExtended> {
  double height = 0;
  String data = '';
  TextEditingController dataController;
  @override
  void initState() {
    dataController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    dataController.dispose();
    StudentDataModel().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.topCenter,
          image: AssetImage('assets/imgs/background.png'),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => dataManager(context),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 35.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: height * .15,
              ),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(9.0),
                // height: 50,
                width: MediaQuery.of(context).size.width * .7,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor ==
                          Color(0xfffafafa)
                      ? Colors.white
                      : Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  enabled: false,
                  controller: dataController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter RollNo',
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
            numberBuilder(numbers: ['1', '2', '3']),
            numberBuilder(numbers: ['4', '5', '6']),
            numberBuilder(numbers: ['7', '8', '9']),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    child: InkWell(
                      child: Icon(Icons.arrow_back),
                    ),
                    onTap: deleteCharecter,
                    onLongPress: onLongPress,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: addingZero,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 25),
                        child: Text(
                          '0',
                          style: Theme.of(context).textTheme.display1,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () {
                        String rollNo = dataController.text.trim();
                        dataController.clear();
                        pushData(context, rollNo);
                      }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Row numberBuilder({List<String> numbers}) {
    return Row(
      children: <Widget>[
        numberRows(numbers, 0),
        numberRows(numbers, 1),
        numberRows(numbers, 2),
      ],
    );
  }

  Expanded numberRows(List<String> numbers, int i) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            dataController.value = TextEditingValue(
              text: '${dataController.value.text + numbers[i]}',
            );
          });
          HapticFeedback.heavyImpact();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 25),
            child: Text(
              '${numbers[i]}',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
      ),
    );
  }

  void addingZero() {
    setState(() {
      dataController.value = TextEditingValue(
        text: '${dataController.value.text}' + '0',
      );
    });
    HapticFeedback.lightImpact();
  }

  void onLongPress() {
    setState(() {
      dataController.value = TextEditingValue(text: '');
    });
    HapticFeedback.heavyImpact();
  }

  void deleteCharecter() {
    setState(() {
      String value = dataController.value.text;
      int length = value.length;
      if (length != 0) {
        dataController.value =
            TextEditingValue(text: '${value.substring(0, length - 1)}');
      }
    });
    HapticFeedback.heavyImpact();
  }

  Function pushData = (BuildContext context, String rollNo) async {
    if (rollNo.isEmpty) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Enter RollNo'),
        ),
      );
    } else {
      int n = int.tryParse(rollNo) ?? -10;
      if (n != -10) {
        StudentDataModel st = new StudentDataModel(rollNo: rollNo);
        await st.openDataBaseCon();
        final responseList = await st.retriveData();
        if (responseList[0] != 0) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Uploaded with Id: ${responseList[0]} & Late Count: ${responseList[1]}'),
            ),
          );
        } else {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Something Went Wrong!'),
            ),
          );
        }
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Enter Valid RollNo'),
          ),
        );
      }
    }
  };

  final Function dataManager = (BuildContext context) async {
    StudentDataModel st = new StudentDataModel();
    _list = await st.dispalayData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayLateData(dataList: _list),
      ),
    );
  };
}
