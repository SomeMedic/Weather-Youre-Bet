import 'dart:io';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weatherbet/app/api/api.dart';
import 'package:weatherbet/app/api/city_api.dart';
import 'package:weatherbet/app/controller/controller.dart';
import 'package:weatherbet/app/data/db.dart';
import 'package:weatherbet/app/ui/places/view/place_info.dart';
import 'package:weatherbet/app/ui/places/widgets/create_place.dart';
import 'package:weatherbet/app/ui/places/widgets/place_card.dart';
import 'package:weatherbet/app/ui/widgets/weather/status/status_data.dart';
import 'package:weatherbet/app/ui/widgets/weather/status/status_weather.dart';
import 'package:weatherbet/app/ui/widgets/text_form.dart';
import 'package:weatherbet/main.dart';
import 'dart:math' as math; // Добавляем импорт для pow

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);
  final weatherController = Get.put(WeatherController());
  final statusWeather = StatusWeather();
  final statusData = StatusData();
  final Future<CacheStore> _cacheStoreFuture = _getCacheStore();

  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();

  final bool _isDarkMode = Get.theme.brightness == Brightness.dark;
  WeatherCard? _selectedWeatherCard;
  bool _isCardVisible = false;
  late final AnimationController _animationController;
  late final Animation<Offset> _offsetAnimation;
  static const _useTransformerId = 'useTransformerId';
  final bool _useTransformer = true;

  final _focusNode = FocusNode();
  late final TextEditingController _controllerSearch = TextEditingController();

  // Добавляем контроллер для лайдера
  double _currentZoom = 8.0;
  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

  static Future<CacheStore> _getCacheStore() async {
    final dir = await getTemporaryDirectory();
    return FileCacheStore('${dir.path}${Platform.pathSeparator}MapTiles');
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    _controllerSearch.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetMapOrientation({LatLng? center, double? zoom}) {
    _animatedMapController.animateTo(
      customId: _useTransformer ? _useTransformerId : null,
      dest: center,
      zoom: zoom,
      rotation: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onMarkerTap(WeatherCard weatherCard) {
    setState(() {
      _selectedWeatherCard = weatherCard;
    });
    _animationController.forward();
    _isCardVisible = true;

    if (_fabKey.currentState?.isOpen == true) {
      _fabKey.currentState?.toggle();
    }
  }

  void _hideCard() {
    _animationController.reverse().then((_) {
      setState(() {
        _isCardVisible = false;
        _selectedWeatherCard = null;
      });
    });
    _focusNode.unfocus();
  }

  Widget _buidStyleMarkers(int weathercode, String time, String sunrise,
      String sunset, double temperature2M) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            statusWeather.getImageNow(
              weathercode,
              time,
              sunrise,
              sunset,
            ),
            scale: 18,
          ),
          const MaxGap(5),
          Text(
            statusData
                .getDegree(roundDegree ? temperature2M.round() : temperature2M),
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMainLocationMarker(
      WeatherCard weatherCard, int hourOfDay, int dayOfNow) {
    return Marker(
      height: 50,
      width: 100,
      point: LatLng(weatherCard.lat!, weatherCard.lon!),
      child: GestureDetector(
        onTap: () => _onMarkerTap(weatherCard),
        child: _buidStyleMarkers(
          weatherCard.weathercode![hourOfDay],
          weatherCard.time![hourOfDay],
          weatherCard.sunrise![dayOfNow],
          weatherCard.sunset![dayOfNow],
          weatherCard.temperature2M![hourOfDay],
        ),
      ),
    );
  }

  Marker _buildCardMarker(WeatherCard weatherCardList) {
    return Marker(
      height: 50,
      width: 100,
      point: LatLng(weatherCardList.lat!, weatherCardList.lon!),
      child: GestureDetector(
        onTap: () => _onMarkerTap(weatherCardList),
        child: _buidStyleMarkers(
          weatherCardList.weathercode![weatherController.getTime(
              weatherCardList.time!, weatherCardList.timezone!)],
          weatherCardList.time![weatherController.getTime(
              weatherCardList.time!, weatherCardList.timezone!)],
          weatherCardList.sunrise![weatherController.getDay(
              weatherCardList.timeDaily!, weatherCardList.timezone!)],
          weatherCardList.sunset![weatherController.getDay(
              weatherCardList.timeDaily!, weatherCardList.timezone!)],
          weatherCardList.temperature2M![weatherController.getTime(
              weatherCardList.time!, weatherCardList.timezone!)],
        ),
      ),
    );
  }

  Widget _buildMapTileLayer(CacheStore cacheStore) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.darkmoonight.rain',
      tileProvider: CachedTileProvider(
        store: cacheStore,
        maxStale: const Duration(days: 30),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return _isCardVisible && _selectedWeatherCard != null
        ? SlideTransition(
            position: _offsetAnimation,
            child: GestureDetector(
              onTap: () => Get.to(
                () => PlaceInfo(weatherCard: _selectedWeatherCard!),
                transition: Transition.downToUp,
              ),
              child: PlaceCard(
                time: _selectedWeatherCard!.time!,
                timeDaily: _selectedWeatherCard!.timeDaily!,
                timeDay: _selectedWeatherCard!.sunrise!,
                timeNight: _selectedWeatherCard!.sunset!,
                weather: _selectedWeatherCard!.weathercode!,
                degree: _selectedWeatherCard!.temperature2M!,
                district: _selectedWeatherCard!.district!,
                city: _selectedWeatherCard!.city!,
                timezone: _selectedWeatherCard!.timezone!,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildHeatmapLayer() {
    return Obx(() {
      final points = <LatLng>[];
      final temperatures = <double>[];
      
      // Добавляем основную локацию
      points.add(LatLng(weatherController.location.lat!, weatherController.location.lon!));
      temperatures.add(weatherController.mainWeather.temperature2M![weatherController.hourOfDay.value]);
      
      // Добавляем сохраненные локации
      for (var card in weatherController.weatherCards) {
        points.add(LatLng(card.lat!, card.lon!));
        temperatures.add(card.temperature2M![weatherController.getTime(card.time!, card.timezone!)]);
      }
      
      final mapState = _animatedMapController.mapController;
      
      return CustomPaint(
        size: Size(Get.width, Get.height),
        painter: HeatmapPainter(
          points: points,
          temperatures: temperatures,
          mapController: mapState,
        ),
      );
    });
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 5,
      top: 120,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor.withOpacity(0.5), // Полупрозрачный фон
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          height: 350,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconsaxPlusLinear.search_zoom_in,
                  size: 20,
                  color: context.theme.iconTheme.color?.withOpacity(0.5), // Полупрозрачная иконка
                ),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _currentZoom,
                      min: _minZoom,
                      max: _maxZoom,
                      onChanged: (value) {
                        setState(() {
                          _currentZoom = value;
                          _animatedMapController.mapController.move(
                            _animatedMapController.mapController.camera.center,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Icon(
                  IconsaxPlusLinear.search_zoom_out_1,
                  size: 20,
                  color: context.theme.iconTheme.color?.withOpacity(0.5), // Полупрозрачная иконка
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return Positioned(
      right: 16,
      bottom: _isCardVisible ? 180 : 16, // Уменьшили отступ снизу
      child: FloatingActionButton(
        heroTag: null,
        child: const Icon(IconsaxPlusLinear.home_2),
        onPressed: () => _resetMapOrientation(
          center: LatLng(weatherController.location.lat!, weatherController.location.lon!),
          zoom: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainLocation = weatherController.location;
    final mainWeather = weatherController.mainWeather;

    final hourOfDay = weatherController.hourOfDay.value;
    final dayOfNow = weatherController.dayOfNow.value;

    return Scaffold(
      body: FutureBuilder<CacheStore>(
        future: _cacheStoreFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final cacheStore = snapshot.data!;

          return Stack(
            children: [
              FlutterMap(
                mapController: _animatedMapController.mapController,
                options: MapOptions(
                  backgroundColor: context.theme.colorScheme.surface,
                  initialCenter: LatLng(mainLocation.lat!, mainLocation.lon!),
                  initialZoom: 8,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(-90, -180),
                      const LatLng(90, 180),
                    ),
                  ),
                  onTap: (_, __) => _hideCard(),
                  onLongPress: (tapPosition, point) => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    enableDrag: false,
                    builder: (BuildContext context) => CreatePlace(
                      latitude: '${point.latitude}',
                      longitude: '${point.longitude}',
                    ),
                  ),
                ),
                children: [
                  if (_isDarkMode)
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        -0.2, -0.7, -0.08, 0, 255,
                        -0.2, -0.7, -0.08, 0, 255,
                        -0.2, -0.7, -0.08, 0, 255,
                        0, 0, 0, 1, 0,
                      ]),
                      child: _buildMapTileLayer(cacheStore),
                    )
                  else
                    _buildMapTileLayer(cacheStore),
                  _buildHeatmapLayer(),
                  Obx(() {
                    final mainMarker = _buildMainLocationMarker(
                      WeatherCard.fromJson({
                        ...mainWeather.toJson(),
                        ...mainLocation.toJson(),
                      }),
                      hourOfDay,
                      dayOfNow,
                    );

                    final cardMarkers = weatherController.weatherCards
                        .map((weatherCardList) =>
                            _buildCardMarker(weatherCardList))
                        .toList();

                    return MarkerLayer(
                      markers: [mainMarker, ...cardMarkers],
                    );
                  }),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildWeatherCard(),
                  ),
                  _buildZoomControls(),
                  _buildHomeButton(),
                ],
              ),
              RawAutocomplete<Result>(
                focusNode: _focusNode,
                textEditingController: _controllerSearch,
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return MyTextForm(
                    labelText: 'search'.tr,
                    type: TextInputType.text,
                    icon: const Icon(IconsaxPlusLinear.global_search),
                    controller: _controllerSearch,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    focusNode: _focusNode,
                    onChanged: (value) => setState(() {}),
                    iconButton: _controllerSearch.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _controllerSearch.clear();
                            },
                            icon: const Icon(
                              IconsaxPlusLinear.close_circle,
                              color: Colors.grey,
                              size: 20,
                            ),
                          )
                        : null,
                  );
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Result>.empty();
                  }
                  return WeatherAPI().getCity(textEditingValue.text, locale);
                },
                onSelected: (Result selection) {
                  _animatedMapController.mapController.move(
                      LatLng(selection.latitude, selection.longitude), 14);
                  _controllerSearch.clear();
                  _focusNode.unfocus();
                },
                displayStringForOption: (Result option) =>
                    '${option.name}, ${option.admin1}',
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Result> onSelected,
                    Iterable<Result> options) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        elevation: 4.0,
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
                                  style: context.textTheme.labelLarge,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: ExpandableFab.location,
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final List<LatLng> points;
  final List<double> temperatures;
  final MapController mapController;
  
  HeatmapPainter({
    required this.points,
    required this.temperatures,
    required this.mapController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Получаем текущий центр и зум карты
    final center = mapController.camera.center;
    final zoom = mapController.camera.zoom;
    
    // Вычисляем bounds
    final double latRadian = center.latitude * math.pi / 180;
    final double metersPerPx = 156543.03392 * math.cos(latRadian) / math.pow(2, zoom);
    final double worldPx = size.width * metersPerPx;
    
    final bounds = LatLngBounds(
      LatLng(
        center.latitude - worldPx / 111319.9,
        center.longitude - worldPx / (111319.9 * math.cos(latRadian)),
      ),
      LatLng(
        center.latitude + worldPx / 111319.9,
        center.longitude + worldPx / (111319.9 * math.cos(latRadian)),
      ),
    );

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final temp = temperatures[i];
      
      final pixelPoint = _latLngToPixel(point, bounds, size);
      final radius = 50 * math.pow(2, zoom - 8).toDouble();
      
      final gradient = RadialGradient(
        colors: [
          _getColorForTemperature(temp),
          _getColorForTemperature(temp).withOpacity(0),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: pixelPoint, radius: radius),
        );

      canvas.drawCircle(pixelPoint, radius, paint);
    }
  }

  Color _getColorForTemperature(double temp) {
    if (temp <= -20) return Colors.blue.withOpacity(0.5);
    if (temp >= 40) return Colors.red.withOpacity(0.5);
    
    // Линейная интерполяция между цветами
    if (temp < 0) {
      return Color.lerp(
        Colors.blue.withOpacity(0.5),
        Colors.green.withOpacity(0.5),
        (temp + 20) / 20,
      )!;
    } else if (temp < 20) {
      return Color.lerp(
        Colors.green.withOpacity(0.5),
        Colors.yellow.withOpacity(0.5),
        temp / 20,
      )!;
    } else {
      return Color.lerp(
        Colors.yellow.withOpacity(0.5),
        Colors.red.withOpacity(0.5),
        (temp - 20) / 20,
      )!;
    }
  }

  Offset _latLngToPixel(LatLng point, LatLngBounds bounds, Size size) {
    final percentX = (point.longitude - bounds.west) / (bounds.east - bounds.west);
    final percentY = (bounds.north - point.latitude) / (bounds.north - bounds.south);
    
    return Offset(
      size.width * percentX,
      size.height * percentY,
    );
  }

  @override
  bool shouldRepaint(HeatmapPainter oldDelegate) => true;
}
