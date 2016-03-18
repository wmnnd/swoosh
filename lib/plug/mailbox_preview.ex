defmodule Plug.Swoosh.MailboxPreview do
  use Plug.Router
  use Plug.ErrorHandler

  alias Swoosh.InMemoryMailbox

  require EEx
  EEx.function_from_file :defp, :template, "lib/plug/templates/mailbox_viewer/index.html.eex", [:assigns]

  def call(conn, opts) do
    conn = assign(conn, :base_path, opts[:base_path] || "/")
    super(conn, opts)
  end

  plug :match
  plug :dispatch

  get "/" do
    emails = InMemoryMailbox.all()
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, template(emails: emails, email: nil, conn: conn))
  end

  get "/:id/html" do
    email = InMemoryMailbox.get(id)
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, email.html_body)
  end

  get "/:id" do
    emails = InMemoryMailbox.all()
    email = InMemoryMailbox.get(id)
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, template(emails: emails, email: email, conn: conn))
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end

  defp to_absolute_url(conn, path), do: "#{conn.assigns.base_path}/#{path}"
end
