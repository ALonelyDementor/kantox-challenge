defmodule BigChain.Repo.Migrations.AddQuantityField do
  use Ecto.Migration

  def products_table_name do
    Application.get_env(:big_chain, BigChain.Products.Product)[:products_table_name]
  end

  def change do
    alter table(products_table_name()) do
      add :quantity, :integer, default: 0, null: false
    end
  end
end
