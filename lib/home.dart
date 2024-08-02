import 'package:bluetoothprint/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';

class HomePage extends StatelessWidget {
  TextEditingController itemNameController = TextEditingController();

  TextEditingController itemQuantityController = TextEditingController();

  ReceiptController? receiptController;

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 23, 106, 144),
      appBar: AppBar(
        title: Text("Bluetooth Print",style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 23, 106, 144),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                bluetoothProvider.connected?bluetoothProvider.disconnect():bluetoothProvider.connectToDevice();
              },
              child: CircleAvatar(
                backgroundColor: bluetoothProvider.connected?const Color.fromARGB(255, 93, 171, 235):Colors.transparent,
                child: Icon(Icons.bluetooth_connected_outlined,color: Colors.white,),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<BluetoothDevice>(
                hint: Text("Device",style: TextStyle(color: Colors.white),),
                value: bluetoothProvider.selectedDevice,
                dropdownColor: Color.fromARGB(255, 23, 106, 144),
                onChanged: (BluetoothDevice? value) {
                  bluetoothProvider.setSelectedDevice(value);
                },
                items: bluetoothProvider.devices
                    .map((device) => DropdownMenuItem(
                          child: Text(device.name ?? "",style: TextStyle(color: Colors.white),),
                          value: device,
                        ))
                    .toList(),
                            ),
            
            SizedBox(height: 20),
            TextFormField(
              controller: itemNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                hintText: "Name",
                hintStyle: TextStyle(color: Color.fromARGB(255, 185, 184, 184)),
                fillColor: Colors.white,
                filled: true,
                
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: itemQuantityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                fillColor: Colors.white,
                filled: true,
                hintText: "Age",
                hintStyle: TextStyle(color: Color.fromARGB(255, 185, 184, 184))
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: (){
                 bluetoothProvider.addItem(
                  itemNameController.text.trim(),
                  itemQuantityController.text.trim(),
                );
                itemNameController.clear();
                itemQuantityController.clear();
              },
              child: Container(
                height: 40,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(child: Text('Add',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),)),
                
              ),
            ),
            SizedBox(height: 20),
            
            Expanded(
              child: Center(
                child: Receipt(
                  backgroundColor: Colors.white,
                  
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        border: TableBorder.all(),
                        columnWidths: {
                          0: FlexColumnWidth(2), 
                          1: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('Item Name',
                                      style:
                                          TextStyle(fontWeight: FontWeight.w700,)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('Qty',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                          ...bluetoothProvider.items.entries.map((entry) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(entry.key),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(entry.value),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                  onInitialized: (controller) {
                    receiptController = controller;
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){
                  bluetoothProvider.connected
                  ?  bluetoothProvider.printReceipt(receiptController)
                   : null;
                   bluetoothProvider.items.clear();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 75, 231, 245)
                  ),
                  child: Center(child: Text("Print Receipt",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
