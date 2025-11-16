import '../entities/user_entity.dart';

/// Use case for searching/filtering users locally
class SearchUsersUsecase {
  /// Filter users by search query
  ///
  /// Searches in first name, last name, and email
  /// Case-insensitive search
  List<UserEntity> call({
    required List<UserEntity> users,
    required String query,
  }) {
    if (query.isEmpty) {
      return users;
    }

    final lowerQuery = query.toLowerCase();

    return users.where((user) {
      final firstNameMatch = user.firstName.toLowerCase().contains(lowerQuery);
      final lastNameMatch = user.lastName.toLowerCase().contains(lowerQuery);
      final emailMatch = user.email.toLowerCase().contains(lowerQuery);
      final fullNameMatch = user.fullName.toLowerCase().contains(lowerQuery);

      return firstNameMatch || lastNameMatch || emailMatch || fullNameMatch;
    }).toList();
  }
}
