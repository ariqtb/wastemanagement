import 'package:flutter/material.dart';

Future<void> showDialogSuccess(BuildContext context, msg) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${msg[0]}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'))
          ],
        );
      });
}

Future<void> showDialogError(BuildContext context, msg) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: AlertDialog(
            title: Text('${msg[0]}'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('${msg[1]}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Okay'))
            ],
          ),
        );
      });
}

// CONTOH PENGGUNAAN
// final pop = await confirmDialog(context, [
//           ...['Konfirmasi', 'Apakah anda ingin keluar?']
//         ]);
Future<bool?> confirmDialog(BuildContext context, msg) async {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('${msg[0]}'),
            content: Text('${msg[1]}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Tidak')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('Ya')),
            ],
          ));
}

Future<bool?> exitDialog(BuildContext context, msg) async {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('${msg[0]}'),
            content: Text('${msg[1]}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Tidak')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  },
                  child: Text('Ya')),
            ],
          ));
}

showModal(context) {
  return showModalBottomSheet(
    isDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200.0,
        color: Colors.white,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Data sedang disimpan'),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator()
          ]),
        ),
      );
    },
  );
}
