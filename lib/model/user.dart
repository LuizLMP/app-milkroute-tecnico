class User {
  String? _username;
  String? _login;
  String? _password;
  String? _empresa;
  String? _token;
  DateTime? _expirationToken;

  User(_username, this._login, this._password, this._empresa, this._token, this._expirationToken);

  User.fromJson(Map<String, dynamic> json) {
    this._username = json["username"] ?? "";
    this._login = json["login"];
    this._password = json["password"];
    this._empresa = json["empresa"];
    this._token = json["token"];
    this._expirationToken = DateTime.parse(json["expirationToken"]);
  }

  String? get username => _username;
  String? get login => _login;
  String? get password => _password;
  String? get empresa => _empresa;
  String? get token => _token;
  DateTime? get expirationToken => _expirationToken;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["username"] = _username;
    data["login"] = _login;
    data["password"] = _password;
    data["empresa"] = _empresa;
    data["token"] = _token;
    data["expirationToken"] = _expirationToken;

    return data;
  }
}
