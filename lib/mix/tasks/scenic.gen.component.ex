defmodule Mix.Tasks.Scenic.Gen.Component do
  @shortdoc "Creates scaffolding for a new Scenic component."

  @moduledoc """
  Generates Scene boilerplate for a new component.

  ```bash
  mix scenic.gen.component component_name
  ```
  """
  use Mix.Task

  import Mix.Generator
  alias ScenicNew.Common

  @switches [
    app: :string,
    module: :string
  ]

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

      [component_module_name | _] ->
        Common.elixir_version_check!()
        file_name = opts[:module] || Macro.underscore(component_module_name)
        mod_name = opts[:app] || component_module_name

        Common.check_mod_name_validity!(mod_name)
        Common.check_mod_name_availability!(mod_name)

        generate(file_name, mod_name)
    end
  end

  # --------------------------------------------------------
  defp generate(component_filename, component_module) do
    assigns = [
      app_module_name: Common.base_module(),
      component_module_name: component_module
    ]

    component_path = "lib/components/#{component_filename}.ex"

    create_directory("lib/components")
    create_file(component_path, component_new_template(assigns))

    Mix.shell().info("Created component #{component_filename}.")
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
