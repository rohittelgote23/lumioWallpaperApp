import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../bloc/download_cubit.dart';
import '../bloc/set_wallpaper_cubit.dart';
import '../bloc/set_wallpaper_state.dart';
import '../../favorites/bloc/favorites_cubit.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../auth/bloc/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wallpaper Detail Screen
///
/// Displays wallpaper previews in a vertical swipable PageView.
/// Supports Info, Save, and Fav buttons for the active wallpaper.
class WallpaperDetailScreen extends StatefulWidget {
  final List<WallpaperModel> wallpapers;
  final int initialIndex;
  final String? heroTag;

  const WallpaperDetailScreen({
    super.key,
    required this.wallpapers,
    required this.initialIndex,
    this.heroTag,
  });

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  late int _currentIndex;
  late PageController _pageController;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isPreviewMode = false;
  bool _showSwipeHint = false;
  Timer? _swipeHintTimer;
  bool _hasSeenSwipeHint = true; // Default to true until loaded

  WallpaperModel get _currentWallpaper => widget.wallpapers[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _checkSwipeHintStatus();
  }

  @override
  void dispose() {
    _removeInfoPopup();
    _pageController.dispose();
    _swipeHintTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSwipeHintStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_swipe_hint') ?? false;
    if (mounted) {
      setState(() {
        _hasSeenSwipeHint = hasSeen;
      });
      if (!hasSeen) {
        _startSwipeHintTimer();
      }
    }
  }

