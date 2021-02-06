defmodule Mix.Tasks.Scenic.Gen.Component do
  @shortdoc "Creates scaffolding for a new Scenic component."

  @moduledoc """
  Generates Scene boilerplate for a new component.

  ```bash
  mix scenic.gen.component ComponentName
  ```
  """
  use Mix.Task

  import Mix.Generator
  alias ScenicNew.Common

  @switches [app: :string]

  @task "scenic.gen.component"
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
        Mix.Tasks.Help.run([@task])

      [component_module | _] ->
        Common.elixir_version_check!()
        file_name = Macro.underscore(component_module)
        app_module = opts[:app] || Common.base_module()
        full_module = Module.concat([app_module, "Component", component_module])
        generate(file_name, component_module, full_module)
    end
  end

  # --------------------------------------------------------
  defp generate(component_filename, component_module, full_module) do
    component_path = "lib/components/#{component_filename}.ex"
    create_directory("lib/components")
    create_file(component_path, component_new_template(component_module: inspect(full_module)))
    Mix.shell().info("Created component #{component_module}.")
  end

  # ============================================================================
  # template files
  [
    component_new: "templates/gen_component/lib/components/component.ex.eex"
  ]
  |> Enum.each(fn {name, content} ->
    embed_template(name, from_file: content)
  end)
end
