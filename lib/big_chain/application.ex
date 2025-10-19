defmodule BigChain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # BigChainWeb.Telemetry,
      BigChain.Repo,
      # {DNSCluster, query: Application.get_env(:big_chain, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BigChain.PubSub},
      # Start a worker by calling: BigChain.Worker.start_link(arg)
      # {BigChain.Worker, arg},
      # Start to serve requests, typically the last entry
      BigChainWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BigChain.Supervisor]
    start_session_table()
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BigChainWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp start_session_table do
    :ets.new(:session_table, [:named_table, :public, read_concurrency: true])
  end
end
