import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';

class BluetoothProvider with ChangeNotifier {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;
  Map<String, dynamic> items = {};

  BluetoothProvider() {
    initBluetooth();
  }

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  bool get connected => _connected;

  Future<void> initBluetooth() async {
    try {
      bool? isAvailable = await bluetooth.isAvailable;
      bool? isOn = await bluetooth.isOn;

      if (!isAvailable! || !isOn!) {
        print("Bluetooth is not available or not turned on.");
        return;
      }

      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      _devices = devices;
      notifyListeners();

      bluetooth.onStateChanged().listen((state) {
        _connected = state == BlueThermalPrinter.CONNECTED;
        notifyListeners();
      });
    } catch (e) {
      print("Error initializing Bluetooth: $e");
    }
  }

  void setSelectedDevice(BluetoothDevice? device) {
    _selectedDevice = device;
    notifyListeners();
  }

  void connectToDevice() {
    if (_selectedDevice != null) {
      bluetooth.connect(_selectedDevice!).catchError((error) {
        _connected = false;
        notifyListeners();
      });
    }
  }

  void disconnect() {
    bluetooth.disconnect();
    _connected = false;
    notifyListeners();
  }

  void addItem(String name, String quantity) {
    items[name] = quantity;
    notifyListeners();
  }

  void printReceipt(ReceiptController? receiptController) {
    if (_connected) {
      bluetooth.printNewLine();
      bluetooth.printCustom("Receipt", 3, 1);
      bluetooth.printNewLine();

      items.forEach((key, value) {
        bluetooth.printCustom("$key: $value", 1, 0);
      });

      bluetooth.printNewLine();
      bluetooth.printNewLine();
    }
  }
}
