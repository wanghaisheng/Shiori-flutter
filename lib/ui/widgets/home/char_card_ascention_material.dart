import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../pages/character_page.dart';

class CharCardAscentionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<String> charImgs;
  final String bossName;
  final List<int> days;

  const CharCardAscentionMaterial.fromDays({
    Key key,
    @required this.name,
    @required this.image,
    @required this.days,
    @required this.charImgs,
  })  : bossName = null,
        super(key: key);

  const CharCardAscentionMaterial.fromBoss({
    Key key,
    @required this.name,
    @required this.image,
    @required this.bossName,
    @required this.charImgs,
  })  : days = const [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final chars = charImgs
        .map(
          (e) => Container(
            margin: const EdgeInsets.all(3),
            child: InkWell(
              onTap: () => _gotoCharacterPage(e, context),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(e),
              ),
            ),
          ),
        )
        .toList();
    final obtainOn = days.isNotEmpty ? s.translateDays(days) : bossName;

    return Card(
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Container(
        padding: Styles.edgeInsetAll5,
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 35,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image, width: 120, height: 100),
                  Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tooltip(
                    message: obtainOn,
                    child: Text(
                      obtainOn,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.subtitle2.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 60,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: chars,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _gotoCharacterPage(String image, BuildContext context) async {
    context.read<CharacterBloc>().add(CharacterEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => CharacterPage());
    await Navigator.push(context, route);
  }
}
