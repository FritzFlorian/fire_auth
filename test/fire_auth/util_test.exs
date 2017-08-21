defmodule FireAuth.UtilTest do
  use ExUnit.Case

  test "loading record definitions works" do
    require FireAuth.Util
  end

  test "util mocks time for tests" do
    assert 1503350512 == FireAuth.Util.current_time
  end

  test "util mocks http client for tests" do
    assert FireAuth.HttpClientMock == FireAuth.Util.http_client
  end
end
