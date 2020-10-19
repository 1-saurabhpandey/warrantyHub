// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:warranty_tracker/Screens/itemDetail.dart';
// import 'package:warranty_tracker/Services/database.dart';

// class CategoryDetail extends StatefulWidget {

// final data;
//  CategoryDetail({Key key, @required this.data}) : super(key: key);
  
//   @override
//   _CategoryDetailState createState() => _CategoryDetailState();
// }

// class _CategoryDetailState extends State<CategoryDetail> {

  
// DataService _dataService = DataService();
// DataStorage _dataStorage = DataStorage();
 
//   int difference ;
//   String timeLeft ;
//   String status;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xff5458e1),
//         title: Text('Category Detail'),
//       ),

//       body: 
//             Container(
//               decoration: BoxDecoration
//               (borderRadius: BorderRadius.only(topLeft: Radius.circular(25),
//               topRight: Radius.circular(25)),
//               color: Colors.white,),

//               child: FutureBuilder(

//                 future: _dataService.getDataforcategory(widget.data),
//                 builder: (BuildContext context,snapshot){

//                 if(snapshot.connectionState== ConnectionState.waiting){
//                   return Center(child: Text("Loading..."),);
//                 }else{
                 
//                   return ListView.builder(
//                     itemCount: snapshot.data.length,
//                     itemBuilder: (context,index){

//                       DateTime date = DateTime.now();
//                       String exdate = snapshot.data[index].data["expiry_date"];
//                       DateTime expiryDate = DateTime.parse(exdate);

//                       var format = DateFormat('dd/MM/yyyy');
//                       String date2 = format.format(expiryDate);

//                       if(date.isBefore(expiryDate)){
//                           status = 'Active';
//                         }else{
//                           status ='Expired';
//                         }

//                      if(expiryDate.difference(date).inDays.isNegative){
//                        timeLeft = "Active before $date2 ";
//                      }else{
//                        difference = expiryDate.difference(date).inDays;
//                        timeLeft = "Expires on $date2 ";
//                      }
                      
//                       return Column(
//                         children: <Widget>[

//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(20,10,20,10),
//                             child: InkWell(
//                               onTap: (){
//                                 Navigator.of(context).push(MaterialPageRoute(
//                                 builder:(BuildContext context) => ItemDetail(
//                                   docid: snapshot.data[index].data["docid"],                                 
//                                 )
//                                 ));
//                               },
//                                 child: Container(
//                                 decoration: BoxDecoration(borderRadius: 
//                                 BorderRadius.all(Radius.circular(30)),
//                                 color: Color(0xffeaeaea),
                                
//                                 ),
//                                 child:
                                  
//                                    Row(
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        Padding(
//                                          padding: const EdgeInsets.only(left: 15),
//                                          child: Container(
                                          
//                                           height: 100, width: 100,
//                                           child: FutureBuilder(
//                                             future: _dataStorage.getImage(snapshot.data[index].data["docid"]),
//                                             builder: (BuildContext context, snapshot){
//                                               if(snapshot.connectionState== ConnectionState.waiting){
//                                               return Center(child: CupertinoActivityIndicator(),);
//                                               }
//                                               if(snapshot.data == null){
//                                               return Center(child: Image.asset('lib/images/noimage.jpg'),);
//                                               }
//                                               else{
//                                               return Container(
                                                
//                                                 child: Image.network(snapshot.data,
//                                                 fit: BoxFit.cover,
//                                                 ),
//                                               );
//                                               }                                       
//                                             },
//                                           ),
//                                   ),
//                                        ),

//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     children: <Widget>[
//                                     SizedBox(height: 30,),
//                                     Container(
//                                       width: 150,
//                                       child: Column(
//                                           children: <Widget>[
//                                             Text(snapshot.data[index].data["name"],
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.robotoSlab(textStyle:TextStyle(fontSize: 25))),
                                          
//                                             Text(snapshot.data[index].data["category"],
//                                             style: GoogleFonts.raleway(textStyle:TextStyle(fontSize: 15))),
//                                           ],
//                                         ),
//                                     ),

//                                       Padding(
//                                         padding: const EdgeInsets.fromLTRB(5,20,5,5),
//                                         child: Text(timeLeft,style: GoogleFonts.merriweather(
//                                           textStyle:TextStyle(fontSize: 15))),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(top:8.0),
//                                         child: Text(
//                                           status,
//                                           style:GoogleFonts.openSans(textStyle: TextStyle(color:
//                                           status == "Expired" ? 
//                                           Colors.red :  Colors.green,
//                                           fontSize: 17,fontWeight: FontWeight.bold
//                                         ),),)
//                                       ),
                                      
//                                       SizedBox(height: 30,)
//                                   ],)
//                                      ],
                                   
                                  
//                                   ),
//                                    )
//                               ),
//                             ),
                          
//                          Divider(thickness: 3,indent: 10,)
//                         ],
//                       );
//                   } );
//                 }
//       },),
//             ),
//     );
//   }
// }