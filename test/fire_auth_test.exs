defmodule FireAuthTest do
  use ExUnit.Case
  use Plug.Test

  @valid_token "eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyNzE3N2FmNzhjYTk2Yjk0NjBjMDc0OGEwYzcyODM1MjA1M2YxMzYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbmFkYS1wcmV2aWV3IiwicHJvdmlkZXJfaWQiOiJhbm9ueW1vdXMiLCJhdWQiOiJuYWRhLXByZXZpZXciLCJhdXRoX3RpbWUiOjE1MDMzNDU1NDcsInVzZXJfaWQiOiI4bmluOEVQQVEzVE1nSHhIWEpldE10R2NIbGUyIiwic3ViIjoiOG5pbjhFUEFRM1RNZ0h4SFhKZXRNdEdjSGxlMiIsImlhdCI6MTUwMzM1MDQ4MywiZXhwIjoxNTAzMzU0MDgzLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7fSwic2lnbl9pbl9wcm92aWRlciI6ImFub255bW91cyJ9fQ.tlMfsd1CHXyHiAmbBcVGdEMUvQSvYY2bZeX8pWHGdN1pJ-PCisK8r28mBHI1-pHQTXgRH84MF92BmHYKPeJapEP13pnVgPZqqfXJ44i0-QGeCbVWHthzs_O-i1W4PAxjn0fUL_K9ZeU7vqbDUCIkgx3MtfOhn-ASfo2ead9vgZquSJP7DnV4KScOvJ8-yJDStQvfnSbYKTfCBQAp-rD95ZKhmQhpUUcFjy0ameephgHBvywyOkkNVJquteH33wh3X-2LaNoK6YF0xTmzJ234DMVZ_RNo3GtHZZ51hoJKXv8rZcHxxs3pv2XsgOQbuq5CEy78-XNBsso_wy4gQnYlbg"
  @invalid_token "eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyNzE3N2FmNzhjYTk2Yjk0NjBjMDc0OGEwYzcyODM1MjA1M2YxMzYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbmFkYS1wcmV2aWV3IiwicHJvdmlkZXJfaWQiOiJhbm9ueW1vdXMiLCJhdWQiOiJuYWRhLXByZXZpZXciLCJhdXRoX3RpbWUiOjE1MDMzNDU1NDcsInVzZXJfaWQiOiI4bmluOEVQQVEzVE1nSHhIWEpldE10R2NIbGUyIiwic3ViIjoiOG5pbjhFUEFRM1RNZ0h4SFhKZXRNdEdjSGxlMiIsImlhdCI6MTUwMzM0NTU0OCwiZXhwIjoxNTAzMzQ5MTQ4LCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7fSwic2lnbl9pbl9wcm92aWRlciI6ImFub255bW91cyJ9fQ.WLdNP6VvXbgAaGyh0w-ZqgdtAXhfJpZ5OQ0aLu5E63opsmhPqdw2trZHcmpX35vHVAEQ1jIxNs_X8-WrSPdzPWYPpJCCGc0jY35DCj8JVlPsWCOlYvDL0uFSPsZYQIvy9wpwEfAC2eb5OH5bGIOQluwy8x2NO1PHjk2jbpEn7NXlp5tS-3JzI1oz-aaREGSwy-1U89rL8FnKz5dVZhxUySXjJeGMGq8MMvAyNCHU8FkflX5bT6eUiR2GGIrNbcvtErmWbLvd18o68qeCaw6myI9-97MCTvWJmdo_K4uH4XUH20AU50sskhqknTcheKj_w2qjAGHZ-cfIbWbKuseBjw"

  defmodule TestRouter do
    use Plug.Router

    plug FireAuth, [load_user: &TestRouter.load_user/1, load_groups: &TestRouter.load_groups/2]

    match _, do: send_resp(conn, 200, "")

    def load_user(%{id: "some id"}) do
      %{
        name: "some name",
        id: "some id",
        groups: ["manager"]
      }
    end

    def load_user(%{id: "8nin8EPAQ3TMgHxHXJetMtGcHle2"}) do
      %{
        name: nil,
        id: "8nin8EPAQ3TMgHxHXJetMtGcHle2",
        groups: []
      }
    end

    def load_groups(_info, %{groups: groups}) do
      groups
    end
  end

  @opts TestRouter.init([])

  test "groups are loaded correctly" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth_user, %{groups: ["admin"]})
            |> TestRouter.call(@opts)

    assert conn.assigns.fire_auth.authenticated
    assert %{groups: ["admin"]} == conn.assigns.fire_auth.user
    assert ["admin"] == conn.assigns.fire_auth.groups
  end

  test "user is loaded correctly" do
    conn = conn(:get, "some_route")
            |> assign(:fire_auth_user, nil)
            |> assign(:fire_auth_token_info, %{id: "some id"})
            |> TestRouter.call(@opts)

    assert conn.assigns.fire_auth.authenticated
    assert %{name: "some name", id: "some id", groups: ["manager"]} ==
              conn.assigns.fire_auth.user
    assert ["manager"] == conn.assigns.fire_auth.groups
  end

  test "authenticated is false without user set" do
    conn = conn(:get, "/some_route")
            |> TestRouter.call(@opts)

    refute conn.assigns.fire_auth.authenticated
  end

  test "refuses wrong token header" do
    conn = conn(:get, "/some_route")
           |> put_req_header("authorization", "wrong #{@valid_token}")
           |> TestRouter.call(@opts)

    refute conn.assigns.fire_auth.authenticated
  end

  @tag :capture_log
  test "loads correct user when valid token is given in header" do
    conn = conn(:get, "/some_route")
            |> put_req_header("authorization", "Bearer #{@valid_token}")
            |> TestRouter.call(@opts)

    assert conn.assigns.fire_auth.authenticated
    assert "8nin8EPAQ3TMgHxHXJetMtGcHle2" == conn.assigns.fire_auth.user.id
  end

  test "refuses invalid token" do
    conn = conn(:get, "/some_route")
            |> put_req_header("authorization", "Bearer #{@invalid_token}")
            |> TestRouter.call(@opts)

    refute conn.assigns.fire_auth.authenticated
  end

end
