defmodule FireAuth.Secure do
  @moduledoc """
  Secures routes.
  Requires FireAuth plug to be called before.
  Can optionally restrict route access to a specific user group.

  secure with group:
  plug FireAuth.Secure, group: "required_group"
   
  only for authorized users:
  plug FireAuth.Secure

  only secure some routes
  plug FireAuth.Secure when action in [:index]
  """
  import Plug.Conn

  def init(opts) do
    case Keywod.fetch(opts, :group) do
      {:ok, group} ->
        %{group: group}
      _ ->
        %{}
    end
  end

  def call(%{assigns: %{fire_auth: %{authenticated: true} = fire_auth}} = conn, opts) do
    case opts do
      %{grop: group} ->
        if Enum.member?(fire_auth.groups , group) do
          conn
        else
          conn
            |> put_resp_content_type("application/json")
            |> resp(:forbidden, "{\"error\": \"Forbidden!\"}")
            |> halt()
        end
      _ -> 
        conn
    end
  end

  def call(conn, _) do
    conn
      |> put_resp_content_type("application/json")
      |> resp(:unauthorized, "{\"error\": \"Authentication Required!\"}")
      |> halt()
  end
end
