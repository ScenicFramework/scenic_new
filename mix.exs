defmodule ScenicBootstrap.MixProject do
  use Mix.Project

  def project do
    [
      app: :scenic_bootstrap,
      version: "0.7.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
    []
  end
end
