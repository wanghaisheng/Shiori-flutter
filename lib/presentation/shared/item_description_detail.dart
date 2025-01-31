import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/images/primogem_icon.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ItemDescriptionDetail extends StatelessWidget {
  final String title;
  final Widget? body;
  final Color textColor;

  const ItemDescriptionDetail({
    super.key,
    required this.title,
    this.body,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemDescriptionTitle(title: title, textColor: textColor),
        if (body != null) body!,
      ],
    );
  }
}

class ItemDescriptionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const ItemDescriptionTitle({
    super.key,
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: PrimoGemIcon(),
      title: Transform.translate(
        offset: Styles.listItemWithIconOffset,
        child: Tooltip(
          message: title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall!.copyWith(color: textColor, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Divider(color: textColor, thickness: 2),
            ],
          ),
        ),
      ),
    );
  }
}
