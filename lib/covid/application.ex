defmodule Covid.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, deps: [Covid, CovidWeb]

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      CovidWeb.Endpoint,
      Covid.CovidDataStore,
      Covid.DohTracker.SiteCrawler
      # Starts a worker by calling: Covid.Worker.start_link(arg)
      # {Covid.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Covid.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CovidWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
