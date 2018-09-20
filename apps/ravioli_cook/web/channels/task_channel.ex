defmodule RavioliCook.TaskChannel do
  use RavioliCook.Web, :channel
  alias RavioliCook.TaskServer

  def join("tasks:*", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("task_request", %{}, socket) do
    IO.inspect TaskServer.get()

  	case TaskServer.get() do
      nil -> nil
      tasks ->
        push(socket, "task_response", %{:items => tasks})
    end
    {:noreply, socket}
  end
end
