import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_clone/core/usecase/usecase.dart';
import 'package:spotify_clone/domain/repository/auth/auth.dart';

import '../../../service_locator.dart';

class FavoriteSongStreamUseCase implements UseCase<bool?, dynamic> {
  @override
  Future<bool?> call({params}) async {
    return null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStream() {
    return sl<AuthRepository>().getFavoriteStream() as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }
}
