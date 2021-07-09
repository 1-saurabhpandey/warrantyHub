import 'package:flutter/material.dart';
import 'package:get/get.dart'; 

class SearchList extends SearchDelegate{

  final List dataList;
  final String type;
  SearchList(this.dataList,this.type);

  var formkey = GlobalKey<FormState>();
  late String name;

  TextEditingController nameCon = TextEditingController();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [Container()];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context,null),
    );
  }
   
  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    final results = query.isEmpty ? dataList : dataList.where((element) => element.toLowerCase().startsWith(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context,index) =>
        Column(
          children: [
            ListTile(
              title: Text(results[index]),
              onTap: () => close(context,results[index]) 

            ), 
            index != results.length - 1 
            ? Container() 
            : ListTile(
              title: Text( 
                'Add new $type',
                style: TextStyle(
                  color: Color(0xff5458e1),
                  fontWeight: FontWeight.bold
                ),
              ),
              onTap: () => Get.bottomSheet(addNewDialog(context))
            )
          ],
        )
    );
  }

  Widget addNewDialog(BuildContext context){
    return Container(

      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Colors.white,
      ),

      child: Form(
        key: formkey,
        child: Column(
          children: <Widget>[
            SizedBox(height:10),

            Align(
              child: Container(
                width: 80,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  color: Colors.black,
                ),
              ),
            ),
            
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                child: TextFormField(
                  controller: nameCon,
                  decoration: 
                  InputDecoration(

                    labelText: '$type name', 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))
                    ),

                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff757575 ))),
                    labelStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                    
                  ),

                  validator: (val) => val!.isEmpty ? 'Enter $type name' : null,
                  onChanged: (val) => name = val
                  
                ),),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                child: Text('Add',style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                ) ,
                onPressed: () async{
                  if(formkey.currentState!.validate()){
                    close(context,name);
                  }
              },
          ),
            )
        ]
      )
  ),
    );
  }
    
}