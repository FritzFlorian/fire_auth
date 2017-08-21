defmodule FireAuthTest do
  use ExUnit.Case
  doctest FireAuth

  test "loading record definitions works" do
    require FireAuth.RecordHelper
  end
end
