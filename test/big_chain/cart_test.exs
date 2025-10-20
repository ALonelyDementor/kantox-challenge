defmodule BigChain.CartTest do
  use BigChain.DataCase

  alias BigChain.Cart
  alias BigChain.Cart.Product

  describe "adding products to cart" do
    test "adds a product to an empty cart" do
      cart = Cart.new_empty()

      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      Product.update_stock("GR1", 10)

      {:ok, updated_cart} = Cart.add_product(cart, "GR1")

      assert length(updated_cart.products) == 1
      assert hd(updated_cart.products).product_code == "GR1"
      assert updated_cart.total_price == 311
    end
  end


end
