import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_clone/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  Duration bufferDuration = Duration.zero;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    audioPlayer.playerStateStream.listen(
      (stream) {
        if (stream.processingState == ProcessingState.completed) {
          songPosition = Duration.zero;
          audioPlayer.pause();
          audioPlayer.seek(songPosition);
          emit(SongPlayerLoaded());
        }
      },
    );

    audioPlayer.positionStream.listen(
      (position) {
        songPosition = position;
        if (audioPlayer.processingState == ProcessingState.ready) updateSongPlayer();
      },
    );

    audioPlayer.durationStream.listen(
      (duration) {
        songDuration = duration!;
      },
    );

    audioPlayer.bufferedPositionStream.listen(
      (buffer) {
        bufferDuration = buffer;
      },
    );
  }

  void updateSongPlayer() {
    if (!isClosed) emit(SongPlayerLoaded());
  }

  Future<void> loadSong(String url) async {
    print(url);
    try {
      emit(SongPlayerLoading());
      await audioPlayer.setUrl(url);
      emit(SongPlayerLoaded());
      audioPlayer.play();
    } catch (e) {
      emit(SongPlayerFailure());
    }
  }

  void playOrPauseSong() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  void handleSeek(double value) async {
    emit(SongPlayerLoading());
    await audioPlayer.seek(Duration(seconds: value.toInt()));
    emit(SongPlayerLoaded());
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
