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
    field :quantity, :integer, default: 0

    # this seems not to be necessary, but let's leave it here in case we find it useful later
    timestamps()
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

  def update_stock(product_code, quantity) do
    case get_product_by_code(product_code) do
      nil ->
        {:error, :product_not_found}
      product ->
        updated_quantity = product.quantity + quantity

        changeset = Ecto.Changeset.change(product, quantity: updated_quantity)
        BigChain.Repo.update(changeset)
    end
  end

  def get_product_by_code(product_code) do
    __MODULE__
    |> from(as: :u)
    |> where([u], u.product_code == ^product_code)
    |> BigChain.Repo.one()
  end

  def get_all_products() do
    BigChain.Repo.all(__MODULE__)
  end

  def has_enough_quantity?(%__MODULE__{quantity: available}, requested) when available >= requested, do: true
  def has_enough_quantity?(_product, _requested), do: false

  def get_product_if_at_least_one(product_code) do
    product =
      product_code
      |> get_product_by_code

    if has_enough_quantity?(product, 1) do
      {:ok, product}
    else
      {:error, :insufficient_quantity}
    end
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
