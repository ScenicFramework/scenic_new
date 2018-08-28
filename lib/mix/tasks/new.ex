#
#  Created by Boyd Multerer on August, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Mix.Tasks.Scenic.New do
  use Mix.Task

  import Mix.Generator

  # import IEx

  @switches [
    app: :string,
    module: :string
  ]

  @scenic_version Mix.Project.config()[:version]
  @parrot_bin File.read!("static/scenic_parrot.png")

  @parrot_hash      "UfHCVlANI2cFbwSpJey64FxjT-0"

  # --------------------------------------------------------
  def run(argv) do
    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.raise("Expected app PATH to be given, please use \"mix scenic.new PATH\"")

      [path | _] ->
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
  defp generate(app, mod, _path, _opts) do
    assigns = [
      app: app,
      mod: mod,
      elixir_version: get_version(System.version()),
      scenic_version: @scenic_version,
      parrot_hash: @parrot_hash
    ]

    create_file("README.md", readme_template(assigns))
    create_file(".formatter.exs", formatter_template(assigns))
    create_file(".gitignore", gitignore_template(assigns))
    create_file("mix.exs", mix_exs_template(assigns))
    create_file("Makefile", makefile_template(assigns))

    create_directory("config")
    create_file("config/config.exs", config_template(assigns))

    create_directory("lib")
    create_file("lib/#{app}.ex", app_template(assigns))

    create_directory("static")
    create_file("static/images/scenic_parrot.png.#{@parrot_hash}", @parrot_bin)

    create_directory("lib/scenes")
    create_file("lib/scenes/components.ex", scene_components_template(assigns))
    create_file("lib/scenes/demo.ex", scene_demo_template(assigns))
    create_file("lib/scenes/primitives.ex", scene_primitives_template(assigns))
    create_file("lib/scenes/splash.ex", scene_splash_template(assigns))

    create_directory("lib/components")
    create_file("lib/components/nav.ex", nav_template(assigns))

    # create_directory("test")
    # create_file("test/test_helper.exs", test_helper_template(assigns))
    # create_file("test/#{app}_test.exs", test_template(assigns))

    """

    Your Scenic project was created successfully.

    Next:
      cd into your app directory and run "mix deps.get"

    Then:
      Run "mix scenic.run" (in the app directory) to start your app
      Run "iex -S mix" (in the app directory) to debug your app

    """
    # |> String.trim_trailing()
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

  embed_template(:readme, from_file: "templates/README.md.eex" )
  embed_template(:formatter, from_file: "templates/formatter.exs" )
  embed_template(:gitignore, from_file: "templates/gitignore" )
  embed_template(:mix_exs, from_file: "templates/mix.exs.eex" )
  embed_template(:makefile, from_file: "templates/Makefile" )

  embed_template(:config, from_file: "templates/config/config.exs.eex" )

  embed_template(:app, from_file: "templates/lib/app.ex.eex" )

  embed_template(:nav, from_file: "templates/lib/components/nav.ex.eex" )

  embed_template(:scene_components, from_file: "templates/lib/scenes/components.ex.eex" )
  embed_template(:scene_demo, from_file: "templates/lib/scenes/demo.ex.eex" )
  embed_template(:scene_primitives, from_file: "templates/lib/scenes/primitives.ex.eex" )
  embed_template(:scene_splash, from_file: "templates/lib/scenes/splash.ex.eex" )



  # ============================================================================
  # validity functions taken from Elixir new task

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
  end

  defp check_mod_name_validity!(name) do
    unless name =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp check_mod_name_availability!(name) do
    name = Module.concat(Elixir, name)

    if Code.ensure_loaded?(name) do
      Mix.raise("Module name #{inspect(name)} is already taken, please choose another name")
    end
  end

  defp check_directory_existence!(path) do
    msg = "The directory #{inspect(path)} already exists. Are you sure you want to continue?"

    if File.dir?(path) and not Mix.shell().yes?(msg) do
      Mix.raise("Please select another directory for installation")
    end
  end
end
