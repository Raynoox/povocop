defmodule RavioliCook.ResultChannel do
  @moduledoc """
    Let us not worry about docs right now
  """

  use RavioliCook.Web, :channel

  alias RavioliCook.Results.ServerRegistry

  def join("result:job-" <> job_id, _msg, socket) do
    IO.inspect "zxczxv"
    pid = ServerRegistry.get_result_server(job_id)
    IO.inspect "got results"
    IO.inspect pid
    new_socket = assign(socket, :result_server, pid)

    {:ok, new_socket}
  end

  def handle_in("result", data, socket) do
    pid = socket.assigns.result_server
    RavioliCook.Results.add_result(pid, data)
#TODO dodać do data user_id
    {:noreply, socket}
  end
end
