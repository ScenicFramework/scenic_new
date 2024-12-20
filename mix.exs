defmodule ScenicNew.MixProject do
  use Mix.Project

  @version "0.11.0"
  @github "https://github.com/ScenicFramework/scenic_new"

  def project do
    [
      app: :scenic_new,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: [
        main: "Mix.Tasks.Scenic.New"
      ],
      description: description(),
      package: [
        contributors: ["Boyd Multerer"],
        maintainers: ["Boyd Multerer"],
        licenses: ["Apache-2.0"],
        links: %{github: @github},
        files: [
          "templates/**/*.jpg",
          "templates/**/gitignore",
          "templates/**/*.exs",
          # "templates/**/*.config",
          "templates/**/*.txt",
          "templates/**/*.jpg",
          # "templates/**/*.png",
          "templates/**/*.eex",
          "config",
          # "test",
          "mix.exs",
          ".formatter.exs",
          ".gitignore",
          "LICENSE",
          "README.md",
          "lib/**/*.ex"
        ]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: [:dev, :docs], runtime: false},
      {:excoveralls, "~> 0.17", only: :test},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false}
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

  defp description() do
    """
    ScenicNew - Mix task to generate a starter application
    """
  end
end
