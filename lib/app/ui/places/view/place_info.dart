import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:weatherbet/app/controller/controller.dart';
import 'package:weatherbet/app/data/db.dart';
import 'package:weatherbet/app/ui/widgets/weather/daily/daily_card_list.dart';
import 'package:weatherbet/app/ui/widgets/weather/daily/daily_container.dart';
import 'package:weatherbet/app/ui/widgets/weather/desc/desc_container.dart';
import 'package:weatherbet/app/ui/widgets/weather/hourly.dart';
import 'package:weatherbet/app/ui/widgets/weather/now.dart';
import 'package:weatherbet/app/ui/widgets/weather/sunset_sunrise.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/services.dart';

class PlaceInfo extends StatefulWidget {
  const PlaceInfo({
    super.key,
    required this.weatherCard,
  });
  final WeatherCard weatherCard;

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  int timeNow = 0;
  int dayNow = 0;
  final weatherController = Get.put(WeatherController());
  final itemScrollController = ItemScrollController();

  @override
  void initState() {
    getTime();
    super.initState();
  }

  void getTime() {
    final weatherCard = widget.weatherCard;

    timeNow =
        weatherController.getTime(weatherCard.time!, weatherCard.timezone!);
    dayNow =
        weatherController.getDay(weatherCard.timeDaily!, weatherCard.timezone!);
    Future.delayed(const Duration(milliseconds: 30), () {
      itemScrollController.scrollTo(
        index: timeNow,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherCard = widget.weatherCard;
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
          icon: const Icon(
            IconsaxPlusLinear.arrow_left_3,
            size: 20,
          ),
        ),
        title: Column(
          children: [
            Text(
              weatherCard.district!.isNotEmpty
                  ? '${weatherCard.city}'
                  : '${weatherCard.city}',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (weatherCard.district!.isNotEmpty)
              Text(
                weatherCard.district!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await weatherController.updateCard(weatherCard);
            getTime();
            setState(() {});
          },
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          strokeWidth: 2,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              _buildNowSection(weatherCard),
              const SizedBox(height: 16),
              _buildHourlyForecast(weatherCard, colorScheme),
              const SizedBox(height: 16),
              _buildSunriseSunset(weatherCard),
              const SizedBox(height: 16),
              _buildWeatherDetails(weatherCard),
              const SizedBox(height: 16),
              _buildDailyForecast(weatherCard),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNowSection(WeatherCard weatherCard) {
    return Card(
      elevation: 0,
      child: Now(
        time: weatherCard.time![timeNow],
        weather: weatherCard.weathercode![timeNow],
        degree: weatherCard.temperature2M![timeNow],
        feels: weatherCard.apparentTemperature![timeNow]!,
        timeDay: weatherCard.sunrise![dayNow],
        timeNight: weatherCard.sunset![dayNow],
        tempMax: weatherCard.temperature2MMax![dayNow]!,
        tempMin: weatherCard.temperature2MMin![dayNow]!,
      ),
    );
  }

  Widget _buildHourlyForecast(WeatherCard weatherCard, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 135,
          child: ScrollablePositionedList.separated(
            key: const PageStorageKey(1),
            separatorBuilder: (context, index) => VerticalDivider(
              width: 10,
              indent: 40,
              endIndent: 40,
              color: colorScheme.outline.withOpacity(0.1),
            ),
            scrollDirection: Axis.horizontal,
            itemScrollController: itemScrollController,
            itemCount: weatherCard.time!.length,
            itemBuilder: (ctx, i) => _buildHourlyItem(weatherCard, i, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyItem(WeatherCard weatherCard, int i, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          timeNow = i;
          dayNow = (i / 24).floor();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: i == timeNow
              ? colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Hourly(
          time: weatherCard.time![i],
          weather: weatherCard.weathercode![i],
          degree: weatherCard.temperature2M![i],
          timeDay: weatherCard.sunrise![(i / 24).floor()],
          timeNight: weatherCard.sunset![(i / 24).floor()],
        ),
      ),
    );
  }

  Widget _buildSunriseSunset(WeatherCard weatherCard) {
    return SunsetSunrise(
      timeSunrise: weatherCard.sunrise![dayNow],
      timeSunset: weatherCard.sunset![dayNow],
    );
  }

  Widget _buildWeatherDetails(WeatherCard weatherCard) {
    return DescContainer(
      humidity: weatherCard.relativehumidity2M?[timeNow],
      wind: weatherCard.windspeed10M?[timeNow],
      visibility: weatherCard.visibility?[timeNow],
      feels: weatherCard.apparentTemperature?[timeNow],
      evaporation: weatherCard.evapotranspiration?[timeNow],
      precipitation: weatherCard.precipitation?[timeNow],
      direction: weatherCard.winddirection10M?[timeNow],
      pressure: weatherCard.surfacePressure?[timeNow],
      rain: weatherCard.rain?[timeNow],
      cloudcover: weatherCard.cloudcover?[timeNow],
      windgusts: weatherCard.windgusts10M?[timeNow],
      uvIndex: weatherCard.uvIndex?[timeNow],
      dewpoint2M: weatherCard.dewpoint2M?[timeNow],
      precipitationProbability: weatherCard.precipitationProbability?[timeNow],
      shortwaveRadiation: weatherCard.shortwaveRadiation?[timeNow],
      initiallyExpanded: false,
      title: 'hourlyVariables'.tr,
    );
  }

  Widget _buildDailyForecast(WeatherCard weatherCard) {
    return DailyContainer(
      weatherData: weatherCard,
      onTap: () {
        HapticFeedback.selectionClick();
        Get.to(
          () => DailyCardList(weatherData: weatherCard),
          transition: Transition.downToUp,
        );
      },
    );
  }
}
