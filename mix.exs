defmodule Imager.MixProject do
  use Mix.Project

  def project do
    [
      app: :imager,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications:
        [:logger, :crypto] ++
          case Mix.env() do
            :test -> [:inets]
            _ -> []
          end
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:image, "~> 0.37.0"},
      {:plug, "~> 1.10"},
      {:bandit, "~> 1.0-pre", only: [:dev, :test]},
      {:finch, "~> 0.16.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:stream_data, "~> 0.6.0", only: :test}
    ]
  end
end
