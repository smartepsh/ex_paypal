defmodule PayPal.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  def start(_type, _args) do
    children =
      if Application.get_env(:ex_paypal, :environment) == :test,
        do: [],
        else: [PayPal.Token.Refresher]

    opts = [strategy: :one_for_one, name: PayPal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
