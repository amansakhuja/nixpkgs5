{ lib, fetchFromGitHub }:
rec {
  version = "2.3.0";
  minimalOCamlVersion = "4.14.0";

  src = fetchFromGitHub {
    owner = "andersfugmann";
    repo = "amqp-client";
    tag = version;
    hash = "sha256-zWhkjVoKyNCIBXD5746FywCg3DKn1mXb1tn1VlF9Tyg=";
  };

  meta = {
    homepage = "https://github.com/andersfugmann/amqp-client";
    license = lib.licenses.bsd3;
    changelog = "https://raw.githubusercontent.com/andersfugmann/amqp-client/refs/tags/${src.tag}/Changelog";
    maintainers = with lib.maintainers; [ momeemt ];
  };
}
