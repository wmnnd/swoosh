defmodule Swoosh.Adapters.Sendgrid do
  alias HTTPoison.Response
  alias Swoosh.Email

  @behaviour Swoosh.Adapter

  @api_key Application.get_env(:swoosh, :sendgrid)[:api_key]
  @api_endpoint "mail.send.json"
  @base_url "https://api.sendgrid.com/api/"

  def base_url() do
    Application.get_env(:swoosh, :sendgrid)[:base_url] || @base_url
  end

  def deliver(%Email{} = email) do
    headers = [{"Content-Type", "application/x-www-form-urlencoded"},
               {"User-Agent", "swoosh/#{Swoosh.version}"},
               {"Authorization", "Bearer #{@api_key}"}]
    body = prepare_body(email) |> Plug.Conn.Query.encode

    case HTTPoison.post(base_url() <> @api_endpoint, body, headers) do
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

  def prepare_body(%Email{} = email) do
    %{}
    |> prepare_from(email)
    |> prepare_to(email)
    |> prepare_cc(email)
    |> prepare_bcc(email)
    |> prepare_subject(email)
    |> prepare_html_body(email)
    |> prepare_text_body(email)
    |> prepare_reply_to(email)
  end

  def prepare_from(_body, %Email{from: nil}), do: raise ArgumentError, message: "`from` can't be nil"
  def prepare_from(_body, %Email{from: {_name, nil}}), do: raise ArgumentError, message: "`from` address can't be nil"
  def prepare_from(body, %Email{from: {name, address}}) when is_nil(name) or name == "" do
    Map.put(body, :from, address)
  end
  def prepare_from(body, %Email{from: {name, address}}) do
    body
    |> Map.put(:from, address)
    |> Map.put(:fromname, name)
  end

  def prepare_to(_body, %Email{to: []}), do: raise AgumentError, message: "`to` can't be empty"
  def prepare_to(body, %Email{to: to}) do
    {names, addresses} = Enum.unzip(to)
    body
    |> prepare_addresses(:to, addresses)
    |> prepare_names(:to, names)
  end

  def prepare_cc(body, %Email{cc: []}), do: body
  def prepare_cc(body, %Email{cc: cc}) do
    {names, addresses} = Enum.unzip(cc)
    body
    |> prepare_addresses(:cc, addresses)
    |> prepare_names(:cc, names)
  end

  def prepare_bcc(body, %Email{bcc: []}), do: body
  def prepare_bcc(body, %Email{bcc: bcc}) do
    {names, addresses} = Enum.unzip(bcc)
    body
    |> prepare_addresses(:bcc, addresses)
    |> prepare_names(:bcc, names)
  end

  def prepare_subject(_body, %Email{subject: nil}), do: raise ArgumentError, message: "`subject` can't be nil"
  def prepare_subject(body, %Email{subject: subject}) do
    Map.put(body, :subject, subject)
  end

  def prepare_html_body(body, %Email{html_body: nil}), do: body
  def prepare_html_body(body, %Email{html_body: html_body}) do
    Map.put(body, :html, html_body)
  end

  def prepare_text_body(body, %Email{text_body: nil}), do: body
  def prepare_text_body(body, %Email{text_body: text_body}) do
    Map.put(body, :text, text_body)
  end

  def prepare_reply_to(body, %Email{reply_to: nil}), do: body
  def prepare_reply_to(body, %Email{reply_to: reply_to}) do
    Map.put(body, :replyto, reply_to)
  end

  defp prepare_addresses(body, field, addresses) do
    Map.put(body, field, addresses)
  end
  defp prepare_names(body, field, names) do
    if list_empty?(names), do: body, else: Map.put(body, field, names)
  end

  defp list_empty?([]), do: true
  defp list_empty?(list) do
    Enum.all?(list, fn(el) -> el == "" || el == nil end)
  end
end
