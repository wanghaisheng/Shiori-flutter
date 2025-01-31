import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/presentation/character/widgets/character_detail.dart';
import 'package:shiori/presentation/shared/details/constants.dart';
import 'package:shiori/presentation/shared/styles.dart';

class DetailBottomPortraitLayout extends StatelessWidget {
  final List<Widget> children;
  final bool isAnSmallImage;

  const DetailBottomPortraitLayout({
    super.key,
    required this.children,
    this.isAnSmallImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxTopHeight = getTopMarginForPortrait(context, charDescriptionHeight, isAnSmallImage);
    final device = getDeviceType(size);
    final width = size.width * (device == DeviceScreenType.mobile ? 0.9 : 0.8);
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.only(top: maxTopHeight),
        shape: Styles.cardItemDetailShape,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
