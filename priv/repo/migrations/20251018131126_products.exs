defmodule BigChain.Repo.Migrations.Products do
  use Ecto.Migration

  def products_table_name do
    Application.get_env(:big_chain, BigChain.Products.Product)[:products_table_name]
  end

  def change do
    table_name = products_table_name()
    create table(table_name) do
      add :product_code, :string, null: false, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :price, :integer, null: false

      timestamps() # this seems not to be necessary, but let's leave it here in case we find it useful later
    end

    create unique_index(table_name, [:name])
    create unique_index(table_name, [:product_code])
  end
end
