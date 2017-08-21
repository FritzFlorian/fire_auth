defmodule FireAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fire_auth,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpotion, :poison],
      mod: {FireAuth.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:httpotion, "~> 3.0.0"},
      {:poison, "~> 3.1"},
      {:joken, "~> 1.1"}
    ]
  end
end
