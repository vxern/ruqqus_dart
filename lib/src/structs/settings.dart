/// Data structure for a user account's profile settings
class ProfileSettings {
  /// data['over18']
  final bool over18;

  /// data['hide_offensive']
  final bool hideOffensive;

  /// data['show_nsfl']
  final bool showNsfl;

  /// data['filter_nsfw']
  final bool filterNsfw;

  /// data['private']
  final bool private;

  /// data['nofollow']
  final bool nofollow;

  /// data['bio']
  final String bio;

  /// data['title_id']
  final String titleId;

  const ProfileSettings(
    this.over18,
    this.hideOffensive,
    this.showNsfl,
    this.filterNsfw,
    this.private,
    this.nofollow,
    this.bio,
    this.titleId,
  );
}

/// Data structure for updating a password
class UpdatePassword {
  /// data['new_password']
  final String newPassword;

  /// data['old_password']
  final String oldPassword;

  const UpdatePassword(this.newPassword, this.oldPassword);
}

/// Data structure for updating an email
class UpdateEmail {
  /// data['new_email']
  final String newEmail;

  /// data['password']
  final String password;

  const UpdateEmail(this.newEmail, this.password);
}

/// Data structure for enabling 2FA
class Enable2FA {
  /// data['2fa_secret']
  final String twoFactorSecret;

  /// data['2fa_token']
  final String twoFactorToken;

  /// data['password']
  final String password;

  const Enable2FA(this.twoFactorSecret, this.twoFactorToken, this.password);
}

/// Data structure for disabling 2FA
class Disable2FA {
  /// data['2fa_token']
  final String twoFactorToken;

  /// data['password']
  final String password;

  const Disable2FA(this.twoFactorToken, this.password);
}

/// Data structure for deleting a user account
class AccountDeletion {
  /// data['password']
  final String password;

  /// data['delete_reason']
  String? deleteReason;

  /// data['twofactor']
  String? twoFactorToken;

  AccountDeletion(this.password, [this.deleteReason, this.twoFactorToken]);
}
