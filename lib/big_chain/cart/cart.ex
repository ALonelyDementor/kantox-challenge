defmodule BigChain.Cart do
  @moduledoc """
  This is the API for shopping cart maniplulation
  """

  # This is a simple struct for our shopping cart.
  # It will be saved on client for now, yet we might need to save it on database later
  # If associated with an user account
  require Logger
  alias BigChain.Cart.Product, as: Product
  alias BigChain.Cart.ProductRules

  defstruct [:cart_id, :products, :total_price]

  @type products :: [Product.t()]

  @type t :: %__MODULE__{
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
      products: products,
      total_price: total_price
    }
  end

  @spec add_product(t(), Product.t()) :: t()
  def add_product(%__MODULE__{} = cart, product_code) do
    case Product.get_product_if_at_least_one(product_code) do
      {:error, :insufficient_quantity} ->
        Logger.error("Product with code #{product_code} out of stock")
        {:error, :insufficient_product_quantity}
      {:ok, product} ->
        {:ok, do_add_product(cart, product)}
    end
  end

  def remove_product(%__MODULE__{} = cart, product_code) do
    product = Product.get_product_by_code(product_code)
    products_after_removal = List.delete(cart.products, product)

    dbg(products_after_removal)

    new_cart =
      %__MODULE__{
        products: products_after_removal,
        total_price: calculate_total_price(products_after_removal)
      }

    new_cart
  end

  def from_session(%{products: products, total: total} = _session_cart) do
    %__MODULE__{
      products: Enum.map(products, fn product_code -> Product.get_product_by_code(product_code) end),
      total_price: total
    }
  end
  def from_session(%__MODULE__{} = cart), do: cart

  def to_session(%__MODULE__{} = cart) do
    %{
      products: Enum.map(cart.products, fn product -> product.product_code end),
      total: cart.total_price
    }
  end

  def get_total_price_without_rules(%__MODULE__{} = cart) do
    cart.total_price
  end

  def get_total_price(products) do
    unique_products = Enum.uniq_by(products, fn p -> p.product_code end)

    Enum.reduce(unique_products, 0, fn product, acc ->
      quantity = get_product_quantity(products, product.product_code)
      Logger.debug("Calculating price for product #{product.product_code} with quantity #{quantity}")
      price_rules = ProductRules.apply_rules(product, quantity)
      acc + price_rules
    end)
  end

  def get_products(%__MODULE__{} = cart) do
    Enum.uniq(cart.products)
    |> Enum.map(fn product ->
                  %{name: product.name,
                    id: product.product_code,
                    quantity: get_product_quantity(cart.products, product.product_code)}
                end)
  end

  def checkout(%__MODULE__{} = cart) do
    # This checkout system is just going to update the products amounts in stock
    Logger.info("Checking out cart with total price #{cart.total_price}")
    BigChain.Repo.transaction(fn ->
      Enum.uniq(cart.products)
      |> Enum.map(fn product ->
          quantity = get_product_quantity(cart.products, product.product_code)
          Product.update_stock(product.product_code, -quantity)
        end)
    end)

    new_empty()
  end

  # Private functions
  defp calculate_total_price(products) do
    ## TODO: Add support for checkout rules
    Enum.reduce(products, 0, fn product, acc -> acc + product.price end)
  end

  defp get_product_quantity(products, product_code) do
    Enum.count(products, fn p -> p.product_code == product_code end)
  end

  defp do_add_product(%__MODULE__{} = cart, %Product{} = product) do
    new_products = [product | cart.products]

    %__MODULE__{
      products: new_products,
      total_price: get_total_price(new_products)
    }
  end
end
