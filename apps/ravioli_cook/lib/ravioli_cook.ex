defmodule RavioliCook do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(RavioliCook.Endpoint, []),
      supervisor(RavioliCook.Repo, []),
      supervisor(RavioliCook.Presence, []),
      worker(RavioliCook.Tracker.NodeTracker, []),
      worker(RavioliCook.Results.ServerRegistry, []),
      supervisor(Task.Supervisor, [[name: RavioliCook.TaskSupervisor]]),
      worker(RavioliCook.JobFetcher.Server, []),
      worker(RavioliCook.TaskServer, []),
      worker(RavioliCook.Results.Reporter, [])
    ]

    opts = [strategy: :one_for_one, name: RavioliCook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    RavioliCook.Endpoint.config_change(changed, removed)
    :ok
  end
end
