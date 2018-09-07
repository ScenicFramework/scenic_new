defmodule ScenicNew.MixProject do
  use Mix.Project

  @version "0.7.0"

  def project do
    [
      app: :scenic_new,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: [
        main: "Mix.Tasks.Scenic.New"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]}
    ]
  end

  defp aliases do
    [
      build: [&build_releases/1]
    ]
  end

  defp build_releases(_) do
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run([])
    Mix.Tasks.Archive.Build.run(["--output=scenic_new.ez"])
    File.rename("scenic_new.ez", "./archives/scenic_new.ez")
    File.rename("scenic_new-#{@version}.ez", "./archives/scenic_new-#{@version}.ez")
  end
end
