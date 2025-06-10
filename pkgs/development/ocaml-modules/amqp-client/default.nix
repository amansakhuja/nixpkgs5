{
  buildDunePackage,
  callPackage,
  amqp-client-base ? callPackage ./base.nix { },
}:
buildDunePackage {
  pname = "amqp-client";

  inherit (amqp-client-base) version minimalOCamlVersion src;

  doCheck = true;

  meta = amqp-client-base.meta // {
    description = "Amqp client base library";
    longDescription = ''
      This library provides high level client bindings for amqp. The library
      is tested with rabbitmq, but should work with other amqp
      servers. The library is written in pure OCaml.

      This is the base library required by lwt/async versions.
      You should install either amqp-client-async or amqp-client-lwt
      for actual client functionality.
    '';
  };
}
