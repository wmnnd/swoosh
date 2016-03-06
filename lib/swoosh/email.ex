defmodule Swoosh.Email do
  @moduledoc """
  Primitive for composing emails.

  ## Example

      %Email{}
      |> to("tony@stark.com")
      |> cc({"Steve Rogers", "steve@rogers.com"})
      |> cc(["bruce@banner.com", {"Thor Odinson", "thor@odinson.com"}])
      |> bcc("jarvis@avengers.com")
      |> subject("Welcome, to the Avengers")
      |> html_body("<h1>Welcome to the Avengers</h1>")
      |> text_body("Welcome to the Avengers")
  """

  defstruct subject: "", from: nil, to: [], cc: [], bcc: [], text_body: nil,
            html_body: nil, attachments: nil, reply_to: nil, headers: %{}

  @doc """
  Sets the `from` header.

  Valid formats:
  * `"tony@stark.com"`
  * `{"Tony Stark", "tony@stark.com"}
  """
  def from(%__MODULE__{} = email, from) do
    from = format_recipient(from)
    %{email | from: from}
  end

  for fun <- [:subject, :text_body, :html_body, :reply_to] do
    @doc """
    Sets the #{fun}.

    Valid formats:
    * `"tony@stark.com"`
    * `{"Tony Stark", "tony@stark.com"}
    """
    def unquote(fun)(%__MODULE__{} = email, value) do
      %{email | unquote(fun) => value}
    end
  end

  for fun <- [:to, :cc, :bcc] do
    @doc """
    Adds new recipients to the `#{fun}` header.

    Valid formats for recipients:
    * `"tony@stark.com"`
    * `{"Tony Stark", "tony@stark.com"}
    """
    def unquote(fun)(%__MODULE__{unquote(fun) => existing_recipients} = email, recipients) when is_list(recipients) do
      recipients =
        recipients
        |> Enum.map(&format_recipient(&1))
        |> Kernel.++(existing_recipients)
      %{email | unquote(fun) => recipients}
    end
    def unquote(fun)(%__MODULE__{} = email, recipient) do
      unquote(fun)(email, [recipient])
    end

    @doc """
    Puts new recipients in the `#{fun}` header.

    It will replace any previously added `#{fun}` recipients.

    Valid formats for recipients:
    * `"tony@stark.com"`
    * `{"Tony Stark", "tony@stark.com"}
    """
    def unquote(:"put_#{fun}")(%__MODULE__{} = email, recipients) when is_list(recipients) do
      recipients =
        recipients
        |> Enum.map(&format_recipient(&1))
      %{email | unquote(fun) => recipients}
    end
    def unquote(:"put_#{fun}")(%__MODULE__{} = email, recipient) do
      unquote(:"put_#{fun}")(email, [recipient])
    end
  end

  @doc """
  Puts a new header in the email.

  The header name and value must be of type string.
  """
  def header(%__MODULE__{headers: headers} = email, name, value) when is_binary(name) and is_binary(value) do
    headers = headers |> Map.put(name, value)
    Map.put(email, :headers, headers)
  end
  def header(%__MODULE__{}, name, value) do
    raise ArgumentError, message:
    """
    header/3 expects the header name and value to be strings.

    Instead it got:
      name: `#{inspect name}`.
      value: `#{inspect value}`.
    """
  end

  defp format_recipient({name, address} = recipient) when is_binary(name) and is_binary(address) and recipient != "" do
    recipient
  end
  defp format_recipient(recipient) when is_binary(recipient) and recipient != "" do
    {"", recipient}
  end
  defp format_recipient(invalid) do
    raise ArgumentError, message:
    """
    The recipient `#{inspect invalid}` is invalid.

    Recipients must be a string representing an email address like
    `foo@bar.com` or a two elements tuple `{name, address}`, where
    name and address are strings.
    """
  end
end
