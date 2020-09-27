// structs/settings.dart - File for storing classes used for various settings

/// Your profile settings
class ProfileSettings {
  bool over_18;
  bool hide_offensive;
  bool show_nsfl;
  bool filter_nsfw;
  bool private;
  bool nofollow;
  String bio;
  String title_id;

  ProfileSettings(
      {this.over_18,
      this.hide_offensive,
      this.show_nsfl,
      this.filter_nsfw,
      this.private,
      this.nofollow,
      this.bio,
      this.title_id});
}

/// Struct for new password
class UpdatePassword {
  final String new_password;
  final String old_password;

  UpdatePassword(this.new_password, this.old_password);
}

/// Struct for new email
class UpdateEmail {
  final String new_email;
  final String password;

  UpdateEmail(this.new_email, this.password);
}

/// Struct for 2fa enabling
class Enable2FA {
  final String two_factor_secret;
  final String two_factor_token;
  final String password;

  Enable2FA(this.two_factor_secret, this.two_factor_token, this.password);
}

/// Struct for 2fa disabling
class Disable2FA {
  final String two_factor_token;
  final String password;

  Disable2FA(this.two_factor_token, this.password);
}
