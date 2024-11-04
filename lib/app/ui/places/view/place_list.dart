import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:weatherbet/app/controller/controller.dart';
import 'package:weatherbet/app/ui/places/widgets/place_card_list.dart';
import 'package:weatherbet/app/ui/widgets/text_form.dart';
import 'package:flutter/services.dart';
import 'package:weatherbet/app/ui/places/widgets/create_place.dart';

class PlaceList extends StatefulWidget {
  const PlaceList({super.key});

  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  final weatherController = Get.put(WeatherController());
  TextEditingController searchTasks = TextEditingController();
  String filter = '';

  applyFilter(String value) async {
    filter = value.toLowerCase();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    applyFilter('');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final titleMedium = textTheme.titleMedium;
    final colorScheme = context.theme.colorScheme;

    return Obx(
      () => weatherController.weatherCards.isEmpty
          ? _buildEmptyState(titleMedium)
          : _buildPlacesList(colorScheme),
    );
  }

  Widget _buildEmptyState(TextStyle? titleMedium) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceVariant.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/City.png',
                scale: 6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: Get.size.width * 0.8,
              child: Text(
                'noWeatherCard'.tr,
                textAlign: TextAlign.center,
                style: titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Добавить действие для добавления первого места
                Get.to(() => const CreatePlace());
              },
              icon: const Icon(IconsaxPlusLinear.add_circle),
              label: Text('addFirstPlace'.tr),
              style: TextButton.styleFrom(
                foregroundColor: context.theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList(ColorScheme colorScheme) {
    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: MyTextForm(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  labelText: 'search'.tr,
                  type: TextInputType.text,
                  icon: Icon(
                    IconsaxPlusLinear.search_normal_1,
                    size: 20,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  controller: searchTasks,
                  onChanged: applyFilter,
                  iconButton: searchTasks.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchTasks.clear();
                            applyFilter('');
                            HapticFeedback.lightImpact();
                          },
                          icon: Icon(
                            IconsaxPlusLinear.close_circle,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await weatherController.updateCacheCard(true);
          setState(() {});
        },
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        strokeWidth: 2,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: PlaceCardList(
            key: ValueKey(filter),
            searchCity: filter,
          ),
        ),
      ),
    );
  }
}
