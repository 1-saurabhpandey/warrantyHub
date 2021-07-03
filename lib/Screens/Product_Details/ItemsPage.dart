import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:warranty_tracker/Screens/Product_Details/AddItemPage.dart';
import 'package:warranty_tracker/Screens/Product_Details/ItemDetail.dart';
import 'package:warranty_tracker/ViewModels/ItemsViewModel.dart';

// ignore: must_be_immutable
class Items extends StatelessWidget {                            

  late String status;
  late int difference ;
  late String timeLeft ;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Icon(Icons.add,color: Colors.white),
        backgroundColor: Color(0xff5458e1),
        elevation: 7,mini: true,
        onPressed: () => Get.to(() => AddItem()),
      ),
       
      body: SafeArea(
        child: Container( 
          color: Theme.of(context).canvasColor,
          child: listData()
        )
      ),
    );  
  }

  Widget listData(){  

    return GetX<ItemViewModel>(
      init: ItemViewModel(),
      builder: (data){

        List items = data.getItemList();

        return items.isNotEmpty ? ListView.builder(
          
          itemCount: items.length,
          itemBuilder: (context,index){

            DateTime date = DateTime.now();
            DateTime expiryDate = items[index]['details']["expiry"].toDate();

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
                color: Theme.of(context).cardColor,
                elevation: 7, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                child: InkWell(
                  onTap: () async{
                    
                    Get.to(() => ItemDetail(productId: items[index]['productId']));
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
                              child: items[index]['details']["image"].isEmpty
                              ? Image.asset('lib/images/noimage.jpg')
                              : Image.network( 
                                items[index]['details']["image"][0],fit: BoxFit.fitWidth, 
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
                                  items[index]['details']["name"], 
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.oswald(textStyle:TextStyle(fontSize: 25))
                                ),
                              ), 

                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  items[index]['details']["category"],
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
        ) : noProduct();
      
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