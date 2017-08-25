defmodule FireAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fire_auth,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/FritzFlorian/fire_auth"
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
      {:joken, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description() do
    "Firebase Authentication for Plug"
  end

  defp package() do
    [
      name: "fire_auth",
      maintainers: ["Florian Fritz"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/FritzFlorian/fire_auth"}
    ]
  end
end
