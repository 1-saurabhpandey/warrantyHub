import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Services/database.dart';

class CategoriesModel extends ChangeNotifier{

  List<String> categorydata = [];

  void getcategories(List data){
    categorydata = data ;
  }
}

class De extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DemoModel(),
      child: Demo(),
    );
  }
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DemoClass(),
    );
  }
}

class DemoClass extends StatefulWidget {
  @override
  _DemoClassState createState() => _DemoClassState();
}

class _DemoClassState extends State<DemoClass> {

  var dataStream;

  setData(var data){
    Provider.of<DemoModel>(context,listen: false).setData(data);
  }

  void getStream(){
    print('stream');
    dataStream = DataService().getData();
  }
  @override
  void initState() {
    print('class1 init'); 
    getStream();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  
  @override
  Widget build(BuildContext context) {
 

    return Scaffold( 
      body: Center(
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => DemoClass3())),
          child: Container(
            color: Colors.red,
            height: 300, width: 300,
            child: StreamBuilder(
              stream: dataStream,
              builder: (context,snap){
               print('FirstScreen build');
                if(snap.hasData){
                  WidgetsBinding.instance.addPostFrameCallback(setData(snap.data.documents[0]['name']));
                   
                return Text(snap.data.documents[0]['name']);
                }
               

                else return CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DemoClass2 extends StatefulWidget {
  @override
  _DemoClass2State createState() => _DemoClass2State();
}

class _DemoClass2State extends State<DemoClass2> {

  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.blue,
          height: 300, width: 300,
          child: Consumer<DemoModel>(
            builder: (context, data, child){
             return Center(child: Text(data.getData()));
            },
          )
          
           
        ),
      ),
    );
  }
}

class DemoClass3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => DemoClass2())),
        child: Container(height: 300,width: 300,color: Colors.yellow,)),),
    );
  }
}

// class FirstScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {

//     print('FirstScreen');

//     return Scaffold( 
//       body: Center(
//         child: InkWell(
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SecondScreen())),

//           child: Container(
//             child: StreamBuilder(
//               stream: Firestore.instance.collection('items').snapshots(),
//               builder: (context,snap){

//                 print('FirstScreen : ${snap.connectionState}');

//                 if(snap.hasData)
//                 return Text(snap.data.documents[0]['name']);

//                 else return CircularProgressIndicator();
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class SecondScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {

//     print('SecondScreen');
    
//     return Scaffold( 
//       body: Center(
//         child: Container(
//           child: StreamBuilder(
//             stream: Firestore.instance.collection('products').snapshots(),
//             builder: (context,snap){

//               print('SecondScreen : ${snap.connectionState}');

//               if(snap.hasData)
//               return Text(snap.data.documents[0]['name']);

//               else return CircularProgressIndicator();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class DemoModel extends ChangeNotifier{

  var data;

  void setData(var streamdata){
    data = streamdata;
    print('Demo build');
    notifyListeners();
  }
  
   getData(){
    print('Demo2 build');
    return data;
  }


}