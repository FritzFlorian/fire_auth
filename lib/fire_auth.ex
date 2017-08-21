defmodule FireAuth do
  @moduledoc """
  Used to authenticate users with firebase id tokens.
  Usage:

  plug FireAuth, [load_user: function, load_groups: function]
  ...
  plug FireAuth.Secure, group: "required_group"
  """
  import Plug.Conn
  require Logger

  def init(opts) do
    load_user = 
      case Keyword.fetch(opts, :load_user) do
        {:ok, load_user} ->
          load_user
        _ ->
          fn _ -> nil end
      end

    load_groups =
      case Keyword.fetch(opts, :load_groups) do
        {:ok, load_user} ->
          load_user
        _ ->
          fn _, _ -> [] end
      end

    %{load_user: load_user, load_groups: load_groups}
  end

  # For mocking in tests set the :fire_auth_user, :fire_auth_groups, :fire_auth_token_info assigns.
  # :fire_auth_user is required to trigger the mocking
  def call(%{assigns: %{fire_auth_user: user}} = conn, 
         %{load_user: load_user, load_groups: load_groups}) do
    info = Map.get(conn.assigns, :fire_auth_token_info)
    user = user || load_user.(info)
       
    fire_auth = %{
      authenticated: true,
      token_info: info,
      user: user,
      groups: Map.get(conn.assigns, :fire_auth_groups) || load_groups.(info, user)
    }

    assign(conn, :fire_auth, fire_auth)
  end

  def call(conn, %{load_user: load_user, load_groups: load_groups}) do
    auth_token = conn
                    |> Plug.Conn.get_req_header("authorization")
                    |> Enum.map(&String.split/1)
                    |> Enum.filter(fn e -> length(e) == 2 end)
                    |> Enum.filter(fn [type, _] -> String.downcase(type) == "bearer" end)
                    |> Enum.map(fn [_, token] -> token end)
                    |> Enum.at(0)

    if auth_token do
      case validate_token(auth_token) do
        {:ok, info} -> 
          user = load_user.(info)

          fire_auth = %{
            authenticated: true,
            token_info: info,
            user: user,
            groups: load_groups.(info, user)
          }

          assign(conn, :fire_auth, fire_auth)
        _ -> 
          fire_auth = %{
            authenticated: false,
            token_info: nil,
            user: nil,
            groups: nil
          }

          assign(conn, :fire_auth, fire_auth)
      end
    else
      fire_auth = %{
        authenticated: false,
        token_info: nil,
        user: nil,
        groups: nil
      }

      assign(conn, :fire_auth, fire_auth)
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
