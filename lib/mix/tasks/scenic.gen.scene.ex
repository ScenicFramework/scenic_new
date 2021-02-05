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
  defp generate(component_filename, component_module) do
    if Mix.Project.umbrella?() do
      Mix.raise "mix scenic.gen.scene must be invoked from within your scenic application root directory."
    end

    assigns = [
      app_module_name: Common.base_module(), #TOD: Figure out the right module name.
      scene_module_name: component_module
    ]

    component_path = "lib/scenes/#{component_filename}.ex"

    create_directory("lib/scenes")
    create_file(component_path, scene_new_template(assigns))

    """
    Created component #{component_filename}.
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
