#
#  Created by Boyd Multerer on 2018-10-11.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

# A module to hold terms that represent the static file assets.
# better to do this once than load them repeatedly into the 
# different "new" types.

defmodule ScenicNew.Common do
  import Mix.Generator

  @scenic_version Mix.Project.config()[:version]

  @fairy_grove_bin File.read!("templates/assets/images/fairy_grove.jpg")
  @cyanoramphus_bin File.read!("templates/assets/images/cyanoramphus_zealandicus_1849.jpg")

  # ============================================================================
  # template files
  templates = [
    formatter: "templates/formatter.exs",
    gitignore: "templates/gitignore",
    attribution: "templates/assets/images/attribution.txt",
    comp_readme: "templates/common/comp_readme.txt",
    pubsub_readme: "templates/common/pubsub_readme.txt",
    assets_readme: "templates/common/assets_readme.txt",
    scene_readme: "templates/common/scene_readme.txt"
  ]

  Enum.each(templates, fn {name, content} ->
    embed_template(name, from_file: content)
  end)

  # ============================================================================
  # accessors

  def scenic_version(), do: @scenic_version

  def cyanoramphus(), do: @cyanoramphus_bin
  def fairy_grove(), do: @fairy_grove_bin

  def formatter(assigns), do: formatter_template(assigns)
  def gitignore(assigns), do: gitignore_template(assigns)
  def attribution(assigns), do: attribution_template(assigns)

  def comp_readme(assigns), do: comp_readme_template(assigns)
  def pubsub_readme(assigns), do: pubsub_readme_template(assigns)
  def assets_readme(assigns), do: assets_readme_template(assigns)
  def scene_readme(assigns), do: scene_readme_template(assigns)

  # ============================================================================
  # validity functions taken from Elixir new task
  def elixir_version_check! do
    unless Version.match?(System.version(), "~> 1.7") do
      Mix.raise(
        "Scenic v#{@scenic_version} requires at least Elixir v1.7.\n" <>
          "You have #{System.version()}. Please update accordingly."
      )
    end
  end

  def check_application_name!(name, inferred?) do
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

  def check_mod_name_validity!(name) do
    unless name =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  def check_mod_name_availability!(name) do
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

  def check_directory_existence!(path) do
    msg = "The directory #{inspect(path)} already exists. Are you sure you want to continue?"

    if File.dir?(path) and not Mix.shell().yes?(msg) do
      Mix.raise("Please select another directory for installation")
    end
  end
end
