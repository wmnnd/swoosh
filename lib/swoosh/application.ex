defmodule Swoosh.Application do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Swoosh.InMemoryMailbox, []),
    ]

    children =
      if Application.get_env(:swoosh, :serve_mailbox) do
        Logger.info("Running Swoosh mailbox preview server with Cowboy using http on port 4000")
        port = Application.get_env(:swoosh, :preview_port, 4000)
        [Plug.Adapters.Cowboy.child_spec(:http, Plug.Swoosh.MailboxPreview, [], port: port) | children]
      else
        children
      end

    opts = [strategy: :one_for_one, name: Swoosh.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
