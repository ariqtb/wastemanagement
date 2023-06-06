import 'package:image_picker/image_picker.dart';
import 'dart:io';

final picker = ImagePicker();

// Future getImageFromGallery() async {
//   final pickedFile = await picker.getImage(source: ImageSource.gallery);

//   setState(() {
//     if (pickedFile != null) {
//       _imageFile = File(pickedFile.path);
//     } else {
//       print('No image selected.');
//     }
//   });
// }

// Future getImageFromCamera() async {
//   final pickedFile =
//       await picker.getImage(source: ImageSource.camera, imageQuality: 20);
//   setState(() {
//     if (pickedFile != null) {
//       _imageFile = File(pickedFile.path);
//       List<int> bytesPhoto = _imageFile!.readAsBytesSync();
//       // _imageFile = FlutterExifRotation.rotateImage(path: pickedFile.path);
//     } else {
//       print('No image selected.');
//     }
//   });
// }
