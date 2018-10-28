#
#  Created by Boyd Multerer on August, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Mix.Tasks.Scenic.New.Nerves do
  @moduledoc """
  Generates a starter Scenic application.

  This is the easiest way to set up a new Scenic project.

  ## Install `scenic.new`

  ```bash
  mix archive.install hex scenic_new
  ```

  ## Build the Starter Application

  First, navigate the command-line to the directory where you want to create
  your new Scenic application. Then run the following commands: (change
  `my_app` to the name of your application)

  ```bash
  mix scenic.new my_app
  cd my_app
  mix do deps.get, scenic.run
  ```

  ## Running and Debugging

  Once the application and its dependencies are set up, there are two main ways
  to run it.

  If you want to run your application under `IEx` so that you can debug it,
  simply run

  ```bash
  iex -S mix
  ```

  This works just like any other Elixir application.

  If you want to run your application outside of `IEx`, you should start it
  like this:

  ```bash
  mix scenic.run
  ```

  ## The Starter Application

  The starter application created by the generator above shows the basics of
  building a Scenic application. It has four scenes, two components, and a
  simulated sensor.

  Scene | Description
  --- | ---
  Splash | The Splash scene is configured to run when the application is started in the `config/config.exs` file. It runs a simple animation, then transitions to the Sensor scene. It also shows how intercept basic user input to exit the scene early.
  Sensor | The Sensor scene depicts a simulated temperature sensor. The sensor is always running and updates it's data through the `Scenic.SensorPubSub` server.
  Primitives | The Primitives scenes displays an overview of the basic primitive types and some of the styles that can be applied to them.
  Components | The Components scene shows the basic components that come with Scenic. The crash button will cause a match error that will crash the scene, showing how the supervision tree restarts the scene. It also shows how to receive events from components.

  Component | Description
  --- | ---
  Nav | The navigation bar at the top of the main scenes shows how to navigate between scenes and how to construct a simple component and pass a parameter to it. Note that it references a clock, creating a nested component. The clock is positioned by dynamically querying the width of the ViewPort
  Notes | The notes section at the bottom of each scene is very simple and also shows passing in custom data from the parent.

  The simulated temperature sensor doesn't collect any actual data, but does
  show how you would set up a real sensor and publish data from it into the
  `Scenic.SensorPubSub` service.

  ## What to read next

  Next, you should read guides describing the overall Scenic structure. This is
  in the documentation for Scenic itself
  """
  use Mix.Task

  import Mix.Generator
  alias ScenicNew.Common

  @shortdoc "Creates a new Scenic v#{Common.scenic_version()} Nerves application"

  @switches [
    app: :string,
    module: :string
  ]

  # --------------------------------------------------------
  def run(argv) do
    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.Tasks.Help.run(["scenic.new"])

      [path | _] ->
        Common.elixir_version_check!()
        app = opts[:app] || Path.basename(Path.expand(path))
        Common.check_application_name!(app, !opts[:app])
        mod = opts[:module] || Macro.camelize(app)
        Common.check_mod_name_validity!(mod)
        Common.check_mod_name_availability!(mod)

        unless path == "." do
          Common.check_directory_existence!(path)
          File.mkdir_p!(path)
        end

        File.cd!(path, fn ->
          generate(app, mod, path, opts)
        end)
    end
  end

  # --------------------------------------------------------
  defp generate(app, mod, path, _opts) do
    assigns = [
      app: app,
      mod: mod,
      elixir_version: get_version(System.version()),
      scenic_version: Common.scenic_version()
    ]

    create_file(".formatter.exs", Common.formatter(assigns))
    create_file(".gitignore", Common.gitignore(assigns))
    create_file("README.md", readme_template(assigns))
    create_file("mix.exs", mix_exs_template(assigns))

    create_directory("config")
    create_file("config/config.exs", config_template(assigns))
    create_file("config/config.host.exs", config_host_template(assigns))
    create_file("config/config.rpi3.exs", config_rpi3_template(assigns))

    create_directory("lib")
    create_file("lib/#{app}.ex", app_template(assigns))

    create_directory("priv/static")
    # create_file("priv/static/images/attribution.txt", Common.attribution(assigns))
    # create_file("priv/static/images/scenic_parrot.png", Common.parrot)
    # create_file("priv/static/images/cyanoramphus_zealandicus_1849.jpg", Common.cyanoramphus)

    create_directory("lib/scenes")
    create_file("lib/scenes/crosshair.ex", scene_crosshair_template(assigns))
    create_file("lib/scenes/sys_info.ex", scene_sys_info_template(assigns))

    create_directory("lib/components")

    create_directory("lib/sensors")

    create_directory("rel")
    create_directory("rel/plugins")
    create_file("rel/vm.args", rel_vm_template(assigns))
    create_file("rel/plugins/.gitignore", rel_plugins_gitignore_template(assigns))

    create_directory("rootfs_overlay")
    create_directory("rootfs_overlay/etc")
    create_file("rootfs_overlay/etc/erlinit.config", overlay_erlinit_template(assigns))
    create_file("rootfs_overlay/etc/iex.exs", overlay_iex_template(assigns))

    """

    Your Scenic project was created successfully.

    Next steps for getting started:

        $ cd #{path}
        $ mix deps.get

    You can start your app with:

        $ mix scenic.run

    You can also run it interactively like this:

        $ iex -S mix

    """
    |> Mix.shell().info()
  end

  # --------------------------------------------------------
  defp get_version(version) do
    {:ok, version} = Version.parse(version)

    "#{version.major}.#{version.minor}" <>
      case version.pre do
        [h | _] -> "-#{h}"
        [] -> ""
      end
  end

  # ============================================================================
  # template files
  templates = [
    # formatter: "templates/formatter.exs",
    # gitignore: "templates/gitignore",
    readme: "templates/new_nerves/README.md.eex",
    mix_exs: "templates/new_nerves/mix.exs.eex",
    config: "templates/new_nerves/config/config.exs.eex",
    config_host: "templates/new_nerves/config/config.host.exs.eex",
    config_rpi3: "templates/new_nerves/config/config.rpi3.exs.eex",
    app: "templates/new_nerves/lib/app.ex.eex",
    scene_crosshair: "templates/new_nerves/lib/scenes/crosshair.ex.eex",
    scene_sys_info: "templates/new_nerves/lib/scenes/sys_info.ex.eex",
    rel_vm: "templates/new_nerves/rel/vm.args",
    rel_plugins_gitignore: "templates/new_nerves/rel/plugins/gitignore",
    overlay_erlinit: "templates/new_nerves/rootfs_overlay/etc/erlinit.config",
    overlay_iex: "templates/new_nerves/rootfs_overlay/etc/iex.exs"
  ]

  Enum.each(templates, fn {name, content} ->
    embed_template(name, from_file: content)
  end)
end
