defmodule Wanon.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table("quote") do
      add :creator, :map, null: false
      timestamps(updated_at: false)
    end

    create table("quote_entry") do
      add :order, :integer, null: false
      add :message, :map, null: false
      add :quote_id, references("quote"), null: false
    end
  end
end
