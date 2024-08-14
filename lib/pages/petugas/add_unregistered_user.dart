import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';

class AddUnregisteredUserData extends StatefulWidget {
  const AddUnregisteredUserData({super.key});

  @override
  State<AddUnregisteredUserData> createState() =>
      _AddUnregisteredUserDataState();
}

class _AddUnregisteredUserDataState extends State<AddUnregisteredUserData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late String dateWasteComing;

  

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.background,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Input data sampah'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: const Text(
                    'Nama Pengirim*',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OpenSans',
                    ),
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 60,
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nama',
                  ),
                ),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: const Text(
                    'Tanggal Pengiriman/Datang*',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OpenSans',
                    ),
                  )),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  // height: 65,
                  child: DateTimeFormField(
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.black45),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.event_note),
                      labelText: 'Tanggal',
                    ),
                    mode: DateTimeFieldPickerMode.dateAndTime,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (e) =>
                        (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                    onDateSelected: (DateTime value) {
                      setState(() {
                        dateWasteComing = value.toString();
                      });
                      print(dateWasteComing);
                    },
                  )),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: const Text(
                    'Keterangan Lain',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OpenSans',
                    ),
                  )),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: TextField(
                    controller: noteController,
                    maxLines:
                        5, // or set to a specific number, such as 5 for 5 lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle the text input
                    },
                  )),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 110,
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    onPressed: () {},
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
