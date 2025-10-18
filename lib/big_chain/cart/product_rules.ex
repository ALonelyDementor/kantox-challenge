defmodule BigChain.Cart.ProductRules do
  @moduledoc """
  This is business lgic right here, yet, we don't need to implement it here.
  The kind of business logic request, can be implemented also on the database directly
  using rules and triggers.
  This would lift the load from the application side drastically, since the app doesn't even need to know how many
  of these products are in the cart (and we don't need to perform some memoization-like optimisation).
  However, for the sake of this exercise, we will implement a simple rule engine here.
  """
  def apply_rules(product, quantity) do
    product_rules = get_rules_for_product(product.product_code)

    apply_rules_to_product(product, quantity, product_rules)
  end

  def new_product_rule(product_code, attr) do
    rules = Application.get_env(:big_chain, BigChain.Cart.ProductRules)[:rules]
    updated_rules = Map.put(rules, product_code, attr)

    Application.put_env(:big_chain, BigChain.Cart.ProductRules, rules: updated_rules)
  end

  ## Private Function
  defp get_rules_for_product(product_code) do
    rules = Application.get_env(:big_chain, BigChain.Cart.ProductRules)[:rules]
    Map.get(rules, product_code, %{})
  end

  defp apply_rules_to_product(product, qty, %{rule: :buy_one_get_one_free}) do
    free_items = div(qty, 2)
    paid_items = qty - free_items # If qty is odd, the last one is paid
    paid_items * product.price
  end
  defp apply_rules_to_product(product, qty, %{rule: :discount_relative} = product_rules) do
    discount_percentage = Map.get(product_rules, :amount, 0)

    amount_of_discounted_products = discounted_products(qty, product_rules)

    # To calculate the final price, we need to see how many products are eligible for the discount
    # This said, if user purchased 2 products, discount will be applied to 0 products

    remainder_of_products = qty - amount_of_discounted_products
    discounted_price = product.price * ((100 - discount_percentage) / 100)

    discounted_price * amount_of_discounted_products + remainder_of_products * product.price
  end
  defp apply_rules_to_product(product, qty, %{rule: :discount_absolute} = product_rules) do
    discount_percentage = Map.get(product_rules, :percentage, 0)
    amount_of_discounted_products = discounted_products(qty, product_rules)

    products_without_discount = qty - amount_of_discounted_products
    discounted_price = product.price * (discount_percentage / 100)
    discounted_price * amount_of_discounted_products + products_without_discount * product.price
  end

  defp discounted_products(qty, %{for_each: per_product_amount}) do
    div(qty, per_product_amount) * qty
  end
  defp discounted_products(qty, %{more_than: more_than}) do
    if qty > more_than, do: qty, else: 0
  end
end
