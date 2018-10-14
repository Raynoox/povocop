defmodule RavioliCook.TaskChannel do
  use RavioliCook.Web, :channel
  alias RavioliCook.TaskServer

  def join("tasks:*", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("task_request", clientInfo, socket) do
    #IO.inspect clientInfo
    #IO.inspect TaskServer.get(clientInfo)

  	case TaskServer.get_best(clientInfo) do
      nil -> nil
      tasks ->
        push(socket, "task_response", %{:items => tasks})
    end
    {:noreply, socket}
  end
end
