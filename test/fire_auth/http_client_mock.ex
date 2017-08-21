defmodule FireAuth.HttpClientMock do
  def get(_) do
    {:ok, body} = File.read("test/google-keys.json")
    %{body: body}
  end
end
