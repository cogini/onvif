defmodule Onvif.MixProject do
  use Mix.Project

  def project do
    [
      app: :onvif,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      erlc_options: erlc_options(),
      dialyzer: [
        # plt_add_deps: :project,
        # plt_add_apps: [:ssl, :mnesia, :compiler, :xmerl, :inets, :disk_log],
        plt_add_deps: true,
        # flags: ["-Werror_handling", "-Wrace_conditions"],
        # flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs],
        # ignore_warnings: "dialyzer.ignore-warnings"
      ],
      deps: deps()
    ]
  end

  defp erlc_options do
    includes = Path.wildcard(Path.join(Mix.Project.deps_path, "*/include"))
    [:debug_info] ++ Enum.map(includes, fn(path) -> {:i, path} end) ++ otp_release_options()
  end

  defp otp_release_options do
    otp_release = String.to_integer(to_string(:erlang.system_info(:otp_release)))
    otp_release_options(otp_release)
  end
  defp otp_release_options(otp_release) when otp_release < 21 do
    [d: :"FUN_STACKTRACE"]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Onvif.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5.1", only: [:dev, :test], runtime: false},
      {:recon, "~> 2.3"},
      {:sweet_xml, "~> 0.6.5"},
      {:uuid, github: "okeuday/uuid", override: true},
      {:httpoison, "~> 1.3"},
      {:erlsom, github: "cogini/erlsom", override: true},
      # {:erlsom, "~> 1.4"},
      # {:poison, "~> 3.1.0", override: true},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
