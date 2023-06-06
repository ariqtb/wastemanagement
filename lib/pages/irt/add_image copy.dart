// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import '../../components/alert.dart';

// class AddSortedImage extends StatefulWidget {
//   const AddSortedImage({super.key});

//   @override
//   State<AddSortedImage> createState() => _AddSortedImageState();
// }

// class _AddSortedImageState extends State<AddSortedImage> {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           final pop = await confirmDialog(context, [
//             ...['Konfirmasi', 'Apakah anda ingin membatalkan aksi?']
//           ]);
//           return pop ?? false;
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: true,
//             title: Text('data'),
//           ),
//           body: Center(
//             child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _imageFile != null
//                   ? Image.file(
//                       _imageFile!,
//                       height: 200,
//                     )
//                   : Container(
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.green, width: 3),
//                       ),
//                       child: Text('Belum ada foto yang dipilih')),
//               SizedBox(
//                 height: 20,
//               ),
//               ElevatedButton(
//                 onPressed: getImageFromCamera,
//                 child: Text('Ambil Foto'),
//               ),
//               SizedBox(
//                 height: 50,
//               ),
//               Container(
//                 child: Text('Masukkan berat'),
//               ),
//               DropdownButtonHideUnderline(
//                 child: SingleChildScrollView(
//                   physics: BouncingScrollPhysics(),
//                   child: DropdownButton<double>(
//                     value: weightValue,
//                     items: items
//                         .map((double value) => DropdownMenuItem<double>(
//                               value: value,
//                               child: Text('${value} Kg'),
//                             ))
//                         .toList(),
//                     hint: Text('Select weight'),
//                     onChanged: (double? value) {
//                       setState(() {
//                         weightValue = value;
//                       });
//                       print(weightValue);
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 50,
//               ),
//               weightValue != null && selectedIndex < 4 && _imageFile != null
//                   ? ElevatedButton(
//                       child: Text('Lanjut'),
//                       onPressed: () async {
//                         // print(photoList.length);
//                         // if (photoList.length <= 3) {
//                         await getImageData();
//                         if (photoList.length == 4) {
//                           await uploadData(wasteData);
//                           toNextPage(context);
//                         }
//                         if (photoList.length < 4) {
//                           setState(() {
//                             selectedIndex++;
//                           });
//                         }
//                         // }
//                         print('${photoList.length}');
//                         // if (photoList.length >= 4) {
//                         //   setState(() {
//                         //     isDone = true;
//                         //   });
//                         // }
//                       },
//                     )
//                   : Container(),
//               isLoading ? showModal(context) : Container(),
//             ],
//           ),
//           ),
//         ));
//   }
// }
