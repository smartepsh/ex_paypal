defmodule PayPal.Token.Refresher do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    Process.flag(:trap_exit, true)

    {:ok, args, {:continue, nil}}
  end

  def handle_continue(_, _state) do
    case refresh_token() do
      {:ok, seconds} ->
        send_next_signal(seconds)
        {:noreply, seconds}

      {:error, reason} ->
        {:stop, reason}
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

  def refresh_token do
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
