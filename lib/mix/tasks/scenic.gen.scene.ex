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
      Mix.raise(
        "mix scenic.gen.component must be invoked from within your scenic application root directory."
      )
    end

    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.Tasks.Help.run(["scenic.gen.scene"])

      [scene_module_name | _] ->
        Common.elixir_version_check!()
        file_name = opts[:module] || Macro.underscore(scene_module_name)
        mod_name = opts[:app] || scene_module_name
        Common.check_mod_name_validity!(mod_name)
        Common.check_mod_name_availability!(mod_name)

        generate(file_name, mod_name)
    end
  end

  # --------------------------------------------------------
  defp generate(scene_filename, scene_module) do
    assigns = [
      app_module_name: Common.base_module(),
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
