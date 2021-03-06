defmodule JsonValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :json_validator,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:saul, "~> 0.1"},
      {:mix_test_watch, "~> 0.9", only: :dev},
      {:jason, "~> 1.1", only: :test}
    ]
  end
end
