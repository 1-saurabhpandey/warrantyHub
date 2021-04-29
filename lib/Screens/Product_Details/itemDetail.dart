import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Address_Details/newAddress.dart';
import 'package:warranty_tracker/Screens/Product_Details/itembill.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/preview.dart';
import 'package:warranty_tracker/Services/database.dart';


class ItemDetail extends StatefulWidget {

 final productId ;

  ItemDetail({this.productId });

   @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {

  late String status ;
  late int productListLength;
  
  @override
  Widget build(BuildContext context){ 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5458e1),
        title: Text('Product Details'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Delete'),
                value: 'delete',
              )
            ],
            onSelected: (value) => delete(context, widget.productId , productListLength)
          )
        ]
      ),
      backgroundColor: Color(0xfff0f4ff),
      body: itemDetails()
    );
  }

  Widget itemDetails(){

    List? addressData = Provider.of<DataModel>(context).getAddressData();
    var data = Provider.of<DataModel>(context).getProductsData();

    //to check before deleting whether this is last product of list or not
    List? productIdList = data['products'] ?? null;
    productListLength = productIdList != null ?  productIdList.length : 0;
    
    
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context,index){
                       
        Map result = data[widget.productId];        
        DateTime date = DateTime.now();
        var format = DateFormat('dd/MM/yyyy'); 

        String formattedExpiryDate = format.format(result["expiry"].toDate());

        String formattedPurchaseDate = format.format(result["purchase"].toDate());
                      
        
        if(date.isBefore(result["expiry"].toDate())){
          status = 'Active';
        }else{ 
          status ='Expired';
        }
      

        return Container(
          child: Column(
            children: <Widget>[

              result['image'] != null 
                ? CarouselSlider(
                  options: CarouselOptions(
                    height: 250, autoPlay: true,
                    viewportFraction: 0.65, 
                    autoPlayInterval: Duration(seconds: 4), 
                    autoPlayCurve: Curves.decelerate,
                    pauseAutoPlayOnTouch: true,
                    enlargeCenterPage: true,
                  ),

                  items: List.generate(
                    result['image'].length, (index){ 

                      return Card(
                        color: Colors.white,
                        elevation: 8, 
                        child: Padding( 
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            height: 30,width: 200,
                            child: InkWell(
                              child: Image.network( 
                                result['image'][index],fit:BoxFit.fitWidth,
                                loadingBuilder: (context, child, loadingProgress){
                                  return loadingProgress == null 
                                  ? child 
                                  : Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null 
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null
                                    ),
                                  );
                                },
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Preview(result['name'], null, 'image', result['image'][index]))),
                            )
                          ),
                        ),
                      );
                    }
                  )
                )
              : Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 200,width: 200,
                  child: InkWell(
                    child: Image.asset('lib/images/noimage.jpg')
                  ) 
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top:5.0,bottom: 3), 
                child: Chip(
                  // shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green),borderRadius: BorderRadius.circular(20)), 
                  label: Text(
                    status, style: TextStyle(
                    fontSize: 16,fontWeight: FontWeight.bold,
                    color: status == 'Active' ? Colors.green : Colors.red
                  )),  
                  
                  backgroundColor: status == 'Active' ? Colors.green[100] : Colors.red[100], 
                )
              ), 
              
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.receipt),
                    title: Text('Product Receipts',
                      style: TextStyle(fontSize: 15),),
                    onTap:() =>
                      WidgetsBinding.instance!.addPostFrameCallback((_) async {
                          
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Receipt(productid: widget.productId,)));
                      }
                    )
                  ),
                ),
              ),
              
              productHighlightsCard(result, formattedPurchaseDate, formattedExpiryDate),
              productDetailsCard(result),
              retailerCard(result),
              addressCard(addressData, result['address_id'])

            ],
          ),
        );
      }
    );
  }

  Widget rowData(String text1, String text2, BuildContext context){
    var rowWidth = (MediaQuery.of(context).size.width - MediaQuery.of(context).padding.horizontal) / 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: <Widget>[

        Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          width: rowWidth,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(text1,
            style:GoogleFonts.sourceSansPro(textStyle:  TextStyle(color: Colors.grey[600],fontSize: 17),),)
          ), 
        ), 

        Expanded(
          child: Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            width: rowWidth,
            child: Align( 
              alignment: Alignment.topLeft, 
              child: Text(text2,
              style: GoogleFonts.sourceSansPro(textStyle: TextStyle(color: Colors.black,fontSize: 17),),) 
            ),
          ),
        ),
      ],
    );
  }

  Widget productHighlightsCard(Map data, String purchase, String expiry){

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          child: Column( 
            children: <Widget>[
 
              Padding(
                padding: const EdgeInsets.only(bottom: 10), 
                child: Align( 
                  alignment: Alignment.topLeft,
                  child: Text('Product Highlights',
                    style: GoogleFonts.oswald(textStyle:  TextStyle(fontSize: 20),)),
                ),
              ),
              
              rowData('Product Name', data['name'],context),
              rowData('Product Category', data['category'],context),
              rowData('Purchase Date', purchase,context),
              rowData('Expiry Date', expiry,context),
            ]
          )
        ),
      ),
    );
  }

  Widget productDetailsCard(Map data){
    
    var format = DateFormat('dd/MM/yyyy');
    String formattedAddedOn = format.format(data['added_on'].toDate());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container( 
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          child: Column( 
            children: <Widget>[
 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align( 
                  alignment: Alignment.topLeft,
                  child: Text('Product Details',
                  style: GoogleFonts.oswald(textStyle:  TextStyle(fontSize: 20),)),),
              ),

              rowData('Manufacturer', data['manufacturer'], context),
              rowData('Product', 'Product name goes here',context),
              rowData('Product Description', 'Product description goes here',context),
              rowData('Product Added On', formattedAddedOn,context),  
              rowData('Product Added By', data['added_by'],context),
              rowData('Product Invoice No', data['invoice_no'],context),


            ]
          )
        ),
      ),
    );
  }

  Widget retailerCard(Map data){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
               alignment: Alignment.topLeft,
               child: Text('Retailer Details',
               style: GoogleFonts.oswald(
                textStyle: TextStyle(fontSize: 20),)),),

              rowData('Retailer', data['retailer'] == null ? 'Not available' : data['retailer'] , context),
              rowData('Retailer Address', data['retailer_address'] == null ? 'Not available' : data['retailer_address'], context),
            ],
          ),
        ), 
      ),
    );
  }

  Widget addressCard(List? data, String addId){

    // show only that address which have this id
    List? result = data != null ? data.where((e) => e['id'] == addId).toList() : null; 
    
    return Padding( 
      padding: EdgeInsets.all(8),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(8.0),

          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Address Details',
                      style: GoogleFonts.oswald(textStyle: TextStyle(fontSize: 20),))),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      child: Icon(Icons.edit),
                      onTap:() => updateAddress(data),
                    )
                  ),
                ],
              ), 
              
              result == null
              ? Padding (
                padding: const EdgeInsets.all(8.0),
                child: Text('No address is linked with this product',
                  style: GoogleFonts.sourceSansPro(textStyle: TextStyle(fontWeight: FontWeight.w500,
                    fontSize: 18))),
              ) 
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      result[0]['person_name'],
                      style: GoogleFonts.sourceSansPro(textStyle: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 18)),),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                                            
                      text: TextSpan(
                        style: GoogleFonts.sourceSansPro(textStyle: TextStyle(color: Colors.black,fontSize: 17),),
                        children: [
                          TextSpan(
                            text: result[0]['address'] + ', ',
                                                  
                          ),
                          TextSpan(
                            text: result[0]['city'] + ', '
                          ),
                          TextSpan(
                            text: result[0]['state'] + '- '
                          ),
                          TextSpan(
                            text: result[0]['pincode'].toString()
                          ),
                        ]
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(8,8,8,5),
                    child: Text(result[0]['landmark'],
                      style: GoogleFonts.sourceSansPro(textStyle: TextStyle(fontSize: 17),),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8,5,8,8),
                    child: Text(result[0]['phone'].toString(),
                      style: GoogleFonts.sourceSansPro(textStyle: TextStyle(fontSize: 17),),),
                  )
                ],
              ), 
            ],
          )
        ),
      ),
    );
  }

  Future delete(BuildContext context , String productId, int productListLength){

    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: () {
                Navigator.of(context,rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: Text('Yes',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: ()async {
                var result = await DataService().deleteProducts(productId, productListLength);

                Navigator.of(context,rootNavigator: true).pop();
                Navigator.of(context).pop(result);
              },
            )
          ],
        );
      }
    ); 
  }

  Future updateAddress(List? data){

    late String addressId;

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context){  

        List<DropdownMenuItem> dropdownitems = [];

        dropdownitems.add(
          DropdownMenuItem(
            child: Text('Add new address', style: TextStyle(color: Color(0xff5458e1), fontWeight: FontWeight.bold),),
            value: 'new address',
          )
        );

         if(data != null){
          for(int i=0 ; i< data.length; i++){
            dropdownitems.add(
              DropdownMenuItem(
                child: Text(
                  data[i]['address'] + ',' + data[i]['city'] 
                  + ',' + data[i]['state'] + ',' + data[i]['pincode'].toString() 
                ),
                value: data[i]['id'],
              )
            );
          }
        }

        return Container(
          child: ListView(
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  child: Container(
                    width: 60,height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: Colors.grey))
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 17, 12, 17),
                child: DropdownButtonFormField<dynamic>(
                  items: dropdownitems,
                  hint: Text('Select an addresses'),
                  onChanged: (val){
                    val == 'new address' 
                    ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewAddress())).then((value) => Navigator.of(context).pop())
                    : addressId = val;
                  },
                  value: addressId,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                  ),
                  onPressed: () => DataService().updateAddress(addressId, widget.productId).then((value) => Navigator.of(context).pop()),
                  child: Text('Update details'),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}