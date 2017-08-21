defmodule FireAuth.KeyServer do
  @moduledoc """
  Handles the calls to google to feth the public keys needed in the auth process.
  Will cache the keys for some time to avoid usage limits.
  """
  use GenServer
  require Logger

  # The interval to fetch a new keybase from google
  @fetch_interval 1000 * 60 * 60 # one hour
  @cert_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  @doc """
  Starts the registry.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: FireAuth.KeyServer])
  end

  @doc """
  request the current keybase file as json.
  """
  def get_keybase() do
    GenServer.call(FireAuth.KeyServer, :get_keybase)
  end

  # Server Implementation
  def init(:ok) do
    {:ok, %{keybase: nil, last_update: 0}}
  end

  def handle_call(:get_keybase, _from, %{keybase: keybase, last_update: last_update} = state) do
    if last_update + @fetch_interval > :os.system_time(:millisecond) do
      {:reply, keybase, state}
    else
      keybase = fetch_keybase()
      state = %{keybase: keybase, last_update: :os.system_time(:millisecond)}
      {:reply, keybase, state}
    end
  end

  # ignore unknown info messages
  def handle_info(_ , state) do
    {:ok, state}
  end

  # Internal implementations

  defp fetch_keybase() do
    Logger.info(fn -> "Fetching Keybase for FireAuth...." end)
    FireAuth.Util.http_client.get(@cert_url).body
    |> Poison.decode!
  end
end
