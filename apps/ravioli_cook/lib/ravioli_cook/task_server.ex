defmodule RavioliCook.TaskServer do
  use GenServer

  @name :task_server
  @timeout 20_000

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  @doc "Add the tasks to the queue"
  def add(tasks), do: GenServer.cast(@name, {:add, tasks})
  @doc "Removes the task from the queue when it's finished"
  def remove(task_id), do: GenServer.cast(@name, {:remove, task_id})
  def get(), do: GenServer.call(@name, :get)
  def finish_job(job_id), do: GenServer.cast(@name, {:finish_job, job_id})

  def get(id), do: GenServer.call(@name, {:get, id})

  def init(_) do
    {:ok, []}
  end

  def handle_call(:get, _from, []) do
    {:reply, [], []}
  end
  def handle_call(:get, _from, tasks) when length(tasks) < 6 do
    {:reply, tasks, tasks}
  end
  def handle_call(:get, from, tasks) do
    # TODO predykcja tutaj zmienić ilość wysyłanych zadań, przy okazji zmienić na 50 batch_size
    batch = Enum.take(tasks, 5)
    GenServer.reply(from, batch)
    {:noreply, Enum.drop(tasks, 5) ++ batch}
  end

  def handle_call({:get, id}, _from, tasks) do
    task = Enum.find(tasks, fn task ->
      task["task_id"] == id
    end)

    {:reply, task, tasks}
  end

  def handle_cast({:add, new_tasks}, tasks) do
    {:noreply, tasks ++ new_tasks}
  end

  def handle_cast({:remove, task_id}, tasks) do
    new_tasks = Enum.reject(tasks, &(&1["task_id"] == task_id))
    {:noreply, new_tasks}
  end

  def handle_cast({:finish_job, job_id}, tasks) do
    new_tasks = Enum.reject(tasks, &(&1["job_id"] == job_id))
    {:noreply, new_tasks}
  end
end
