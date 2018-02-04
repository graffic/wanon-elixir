defmodule Telegram.Mock do
  @behaviour Telegram.API

  def get_me() do
    {:ok, %{}}
  end

  def get_updates(_) do
    {:ok, %{}}
  end
  def reply(_, "Reply to a message to add a quote"), do:
    send self(), :reply_error 

  def reply(_, "procesado correctamente, siguienteeeeeee!!!!"), do:
    send self(), :reply_processed
    
  def reply(_, _) do
    nil
  end
end