import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../bloc/download_cubit.dart';
import '../bloc/set_wallpaper_cubit.dart';
import '../bloc/set_wallpaper_state.dart';
import '../../favorites/bloc/favorites_cubit.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../auth/bloc/auth_cubit.dart';

/// Wallpaper Detail Screen
///
/// Displays full wallpaper preview with Info, Save, and Fav buttons
class WallpaperDetailScreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  final String? heroTag;

  const WallpaperDetailScreen({
    super.key,
    required this.wallpaper,
    this.heroTag,
  });

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  CachedVideoPlayerPlus? _videoController;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isVideoInitialized = false;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    // Increment view count
    WallpaperRepository().incrementViews(widget.wallpaper.id);

    if (widget.wallpaper.isVideo && widget.wallpaper.hasValidUrl) {
      _videoController =
          CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.wallpaper.fullUrl))
            ..initialize()
                .then((_) {
                  // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
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
                  // Ensure the first frame is shown after the video is initialized
                  if (mounted) {
                    setState(() {
                      _hasError = true;
                      _errorMessage = 'Failed to load video';
                    });
                  }
                });
    } else {
      if (widget.wallpaper.isVideo && !widget.wallpaper.hasValidUrl) {
        _hasError = true;
        _errorMessage = 'Invalid video URL';
      }
    }
  }

  @override
  void dispose() {
    _removeInfoPopup();
    _videoController?.dispose();
    super.dispose();
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
              width: 200, // Reduced width
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(
                  -60,
                  -100,
                ), // Aligned to start of button, moved up
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
                          widget.wallpaper.info.isNotEmpty
                              ? widget.wallpaper.info
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
    if (!widget.wallpaper.isPremium) return true;
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
              // Navigate to subscription screen
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
          )..checkDownloadStatus(widget.wallpaper.id),
        ),
        BlocProvider(create: (context) => SetWallpaperCubit()),
      ],
      child: BlocListener<SetWallpaperCubit, SetWallpaperState>(
        listener: (context, state) {
          if (state is SetWallpaperSuccess) {
            // Navigator.pop(context); // Keep the screen open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SetWallpaperError) {
            // Navigator.pop(context); // Keep the screen open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SetWallpaperLoading) {
            // Optional: Show loading indicator
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
                  // Wallpaper Preview
                  if (_hasError)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage.isNotEmpty
                                ? _errorMessage
                                : 'Error loading media',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  else if (widget.wallpaper.isVideo)
                    if (_videoController != null && _isVideoInitialized)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width:
                                _videoController!.controller.value.size.width,
                            height:
                                _videoController!.controller.value.size.height,
                            child: VideoPlayer(_videoController!.controller),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                  else if (widget.wallpaper.hasValidUrl)
                    Hero(
                      tag: widget.heroTag ?? 'wallpaper_${widget.wallpaper.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.wallpaper.fullUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),

                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPreviewMode = !_isPreviewMode;
                        });
                      },
                      behavior: HitTestBehavior.translucent,
                    ),
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

                    // Title
                    Positioned(
                      bottom: 100, // Above control bar
                      left: 16,
                      right:
                          80, // Leave room for Fav button if needed, though it's bottom right
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.wallpaper.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(0.0, 2.0),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                          boxShadow: [
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
                                color: Color(0xFF7C4DFF),
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
                                    color: Color(0xFF1E1E26),
                                    icon: isDownloaded
                                        ? Icons.check_circle_rounded
                                        : Icons.download_rounded,
                                    onTap: () {
                                      if (isDownloaded) return;
                                      final ext = widget.wallpaper.isVideo
                                          ? 'mp4'
                                          : 'jpg';
                                      final filename =
                                          'lumio_${widget.wallpaper.id}.$ext';
                                      context
                                          .read<DownloadCubit>()
                                          .downloadWallpaper(
                                            widget.wallpaper.fullUrl,
                                            filename,
                                          );
                                    },
                                    isLoading: isDownloading,
                                    isActive: isDownloaded,
                                  );
                                },
                              ),

                              if (!widget.wallpaper.isVideo) ...[
                                const SizedBox(width: 4),

                                // Set Wallpaper Button
                                _buildControlBarButton(
                                  context,
                                  icon: Icons.wallpaper_rounded,
                                  color: Color(0xFF1E1E26),
                                  onTap: () {
                                    // Capture the valid cubit from the Builder context
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
                                          borderRadius: BorderRadius.vertical(
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
                                                _startCropProcess(
                                                  widget.wallpaper.fullUrl,
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
                                                _startCropProcess(
                                                  widget.wallpaper.fullUrl,
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
                                                _startCropProcess(
                                                  widget.wallpaper.fullUrl,
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
                                color: Color(0xFF1E1E26),
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
                            widget.wallpaper.id,
                          );
                          return GestureDetector(
                            onTap: () {
                              context.read<FavoritesCubit>().toggleFavorite(
                                widget.wallpaper.id,
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
                                    ? Color(0xFF7C4DFF)
                                    : Colors.black,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ], // End of if (!_isPreviewMode)
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
                            'Wednesday, May 23', // Simulated date
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
          color: isActive ? Color(0xFF7C4DFF) : Colors.transparent,
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

  Future<void> _startCropProcess(
    String url,
    int location,
    SetWallpaperCubit cubit,
  ) async {
    if (!mounted) return;
    // final cubit = context.read<SetWallpaperCubit>(); // Context is invalid here

    // 1. Get file
    final file = await cubit.getWallpaperFile(url);
    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download image for cropping'),
          ),
        );
      }
      return;
    }

    // 2. Crop
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop & Adjust',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          backgroundColor: Colors.black,
        ),
      ],
    );

    if (croppedFile != null && mounted) {
      // 3. Set Wallpaper from cropped file
      cubit.setWallpaperFromFile(croppedFile.path, location);
    }
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
