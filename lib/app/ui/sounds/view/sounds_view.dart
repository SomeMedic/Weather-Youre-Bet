import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:weatherbet/app/controller/sound_controller.dart';

class SoundsView extends StatelessWidget {
  const SoundsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nature_sounds'.tr),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.info_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('tip'.tr),
                  content: Text('sounds_mix_tip'.tr),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('got_it'.tr),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoundCard(
            title: 'wind'.tr,
            soundPath: 'sounds/wind.mp3',
            icon: IconsaxPlusLinear.wind,
          ),
          SoundCard(
            title: 'leaves'.tr,
            soundPath: 'sounds/leaves.mp3',
            icon: IconsaxPlusLinear.tree,
          ),
          SoundCard(
            title: 'sea'.tr,
            soundPath: 'sounds/sea.mp3',
            icon: IconsaxPlusLinear.cloud_drizzle,
          ),
          SoundCard(
            title: 'bees'.tr,
            soundPath: 'sounds/bees.mp3',
            icon: IconsaxPlusLinear.sun_1,
          ),
          SoundCard(
            title: 'insects'.tr,
            soundPath: 'sounds/insects.mp3',
            icon: IconsaxPlusLinear.sun_fog,
          ),
          SoundCard(
            title: 'birds'.tr,
            soundPath: 'sounds/birds.mp3',
            icon: IconsaxPlusLinear.cloud,
          ),
          SoundCard(
            title: 'night_forest'.tr,
            soundPath: 'sounds/night_forest.mp3',
            icon: IconsaxPlusLinear.moon,
          ),
          SoundCard(
            title: 'creek'.tr,
            soundPath: 'sounds/creek.mp3',
            icon: IconsaxPlusLinear.drop,
          ),
          SoundCard(
            title: 'thunder_rain'.tr,
            soundPath: 'sounds/rainThunder.mp3',
            icon: IconsaxPlusLinear.cloud_lightning,
          ),
        ],
      ),
    );
  }
}

class SoundCard extends StatefulWidget {
  final String title;
  final String soundPath;
  final IconData icon;

  const SoundCard({
    super.key,
    required this.title,
    required this.soundPath,
    required this.icon,
  });

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> with SingleTickerProviderStateMixin {
  final soundController = Get.put(SoundController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    soundController.initPlayer(widget.soundPath);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    await soundController.togglePlay(widget.soundPath);
    if (soundController.isPlaying[widget.soundPath]!) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    HapticFeedback.lightImpact();
  }

  void _updateVolume(double value) {
    soundController.updateVolume(widget.soundPath, value);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SoundController>(
      builder: (controller) {
        final isPlaying = controller.isPlaying[widget.soundPath] ?? false;
        final volume = controller.volumes[widget.soundPath] ?? 1.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _togglePlay,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: isPlaying ? 1 : 0,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isPlaying 
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                  : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isPlaying ? 1.0 : 0.0,
                                child: Text(
                                  'playing'.tr,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.2).animate(_animationController),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
                              size: 32,
                            ),
                            color: isPlaying 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            onPressed: _togglePlay,
                          ),
                        ),
                      ],
                    ),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      offset: isPlaying ? Offset.zero : const Offset(0, 1),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isPlaying ? 1.0 : 0.0,
                        child: Column(
                          children: [
                            const Gap(12),
                            Row(
                              children: [
                                Icon(
                                  Icons.volume_down,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: volume,
                                    onChanged: _updateVolume,
                                    activeColor: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Icon(
                                  Icons.volume_up,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ],
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
    );
  }
}
