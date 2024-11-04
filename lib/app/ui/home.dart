import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:isar/isar.dart';
import 'package:weatherbet/app/api/api.dart';
import 'package:weatherbet/app/api/city_api.dart';
import 'package:weatherbet/app/controller/controller.dart';
import 'package:weatherbet/app/data/db.dart';
import 'package:weatherbet/app/ui/places/view/place_list.dart';
import 'package:weatherbet/app/ui/places/widgets/create_place.dart';
import 'package:weatherbet/app/ui/geolocation.dart';
import 'package:weatherbet/app/ui/main/view/main.dart';
import 'package:weatherbet/app/ui/map/view/map.dart';
import 'package:weatherbet/app/ui/settings/view/settings.dart';
import 'package:weatherbet/app/utils/show_snack_bar.dart';
import 'package:weatherbet/main.dart';
import 'package:weatherbet/app/ui/sounds/view/sounds_view.dart';
import 'package:weatherbet/app/controller/sound_controller.dart';
import 'package:flutter/services.dart';
import 'package:weatherbet/theme/theme.dart';

extension GradientOpacity on LinearGradient {
  LinearGradient withOpacity(double opacity) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: stops,
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
    );
  }

  LinearGradient scale(double scale) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: stops,
      colors: colors.map((color) => color.withOpacity(scale)).toList(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int tabIndex = 0;
  bool visible = false;
  final _focusNode = FocusNode();
  late TabController tabController;
  final weatherController = Get.put(WeatherController());
  final soundController = Get.put(SoundController());
  final _controller = TextEditingController();

  final List<Widget> pages = [
    const MainPage(),
    const PlaceList(),
    const SoundsView(),
    if (!settings.hideMap) const MapPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    getData();
    setupTabController();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void setupTabController() {
    tabController = TabController(
      initialIndex: tabIndex,
      length: pages.length,
      vsync: this,
    );

    tabController.animation?.addListener(() {
      int value = (tabController.animation!.value).round();
      if (value != tabIndex) setState(() => tabIndex = value);
    });

    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
  }

  void getData() async {
    await weatherController.deleteCache();
    await weatherController.updateCacheCard(false);
    await weatherController.setLocation();
  }

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
    tabController.animateTo(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final labelLarge = textTheme.labelLarge;
    final colorScheme = context.theme.colorScheme;
    final brightness = context.theme.brightness;

    final textStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return DefaultTabController(
      length: pages.length,
      child: ScaffoldMessenger(
        key: globalKey,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: _buildLeadingButton(),
            title: _buildTitle(textStyle, labelLarge),
            actions: _buildActions(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: brightness == Brightness.light
                      ? lightPrimaryGradient.scale(0.1)
                      : darkPrimaryGradient.scale(0.1),
                ),
                height: 2.0,
              ),
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: TabBarView(
                  controller: tabController,
                  children: pages,
                ),
              ),
              if (weatherController.isLoading.isTrue)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: brightness == Brightness.light
                          ? lightCardGradient.withOpacity(0.9)
                          : darkCardGradient.withOpacity(0.9),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
          floatingActionButton: _buildFloatingActionButton(context),
        ),
      ),
    );
  }

  Widget _buildTitle(TextStyle? textStyle, TextStyle? labelLarge) {
    return switch (tabIndex) {
      0 => visible
          ? RawAutocomplete<Result>(
              focusNode: _focusNode,
              textEditingController: _controller,
              fieldViewBuilder: (_, __, ___, ____) {
                return TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: labelLarge?.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                  ),
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Result>.empty();
                }
                return WeatherAPI().getCity(textEditingValue.text, locale);
              },
              onSelected: (Result selection) async {
                await weatherController.deleteAll(true);
                await weatherController.getLocation(
                  double.parse('${selection.latitude}'),
                  double.parse('${selection.longitude}'),
                  selection.admin1,
                  selection.name,
                );
                visible = false;
                _controller.clear();
                _focusNode.unfocus();
                setState(() {});
              },
              displayStringForOption: (Result option) =>
                  '${option.name}, ${option.admin1}',
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<Result> onSelected,
                  Iterable<Result> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    elevation: 4.0,
                    child: SizedBox(
                      width: 250,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Result option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: ListTile(
                              title: Text(
                                '${option.name}, ${option.admin1}',
                                style: labelLarge,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            )
          : Obx(
              () {
                final location = weatherController.location;
                final city = location.city;
                final district = location.district;
                return Text(
                  weatherController.isLoading.isFalse
                      ? district!.isEmpty
                          ? '$city'
                          : city!.isEmpty
                              ? district
                              : '$city' ', $district'
                      : settings.location
                          ? 'search'.tr
                          : (isar.locationCaches.where().findAllSync())
                                  .isNotEmpty
                              ? 'loading'.tr
                              : 'searchCity'.tr,
                  style: textStyle,
                );
              },
            ),
      1 => Text('cities'.tr, style: textStyle),
      2 => Text('nature_sounds'.tr, style: textStyle),
      3 => settings.hideMap
          ? Text('settings_full'.tr, style: textStyle)
          : Text('map'.tr, style: textStyle),
      4 => Text('settings_full'.tr, style: textStyle),
      int() => null,
    } ?? const SizedBox.shrink(); // Добавляем fallback для null
  }

  List<Widget>? _buildActions() {
    return switch (tabIndex) {
      0 => [
          IconButton(
            onPressed: () {
              if (visible) {
                _controller.clear();
                _focusNode.unfocus();
                visible = false;
              } else {
                visible = true;
              }
              setState(() {});
            },
            icon: Icon(
              visible
                  ? IconsaxPlusLinear.close_circle
                  : IconsaxPlusLinear.search_normal_1,
              size: 18,
            ),
          )
        ],
      int() => null,
    };
  }

  Widget _buildLeadingButton() {
    final button = switch (tabIndex) {
      0 => IconButton(
          onPressed: () {
            Get.to(() => const SelectGeolocation(isStart: false),
                transition: Transition.downToUp);
          },
          icon: const Icon(
            IconsaxPlusLinear.global_search,
            size: 18,
          ),
        ),
      int() => null,
    };
    return button ?? const SizedBox.shrink(); // Возвращаем пустой виджет если null
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final brightness = context.theme.brightness;
    
    return tabIndex == 1
        ? Container(
            decoration: BoxDecoration(
              gradient: brightness == Brightness.light
                  ? lightPrimaryGradient
                  : darkPrimaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (brightness == Brightness.light
                          ? lightPrimaryGradient
                          : darkPrimaryGradient)
                      .colors
                      .first
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.transparent,
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: false,
                builder: (BuildContext context) => const CreatePlace(),
              ),
              child: const Icon(IconsaxPlusLinear.add, color: Colors.white),
            ),
          )
        : const SizedBox.shrink();
  }

  List<NavigationDestination> _buildNavigationDestinations() {
    return [
      _buildNavDestination(
        IconsaxPlusLinear.cloud_sunny,
        IconsaxPlusBold.cloud_sunny,
        'name'.tr,
      ),
      _buildNavDestination(
        IconsaxPlusLinear.buildings,
        IconsaxPlusBold.buildings,
        'cities'.tr,
      ),
      _buildNavDestination(
        IconsaxPlusLinear.music,
        IconsaxPlusBold.music,
        'nature_sounds'.tr,
      ),
      if (!settings.hideMap)
        _buildNavDestination(
          IconsaxPlusLinear.map,
          IconsaxPlusBold.map,
          'map'.tr,
        ),
      _buildNavDestination(
        IconsaxPlusLinear.setting_2,
        IconsaxPlusBold.setting_2,
        'settings_full'.tr,
      ),
    ];
  }

  NavigationDestination _buildNavDestination(
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    return NavigationDestination(
      icon: Icon(icon, size: 20),
      selectedIcon: Icon(selectedIcon, size: 20),
      label: label,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final brightness = context.theme.brightness;
    
    return Container(
      decoration: BoxDecoration(
        gradient: brightness == Brightness.light
            ? lightCardGradient
            : darkCardGradient,
        border: Border(
          top: BorderSide(
            color: colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        elevation: 0,
        height: 65,
        backgroundColor: Colors.transparent,
        indicatorColor: brightness == Brightness.light
            ? lightSecondaryGradient.colors.first.withOpacity(0.1)
            : darkSecondaryGradient.colors.first.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 400),
        onDestinationSelected: (int index) {
          HapticFeedback.lightImpact();
          changeTabIndex(index);
        },
        selectedIndex: tabIndex,
        destinations: _buildNavigationDestinations(),
      ),
    );
  }

  // Обновляем метод для поиска
  Widget _buildSearchField(TextStyle? labelLarge) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: labelLarge?.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'search'.tr,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
          prefixIcon: Icon(
            IconsaxPlusLinear.search_normal_1,
            size: 18,
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // Обновляем внешний вид списка результатов поиска
  Widget _buildSearchResults(Iterable<Result> options, AutocompleteOnSelected<Result> onSelected, TextStyle? labelLarge) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
        shadowColor: context.theme.colorScheme.shadow.withOpacity(0.1),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final Result option = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(option),
                borderRadius: index == 0
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : index == options.length - 1
                        ? const BorderRadius.vertical(bottom: Radius.circular(12))
                        : null,
                child: ListTile(
                  title: Text(
                    '${option.name}, ${option.admin1}',
                    style: labelLarge,
                  ),
                  leading: const Icon(IconsaxPlusLinear.location),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
