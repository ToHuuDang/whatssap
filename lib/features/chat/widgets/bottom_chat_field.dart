import 'package:whatsapp_ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/providers/message_reply_provider.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/message_reply_preview.dart';
import 'dart:io';
//import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_sound/public/flutter_sound_recorder.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';

class BottomChatField extends ConsumerStatefulWidget{

  final String recieverUserId;
 // final bool isGroupChat;
  const BottomChatField({
    Key?key,
    required this.recieverUserId,
  }) : super(key: key);

 @override
    ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField>{
   bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
 // FlutterSoundRecorder? _soundRecorder;
 // bool isRecorderInit = false;
 // bool isShowEmojiContainer = false;
  //bool isRecording = false;
 // FocusNode focusNode = FocusNode();


 void sendTextMessage() async {
  if(isShowSendButton){
    ref.read(chatControllerProvider).sendTextMessage(
      context,
       _messageController.text.trim(),
        widget.recieverUserId,
        );

        setState(() {
          _messageController.text = '';
        });
  }
 }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }


    @override
    Widget build(BuildContext context) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
               onChanged: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShowSendButton = false;
                    });
                  }
                },

              decoration: InputDecoration(
                filled: true,
                fillColor: mobileChatBoxColor,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: (){},
                          icon: const Icon(
                            Icons.emoji_emotions,
                            color: Colors.grey,
                          ),
                        ),
                         IconButton(
                          onPressed: (){},
                          icon: const Icon(
                            Icons.gif,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                suffixIcon: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       IconButton(
                          onPressed: (){},
                          icon: const Icon(
                            Icons.camera,
                            color: Colors.grey,
                          ),
                        ),
                         IconButton(
                          onPressed: (){},
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      
                    ],
                  ),
                ),
                hintText: 'Type a message!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  )
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
                bottom: 8,
                right: 2,
                left: 2,
              ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF128C7e),
              radius: 25,
              child: GestureDetector(
                child: Icon(
                      isShowSendButton ? Icons.send : Icons.mic,
                       color: Colors.white,
                ),
                onTap: sendTextMessage,
              ),
            ),
          )
        ],
      );
    }
}