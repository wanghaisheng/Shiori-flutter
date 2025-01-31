import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/add_edit_item_bottom_sheet.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/material_item.dart';
import 'package:shiori/presentation/shared/child_item_disabled.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class ItemCard extends StatelessWidget {
  final int sessionKey;
  final int index;
  final String itemKey;
  final String name;
  final String image;
  final int rarity;
  final bool isWeapon;
  final List<ItemAscensionMaterialModel> materials;
  final bool isActive;
  final ElementType? elementType;
  final bool showMaterialUsage;

  const ItemCard({
    super.key,
    required this.sessionKey,
    required this.index,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.rarity,
    required this.isWeapon,
    required this.materials,
    required this.isActive,
    required this.showMaterialUsage,
    this.elementType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final cardColor = elementType != null ? elementType!.getElementColorFromContext(context) : rarity.getRarityColors().last;
    final size = MediaQuery.of(context).size;
    double height = size.height / 2.5;
    if (height > 700) {
      height = 700;
    } else if (height < 500) {
      height = 500;
    }

    return SizedBox(
      height: height,
      child: InkWell(
        borderRadius: Styles.mainCardBorderRadius,
        onTap: () => _editItem(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: Styles.mainCardShape,
          elevation: Styles.cardTenElevation,
          color: cardColor,
          child: ChildItemDisabled(
            isDisabled: !isActive,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FadeInImage(
                  fit: BoxFit.cover,
                  placeholderFit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(File(image)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: Styles.edgeInsetAll10,
                    decoration: Styles.commonCardBoxDecoration,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: name,
                          child: Container(
                            margin: Styles.edgeInsetAll5,
                            child: Text(
                              name,
                              style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Text(
                          s.materials,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall!.copyWith(color: Colors.white),
                        ),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            itemCount: materials.length,
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, index) {
                              final item = materials[index];
                              return MaterialItem(
                                itemKey: item.key,
                                type: item.type,
                                image: item.image,
                                requiredQuantity: item.requiredQuantity,
                                usedQuantity: item.usedQuantity,
                                remainingQuantity: item.remainingQuantity,
                                textColor: Colors.white,
                                sessionKey: sessionKey,
                                showMaterialUsage: showMaterialUsage,
                                iconSize: 40,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editItem(BuildContext context) async {
    final currentData = context.read<CalculatorAscMaterialsBloc>().getItem(index);

    context.read<CalculatorAscMaterialsItemBloc>().add(
          CalculatorAscMaterialsItemEvent.loadWith(
            key: itemKey,
            isCharacter: currentData.isCharacter,
            currentLevel: currentData.currentLevel,
            desiredLevel: currentData.desiredLevel,
            skills: currentData.skills,
            currentAscensionLevel: currentData.currentAscensionLevel,
            desiredAscensionLevel: currentData.desiredAscensionLevel,
            useMaterialsFromInventory: currentData.useMaterialsFromInventory,
          ),
        );

    await ModalBottomSheetUtils.showAppModalBottomSheet(
      context,
      EndDrawerItemType.calculatorAscMaterialsEdit,
      args: AddEditItemBottomSheet.buildNavigationArgsToEditItem(sessionKey, index, isActive, isAWeapon: isWeapon),
    );
  }
}
