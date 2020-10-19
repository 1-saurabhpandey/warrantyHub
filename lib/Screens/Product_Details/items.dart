import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Product_Details/addItem.dart';
import 'package:warranty_tracker/Screens/Product_Details/itemDetail.dart';
import 'package:warranty_tracker/Services/database.dart';

class Items extends StatefulWidget {                            
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  String status;
  int difference ;
  String timeLeft ;
  String purchaseDate ;
  List productsIdList;

  var stream;
  List catman = []; 

  @override
  void initState() {
    stream = DataService().getData();
    catmanStream();
    super.initState();
  }
 
  void catmanStream(){
    var catStream = DataService().getCategory();
    var manStream = DataService().getManufacturer();
    catman.add(catStream);
    catman.add(manStream);

    Provider.of<DataModel>(context,listen: false).setCatManStream(catman);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(0xff5458e1),
        child: Icon(Icons.add,color: Colors.white),
        elevation: 7,mini: true,
        onPressed: ()async {

         var result = await Navigator.of(context).push(
          MaterialPageRoute(builder:(BuildContext context) => AddItem(productsIdList: productsIdList,)));
          
         if(result != null){
           _globalKey.currentState 
          .showSnackBar(
            SnackBar(
              content: result == 'success'  ? Text('New product added successfully') : Text('Some error occured'),
              duration: Duration(seconds: 3)
            )
          );
         }  
        }
      ),
          
       
      body: SafeArea(
        child: Container( 
          color: Color(0xfff0f4ff),
          child: listData()
        )
      ),
    );  
  }

  Widget listData(){  
    return StreamBuilder(

      stream: stream,
      builder: (BuildContext context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: Text("Loading..."),);
        }

        if(snapshot.data != null){
          try{
            productsIdList = snapshot.data["products"] == null ? null : snapshot.data["products"];
            WidgetsBinding.instance.addPostFrameCallback((_){ 
              Provider.of<DataModel>(context,listen:false).setProductsData(snapshot.data);
              Provider.of<DataModel>(context,listen:false).setAddressData(snapshot.data["addresses"]);
            });
  
            return productsIdList != null ? ListView.builder(

              itemCount: productsIdList.length,
              itemBuilder: (context,index){

                var productId = productsIdList[index]; 
                Map products = snapshot.data[productId];

                DateTime date = DateTime.now();
                DateTime expiryDate = products["expiry"].toDate();

                //changing the format of expirydate

                var format = DateFormat('dd/MM/yyyy');
                String date2 = format.format(expiryDate);

                if(date.isBefore(expiryDate)){
                  status = 'Active';
                }
                else{
                  status ='Expired';
                }

                if(expiryDate.difference(date).inDays.isNegative){
                  timeLeft = "Active before $date2 ";
                }else{
                  difference = expiryDate.difference(date).inDays;
                  timeLeft = "Expires on $date2 ";
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20,15,20,5),
                  child: Card(
                    elevation: 7, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async{
                        
                        var result = await Navigator.of(context).push(MaterialPageRoute(
                          builder:(BuildContext context) => ItemDetail(productId: productId)
                        ));

                        if(result != null){
                          _globalKey.currentState 
                          .showSnackBar(
                            SnackBar(
                              content: result == 'success'  ? Text('Product deleted successfully') : Text('Some error occured'),
                              duration: Duration(seconds: 3)
                            )
                          ) ;
                        }  
                      },
                      child: Container(
                                
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15), 
                              child: Container(
                                          
                                height: 100, width: 100,
                                child: Center(
                                  child: products["image"] == null
                                  ? Image.asset('lib/images/noimage.jpg')

                                  : Image.network(products["image"]))
                                          
                              ),
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(height: 30,),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    width: 150,
                                    child: Column(
                                      children: <Widget>[
                                              
                                        Text( 
                                          products["name"], 
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.oswald(textStyle:TextStyle(fontSize: 25))
                                        ),          

                                        Text(
                                          products["category"],
                                          style: GoogleFonts.sourceSansPro(textStyle:TextStyle(fontSize: 17))),
                                      ],
                                    ),
                                  ),
                                ),
                                    
                                Padding(
                                  padding: const EdgeInsets.all(5), 
                                  child: Text(timeLeft,style: GoogleFonts.sourceSansPro(
                                    textStyle:TextStyle(fontSize: 17,fontWeight: FontWeight.w500))),
                                ), 

                                Padding(
                                  padding: const EdgeInsets.only(top:5.0,bottom: 10),
                                  child: Chip(
                                    label: Text(
                                      status, style: TextStyle(
                                      fontSize: 16,fontWeight: FontWeight.bold,
                                      color: status == 'Active' ? Colors.green : Colors.red
                                    )),
                                    backgroundColor: status == 'Active' ? Colors.green[100] : Colors.red[100], 
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
            : noProduct();
          }  // when uid document doesnot exist it will throw error 99caa4 cbe3b3 
          catch(e){
           return noProduct();
          }
        } else return Container();
      }
    );
  }

  Widget noProduct(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("No Products\n\n",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                  
          Text(" Click on PLUS button to add new product", 
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
        ],
      ),
    );  
  }
}