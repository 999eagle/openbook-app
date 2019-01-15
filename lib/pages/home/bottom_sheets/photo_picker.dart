import 'dart:io';

import 'package:Openbook/provider.dart';
import 'package:Openbook/services/image_picker.dart';
import 'package:Openbook/widgets/icon.dart';
import 'package:Openbook/widgets/theming/primary_color_container.dart';
import 'package:Openbook/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBPhotoPickerBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ImagePickerService imagePickerService =
        OpenbookProvider.of(context).imagePickerService;

    List<Widget> photoPickerActions = [
      ListTile(
        leading: OBIcon(OBIcons.gallery),
        title: OBText(
          'From gallery',
        ),
        onTap: () async {
          File image = await imagePickerService.pickImage(
              imageType: OBImageType.post, source: ImageSource.gallery);
          Navigator.pop(context, image);
        },
      ),
      ListTile(
        leading: OBIcon(OBIcons.camera),
        title: OBText(
          'From camera',
        ),
        onTap: () async {
          File image = await imagePickerService.pickImage(
              imageType: OBImageType.post, source: ImageSource.camera);
          Navigator.pop(context, image);
        },
      )
    ];

    return OBPrimaryColorContainer(
      mainAxisSize: MainAxisSize.min,
      child: Column(
        children: photoPickerActions,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}