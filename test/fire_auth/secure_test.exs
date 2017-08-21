defmodule FireAuth.SecureTest do
  use ExUnit.Case
  use Plug.Test

  defmodule NoGroupRouter do
    use Plug.Router
    alias FireAuth.SecureTest

    plug FireAuth, [load_user: &SecureTest.load_user/1, load_groups: &SecureTest.load_groups/2]
    plug FireAuth.Secure

    match _, do: send_resp(conn, 200, "")
  end

  defmodule GroupRouter do
    use Plug.Router
    alias FireAuth.SecureTest

    plug FireAuth, [load_user: &SecureTest.load_user/1, load_groups: &SecureTest.load_groups/2]
    plug FireAuth.Secure, group: "admin"

    match _, do: send_resp(conn, 200, "")
  end


  test "secured route halts without logged in user" do
    conn = conn(:get, "/some_route")
            |> NoGroupRouter.call(NoGroupRouter.init([]))

    assert conn.halted
  end

  test "secrued route continues with logged in user" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth_user, %{})
            |> NoGroupRouter.call(NoGroupRouter.init([]))

    refute conn.halted
  end

  test "route secured with group refuses user withot this group" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth_user, %{})
            |> assign(:fire_auth_groups, ["moderator"])
            |> GroupRouter.call(GroupRouter.init([]))

    assert conn.halted
  end

  test "route secured with group allows user with this group" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth_user, %{})
            |> assign(:fire_auth_groups, ["moderator", "admin"])
            |> GroupRouter.call(GroupRouter.init([]))

    refute conn.halted
  end

  def load_user(_) do
    %{}
  end
  def load_groups(_, _) do
    []
  end
end
