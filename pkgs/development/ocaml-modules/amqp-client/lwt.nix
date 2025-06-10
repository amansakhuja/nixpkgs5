{
  buildDunePackage,
  callPackage,
  amqp-client-base ? callPackage ./base.nix { },
  lwt,
  lwt_log,
  amqp-client,
  uri,
  ezxmlm,
}:
buildDunePackage {
  pname = "amqp-client-lwt";

  inherit (amqp-client-base) version minimalOCamlVersion src;

  buildInputs = [
    lwt
    lwt_log
    amqp-client
    uri
    ezxmlm
  ];

  doCheck = true;

  meta = amqp-client-base.meta // {
    description = "Amqp client library, lwt version";
  };
}
