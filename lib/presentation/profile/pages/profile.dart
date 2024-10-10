import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_clone/core/configs/assets/app_vectors.dart';
import 'package:spotify_clone/domain/usecases/auth/logout.dart';
import 'package:spotify_clone/presentation/auth/pages/signup_or_siginin.dart';
import 'package:spotify_clone/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:spotify_clone/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:spotify_clone/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:spotify_clone/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_clone/presentation/song_player/pages/song_player.dart';
import 'package:spotify_clone/service_locator.dart';

import '../../../common/widgets/favorite_button/favorite_button.dart';
import '../bloc/profile_info_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        backgroundColor: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
        title: const Text('Profile'),
        action: InkWell(
          onTap: () async {
            var result = await sl<LogoutUseCase>().call();
            result.fold(
              (l) {
                var snackbar = const SnackBar(
                  content: Text('Some error occued'),
                  behavior: SnackBarBehavior.floating,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              },
              (r) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => const SignupOrSigninPage()),
                  (route) => false,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Text(
                  'Logout ',
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.redAccent : Colors.red,
                  ),
                ),
                const Icon(Icons.logout_rounded),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileInfo(context),
          const SizedBox(
            height: 30,
          ),
          _favoriteSongs()
        ],
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3.5,
            width: double.infinity,
            decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(50), bottomLeft: Radius.circular(50))),
            child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
              builder: (context, state) {
                if (state is ProfileInfoLoading) {
                  return Container(alignment: Alignment.center, child: const CircularProgressIndicator());
                }
                if (state is ProfileInfoLoaded) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: NetworkImage(state.userEntity.imageURL!))),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(state.userEntity.email!),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        state.userEntity.fullName!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      )
                    ],
                  );
                }

                if (state is ProfileInfoFailure) {
                  return const Text('Please try again');
                }
                return Container();
              },
            ),
          ),
          const ModeChangeButton(),
        ],
      ),
    );
  }

  Widget _favoriteSongs() {
    // ScrollController listScrollController = ScrollController();
    return BlocProvider(
      create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FAVORITE SONGS',
            ),
            const SizedBox(
              height: 20,
            ),
            BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
              builder: (context, state) {
                if (state is FavoriteSongsLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state is FavoriteSongsLoaded) {
                  return state.favoriteSongs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text('No favourite songs'),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3.5 - 200,
                          child: ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                SongPlayerPage(songEntity: state.favoriteSongs[index])));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              image: DecorationImage(
                                                image: NetworkImage(state.favoriteSongs[index].songCoverUrl),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state.favoriteSongs[index].title,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                state.favoriteSongs[index].artist,
                                                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(state.favoriteSongs[index].duration
                                              .toStringAsFixed(2)
                                              .replaceAll('.', ':')),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          FavoriteButton(
                                            songEntity: state.favoriteSongs[index],
                                            key: UniqueKey(),
                                            // function: () {
                                            //   context.read<FavoriteSongsCubit>().removeSong(index);
                                            // },
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(
                                    height: 20,
                                  ),
                              itemCount: state.favoriteSongs.length),
                        );
                }
                if (state is FavoriteSongsFailure) {
                  return const Text('Please try again.');
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}

//MODE CHANGER
class ModeChangeButton extends StatefulWidget {
  const ModeChangeButton({super.key});

  @override
  State<ModeChangeButton> createState() => _ModeChangeButtonState();
}

class _ModeChangeButtonState extends State<ModeChangeButton> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(builder: (_, mode) {
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: GestureDetector(
          onTap: () {
            context.read<ThemeCubit>().updateTheme(mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
          },
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: mode == ThemeMode.dark ? Colors.white70 : Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: Transform.scale(
                  scale: 0.8,
                  child: SvgPicture.asset(
                    mode == ThemeMode.light ? AppVectors.sun : AppVectors.moon,
                    fit: BoxFit.none,
                    colorFilter: mode == ThemeMode.light
                        ? const ColorFilter.mode(Colors.amberAccent, BlendMode.srcIn)
                        : const ColorFilter.mode(Colors.indigo, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
