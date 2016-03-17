defmodule Swoosh.Adapters.MandrillTest do
  use AdapterCase, async: true

  import Swoosh.Email
  alias Swoosh.Adapters.Mandrill

  setup_all do
    bypass = Bypass.open
    config = [base_url: "http://localhost:#{bypass.port}",
              api_key: "jarvis"]

    valid_email =
      %Swoosh.Email{}
      |> from({"T Stark", "tony@stark.com"})
      |> to("steve@rogers.com")
      |> cc({"Bruce Banner", "hulk@smash.com"})
      |> subject("Hello, Avengers!")
      |> html_body("<h1>Hello</h1>")

    {:ok, bypass: bypass, config: config, valid_email: valid_email}
  end

  test "a sent email results in :ok", %{bypass: bypass, config: config, valid_email: email} do
    Bypass.expect bypass, fn conn ->
      conn = parse(conn)
      body_params = %{"key" => "jarvis",
                      "message" => %{
                        "subject" => "Hello, Avengers!",
                        "to" => [%{"type" => "cc", "email" => "hulk@smash.com", "name" => "Bruce Banner"},
                                 %{"type" => "to", "email" => "steve@rogers.com"}],
                        "from_name" => "T Stark",
                        "from_email" => "tony@stark.com",
                        "html" => "<h1>Hello</h1>"}}
      assert body_params == conn.body_params
      assert "/messages/send.json" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200,
                    "[{\"email\":\"steve@rogers.com\",\"status\":\"sent\",\"_id\":\"968791b9f084486f9f65a4a6f93474ad\",\"reject_reason\":null}]")
    end

    assert Mandrill.deliver(email, config) == :ok
  end

  test "a queued email results in :ok", %{bypass: bypass, config: config, valid_email: email} do
    email = put_private(email, :async, true)
    Bypass.expect bypass, fn conn ->
      conn = parse(conn)
      assert true == conn.body_params["async"]
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200,
                    "[{\"email\":\"steve@rogers.com\",\"status\":\"queued\",\"_id\":\"968791b9f084486f9f65a4a6f93474ad\",\"reject_reason\":null}]")
    end

    assert Mandrill.deliver(email, config) == :ok
  end

  test "deliver/1 with 2xx response containing errors", %{bypass: bypass, config: config, valid_email: email} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "[{\"email\":\"leafybasil@gmail.com\",\"status\":\"rejected\",\"_id\":\"e1f1f16d3c6e47c5955ad2b4c3207986\",\"reject_reason\":\"unsigned\"}]")
    end

    assert Mandrill.deliver(email, config) == {:error, %{"_id" => "e1f1f16d3c6e47c5955ad2b4c3207986", "email" => "leafybasil@gmail.com", "reject_reason" => "unsigned", "status" => "rejected"}}
  end

  test "deliver/1 with non 2xx response", %{bypass: bypass, config: config, valid_email: email} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.resp(conn, 500, "{\"status\":\"error\",\"code\":-1,\"name\":\"Invalid_Key\",\"message\":\"Invalid API key\"}")
    end

    assert Mandrill.deliver(email, config) == {:error, %{"code" => -1, "message" => "Invalid API key", "name" => "Invalid_Key", "status" => "error"}}
  end
end
