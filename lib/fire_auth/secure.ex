defmodule FireAuth.Secure do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    if conn.assigns[:authenticated] do
      case Keyword.fetch(opts, :group) do
        {:ok, group} ->
          user_groups = conn.assigns[:groups]
          if Enum.member?(user_groups || [], group) do
            conn
          else
            conn
            |> put_status(:forbidden)
            |> Phoenix.Controller.json(%{error: "Forbidden!"})
            |> halt()
          end
        _ -> 
          conn
      end
    else
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.json(%{error: "Authentication Required!"})
      |> halt()
    end
  end
end
