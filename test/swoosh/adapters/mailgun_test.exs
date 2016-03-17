defmodule Swoosh.Adapters.MailgunTest do
  use AdapterCase, async: true

  import Swoosh.Email
  alias Swoosh.Adapters.Mailgun

  setup_all do
    bypass = Bypass.open
    config = [base_url: "http://localhost:#{bypass.port}",
              domain: "/avengers.com"]

    valid_email =
      %Swoosh.Email{}
      |> from("tony@stark.com")
      |> to("steve@rogers.com")
      |> subject("Hello, Avengers!")
      |> html_body("<h1>Hello</h1>")

    {:ok, bypass: bypass, valid_email: valid_email, config: config}
  end

  test "a sent email results in :ok", %{bypass: bypass, config: config, valid_email: email} do
    Bypass.expect bypass, fn conn ->
      conn = parse(conn)
      expected_path = config[:domain] <> "/messages"
      body_params = %{"subject" => "Hello, Avengers!",
                      "to" => "steve@rogers.com",
                      "from" => "tony@stark.com",
                      "html" => "<h1>Hello</h1>"}
      assert body_params == conn.body_params
      assert expected_path == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, "<h1>hai</h1>")
    end

    assert Mailgun.deliver(email, config) == :ok
  end

  test "delivery/1 with 4xx response", %{bypass: bypass, config: config, valid_email: email} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.resp(conn, 401, "{\"errors\":[\"The provided authorization grant is invalid, expired, or revoked\"], \"message\":\"error\"}")
    end

    assert Mailgun.deliver(email, config) == {:error, %{"errors" => ["The provided authorization grant is invalid, expired, or revoked"], "message" => "error"}}
  end

  test "deliver/1 with 5xx response", %{bypass: bypass, valid_email: email, config: config} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.resp(conn, 500, "{\"errors\":[\"The provided authorization grant is invalid, expired, or revoked\"], \"message\":\"error\"}")
    end

    assert Mailgun.deliver(email, config) == {:error, %{"errors" => ["The provided authorization grant is invalid, expired, or revoked"], "message" => "error"}}
  end
end
