// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:warranty_tracker/Screens/categorydetail.dart';
// import 'package:warranty_tracker/Services/database.dart';

// class Categories extends StatefulWidget {
//   @override
//   _CategoriesState createState() => _CategoriesState();
// }

// class _CategoriesState extends State<Categories> {

//   var _formKey = GlobalKey<FormState>();
//   TextEditingController name = TextEditingController();
//   String catname ;
//   DataService _dataService = DataService();
//   var stream;

//   @override
//   void initState() {
//     stream = _dataService.getCategory();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {

//   return Scaffold(
//     backgroundColor: Color(0xff5458e1),

//     body: Container(
//       decoration: BoxDecoration(
//       borderRadius: BorderRadius.only(
//       topLeft: Radius.circular(15),
//       topRight: Radius.circular(15)),
//       color: Color(0xfff0f4ff),),

//       child: StreamBuilder(
//         stream: stream,
//         builder: (BuildContext context ,snapshot) {

//           if(snapshot.connectionState == ConnectionState.waiting){
//             return Center(child: Text("Loading..."),);}

//             if(!snapshot.hasData){
//                   return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Text("No Category\n\n",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                      
//                       Text(" Click on PLUS button to add new category",
//                       style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                     ],
//                   ),);
//                 }
//             else{
//               List data = snapshot.data['categories'];
              
//               return listData(data);
//             }
//         }
//    ,),
//     ),
//    floatingActionButton: FloatingActionButton(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
//     backgroundColor: Color(0xff5458e1),
//     child: Icon(Icons.add),
//     elevation: 7, mini: true,
//     onPressed: () =>
//     showDialog(context: context,builder: ad)
//     ),
//  );
// }

// Widget listData(List data){
//   return ListView.builder(
//                     itemCount: data.length,
//                     itemBuilder: (context,index){
//                       return Padding(
//                         padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 5),
//                         child: Card(
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(10)
//                          ),
//                           color: Colors.white,
//                           elevation: 7,
//                           child: InkWell(
//                             child:Container(
                              
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  
//                                 children: <Widget>[
//                                 Icon(Icons.label),

//                                 Text(data[index].toString(),
//                                 style: TextStyle(fontSize: 20),),

//                               FutureBuilder(
//                                   future: _dataService.getDataforcategory(
//                                   data[index].toString()),
//                                   builder: (BuildContext context , snapshot){

//                                   if(snapshot.connectionState == ConnectionState.waiting){
//                                     return 
//                                     SizedBox(
//                                       height: 25,width: 25,
//                                       child: Container(                                  
//                                       decoration: BoxDecoration(
//                                       color: Color(0xff5458e1),
//                                       borderRadius: BorderRadius.all(Radius.circular(10))),
                                      
                                      
//                                   ),);}

//                                   else{
//                                     return SizedBox(
//                                       height: 25,width: 25,
//                                       child: Container(                                  
//                                       decoration: BoxDecoration(
//                                       color: Color(0xff5458e1),
//                                       borderRadius: BorderRadius.all(Radius.circular(10))),
//                                       child: Align(
//                                         child: Text(snapshot.data.length.toString(),
//                                         style: TextStyle(color: Colors.white),),
//                                       ),
//                                   ),);}
                                  
//                                   },
//                                 ) 
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             onTap: (){
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(builder: (BuildContext context) => 
//                                 CategoryDetail(data:data[index].toString()))
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                   } );
// }

// Widget ad(BuildContext context) => 
//   SimpleDialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
//     children: <Widget>[
//     Container(
//     child:Form(
//        key: _formKey,
//        child: Column(children: <Widget>[
//          SizedBox(height:10),

//          Align(child: Container(
//            width: 80,
//            height: 3,
//            decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(3)),
//             color: Colors.black,),),),

//          SizedBox(height: 30,),
//       Padding(
//           padding: const EdgeInsets.only(left:20,right: 20,bottom: 20),
//           child: TextFormField(
//           controller: name,
//           decoration: 
//           InputDecoration(labelText: 'Category name', 
//           border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),),
//           validator: (String val) => val.isEmpty ? 'Enter category name' : null,
//           onChanged: (val)=>{
//             setState((){
//               catname = val;
//             })
//           },
//           ),),
       
//        RaisedButton(child: Text('Add',style: TextStyle(color: Colors.white),),
//        color: Color(0xff2a81ea),
//        onPressed: () async{
//          if(_formKey.currentState.validate()){
//            dynamic result = await _dataService.addCategory(catname);
           
//            if(result == 'error'){
//             Fluttertoast.showToast(
//               msg: 'Some error occured',
//               backgroundColor: Colors.black,
//               textColor: Colors.white);             
//            }else{
//              Fluttertoast.showToast(
//               msg: 'New category added successfully',
//               backgroundColor: Colors.black,
//               textColor: Colors.white);           
//            }
//          }
//        },)
//   ],),),
//     )
//   ],);
// }