defmodule Mix.Tasks.Swoosh.Mailbox.Server do
  use Mix.Task

  @shortdoc "Starts the mailbox preview server"

  def run(args) do
    Application.put_env(:swoosh, :serve_mailbox, true)
    Mix.Task.run "run", run_args() ++ args
  end

  defp run_args do
    if iex_running?, do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
