defmodule Swoosh.Adapters.Mandrill do
  alias HTTPoison.Response
  alias Swoosh.Email

  @behaviour Swoosh.Adapter

  @base_url     "https://mandrillapp.com/api/1.0"
  @api_endpoint "/messages/send.json"
  @headers      [{"Content-Type", "application/json"}]

  def base_url(config), do: config[:base_url] || @base_url

  def deliver(%Email{} = email, config \\ []) do
    body = prepare_body(email, config) |> Poison.encode!

    case HTTPoison.post(base_url(config) <> @api_endpoint, body, @headers) do
      {:ok, %Response{status_code: 200, body: body}} ->
        interpret_response(body)
      {:ok, %Response{status_code: code, body: body}} when code != 200 ->
        {:error, Poison.decode!(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp interpret_response(body) when is_binary(body), do: Poison.decode!(body) |> hd |> interpret_response
  defp interpret_response(%{"status" => "sent"}), do: :ok
  defp interpret_response(%{"status" => "queued"}), do: :ok
  defp interpret_response(%{"status" => "rejected"} = body), do: {:error, body}
  defp interpret_response(body), do: {:error, Poison.decode!(body)}

  defp prepare_body(email, config) do
    %{message: prepare_message(email)}
    |> set_async(email)
    |> set_api_key(config)
  end

  defp prepare_message(email) do
    message =
      %{to: []}
      |> prepare_from(email)
      |> prepare_to(email)
      |> prepare_subject(email)
      |> prepare_html(email)
      |> prepare_text(email)
      |> prepare_cc(email)
      |> prepare_bcc(email)
  end

  def set_api_key(body, config), do: Map.put(body, :key, config[:api_key])

  def set_async(body, %Email{private: %{async: true}}), do: Map.put(body, :async, true)
  def set_async(body, _email), do: body

  defp prepare_from(_body, %Email{from: nil}), do: raise ArgumentError, message: "`from` can't be nil"
  defp prepare_from(_body, %Email{from: {_name, nil}}), do: raise ArgumentError, message: "`from` can't be nil"
  defp prepare_from(body, %Email{from: {nil, address}}), do: Map.put(body, :from_email, address)
  defp prepare_from(body, %Email{from: {name, address}}) do
    body
    |> Map.put(:from_name, name)
    |> Map.put(:from_email, address)
  end

  defp prepare_to(_body, %Email{to: []}), do: raise ArgumentError, message: "`to` can't be nil"
  defp prepare_to(body, %Email{to: to}), do: prepare_recipients(body, to)

  defp prepare_cc(body, %Email{cc: []}), do: body
  defp prepare_cc(body, %Email{cc: cc}), do: prepare_recipients(body, cc, "cc")

  defp prepare_bcc(body, %Email{bcc: []}), do: body
  defp prepare_bcc(body, %Email{bcc: bcc}), do: prepare_recipients(body, bcc, "bcc")

  defp prepare_recipients(body, recipients, type \\ "to") do
    recipients =
        recipients
        |> Enum.map(&prepare_recipient(&1, type))
        |> Enum.concat(body[:to])

    Map.put(body, :to, recipients)
  end

  defp prepare_recipient({"", email}, type), do: %{email: email, type: type}
  defp prepare_recipient({name, email}, type), do: %{email: email, name: name, type: type}

  defp prepare_subject(_body, %Email{subject: nil}), do: raise ArgumentError, message: "`subject` can't be nil"
  defp prepare_subject(body, %Email{subject: subject}), do: Map.put(body, :subject, subject)

  defp prepare_text(body, %{text_body: nil, html_body: nil}) do
    raise ArgumentError, message: "`html_body` and `text_body` cannot both be nil"
  end
  defp prepare_text(body, %{text_body: nil}), do: body
  defp prepare_text(body, %{text_body: text_body}), do: Map.put(body, :text, text_body)

  defp prepare_html(body, %{html_body: nil, text_body: nil}) do
    raise ArgumentError, message: "`html_body` and `text_body` cannot both be nil"
  end
  defp prepare_html(body, %{html_body: nil}), do: body
  defp prepare_html(body, %{html_body: html_body}), do: Map.put(body, :html, html_body)
end
