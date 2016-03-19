defmodule Swoosh.Email do
  @moduledoc """
  Defines an Email.

  This module defines a `Swoosh.Email` struct and the main functions for composing an email.  As it is the contract for
  the public APIs of `Swoosh` it is a good idea to make use of these functions rather than build the struct yourself.

  ## Email fields

  * `from` - the email address of the sender, example: `{"Tony Stark", "tony@stark.com"}`
  * `to` - the email address for the recipient(s), example: `[{"Steve Rogers", "steve@rogers.com"}]`
  * `subject` - the subject of the email, example: `"Hello, Avengers!"`
  * `cc` - the intended carbon copy recipient(s) of the email, example: `[{"Bruce Banner", "hulk@smash.com"}]`
  * `bcc` - the intended blind carbon copy recipient(s) of the email, example: `[{"Janet Pym", "wasp@avengers.com"}]`
  * `text_body` - the content of the email in plaintext, example: `"Hello"`
  * `html_body` - the content of the email in HTML, example: `"<h1>Hello</h1>"`
  * `reply_to` - the email address that should receive replies, example: `{"Clints Barton", "hawk@eye.com"}`
  * `headers` - a map of headers that should be included in the email, example: `%{"X-Accept-Language" => "en-us, en"}`
  * `assigns` - a map of values that correspond with any template variables, example: `%{"first_name" => "Bruce"}`

  ## Private

  This key is reserved for use with adapters, libraries and frameworks.

  * `private` - a map of values that are for use by libraries/frameworks, example: `%{phoenix_template: "welcome.html.eex"}`


  ## Provider options

  This key allow users to make use of provider-specific functionality by passing along addition parameters.

  * `provider_options` - a map of values that are specific to adapter provider, example: %{async: true}

  ## Example

      email =
        %Swoosh.Email{}
        |> to("tony@stark.com")
        |> from("bruce@banner.com")
        |> text_body("Welcome to the Avengers")

  The composable nature makes it very easy to continue expanding upon a given Email.

      email =
        email
        |> cc({"Steve Rogers", "steve@rogers.com"})
        |> cc("wasp@avengers.com")
        |> bcc(["thor@odinson.com", {"Henry McCoy", "beast@avengers.com"}])
        |> html_body("<h1>Special Welcome</h1>")
  """

  defstruct subject: "", from: nil, to: [], cc: [], bcc: [], text_body: nil,
            html_body: nil, attachments: nil, reply_to: nil, headers: %{},
            private: %{}, assigns: %{}, provider_options: %{}

  @doc """
  Sets a recipient in the `from` field.

  The recipient must be either; a tuple specifying the name and address of the recipient; a string specifying the 
  address of the recipient.

      iex> %Email{} |> from({"Steve Rogers", "steve@rogers.com"})
      %Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: {"Steve Rogers", "steve@rogers.com"},
       headers: %{}, html_body: nil, private: %{}, provider_options: %{},
       reply_to: nil, subject: "", text_body: nil, to: []}

      iex> %Email{} |> from("steve@rogers.com")
      %Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: {"", "steve@rogers.com"},
       headers: %{}, html_body: nil, private: %{}, provider_options: %{},
       reply_to: nil, subject: "", text_body: nil, to: []}
  """
  def from(%__MODULE__{} = email, from) do
    from = format_recipient(from)
    %{email | from: from}
  end

  @doc """
  Sets a recipient in the `reply_to` field.

  The recipient must be either; a tuple specifying the name and address of the recipient; a string specifying the 
  address of the recipient.

        iex> %Email{} |> reply_to({"Steve Rogers", "steve@rogers.com"})
        %Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: nil,
         headers: %{}, html_body: nil, private: %{}, provider_options: %{},
         reply_to: {"Steve Rogers", "steve@rogers.com"}, subject: "", text_body: nil, to: []}

        iex> %Email{} |> reply_to("steve@rogers.com")
        %Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: nil,
         headers: %{}, html_body: nil, private: %{}, provider_options: %{},
         reply_to: {"", "steve@rogers.com"}, subject: "", text_body: nil, to: []}
  """
  def reply_to(%__MODULE__{} = email, reply_to) do
    reply_to = format_recipient(reply_to)
    %{email | reply_to: reply_to}
  end

  @doc """
  Sets the `subject` field.

  The subject must be a string that contains the subject.

        iex> %Email{} |> subject("Hello")
        %Email{assigns: %{}, attachments: nil, bcc: [],
        cc: [], from: nil, headers: %{}, html_body: nil,
         private: %{}, provider_options: %{}, reply_to: nil, subject: "Hello, Avengers!",
         text_body: nil, to: []}
  """
  def subject(email, subject), do: %{email|subject: subject}

  @doc """
  Sets the `text_body` field.

  The text body must be a string that containing the plaintext content.

      iex> %Email{} |> text_body("Hello")
      %Email{assigns: %{}, attachments: nil, bcc: [],
       cc: [], from: nil, headers: %{}, html_body: nil,
       private: %{}, provider_options: %{}, reply_to: nil, subject: "",
       text_body: "Hello", to: []}
  """
  def text_body(email, text_body), do: %{email|text_body: text_body}

  @doc """
  Sets the `html_body` field.

  The HTML body must be a string that containing the HTML content.

      iex> %Email{} |> html_body("<h1>Hello</h1>")
      %Email{assigns: %{}, attachments: nil, bcc: [],
       cc: [], from: nil, headers: %{}, html_body: "<h1>Hello</h1>",
       private: %{}, provider_options: %{}, reply_to: nil, subject: "",
       text_body: nil, to: []}
  """
  def html_body(email, html_body), do: %{email|html_body: html_body}

  for fun <- [:to, :cc, :bcc] do
    @doc """
    Adds new recipients in the `#{fun}` field.

    The recipient must be; a tuple specifying the name and address of the recipient; a string specifying the 
    address of the recipient; or an array comprised of a combination of either.

          iex> %Email{} |> #{fun}("steve@rogers.com")
          %Email{assigns: %{}, attachments: nil, bcc: [],
           cc: [{"", "steve@rogers.com"}], from: nil, headers: %{}, html_body: nil,
           private: %{}, provider_options: %{}, reply_to: nil, subject: "",
           text_body: nil, to: []}

    iex>
    """
    def unquote(fun)(%__MODULE__{unquote(fun) => existing_recipients} = email, recipients) when is_list(recipients) do
      recipients =
        recipients
        |> Enum.map(&format_recipient(&1))
        |> Enum.concat(existing_recipients)
      %{email | unquote(fun) => recipients}
    end
    def unquote(fun)(%__MODULE__{} = email, recipient) do
      unquote(fun)(email, [recipient])
    end

    @doc """
    Puts new recipients in the `#{fun}` field.

    It will replace any previously added `#{fun}` recipients.
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
  Puts a new `header` in the email.

  The name and value must be specified as strings.

      iex> %Email{} |> header("X-Magic-Number", "7")
      %Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: nil,
       headers: %{"X-Magic-Number" => "7"}, html_body: nil, private: %{},
       provider_options: %{}, reply_to: nil, subject: "", text_body: nil, to: []}
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

  @doc """
  Stores a new **private** key and value in the email.

  This store is meant to be for libraries/framework usage.  The name should be specified as an atom, the value can be
  any term.

      iex> %Email |> put_private(:phoenix_template, "welcome.html.eex")
      %Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: nil,
       headers: %{}, html_body: nil, private: %{phoenix_template: "welcome.html.eex"},
       provider_options: %{}, reply_to: nil, subject: "", text_body: nil, to: []}
  """
  def put_private(%__MODULE__{private: private} = email, key, value) when is_atom(key) do
    %{email | private: Map.put(private, key, value)}
  end

  @doc """
  Stores a new **provider_option** key and value in the email.

  This store is meant for adapter usage, to aid provider-specific functionality.  The name should be specified as an
  atom, the value can be any term.

      iex> %Email{} |> put_provider_option(:async, true)
      %Swoosh.Email{assigns: %{}, attachments: nil, bcc: [], cc: [], from: nil,
       headers: %{}, html_body: nil, private: %{}, provider_options: %{async: true},
       reply_to: nil, subject: "", text_body: nil, to: []}
  """
  def put_provider_option(%__MODULE__{provider_options: provider_options} = email, key, value) when is_atom(key) do
    %{email | provider_options: Map.put(provider_options, key, value)}
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
    `foo@bar.com` or a two element tuple `{name, address}`, where
    name and address are strings.
    """
  end
end

