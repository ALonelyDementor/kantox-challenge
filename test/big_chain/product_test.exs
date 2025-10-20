defmodule BigChain.ProductTest do
    use BigChain.DataCase

  alias BigChain.Cart.Product

  describe "Add a new product" do
    test "adds new product" do
      Product.new_product("GR1", "Green Tea", "A refreshing green tea", 311)
      product = Product.get_product_by_code("GR1")

      assert product.product_code == "GR1"
      assert product.name == "Green Tea"
      assert product.description == "A refreshing green tea"
      assert product.price == 311

    end
  end

  describe "Update product stock" do
    test "updates stock for existing product" do
      Product.new_product("SR1", "Strawberries", "Fresh strawberries", 500)
      Product.update_stock("SR1", 20)

      product = Product.get_product_by_code("SR1")

      assert product.quantity == 20
    end
  end


end
