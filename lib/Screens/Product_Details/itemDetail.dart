import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:warranty_tracker/Screens/Address_Details/NewAddress.dart';
import 'package:warranty_tracker/Screens/Product_Details/ItemBill.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/PreviewPage.dart';
import 'package:warranty_tracker/Services/DataService.dart';
import 'package:warranty_tracker/ViewModels/AddressViewModel.dart';
import 'package:warranty_tracker/ViewModels/ItemsViewModel.dart';


// ignore: must_be_immutable
class ItemDetail extends StatelessWidget {

  final productId ;
  ItemDetail({this.productId });

  late String status ;
  late int productListLength;
  String docSlot = '';
  
  @override
  Widget build(BuildContext context){ 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5458e1),
        title: Text('Product Details'),
        actions: [
          PopupMenuButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Delete'),
                value: 'delete',
              )
            ],
            onSelected: (value) => delete(context, productId , productListLength)
          )
        ]
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: itemDetails()
    );
  }

  Widget itemDetails(){

    return GetBuilder<ItemViewModel>(
      init: ItemViewModel(),
      builder: (itemData) => ListView.builder(
        itemCount: 1,
        itemBuilder: (context,index){

          List data = itemData.getItemList(); 
          productListLength = data.length;

          Map item = data.where((e) => e['productId'] == productId).first['details'];
          docSlot = data.where((e) => e['productId'] == productId).first['docId'];

          DateTime date = DateTime.now();

          var format = DateFormat('dd/MM/yyyy');
          String formattedExpiryDate = format.format(item["expiry"].toDate());
          String formattedPurchaseDate = format.format(item["purchase"].toDate());

          if(date.isBefore(item["expiry"].toDate())){
            status = 'Active';
          }
          else{
            status ='Expired';
          } 

          return Container(
            child: Column(
              children: <Widget>[

                item['image'].isNotEmpty
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
                      item['image'].length, (index){ 

                        return Card(
                         
                          elevation: 8, 
                          child: Padding( 
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              height: 30,width: 200,
                              child: InkWell(
                                child: Image.network( 
                                  item['image'][index],fit:BoxFit.fitWidth,
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
                                onTap: () => Get.to(() => Preview(item['name'], null, 'image', item['image'][index]))
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
                      leading: Icon(Icons.receipt,color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                      title: Text('Product Receipts',
                        style: TextStyle(fontSize: 15,color: Get.isDarkMode ? Colors.grey[400] : Colors.black),),
                      onTap:() =>
                        Get.to(() => ItemBill(productId: productId,))
                    )
                  ),
                ),

                productHighlightsCard(item, formattedPurchaseDate, formattedExpiryDate,context),
                
                productDetailsCard(item,context),
                retailerCard(item,context),

                addressCard(context,item['address_id'])

              ],
            ),
          );
        }
      ),
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
            style:GoogleFonts.sourceSansPro(textStyle:  TextStyle(color: Get.isDarkMode ? Colors.grey[400] : Colors.black,fontSize: 17),),)
          ), 
        ), 

        Expanded(
          child: Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            width: rowWidth,
            child: Align( 
              alignment: Alignment.topLeft, 
              child: Text(text2,
              style: GoogleFonts.sourceSansPro(textStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.black,fontSize: 17)),), 
            ),
          ),
        ),
      ],
    );
  }

  Widget productHighlightsCard(Map data, String purchase, String expiry, BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          child: Column( 
            children: <Widget>[
 
              Padding(
                padding: const EdgeInsets.only(bottom: 10), 
                child: Align( 
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Product Highlights',
                    style: GoogleFonts.oswald(
                      textStyle:  TextStyle(fontSize: 20,color: Get.isDarkMode ? Colors.grey[300] : Colors.black),
                    )
                  ),
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

  Widget productDetailsCard(Map data, BuildContext context){
    
    var format = DateFormat('dd/MM/yyyy');
    var formattedAddedOn = format.format(data['added_on'].toDate());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container( 
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          child: Column( 
            children: <Widget>[
 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align( 
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Product Details',
                    style: GoogleFonts.oswald(
                      textStyle:  TextStyle(fontSize: 20,color: Get.isDarkMode ? Colors.grey[300] : Colors.black),
                    )
                  ),
                ),
              ),

              rowData('Manufacturer', data['manufacturer'], context),
              rowData('Product', 'Product name goes here',context),
              rowData('Product Description', 'Product description goes here',context),
              rowData('Product Added On', formattedAddedOn,context),  
              rowData('Product Added By', data['added_by'].toString(),context),
              rowData('Product Invoice No', data['invoice_no'],context),


            ]
          )
        ),
      ),
    );
  }

  Widget retailerCard(Map data, BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Retailer Details',
                  style: GoogleFonts.oswald(
                    textStyle: TextStyle(fontSize: 20,color: Get.isDarkMode ? Colors.grey[300] : Colors.black),
                  )
                ),
              ),

              rowData('Retailer', data['retailer'] == null ? 'Not available' : data['retailer'] , context),
              rowData('Retailer Address', data['retailer_address'] == null ? 'Not available' : data['retailer_address'], context),
            ],
          ),
        ), 
      ),
    );
  }

  Widget addressCard(BuildContext context, String addId){    
    
    return GetBuilder<AddressViewModel>(
      init: AddressViewModel(),
      builder:(data){
        
        List? addressData = data.getAddressList();
        List? result = addressData != null ? addressData.where((e) => e['id'] == addId).toList() : null; 

        return Padding( 
          padding: EdgeInsets.all(8),
          child: Card(
            elevation: 4,
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
                          style: GoogleFonts.oswald(
                            textStyle: TextStyle(fontSize: 20,color: Get.isDarkMode ? Colors.grey[300] : Colors.black),
                          )
                        )
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          child: Icon(Icons.edit,color: Get.isDarkMode ? Colors.grey[300] : Colors.black),
                          onTap:() => updateAddress(context,addressData,addId),
                        )
                      ),
                    ],
                  ), 
                  
                  result == null
                  ? Padding (
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No address is linked with this product',
                      style: GoogleFonts.sourceSansPro(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,color: Get.isDarkMode ? Colors.grey[300] : Colors.black
                        )
                      )
                    ),
                  ) 
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          result[0]['person_name'],
                          style: GoogleFonts.sourceSansPro(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Get.isDarkMode ? Colors.grey[400] : Colors.black
                            )
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                                                
                          text: TextSpan(
                            style: GoogleFonts.sourceSansPro(textStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.black,fontSize: 17),),
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
                          style: GoogleFonts.sourceSansPro(textStyle: TextStyle(fontSize: 17,color: Get.isDarkMode ? Colors.grey[500] : Colors.black),),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8,5,8,8),
                        child: Text(result[0]['phone'].toString(),
                          style: GoogleFonts.sourceSansPro(textStyle: TextStyle(fontSize: 17,color: Get.isDarkMode ? Colors.grey[500] : Colors.black),),),
                      )
                    ],
                  ), 
                ],
              )
            ),
          ),
        );
      } 
    );
  }

  Future delete(BuildContext context , String productId, int productListLength){

    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this product?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel',style: TextStyle(color: Color(0xff5458e1)),),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Yes',style: TextStyle(color: Color(0xff5458e1)),),
            onPressed: () async {
              await DataService().deleteProducts(productId, productListLength,docSlot);
            },
          )
        ],
      )
    );
  }

  Future updateAddress(BuildContext context, List? data, String currentAddressId){
    String addressId = currentAddressId;
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

    return Get.bottomSheet(
      
      Container(
        height:200,
        color: Theme.of(context).cardColor,
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
                isDense: false,
                isExpanded: true,
                items: dropdownitems,
                hint: Text('Select an addresses'),
                onChanged: (val){
                  val == 'new address' 
                  ? Get.to(() => NewAddress())
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
                onPressed: () => addressId == currentAddressId 
                ? Get.back()
                : DataService().updateAddress(addressId, productId,docSlot),

                child: Text('Update details'),
              ),
            )
          ],
        ),
      ),
    );
  }
}