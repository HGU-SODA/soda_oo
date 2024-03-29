import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oo/screen/mainscreen.dart';
import 'package:oo/screen/setting.dart';
import '../login/randomcode.dart';
import '../main2.dart';
import '../theme/color.dart';
import '../theme/text.dart';

String roomCode = RandomRoomScreen.roomCode;

class albumPage extends StatelessWidget {
  const albumPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.green),
      home: const MultipleImageSelector(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MultipleImageSelector extends StatefulWidget {
  const MultipleImageSelector({
    Key? key,
  }) : super(key: key);

  @override
  State<MultipleImageSelector> createState() => _MultipleImageSelectorState();
}

class _MultipleImageSelectorState extends State<MultipleImageSelector> {
  final picker = ImagePicker();
  TextEditingController commentController = TextEditingController();
  List<String> imageUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppColor.text,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp2()),
            );
          },
        ),
        title: Text(
          '공유앨범',
          style: b20,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 36),
            child: Container(
              width: 110,
              height: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xffC5A0CB),
                ),
                onPressed: () {
                  getImages();
                },
                child: Text(
                  '업로드',
                  style: b18.copyWith(color: AppColor.background),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 0, 40),
            child: Row(
              children: [
                Image.asset(
                  '/Users/parkjiwon/Desktop/soda/oo/assets/podopurple.png',
                  width: 164,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 42),
                  child: Text(
                    settingPage.fm,
                    style: b23,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            indent: 15,
            endIndent: 15,
            color: Color(0xff424242),
            thickness: 1,
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(roomCode)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>?;

                  if (data != null) {
                    imageUrls = List<String>.from(data['images'] ?? []);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    //physics: const NeverScrollableScrollPhysics(),
                    itemCount: imageUrls.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1,
                      crossAxisCount: 2,
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 7,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          _showCommentDialog(imageUrls[index]);
                        },
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.fill,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(String imageUrl) {
    commentController.text = '';
    List<dynamic> comments = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.textbox,
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl),
              SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomCode)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>?;

                    if (data != null) {
                      comments = List<dynamic>.from(data['comments'] ?? []);
                    }
                  }

                  return Column(
                    children: comments.map((comment) {
                      if (comment['imageUrl'] == imageUrl) {
                        return ListTile(
                          leading: Image.asset(
                            '/Users/parkjiwon/Desktop/soda/oo/assets/minipodo.png',
                            width: 48,
                          ),
                          title: Text(comment['comment']),
                        );
                      } else {
                        return Container();
                      }
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: '댓글 남기기',
                  hintStyle: l15g.copyWith(fontSize: 20),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColor.texts),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColor.texts),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: b18,
              ),
            ),
            TextButton(
              onPressed: () {
                _addComment(imageUrl, commentController.text);
                Navigator.of(context).pop();
              },
              child: Text(
                '올리기',
                style: b18,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getImages() async {
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 10,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    List<XFile>? xfilePicks = pickedFiles;

    if (xfilePicks != null && xfilePicks.isNotEmpty) {
      List<File> files = xfilePicks.map((xfile) => File(xfile.path)).toList();
      _updateImagesInFirestore(files);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택된 이미지가 없습니다.')),
      );
    }
  }

  void _updateImagesInFirestore(List<File> files) async {
    try {
      List<String> imageURLs = [];
      for (var file in files) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('images/$fileName');
        await firebaseStorageRef.putFile(file);
        String imageURL = await firebaseStorageRef.getDownloadURL();
        imageURLs.add(imageURL);
      }

      // Update images field in Firestore
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomCode)
          .update({'images': FieldValue.arrayUnion(imageURLs)});
    } catch (e) {
      print('이미지 업로드 오류: $e');
      // 오류 처리
    }
  }

  void _addComment(String imageUrl, String comment) async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomCode)
          .update({
        'comments': FieldValue.arrayUnion([
          {'imageUrl': imageUrl, 'comment': comment}
        ])
      });
      setState(() {
        commentController.text = comment;
      });
    } catch (e) {
      print('댓글 추가 오류: $e');
      // 오류 처리
    }
  }

  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
