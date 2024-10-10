import 'package:flutter/material.dart';
import 'package:spotify_clone/domain/entities/song/song.dart';
import 'package:spotify_clone/domain/usecases/auth/favorite_song_stream.dart';
import 'package:spotify_clone/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:spotify_clone/service_locator.dart';

import '../../../core/configs/theme/app_colors.dart';

class FavoriteButton extends StatefulWidget {
  final SongEntity songEntity;
  final Function? function;
  const FavoriteButton({required this.songEntity, this.function, super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late SongEntity updatedSongEntity;

  @override
  void initState() {
    updatedSongEntity = widget.songEntity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: sl<FavoriteSongStreamUseCase>().getStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 1,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
          bool liked = false;
          if (snapshot.data!.docs.where((map) {
            return map.data()['songId'] == widget.songEntity.songId;
          }).isNotEmpty) {
            liked = true;
          }
          return IconButton(
            onPressed: () async {
              await sl<AddOrRemoveFavoriteSongUseCase>().call(params: widget.songEntity.songId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text(
                        '${!liked ? 'Added to' : 'Removed from'} Liked Songs',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: Durations.extralong4,
                    width: 200,
                    padding: const EdgeInsets.all(8),
                  ),
                );
              }
              if (widget.function != null) {
                widget.function!();
              }
            },
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_outline_outlined,
              size: 25,
              color: liked ? AppColors.primary : AppColors.darkGrey,
            ),
          );
        });
  }
}
