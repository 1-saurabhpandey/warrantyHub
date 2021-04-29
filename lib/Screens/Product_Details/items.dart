import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Model/productsModel.dart';
import 'package:warranty_tracker/Screens/Product_Details/addItem.dart';
import 'package:warranty_tracker/Screens/Product_Details/itemDetail.dart';
import 'package:warranty_tracker/Services/database.dart';

class Items extends StatefulWidget {                            
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  late String status;
  late int difference ;
  late String timeLeft ;
  late String purchaseDate;
  late List? productsIdList;
  List<Map>? data;

  var stream;
  List catman = []; 

  @override
  void initState() {
    super.initState();
    stream = DataService().getData();
    catmanStream();
    
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
          
          Provider.of<DataModel>(context,listen:false).clearImageandBillList();

          var result = await Navigator.of(context).push(
          MaterialPageRoute(builder:(BuildContext context) => AddItem(productsIdList: productsIdList,)));
          
          if(result != null){
            ScaffoldMessenger.of(context) 
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

    return StreamBuilder<dynamic>(

      stream: stream,
      builder: (BuildContext context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){ 
          return Center(child: Text("Loading..."),); 
        } 
        
         
        if(snapshot.data != null){

          Provider.of<ProductsModel>(context,listen: false).setProductIdList(snapshot.data?.docs);
          //giving error setstate or markNeedsBuild called during build
          // print(data[0].keys); // productId
          
        
          try{ 

            // productsIdList = snapshot.data["products"] == null ? null : snapshot.data["products"];  
            // WidgetsBinding.instance.addPostFrameCallback((_){                                              \
            //   Provider.of<DataModel>(context,listen:false).setProductsData(snapshot.data);                  \
            //   // Provider.of<DataModel>(context,listen:false).setAddressData(snapshot.data["addresses"]);   /    Building continuously
            // });                                                                                            /

            return productsIdList != null ? ListView.builder(
              
              itemCount: productsIdList?.length,
              itemBuilder: (context,index){

                
                var productId = productsIdList?[index]; 
                Map products = snapshot.data?[productId];

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
                  padding: const EdgeInsets.fromLTRB(10,5,10,5), 
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
                          ScaffoldMessenger.of(context)
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
                              padding: const EdgeInsets.only(left: 8,right: 8), 
                              child: Container(
                                          
                                height: 120, width: 120,
                                child: Center(
                                  child: products["image"] == null
                                  ? Image.asset('lib/images/noimage.jpg')
                                  : Image.network( 
                                    products["image"][0],fit: BoxFit.fitWidth, 
                                    loadingBuilder: (context, child, loadingProgress){
                                      return loadingProgress == null 
                                      ? child 
                                      : CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null 
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null
                                      );
                                    },
                                  )
                                )
                              ),
                            ),

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[

                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text( 
                                      products["name"], 
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.oswald(textStyle:TextStyle(fontSize: 25))
                                    ),
                                  ), 

                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      products["category"],
                                      style: GoogleFonts.sourceSansPro(textStyle:TextStyle(fontSize: 17))),
                                  ),
                            
                                  Padding(
                                    padding: const EdgeInsets.all(5), 
                                    child: Text(timeLeft,style: GoogleFonts.sourceSansPro(
                                      textStyle:TextStyle(fontSize: 17,fontWeight: FontWeight.w500))),
                                  ), 

                                  Padding(
                                    padding: const EdgeInsets.only(top:5.0,bottom: 3), 
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
          }  // when uid document doesnot exist it will throw error
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