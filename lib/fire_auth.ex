defmodule FireAuth do
  @moduledoc """
  Used to authenticate users with firebase id tokens.
  Usage:

  plug FireAuth, [fetch_or_create_user: fn, fetch_access_list: fn]
  ...
  plug FireAuth.auth, group: "required_group"
  """
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def load_user(conn, opts) do
    fetch_or_create_user = Keyword.fetch!(opts, :fetch_or_create_user)
    fetch_access_list = Keyword.fetch!(opts, :fetch_access_list)
    auth = conn.assigns[:auth]

    user = fetch_or_create_user.(auth)
    access_list = fetch_access_list.(user)
        
    conn
    |> assign(:user, user)
    |> assign(:groups, access_list)
  end

  # Very messy, but fine to test authentication for now
  def call(%{assigns: %{user: user}} = conn, _opts) do
    conn
    |> assign(:authenticated, true)
    |> assign(:groups, user.groups)
  end

  def call(conn, opts) do
    auth_header = conn
                    |> Plug.Conn.get_req_header("authorization")
                    |> Enum.at(0)
    if auth_header do
      [_, id_token] = String.split(auth_header)
      case validate_token(id_token) do
        {:ok, info} -> 
          conn
          |> assign(:authenticated, true)
          |> assign(:auth, info)
          |> load_user(opts)
        _ -> conn
      end
    else
      conn
      |> assign(:authenticated, false)
      |> assign(:auth, nil)
      |> assign(:user, nil)
      |> assign(:groups, [])
    end
  end

  @doc """
  Validates a firebase id token.
  Returns the informatinon encoded in the token.
  """
  def validate_token(token) do
    FireAuth.TokenValidation.validate_token(token)
  end

end
