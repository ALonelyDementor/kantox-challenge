defmodule BigChain.Cart do
  @moduledoc """
  This is the API for shopping cart maniplulation
  """

  # This is a simple struct for our shopping cart.
  # It will be saved on client for now, yet we might need to save it on database later
  # If associated with an user account
  alias BigChain.Cart.Product, as: Product
  alias BigChain.Cart.ProductRules

  defstruct [:cart_id, :products, :total_price]

  @type products :: [Product.t()]

  @type t :: %__MODULE__{
          cart_id: String.t(),
          products: products(),
          total_price: integer()
        }

  @doc """
  Creates a new empty cart
  """
  @spec new_empty() :: t()
  def new_empty do
    new([])
  end

  @doc """
  Creates a new cart with the given list of products
  """
  @spec new(products()) :: t()
  def new(products) when is_list(products) do
    total_price = calculate_total_price(products)
    %__MODULE__{
      cart_id: :crypto.strong_rand_bytes(16) |> Base.encode64,
      products: products,
      total_price: total_price
    }
  end

  @spec add_product_to_cart(t(), Product.t()) :: t()
  def add_product_to_cart(%__MODULE__{} = cart, %Product{} = product) do
    new_products = [product | cart.products]
    new_total_price = cart.total_price + product.price
    %__MODULE__{
      products: new_products,
      total_price: new_total_price
    }
  end

  def get_total_price_without_rules(%__MODULE__{} = cart) do
    cart.total_price
  end

  def get_total_price(%__MODULE__{} = cart) do
    unique_products = Enum.uniq_by(cart.products, fn p -> p.product_code end)
    Enum.reduce(unique_products, 0, fn product, acc ->
      quantity = get_product_quantity(cart.products, product.product_code)
      acc + ProductRules.apply_rules(product, quantity)
    end)
  end

  # Private functions
  defp calculate_total_price(products) do
    ## TODO: Add support for checkout rules
    Enum.reduce(products, 0, fn product, acc -> acc + product.price end)
  end

  defp get_product_quantity(products, product_code) do
    Enum.count(products, fn p -> p.product_code == product_code end)
  end

end
