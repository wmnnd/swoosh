if Code.ensure_loaded?(Phoenix) do
  defmodule Phoenix.Swoosh do
    import Swoosh.Email

    defmacro __using__(opts) do
      unless view = Keyword.get(opts, :view) do
        raise ArgumentError, "no view was set, " <>
                             "you can set one with `use Phoenix.Swoosh, view: MyApp.EmailView`"
      end
      layout = Keyword.get(opts, :layout)
      quote bind_quoted: [view: view, layout: layout] do
        import Swoosh.Email
        import Phoenix.Swoosh

        @view view
        @layout layout || false

        def template_body(email, template, assigns) do
          email
          |> put_new_layout(@layout)
          |> put_new_view(@view)
          |> Phoenix.Swoosh.render_body(template, assigns)
        end
      end
    end

    def render_body(email, template, assigns) when is_atom(template) do
      email
      |> do_render_body(template_name(template, "html"), "html", assigns)
      |> do_render_body(template_name(template, "text"), "text", assigns)
    end

    def render_body(email, template, assigns) when is_binary(template) do
      case Path.extname(template) do
        "." <> format ->
          do_render_body(email, template, format, assigns)
        "" ->
          raise "cannot render template #{inspect template} without format. Use an atom if you " <>
                "want to set both the html and text body."
      end
    end

    defp do_render_body(email, template, format, assigns) do
      assigns = to_map(assigns)
      email =
        email
        |> put_private(:phoenix_template, template)
        |> prepare_assigns(assigns, format)

      view = Map.get(email.private, :phoenix_view) ||
              raise "a view module was not specified, set one with put_view/2"

      content = Phoenix.View.render_to_string(view, template, Map.put(email.assigns, :email, email))
      Map.put(email, :"#{format}_body", content)
    end

    @doc """
    Stores the layout for rendering.

    The layout must be a tuple, specifying the layout view and the layout
    name, or false. In case a previous layout is set, `put_layout` also
    accepts the layout name to be given as a string or as an atom. If a
    string, it must contain the format. Passing an atom means the layout
    format will be found at rendering time, similar to the template in
    `render_template/5`. It can also be set to `false`. In this case, no
    layout would be used.

    ## Examples

        iex> layout(email)
        false

        iex> email = put_layout email, {LayoutView, "email.html"}
        iex> layout(email)
        {LayoutView, "email.html"}

        iex> email = put_layout email, "email.html"
        iex> layout(email)
        {LayoutView, "email.html"}

        iex> email = put_layout email, :email
        iex> layout(email)
        {AppView, :print}
    """
    def put_layout(email, layout) do
      do_put_layout(email, layout)
    end

    defp do_put_layout(email, false) do
      put_private(email, :phoenix_layout, false)
    end

    defp do_put_layout(email, {mod, layout}) when is_atom(mod) do
      put_private(email, :phoenix_layout, {mod, layout})
    end

    defp do_put_layout(email, layout) when is_binary(layout) or is_atom(layout) do
      update_in email.private, fn private ->
        case Map.get(private, :phoenix_layout, false) do
          {mod, _} -> Map.put(private, :phoenix_layout, {mod, layout})
          false    -> raise "cannot use put_layout/2 with atom/binary when layout is false, use a tuple instead"
        end
      end
    end

    @doc """
    Stores the layout for rendering if one was not stored yet.
    """
    def put_new_layout(email, layout)
        when (is_tuple(layout) and tuple_size(layout) == 2) or layout == false do
      update_in email.private, &Map.put_new(&1, :phoenix_layout, layout)
    end

    @doc """
    Retrieves the current layout.
    """
    def layout(email), do: email.private |> Map.get(:phoenix_layout, false)

    @doc """
    Stores the view for rendering.
    """
    def put_view(email, module) do
      put_private(email, :phoenix_view, module)
    end

    @doc """
    Stores the view for rendering if one was not stored yet.
    """
    def put_new_view(email, module) do
      update_in email.private, &Map.put_new(&1, :phoenix_view, module)
    end

    defp prepare_assigns(email, assigns, format) do
      layout =
        case layout(email, assigns, format) do
          {mod, layout} -> {mod, template_name(layout, format)}
          false -> false
        end

      update_in email.assigns,
                & &1 |> Map.merge(assigns) |> Map.put(:layout, layout)
    end

    defp layout(email, assigns, format) do
      if format in ["html", "text"] do
        case Map.fetch(assigns, :layout) do
          {:ok, layout} -> layout
          :error -> layout(email)
        end
      else
        false
      end
    end

    defp to_map(assigns) when is_map(assigns), do: assigns
    defp to_map(assigns) when is_list(assigns), do: :maps.from_list(assigns)
    defp to_map(assigns), do: Dict.merge(%{}, assigns)

    defp template_name(name, format) when is_atom(name), do:
      Atom.to_string(name) <> "." <> format
    defp template_name(name, _format) when is_binary(name), do:
      name
  end
end