  Future<void> _markSwipeHintAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_swipe_hint', true);
    if (mounted) {
      setState(() {
        _hasSeenSwipeHint = true;
        _showSwipeHint = false;
      });
    }
    _swipeHintTimer?.cancel();
  }

  void _startSwipeHintTimer() {
    _swipeHintTimer?.cancel();
    if (mounted) {
      setState(() {
        _showSwipeHint = false;
      });
    }
    // Only show hint if the user has never swiped, and there is a next wallpaper to scroll to
    if (!_hasSeenSwipeHint && _currentIndex < widget.wallpapers.length - 1) {
      _swipeHintTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showSwipeHint = true;
          });
        }
      });
    }
  }

  void _removeInfoPopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showInfoPopup(BuildContext context) {
    if (_overlayEntry != null) {
      _removeInfoPopup();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Close on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeInfoPopup,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Popup
            Positioned(
              width: 200,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(-60, -100),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentWallpaper.info.isNotEmpty
                              ? _currentWallpaper.info
                              : 'No information available.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  bool _isPremiumUnlocked(BuildContext context) {
    if (!_currentWallpaper.isPremium) return true;
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) {
      return state.user.subscription.isPremium;
    }
    return false;
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              'Premium Required',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This wallpaper is exclusive to premium members. Upgrade to unlock unlimited downloads and sets!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium features coming soon!')),
              );
            },
            child: const Text(
              'Go Premium',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DownloadCubit(
            wallpaperRepository: context.read<WallpaperRepository>(),
          )..checkDownloadStatus(_currentWallpaper.id),
        ),
        BlocProvider(create: (context) => SetWallpaperCubit()),
      ],
      child: BlocListener<SetWallpaperCubit, SetWallpaperState>(
        listener: (context, state) {
          if (state is SetWallpaperSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SetWallpaperError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          body: Builder(
            builder: (context) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Swipable Vertical PageView for Wallpapers
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification ||
                          notification is ScrollUpdateNotification) {
                        _startSwipeHintTimer();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        _removeInfoPopup();
                        _startSwipeHintTimer();
                        context.read<DownloadCubit>().checkDownloadStatus(
                          _currentWallpaper.id,
                        );

                        // Mark as seen on their first vertical swipe
                        if (!_hasSeenSwipeHint &&
                            index != widget.initialIndex) {
                          _markSwipeHintAsSeen();
                        }
                      },
                      itemCount: widget.wallpapers.length,
                      itemBuilder: (context, index) {
                        final wallpaper = widget.wallpapers[index];
                        return WallpaperPageContent(
                          key: ValueKey(wallpaper.id),
                          wallpaper: wallpaper,
                          heroTag: widget.heroTag,
                          isInitial: index == widget.initialIndex,
                          onTap: () {
                            setState(() {
                              _isPreviewMode = !_isPreviewMode;
                            });
                            _startSwipeHintTimer();
                          },
                        );
                      },
                    ),
                  ),

                  // Swipe Up Hint overlay
                  if (_showSwipeHint && !_isPreviewMode)
                    Positioned(
                      bottom: 110,
                      left: 0,
                      right: 0,
                      child: const Center(child: SwipeUpHint()),
                    ),

                  if (!_isPreviewMode) ...[
                    // Top Bar (Back, Share)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                          _buildCircleButton(
                            icon: Icons.fullscreen,
                            onTap: () {
                              setState(() {
                                _isPreviewMode = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Bottom Left Control Bar (Download, Set, Info)
                    Positioned(
                      bottom: 30,
                      left: 16,
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Premium Locked State
                            if (!_isPremiumUnlocked(context)) ...[
                              _buildControlBarButton(
                                color: const Color(0xFF7C4DFF),
                                context,
                                icon: Icons.diamond,
                                onTap: () => _showPremiumDialog(context),
                              ),
                            ] else ...[
                              // Unlocked / Free State

                              // Download Button
                              BlocBuilder<DownloadCubit, DownloadState>(
                                builder: (context, state) {
                                  bool isDownloading =
                                      state is DownloadInProgress;
                                  bool isDownloaded = false;
                                  if (state is DownloadChecked) {
                                    isDownloaded = state.isDownloaded;
                                  } else if (state is DownloadSuccess) {
                                    isDownloaded = true;
                                  }

                                  return _buildControlBarButton(
                                    context,
                                    color: const Color(0xFF1E1E26),
                                    icon: isDownloaded
                                        ? Icons.check_circle_rounded
                                        : Icons.download_rounded,
                                    onTap: () {
                                      if (isDownloaded) return;
                                      final ext = _currentWallpaper.isVideo
                                          ? 'mp4'
                                          : 'jpg';
                                      final filename =
                                          'lumio_${_currentWallpaper.id}.$ext';
                                      context
                                          .read<DownloadCubit>()
                                          .downloadWallpaper(
                                            _currentWallpaper.fullUrl,
                                            filename,
                                          );
                                    },
                                    isLoading: isDownloading,
                                    isActive: isDownloaded,
                                  );
                                },
                              ),

                              if (!_currentWallpaper.isVideo) ...[
                                const SizedBox(width: 4),

                                // Set Wallpaper Button
                                _buildControlBarButton(
                                  context,
                                  icon: Icons.wallpaper_rounded,
                                  color: const Color(0xFF1E1E26),
                                  onTap: () {
                                    final setWallpaperCubit = context
                                        .read<SetWallpaperCubit>();

                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                      builder: (btmContext) => Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.home,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                              title: Text(
                                                'Set as Home Screen',
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(btmContext);
                                                _setWallpaperDirectly(
                                                  _currentWallpaper.fullUrl,
                                                  WallpaperManagerPlus
                                                      .homeScreen,
                                                  setWallpaperCubit,
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.lock,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                              title: Text(
                                                'Set as Lock Screen',
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(btmContext);
                                                _setWallpaperDirectly(
                                                  _currentWallpaper.fullUrl,
                                                  WallpaperManagerPlus
                                                      .lockScreen,
                                                  setWallpaperCubit,
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.phone_android,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                              title: Text(
                                                'Set Both',
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(btmContext);
                                                _setWallpaperDirectly(
                                                  _currentWallpaper.fullUrl,
                                                  WallpaperManagerPlus
                                                      .bothScreens,
                                                  setWallpaperCubit,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],

                            const SizedBox(width: 4),

                            // Info Button
                            CompositedTransformTarget(
                              link: _layerLink,
                              child: _buildControlBarButton(
                                context,
                                icon: Icons.info_outline_rounded,
                                color: const Color(0xFF1E1E26),
                                onTap: () => _showInfoPopup(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Right Floating Favorite Button
                    Positioned(
                      bottom: 30,
                      right: 16,
                      child: BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final isFavorite = state.favoriteIds.contains(
                            _currentWallpaper.id,
                          );
                          return GestureDetector(
                            onTap: () {
                              context.read<FavoritesCubit>().toggleFavorite(
                                _currentWallpaper.id,
                              );
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? const Color(0xFF7C4DFF)
                                    : Colors.black,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Simulated Lock Screen UI in Preview Mode
                  if (_isPreviewMode) ...[
                    // Top: Clock and Date
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 80,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            '9:25',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 100,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Wednesday, May 23',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom: Flashlight and Camera Icons
                    Positioned(
                      bottom: 50,
                      left: 30,
                      right: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLockScreenIconButton(
                            Icons.flashlight_on_rounded,
                          ),
                          _buildLockScreenIconButton(Icons.camera_alt_rounded),
                        ],
                      ),
                    ),
                  ],

                  // Loading Indicator Overlay
                  BlocBuilder<SetWallpaperCubit, SetWallpaperState>(
                    builder: (context, state) {
                      if (state is SetWallpaperLoading) {
                        return Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.7),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Setting Wallpaper...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlBarButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isActive = false,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7C4DFF) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1E1E26),
                  ),
                ),
              )
            : Icon(
                isActive ? Icons.check : icon,
                color: isActive ? Colors.white : color,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Future<void> _setWallpaperDirectly(
    String url,
    int location,
    SetWallpaperCubit cubit,
  ) async {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final targetRatio = size.width > 0 && size.height > 0
        ? size.width / size.height
        : null;
    cubit.setWallpaper(url, location, targetRatio: targetRatio);
  }

  Widget _buildLockScreenIconButton(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

/// A self-contained widget for rendering a single page's wallpaper image or video.
/// Correctly disposes of video resources when swiped away.
class WallpaperPageContent extends StatefulWidget {
  final WallpaperModel wallpaper;
  final String? heroTag;
  final bool isInitial;
  final VoidCallback onTap;

  const WallpaperPageContent({
    super.key,
    required this.wallpaper,
    this.heroTag,
    required this.isInitial,
    required this.onTap,
  });

  @override
  State<WallpaperPageContent> createState() => _WallpaperPageContentState();
}

class _WallpaperPageContentState extends State<WallpaperPageContent> {
  CachedVideoPlayerPlus? _videoController;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Increment view count for the wallpaper on loading
    WallpaperRepository().incrementViews(widget.wallpaper.id);

    if (widget.wallpaper.isVideo && widget.wallpaper.hasValidUrl) {
      _videoController =
          CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.wallpaper.fullUrl))
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {
                      _isVideoInitialized = true;
                    });
                    _videoController!.controller.setVolume(0); // Mute video
                    _videoController!.controller.play();
                    _videoController!.controller.setLooping(true);
                  }
                })
                .catchError((error) {
                  if (mounted) {
                    setState(() {
                      _hasError = true;
                      _errorMessage = 'Failed to load video';
                    });
                  }
                });
    } else if (widget.wallpaper.isVideo && !widget.wallpaper.hasValidUrl) {
      _hasError = true;
      _errorMessage = 'Invalid video URL';
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_hasError) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'Error loading media',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else if (widget.wallpaper.isVideo) {
      if (_videoController != null && _isVideoInitialized) {
        content = SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.controller.value.size.width,
              height: _videoController!.controller.value.size.height,
              child: VideoPlayer(_videoController!.controller),
            ),
          ),
        );
      } else {
        content = const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    } else if (widget.wallpaper.hasValidUrl) {
      if (widget.isInitial && widget.heroTag != null) {
        content = Hero(
          tag: widget.heroTag!,
          child: CachedNetworkImage(
            imageUrl: widget.wallpaper.fullUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        );
      } else {
        content = CachedNetworkImage(
          imageUrl: widget.wallpaper.fullUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
    } else {
      content = const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        content,
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

/// Bouncy swipe-up hint overlay widget.
class SwipeUpHint extends StatefulWidget {
  const SwipeUpHint({super.key});

  @override
  State<SwipeUpHint> createState() => _SwipeUpHintState();
}

class _SwipeUpHintState extends State<SwipeUpHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_double_arrow_up_rounded,
                color: Colors.white,
                size: 28,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Swipe up for next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
