defmodule Telegram.API do
  @type response :: {:ok, map} | {:error, map}
  @callback get_me() :: response
  @callback get_updates(offset :: integer) :: response
  @callback reply(original_message :: map, message :: String.t) ::
    HTTPoison.Response.t | HTTPoison.AsyncResponse.t
  @callback send_text(original_message :: map, message :: String.t) ::
    HTTPoison.Response.t | HTTPoison.AsyncResponse.t
  @callback
end
