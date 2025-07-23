# Mix Release

```
$ mix release.init
* creating rel/vm.args.eex
* creating rel/remote.vm.args.eex
* creating rel/env.sh.eex
* creating rel/env.bat.eex
```

## Release with docker

```
$ mix phx.gen.release --docker

Your application is ready to be deployed in a release!

See https://hexdocs.pm/mix/Mix.Tasks.Release.html for more information about Elixir releases.

Using the generated Dockerfile, your release will be bundled into
a Docker image, ready for deployment on platforms that support Docker.

For more information about deploying with Docker see
https://hexdocs.pm/phoenix/releases.html#containers

Here are some useful release commands you can run in any release environment:

    # To build a release
    mix release

    # To start your system with the Phoenix server running
    _build/dev/rel/slink/bin/server

    # To run migrations
    _build/dev/rel/slink/bin/migrate

Once the release is running you can connect to it remotely:

    _build/dev/rel/slink/bin/slink remote

To list all commands:

    _build/dev/rel/slink/bin/slink
```
