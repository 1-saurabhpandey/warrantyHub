import 'package:flutter/material.dart'; 

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
              onTap: () => addNewDialog(context),
            )
          ],
        )
    );
  }

  Widget addNewDialog(BuildContext context) => 
    SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      children: <Widget>[
        Container(
          child:Form(
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
                      color: Colors.black,),),
                ),
                
                Padding(
                    padding: const EdgeInsets.only(left:20,right: 20,bottom: 20),
                    child: TextFormField(
                      controller: nameCon,
                      decoration: 
                      InputDecoration(
                        labelText: '$type name', 
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                      ),

                      validator: (val) => val!.isEmpty ? 'Enter $type name' : null,
                      onChanged: (val) => name = val
                      
                    ),),
                
                ElevatedButton(
                  child: Text('Add',style: TextStyle(color: Colors.white),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                  ) ,
                  onPressed: () async{
                    if(formkey.currentState!.validate()){
                      close(context,name);
                    }
                },
              )
            ]
          )
        ),
      )
    ],    
  );
}