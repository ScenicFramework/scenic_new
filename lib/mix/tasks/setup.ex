#
#  Created by Boyd Multerer on August, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Mix.Tasks.Scenic.Setup do
  @moduledoc """
  Does much of the work to set up Scenic in an existing project, such as Nerves.

  The typical use of this task is to install Scenic into a Nerves project. This assumes
  that you have already installed Nerves.

  [You should read use the Nerves Installation Guide.](https://hexdocs.pm/nerves/installation.html)


  ### Create a new project

  Then create a new Nerves project and set up Scenic within it

  ```bash
  mix nerves.new hello_nerves
  cd hello_nerves
  mix scenic.setup
  ```

  This also works to set up Scenic in a blank Elixir project

  ```bash
  mix new hello_world
  cd hello_world
  mix scenic.setup
  ```

  At this point, the main file structures are set up, but not completely hooked together.

  ### Set up the Scenic dependency

  Add the following lines the this list of deps in the project's mix.exs file. Notice that they
  are usable for all the Nerves targets. (Actually, the local driver doesn't work for bbb yet
  and is very slow and needs work on rpi4, but the point is that it works across host and
  the device target...)

  ```elixir
  {:scenic, "~> 0.11.0"},
  {:scenic_driver_local, "~> 0.11.0"},
  ```

  ### Add Scenic to your app's supervisor

  Next, you need to add Scenic to your app's supervisor so that it starts scenic.
  Something like this should be in your `MyApp` or `MyApp.Application` module.

  ```elixir
  def start(_type, _args) do
    # start the application with the configured viewport
    viewport_config = Application.get_env(:<%= @app %>, :viewport)
    children = [
      {Scenic, [viewport_config]},
      <%= @mod %>.PubSub.Supervisor
    ]
    |> Supervisor.start_link( strategy: :one_for_one )
  end
  ```

  ### Configure your assets

  Add the following to your config.exs file. Change the app name as appropriate. This
  configuration is usually the same for all targets.

  ```elixir
  config :scenic, :assets, module: MyApplication.Assets
  ```

  ### Configure your ViewPort

  Next, you need to configure your ViewPort. This instructs Scenic how to draw
  to the screen, or window. This is typically different for the various Nerves
  targets.

  The following example would go in the host.exs file. Or, if this is just a regular
  elixir project running on a Mac/PC/Linux machine, it could go in config.exs

  ```elixir
  config :my_application, :viewport,
    size: {800, 600},
    theme: :dark,
    default_scene: MyApplication.Scene.Home,
    drivers: [
      [
        module: Scenic.Driver.Local,
        window: [title: "My Application"],
        on_close: :stop_system
      ]
    ]
  ```

  This configuration could be for a Nerves device. In this case an rpi3, that I've been
  using, but it could be any device with a fixed screen.

  ```elixir
  config :my_application, :viewport,
    size: {800, 600},
    theme: :dark,
    default_scene: MyApplication.Scene.Home,
    drivers: [
      [
        module: Scenic.Driver.Local,
        position: [scaled: true, centered: true, orientation: :normal],
      ]
    ]
  ```

  Scenic.Driver.Local has quite a few options you can set.
  Please see it's documentation for more.

  ### Get the Dependencies and Run

  You should now be ready to fetch the dependencies and run your project. Run these
  commands from within your project's main directory.

  ```bash
  mix deps.get
  iex -S mix
  ```

  ## The Starter Application

  The starter application created by the generator adds a minimal set of Scenic files
  displays information about the system it is running on.

  ## What to read next

  Next, you should read guides describing the overall Scenic structure. This is
  in the documentation for Scenic itself
  """
  use Mix.Task

  import Mix.Generator
  alias ScenicNew.Common

  @shortdoc "Creates a new Scenic v#{Common.scenic_version()} application"

  @switches [
    app: :string,
    module: :string
  ]

  # --------------------------------------------------------
  def run(argv) do
    {opts, argv} = OptionParser.parse!(argv, strict: @switches)
    Common.elixir_version_check!()

    path =
      case argv do
        [] -> "."
        [path | _] -> path
      end

    app = opts[:app] || Path.basename(Path.expand(path))
    Common.check_application_name!(app, !opts[:app])
    mod = opts[:module] || Macro.camelize(app)
    Common.check_mod_name_validity!(mod)
    Common.check_mod_name_availability!(mod)

    File.cd!(path, fn ->
      generate(app, mod, path, opts)
    end)
  end

  # --------------------------------------------------------
  defp generate(app, mod, _path, _opts) do
    assigns = [
      app: app,
      mod: mod,
      elixir_version: get_version(System.version()),
      scenic_version: Common.scenic_version()
    ]

    create_file("lib/assets.ex", assets_template(assigns))

    create_directory("assets")
    create_file("assets/readme.txt", Common.assets_readme(assigns))

    create_directory("lib/scenes")
    create_file("lib/scenes/home.ex", scene_home_template(assigns))
    create_file("lib/scenes/readme.txt", Common.scene_readme(assigns))

    create_directory("lib/components")
    create_file("lib/components/readme.txt", Common.comp_readme(assigns))

    create_directory("lib/pubsub")
    create_file("lib/pubsub/supervisor.ex", pubsub_sup_template(assigns))
    create_file("lib/pubsub/readme.txt", Common.pubsub_readme(assigns))

    """

    The Scenic files were added successfully.

    You still need to configure it.

    ------
    Add the following lines the this list of deps in the project's mix.exs file. Notice that they
    are usable for all the Nerves targets. (Actually, the local driver doesn't work for bbb yet
    and is very slow and needs work on rpi4, but the point is that it works across host and
    the device target...)

        {:scenic, "~> #{Common.scenic_version()}"},
        {:scenic_driver_local, "~> #{Common.scenic_version()}"},


    ------
    Add Scenic to your app's supervisor so that it starts scenic.
    Something like this should be in your `#{app}/application.ex` module.

        def start(_type, _args) do
          # start the application with the configured viewport
          viewport_config = Application.get_env(:#{app}, :viewport)
          children = [
            {Scenic, [viewport_config]},
            #{mod}.PubSub.Supervisor
          ]
          |> Supervisor.start_link( strategy: :one_for_one )
        end

    Note: if you don't have an `#{app}/application.ex` module then you probably
    didn't generate your application with `mix new my_app_name --sup`

    ------
    Add the following to your config.exs file. Change the app name as appropriate. This
    configuration is usually the same for all targets.

        config :scenic, :assets, module: #{mod}.Assets


    ------
    Configure your ViewPort. This instructs Scenic how to draw
    to the screen, or window. This is typically different for the various Nerves
    targets. The following example would go in the host.exs file. Or, if this is
    just a regular elixir project running on a Mac/PC/Linux machine,
    it could go in config.exs

        config :#{app}, :viewport,
          size: {800, 600},
          theme: :dark,
          default_scene: #{mod}.Scene.Home,
          drivers: [
            [
              module: Scenic.Driver.Local,
              window: [title: "#{app}"],
              on_close: :stop_system
            ]
          ]

    This configuration could be for a Nerves device.

        config :#{app}, :viewport,
          size: {800, 600},
          theme: :dark,
          default_scene: #{mod}.Scene.Home,
          drivers: [
            [
              module: Scenic.Driver.Local,
              position: [scaled: true, centered: true, orientation: :normal],
            ]
          ]


    ------
    Finally, build and run your app:

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
    assets: "templates/new/lib/assets.ex.eex",
    pubsub_sup: "templates/new/lib/pubsub/supervisor.ex.eex",
    scene_home: "templates/new/lib/scenes/home.ex.eex"
  ]

  Enum.each(templates, fn {name, content} ->
    embed_template(name, from_file: content)
  end)
end
