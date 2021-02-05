defmodule Mix.Tasks.Scenic.Gen.Scene do
  @shortdoc "Creates scaffolding for a new Scenic scene."

  @moduledoc """
  Generates Scene boilerplate for a new scene.

  ```bash
  mix scenic.gen.scene scene_name
  ```
  """
  use Mix.Task

  import Mix.Generator
  alias ScenicNew.Common

  @switches [
    app: :string,
    module: :string
  ]


  # --------------------------------------------------------
  @doc false
  def run(argv) do
    if Mix.Project.umbrella?() do
      Mix.raise "mix scenic.gen.component must be invoked from within your scenic application root directory."
    end

    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.Tasks.Help.run(["scenic.gen.scene"])

      [scene_name | _] ->

        Common.elixir_version_check!()
        app = opts[:app] || Path.basename(Path.expand(scene_name))
        Common.check_application_name!(app, !opts[:app])
        mod = opts[:module] || Macro.camelize(app)
        Common.check_mod_name_validity!(mod)
        Common.check_mod_name_availability!(mod)

        generate(app, mod)
    end
  end

  # --------------------------------------------------------
  defp generate(scene_filename, scene_module) do
    assigns = [
      app_module_name: Common.base_module(), #TOD: Figure out the right module name.
      scene_module_name: scene_module
    ]

    scene_path = "lib/scenes/#{scene_filename}.ex"

    create_directory("lib/scenes")
    create_file(scene_path, scene_new_template(assigns))

    """
    Created scene #{scene_path}.
    """
    |> Mix.shell().info()
  end

  # ============================================================================
  # template files
  [
    scene_new: "templates/gen_scene/lib/scenes/scene.ex.eex"
  ]
  |> Enum.each(fn {name, content} ->
    embed_template(name, from_file: content)
  end)
end
