defmodule Wanon.Quotes.Render do
  alias Wanon.Quotes.QuoteEntry

  @spec render(the_quote :: Wanon.Quotes.Quote) :: String.t
  def render(the_quote) do
    the_quote.entries
    |> Enum.map(&render_entry/1)
    |> Enum.join("\n")
  end

  defp render_entry(%QuoteEntry{message: message}) do
    content = render_content(message)
    name = render_name(message["from"])
    "#{name} #{content}"
  end

  defp render_content(%{"text" => text}), do: text
  defp render_content(_), do: "No text found :("

  defp render_name(%{"username" => username}) do
    "<#{username}>"
  end

  defp render_name(%{"first_name" => first, "last_name" => last}) do
    "<#{first} #{last}>"
  end

  defp render_name(%{"first_name" => first}) do
    "<#{first}>"
  end
end
