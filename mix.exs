defmodule PayPal.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_paypal,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      docs: [extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {PayPal.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:exvcr, "~> 0.8", only: [:dev, :test]},
      {:ex_doc, "~> 0.15", only: [:dev, :docs]},
      {:excoveralls, "~> 0.6", only: [:dev, :test]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Elixir library for working with the PayPal REST API.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      keywords: ["Elixir", "PayPal", "REST", "Payments", "API"],
      maintainers: ["Zen Savona"],
      links: %{
        "GitHub" => "https://github.com/zensavona/paypal",
        "Docs" => "https://hexdocs.pm/paypal"
      }
    ]
  end
end
