defmodule Wanon do
  def start do
    # El cheapo start from iex without supervisor
    Wanon.Telegram.GetUpdates.start_link()
    Wanon.Quotes.Consumer.start_link()
    Wanon.Quotes.Cache.start_link()
    Wanon.Quotes.AddQuote.start_link()
    Wanon.Quotes.RQuote.start_link()
    Wanon.Quotes.CacheClean.start_link()
  end
end
