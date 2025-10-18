defmodule BigChain.Cart.Product do
  ## This module contains the schema and functions to mnage products in the BigChain application.
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query


  @primary_key {:product_code, :string, []}
  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :integer

    timestamps() # this seems not to be necessary, but let's leave it here in case we find it useful later
  end

  @type t :: %__MODULE__{
          product_code: String.t(),
          name: String.t(),
          description: String.t() | nil,
          price: integer()
        }

  ## API functions
  def new_product(code, name, description \\ nil, price) do
    %__MODULE__{
      product_code: code,
      name: name,
      description: description,
      price: price
    }
    |> validate_product()
    |> BigChain.Repo.insert()
  end

  def add_product(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> BigChain.Repo.insert()
  end


  def get_product_by_code(product_code) do
    query = from u in __MODULE__,
              where: u.product_code == ^product_code,
              select: u
    BigChain.Repo.one(query)
  end

  ## Private functions
  defp validate_product(product) do
    product
    |> change
    |> validate_required([:product_code, :name, :price])
    |> unique_constraint(:name)
    |> unique_constraint(:product_code)
  end

  defp changeset(product, attrs) do
    product
    |> cast(attrs, [:product_code, :name, :description, :price])
    |> validate_required([:product_code, :name, :price])
    |> unique_constraint(:name)
    |> unique_constraint(:product_code)
  end

end
