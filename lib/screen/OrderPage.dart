import 'package:admin/screen/AddPage.dart';
import 'package:admin/screen/GroceryPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}


class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Placed Order",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list,color: Colors.white,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GroceryPage(),
              ));
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: Firestore.instance.collection("orders").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                "Loading Data ...",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.documents[index];
              return ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: (ds['status'] == '0') ? Colors.blueGrey : Colors.greenAccent,
                  child: Text(
                      (ds['status'] == '0') ? "I" : "C",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  ds['name'],
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
                subtitle: Text(
                  ds['address'] +", "+ds['phone'],
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14.0),
                ),
                trailing: Text(
                  ds['date'],
                  style: TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
                backgroundColor: Colors.white,
                children: <Widget>[
                  ListView.builder(
                    itemCount: ds['cart'].length,
                    itemBuilder: (context, index){
                      List<String> list = ds['cart'][index].toString().split('@');
                      return ListTile(
                        title: Text(list[0],style: TextStyle(color: Colors.black,fontSize: 16.0),),
                        subtitle: Text("Total : "+list[1],style: TextStyle(color: Colors.blueGrey,fontSize: 14.0),),
                        trailing: Text(list[2],style: TextStyle(color: Colors.orangeAccent,fontSize: 14.0,fontWeight: FontWeight.bold),),
                      );
                    },
                  )
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.blue,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => AddPage(),
          ));
        },
      ),
    );
  }
}
