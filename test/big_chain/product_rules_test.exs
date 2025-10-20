defmodule BigChain.ProductRulesTest do
  use BigChain.DataCase, async: true

  alias BigChain.Cart.Product
  alias BigChain.Cart

  describe "Green Tea Buy one get one free" do
    test "applies buy one get one free rule for GR1" do
      cart = Cart.new_empty()

      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      Product.update_stock("GR1", 10)

      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "GR1")

      assert length(cart.products) == 2
      assert cart.total_price == 311
      assert Enum.all?(cart.products, fn p -> p.product_code == "GR1" end)

    end
  end

  describe "Three or more strawberries drop to 4.5" do
    test "applies bulk discount for SR1" do
      cart = Cart.new_empty()

      Product.new_product("SR1", "Strawberries", "Fresh strawberries", 500)
      Product.update_stock("SR1", 10)

      {:ok, cart} = Cart.add_product(cart, "SR1")
      {:ok, cart} = Cart.add_product(cart, "SR1")
      {:ok, cart} = Cart.add_product(cart, "SR1")

      assert length(cart.products) == 3
      assert cart.total_price == 1350
      assert Enum.all?(cart.products, fn p -> p.product_code == "SR1" end)

    end

  end

  describe "Coffee discount with more than 3 items" do
    test "applies bulk discount for CF1" do
      cart = Cart.new_empty()

      Product.new_product("CF1", "Coffee", "Premium coffee", 1123)
      Product.update_stock("CF1", 10)

      {:ok, cart} = Cart.add_product(cart, "CF1")
      {:ok, cart} = Cart.add_product(cart, "CF1")
      {:ok, cart} = Cart.add_product(cart, "CF1")

      assert length(cart.products) == 3
      assert trunc(cart.total_price) == 2245
      assert Enum.all?(cart.products, fn p -> p.product_code == "CF1" end)
    end
  end

  describe "Test Case 1" do
    test "GR1, SR1, GR1, GR1, CF1" do
      cart = Cart.new_empty()

      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      Product.update_stock("GR1", 10)

      Product.new_product("SR1", "Strawberries", "Fresh strawberries", 500)
      Product.update_stock("SR1", 10)

      Product.new_product("CF1", "Coffee", "Premium coffee", 1123)
      Product.update_stock("CF1", 10)

      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "SR1")
      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "CF1")

      assert length(cart.products) == 5
      assert floor(cart.total_price) == 2245

    end
  end

  describe "Test Case 2" do
    test "GR1, GR1" do
      cart = Cart.new_empty()

      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      Product.update_stock("GR1", 10)

      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "GR1")

      assert length(cart.products) == 2
      assert floor(cart.total_price) == 311

    end
  end

  describe "Test Case 3" do
    test "SR1, SR1, GR1, SR1" do
      cart = Cart.new_empty()

      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      Product.update_stock("GR1", 10)

      Product.new_product("SR1", "Strawberries", "Fresh strawberries", 500)
      Product.update_stock("SR1", 10)

      {:ok, cart} = Cart.add_product(cart, "SR1")
      {:ok, cart} = Cart.add_product(cart, "SR1")
      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "SR1")

      assert length(cart.products) == 4
      assert floor(cart.total_price) == 1661

    end
  end

  describe "Test Case 4" do
    test "GR1, CF1, SR1, CF1, CF1" do
      cart = Cart.new_empty()

      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      Product.update_stock("GR1", 10)

      Product.new_product("SR1", "Strawberries", "Fresh strawberries", 500)
      Product.update_stock("SR1", 10)

      Product.new_product("CF1", "Coffee", "Premium coffee", 1123)
      Product.update_stock("CF1", 10)

      {:ok, cart} = Cart.add_product(cart, "GR1")
      {:ok, cart} = Cart.add_product(cart, "CF1")
      {:ok, cart} = Cart.add_product(cart, "SR1")
      {:ok, cart} = Cart.add_product(cart, "CF1")
      {:ok, cart} = Cart.add_product(cart, "CF1")

      assert length(cart.products) == 5
      assert floor(cart.total_price) == 3056

    end
  end

end
