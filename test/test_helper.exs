Application.load(:wanon)

for app <- Application.spec(:wanon, :applications) do
  Application.ensure_all_started(app)
end

{:ok, _} = Wanon.Repo.start_link()

# Unit/Module tests
Ecto.Adapters.SQL.Sandbox.mode(Wanon.Repo, :manual)
ExUnit.start()
