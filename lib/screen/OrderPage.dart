import 'package:admin/screen/AddPage.dart';
import 'package:admin/screen/GroceryPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _sckey = GlobalKey<ScaffoldState>();

  Widget _okBtn(ds){
    return FlatButton(
      child: Text("Yes"),
      onPressed: () {
        Firestore.instance
            .collection("orders")
            .document(ds.documentID)
            .updateData({'status': 1});
       setState(() {
         Navigator.pop(context);
       });
      },
    );
  }

  Widget _noBtn() {
    return FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  AlertDialog _alertDialog(ds) {
    return AlertDialog(
      title: Text("Delivery Status"),
      content: Text("Is Order Delivered?"),
      actions: <Widget>[
        _noBtn(),
        _okBtn(ds),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sckey,
      appBar: AppBar(
        title: Text(
          "Placed Order",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.list,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
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
                leading: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: (ds['status'] == '0')
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
                    child: (ds['status'] == '0') ? Icon(Icons.shopping_cart,color: Colors.white,) : Icon(Icons.done,color: Colors.white,),
                  ),
                  onTap: () {
                    if (ds['status'] == 1) return null;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _alertDialog(ds);
                      },
                    );
                  },
                ),
                title: Text(
                  ds['name'],
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ds['phone'] + ", " + ds['address'] + "\n",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14.0),
                    ),
                    Text(
                      ds['date'] + "\n",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14.0),
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: ds['cart'].length,
                    itemBuilder: (context, index) {
                      print(ds['cart'].length);
                      List<String> list =
                          ds['cart'][index].toString().split('@');
                      return ListTile(
                        title: Text(
                          list[0],
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                        subtitle: Text(
                          "Total : " + list[1],
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 14.0),
                        ),
                        trailing: Text(
                          list[2],
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold),
                        ),
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
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(),
              ));
        },
      ),
    );
  }
}
