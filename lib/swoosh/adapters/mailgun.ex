defmodule Swoosh.Adapters.Mailgun do
  alias HTTPoison.Response
  alias Swoosh.Email

  @behaviour Swoosh.Adapter

  @base_url     "https://api.mailgun.net/v3"
  @api_endpoint "/messages"

  def base_url(config), do: config[:base_url] || @base_url

  def deliver(%Email{} = email, config \\ []) do
    headers = construct_headers(email, config)
    params = prepare_body(email) |> Plug.Conn.Query.encode

    case HTTPoison.post(base_url(config) <> config[:domain] <> @api_endpoint, params, headers) do
      {:ok, %Response{status_code: code}} when code >= 200 and code <= 299 ->
        :ok
      {:ok, %Response{status_code: code, body: body}} when code >= 400 and code <= 499 ->
        {:error, Poison.decode!(body)}
      {:ok, %Response{status_code: code, body: body}} when code >= 500 and code <= 599 ->
        {:error, Poison.decode!(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp construct_headers(email, config) do
    [{"User-Agent", "swoosh/#{Swoosh.version}"},
     {"Authorization", "Basic #{auth(config)}"},
     {"Content-Type", content_type(email)}]
  end

  defp auth(config), do: Base.encode64("api: #{config[:api_key]}")

  defp content_type(%Email{attachments: nil}), do: "application/x-www-form-urlencoded"
  defp content_type(%Email{attachments: []}), do: "application/x-www-form-urlencoded"
  defp content_type(%Email{}), do: "multipart/form-data"

  defp prepare_body(email) do
    %{}
    |> prepare_from(email)
    |> prepare_to(email)
    |> prepare_subject(email)
    |> prepare_html(email)
    |> prepare_text(email)
    |> prepare_cc(email)
    |> prepare_bcc(email)
  end

  defp prepare_from(_body, %Email{from: nil}), do: raise ArgumentError, message: "`from` can't be nil"
  defp prepare_from(_body, %Email{from: {_name, nil}}), do: raise ArgumentError, message: "`from` can't be nil"
  defp prepare_from(body, %Email{from: from}), do: Map.put(body, :from, prepare_recipient(from))

  defp prepare_to(_body, %Email{to: []}), do: raise ArgumentError, message: "`to` can't be nil"
  defp prepare_to(body, %Email{to: to}), do: Map.put(body, :to, prepare_recipients(to))

  defp prepare_cc(body, %Email{cc: []}), do: body
  defp prepare_cc(body, %Email{cc: cc}), do: Map.put(body, :cc, prepare_recipients(cc))

  defp prepare_bcc(body, %Email{bcc: []}), do: body
  defp prepare_bcc(body, %Email{bcc: bcc}), do: Map.put(body, :bcc, prepare_recipients(bcc))

  defp prepare_recipients(recipients) do
    recipients
    |> Enum.map(&prepare_recipient(&1))
    |> Enum.join(",")
  end

  defp prepare_recipient({"", email}), do: email
  defp prepare_recipient({name, email}), do: name <> "<#{email}>"

  defp prepare_subject(_body, %Email{subject: nil}), do: raise ArgumentError, message: "`subject` can't be nil"
  defp prepare_subject(body, %Email{subject: subject}), do: Map.put(body, :subject, subject)

  defp prepare_text(_body, %{text_body: nil, html_body: nil}) do
    raise ArgumentError, message: "`html_body` and `text_body` cannot both be nil"
  end
  defp prepare_text(body, %{text_body: nil}), do: body
  defp prepare_text(body, %{text_body: text_body}), do: Map.put(body, :text, text_body)

  defp prepare_html(_body, %{html_body: nil, text_body: nil}) do
    raise ArgumentError, message: "`html_body` and `text_body` cannot both be nil"
  end
  defp prepare_html(body, %{html_body: nil}), do: body
  defp prepare_html(body, %{html_body: html_body}), do: Map.put(body, :html, html_body)
end
