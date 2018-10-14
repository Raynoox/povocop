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

  def get_best(clientInfo), do: GenServer.call(@name, {:get_best, clientInfo})

  def init(_) do
    {:ok, []}
  end

  def handle_call(:get, _from, []) do
    {:reply, [], []}
  end
  def handle_call(:get, _from, tasks) when length(tasks) < 6 do
    {:reply, tasks, tasks}
  end

  def handle_call({:get_best, clientInfo}, _from, tasks) when length(tasks) < 6 do
    {:reply, tasks, tasks}
  end

  def handle_call(:get, from, tasks) do
    
    batch = Enum.take(tasks, 3)
    GenServer.reply(from, batch)
    {:noreply, Enum.drop(tasks, 3) ++ batch}
  end

  def handle_call({:get_best, clientInfo}, from, tasks) do 

    default_batch_size = 4
    default_cores = 1
    batch_size = Enum.max([RavioliCook.JobFetcher.Server.get_batch_size_prediction(List.first(tasks)["job_id"], clientInfo)*default_cores,default_batch_size])
    batch = Enum.take(tasks, batch_size)
    GenServer.reply(from, batch)
    {:noreply, Enum.drop(tasks, batch_size) ++ batch}
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
