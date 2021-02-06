defmodule Mix.Tasks.Scenic.Gen.Scene do
  @shortdoc "Creates scaffolding for a new Scenic scene."

  @moduledoc """
  Generates Scene boilerplate for a new scene.

  ```bash
  mix scenic.gen.scene SceneName
  ```
  """
  use Mix.Task

  import Mix.Generator
  alias ScenicNew.Common

  @switches [app: :string]

  @task "scenic.gen.scene"
  # --------------------------------------------------------
  @doc false
  def run(argv) do
    if Mix.Project.umbrella?() do
      message = "mix #{@task} must be invoked from within your scenic application root directory."
      Mix.raise(message)
    end

    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.Tasks.Help.run(["scenic.gen.scene"])

      [scene_module | _] ->
        Common.elixir_version_check!()
        file_name = Macro.underscore(scene_module)
        app_module = opts[:app] || Common.base_module()
        full_module = Module.concat([app_module, "Scene", scene_module])
        generate(file_name, scene_module, full_module)
    end
  end

  # --------------------------------------------------------
  defp generate(scene_filename, scene_module, full_module) do
    scene_path = "lib/scenes/#{scene_filename}.ex"
    create_directory("lib/scenes")
    create_file(scene_path, scene_new_template(scene_module: full_module))
    Mix.shell().info("Created scene #{scene_module}.")
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
