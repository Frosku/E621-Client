let
  nixpkgs = import <nixpkgs> {};
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "perl-ssl-env";
    buildInputs = [
      (perl532.withPackages (p: with p; [
        Appperlbrew
        Appcpanminus
      ]))
      nix
      pkg-config
    ];
    OPENSSL_PREFIX = buildEnv {
      name = "openssl-combined";
      paths = [ openssl openssl.out openssl.dev ];
    };
  }
