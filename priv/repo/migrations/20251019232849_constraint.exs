defmodule BigChain.Repo.Migrations.Constraint do
  use Ecto.Migration

  def products_table_name do
    Application.get_env(:big_chain, BigChain.Products.Product)[:products_table_name]
  end

  def change do
    create constraint(products_table_name(), :quantity_must_be_non_negative, check: "quantity >= 0")
  end
end
