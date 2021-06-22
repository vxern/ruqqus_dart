class ProfileSettings {
  final bool over18;
  final bool hideOffensive;
  final bool showNsfl;
  final bool filterNsfw;
  final bool private;
  final bool nofollow;
  final String bio;
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

class UpdatePassword {
  final String newPassword;
  final String oldPassword;

  const UpdatePassword(this.newPassword, this.oldPassword);
}

class UpdateEmail {
  final String newEmail;
  final String password;

  const UpdateEmail(this.newEmail, this.password);
}

class Enable2FA {
  final String twoFactorSecret;
  final String twoFactorToken;
  final String password;

  const Enable2FA(this.twoFactorSecret, this.twoFactorToken, this.password);
}

class Disable2FA {
  final String twoFactorToken;
  final String password;

  const Disable2FA(this.twoFactorToken, this.password);
}

class AccountDeletion {
  final String password;
  String? deleteReason;
  String? twoFactorToken;

  AccountDeletion(this.password, [this.deleteReason, this.twoFactorToken]);
}
