defmodule RavioliCook.Results do
  @doc "Abstracts sending the `:add_result` message to genserver"
  def add_result(nil, _), do: :ok
  def add_result(pid, result) do
    IO.inspect pid
    IO.inspect result
    GenServer.cast(pid, {:add_result, result})
  end
end
