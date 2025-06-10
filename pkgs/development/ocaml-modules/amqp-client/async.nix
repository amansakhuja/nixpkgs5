{
  buildDunePackage,
  callPackage,
  amqp-client-base ? callPackage ./base.nix { },
  async,
  uri,
  amqp-client,
  ezxmlm,
}:
buildDunePackage {
  pname = "amqp-client-async";

  inherit (amqp-client-base) version minimalOCamlVersion src;

  doCheck = true;

  buildInputs = [
    amqp-client
    async
    uri
    ezxmlm
  ];

  meta = amqp-client-base.meta // {
    description = "Amqp client library, async version";
  };
}
