defmodule PayPal.Token.Refresher do
  @moduledoc """
  Do request token periodically
  """

  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    Process.flag(:trap_exit, true)

    {:ok, args, {:continue, nil}}
  end

  def handle_continue(_, state) do
    if Application.get_env(:ex_paypal, :environment) in [:test, :sandbox] do
      {:noreply, state}
    else
      case refresh_token() do
        {:ok, seconds} ->
          send_next_signal(seconds)
          {:noreply, seconds}

        {:error, reason} ->
          {:stop, reason}
      end
    end
  end

  def handle_info(:refresh, seconds) do
    case refresh_token() do
      {:ok, seconds} ->
        send_next_signal(seconds)
        {:noreply, seconds}

      {:error, _reason} ->
        send_next_signal(seconds)
        {:noreply, seconds}
    end
  end

  defp send_next_signal(seconds) do
    Process.send_after(self(), :refresh, seconds * 1000)
  end

  defp refresh_token do
    case PayPal.API.get_oauth_token() do
      {:ok, {token, seconds}} ->
        Application.put_env(:ex_paypal, :access_token, token)
        Logger.info("[PayPal] Refreshed access token, expires in #{seconds} seconds")
        {:ok, seconds}

      {:error, reason} ->
        Logger.error(
          "[PayPal] Refreshing access token failed with reason: #{reason}, retrying in 1 second"
        )

        {:error, reason}
    end
  end
end
