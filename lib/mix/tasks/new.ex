#
#  Created by Boyd Multerer on August, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Mix.Tasks.Scenic.New do
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
  # import IEx

  @scenic_version Mix.Project.config()[:version]
  @shortdoc "Creates a new Scenic v#{@scenic_version} application"

  @switches [
    app: :string,
    module: :string
  ]

  @parrot_bin File.read!("static/scenic_parrot.png")
  @cyanoramphus_bin File.read!("static/cyanoramphus_zealandicus_1849.jpg")

  # --------------------------------------------------------
  def run(argv) do
    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.Tasks.Help.run(["scenic.new"])

      [path | _] ->
        elixir_version_check!()
        app = opts[:app] || Path.basename(Path.expand(path))
        check_application_name!(app, !opts[:app])
        mod = opts[:module] || Macro.camelize(app)
        check_mod_name_validity!(mod)
        check_mod_name_availability!(mod)

        unless path == "." do
          check_directory_existence!(path)
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
      scenic_version: @scenic_version
    ]

    create_file("README.md", readme_template(assigns))
    create_file(".formatter.exs", formatter_template(assigns))
    create_file(".gitignore", gitignore_template(assigns))
    create_file("mix.exs", mix_exs_template(assigns))

    create_directory("config")
    create_file("config/config.exs", config_template(assigns))

    create_directory("lib")
    create_file("lib/#{app}.ex", app_template(assigns))

    create_directory("priv/static")
    create_file("priv/static/images/attribution.txt", attribution_template(assigns))
    create_file("priv/static/images/scenic_parrot.png", @parrot_bin)
    create_file("priv/static/images/cyanoramphus_zealandicus_1849.jpg", @cyanoramphus_bin)

    create_directory("lib/scenes")
    create_file("lib/scenes/components.ex", scene_components_template(assigns))
    create_file("lib/scenes/sensor.ex", scene_sensor_template(assigns))
    create_file("lib/scenes/primitives.ex", scene_primitives_template(assigns))
    create_file("lib/scenes/transforms.ex", scene_transforms_template(assigns))
    create_file("lib/scenes/splash.ex", scene_splash_template(assigns))

    create_directory("lib/components")
    create_file("lib/components/nav.ex", nav_template(assigns))
    create_file("lib/components/notes.ex", notes_template(assigns))

    create_directory("lib/sensors")
    create_file("lib/sensors/supervisor.ex", sensor_sup_template(assigns))
    create_file("lib/sensors/temperature.ex", sensor_temp_template(assigns))

    # create_directory("test")
    # create_file("test/test_helper.exs", test_helper_template(assigns))
    # create_file("test/#{app}_test.exs", test_template(assigns))

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
    readme: "templates/README.md.eex",
    formatter: "templates/formatter.exs",
    gitignore: "templates/gitignore",
    mix_exs: "templates/mix.exs.eex",
    config: "templates/config/config.exs.eex",
    app: "templates/lib/app.ex.eex",
    nav: "templates/lib/components/nav.ex.eex",
    notes: "templates/lib/components/notes.ex.eex",
    attribution: "static/attribution.txt",
    scene_components: "templates/lib/scenes/components.ex.eex",
    scene_sensor: "templates/lib/scenes/sensor.ex.eex",
    scene_primitives: "templates/lib/scenes/primitives.ex.eex",
    scene_transforms: "templates/lib/scenes/transforms.ex.eex",
    scene_splash: "templates/lib/scenes/splash.ex.eex",
    sensor_sup: "templates/lib/sensors/supervisor.ex.eex",
    sensor_temp: "templates/lib/sensors/temperature.ex.eex"
  ]

  Enum.each(templates, fn {name, content} ->
    embed_template(name, from_file: content)
  end)

  # ============================================================================
  # validity functions taken from Elixir new task
  defp elixir_version_check! do
    unless Version.match?(System.version(), "~> 1.7") do
      Mix.raise(
        "Scenic v#{@scenic_version} requires at least Elixir v1.7.\n" <>
          "You have #{System.version()}. Please update accordingly."
      )
    end
  end

  defp check_application_name!(name, inferred?) do
    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      Mix.raise(
        "Application name must start with a lowercase ASCII letter, followed by " <>
          "lowercase ASCII letters, numbers, or underscores, got: #{inspect(name)}" <>
          if inferred? do
            ". The application name is inferred from the path, if you'd like to " <>
              "explicitly name the application then use the \"--app APP\" option"
          else
            ""
          end
      )
    end

    if String.trim(name) |> String.downcase() == "scenic" do
      Mix.raise("Application name cannot be scenic")
    end
  end

  defp check_mod_name_validity!(name) do
    unless name =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp check_mod_name_availability!(name) do
    [name]
    |> Module.concat()
    |> Module.split()
    |> Enum.reduce([], fn name, acc ->
      mod = Module.concat([Elixir, name | acc])

      if Code.ensure_loaded?(mod) do
        Mix.raise("Module name #{inspect(mod)} is already taken, please choose another name")
      else
        [name | acc]
      end
    end)
  end

  defp check_directory_existence!(path) do
    msg = "The directory #{inspect(path)} already exists. Are you sure you want to continue?"

    if File.dir?(path) and not Mix.shell().yes?(msg) do
      Mix.raise("Please select another directory for installation")
    end
  end
end
