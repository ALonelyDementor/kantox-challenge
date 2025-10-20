import Config

config :big_chain, BigChain.Cart.ProductRules,
  # while developing this, I feel like this is a bit unnecessarily complex,
  # since we need to know all the products. Also, it doesn't fell scalable enough.
  # A best approach feels like adding these rules on the database side, using triggers and rules.
  # And update the rules with migrations.
  rules:
    %{
      GR1: %{rule: :buy_one_get_one_free},
      SR1: %{rule: :discount_relative, amount: 10, for_each: 3},
      CF1: %{rule: :discount_absolute, percentage: 66.66, for_each: 3}
    }
