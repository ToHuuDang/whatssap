import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/providers/message_reply_provider.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repository.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/models/chat_contact.dart';
import 'package:whatsapp_ui/models/group.dart';
import 'package:whatsapp_ui/models/message.dart';
import 'package:whatsapp_ui/models/user_model.dart';
final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
   final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
        List<ChatContact> contacts = [];
            for(var document in event.docs){
            var chatContact = ChatContact.fromMap(document.data());

            var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
            
        var user = UserModel.fromMap(userData.data()!);
      contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

   void _saveDataToContactsSubcollection(
      UserModel senderUserData,
      UserModel? recieverUserData,
      String text,
     DateTime timeSent,
      String recieverUserId,
    //  bool isGroupChat,
   )  async{

    // users -> reciever user id => chats -> current user id -> set data
        var senderChatContact = ChatContact(
        name: recieverUserData!.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .set(
            senderChatContact.toMap(),
          );
    }
  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
   required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
  //  required MessageReply? messageReply,
   // required String senderUsername,
    required String? recieverUserName,
   // required bool isGroupChat,
  }) async {
      final message = Message(
      senderId: auth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,

      );

     // users -> sender id -> reciever id -> messages -> message id -> store message
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );

  }

  void sendTextMessage({
      required BuildContext context,
      required String text,
      required String recieverUserId,
      required UserModel senderUser,
     // required MessageReply? messageReply,
     // required bool isGroupChat,

  }) async {
    try{
        var timeSent = DateTime.now();
        UserModel? recieverUserData;

        var userDataMap = await firestore.collection('users').doc(recieverUserId).get();

        recieverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
         senderUser,
         recieverUserData,
         text,
         timeSent,
         recieverUserId,
        // isGroupChat,
      );

       _saveMessageToMessageSubcollection(
       recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
         messageId: messageId,
         username: senderUser.name,
        // messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        // senderUsername: senderUser.name,
        // isGroupChat: isGroupChat,
       );

    } catch (e) {
       showSnackBar(context: context, content: e.toString());
    }
  }


}