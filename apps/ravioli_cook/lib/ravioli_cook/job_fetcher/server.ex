defmodule RavioliCook.JobFetcher.Server do
  @moduledoc """
  Server fetching the jobs api for existing jobs. After receiving the list,
  it saves the new ones in its state. Makes an API call every `@interval` seconds.
  """
  use GenServer

  alias RavioliCook.JobFetcher.Api
  alias RavioliCook.Tracker.JobTracker
  alias RavioliCook.{JobDivider, Job, TaskServer}

  @name :job_fetcher
  @interval 25_000
  @timeout 20_000
  @jobs_api Application.get_env(:ravioli_cook, :jobs_api, RavioliCook.JobFetcher.Api)

  # Client API
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @doc "Returns the list of current jobs"
  def get_jobs(), do: GenServer.call(@name, :get_jobs)

  def get_job(job_id), do: GenServer.call(@name, {:get_job, job_id})

  def start_job(job), do: GenServer.cast(@name, {:start_job, job})

  def update_next_start_time(job_id, time) do
    GenServer.cast(@name, {:update_start_time, job_id, time})
  end

  def get_batch_size_prediction(job_id, attributes) do
    GenServer.call(@name, {:get_batch_size_prediction, job_id, attributes})
  end

  # Callbacks
  def init(%{}) do
    Process.send_after(self(), :fetch_jobs, 1_000)
    {:ok, %{jobs: []}}
  end

  def handle_call(:get_jobs, _from, %{jobs: jobs} = state) do
    {:reply, jobs, state}
  end

  def handle_call({:get_job, job_id}, _from, %{jobs: jobs} = state) do
    job = Enum.find(jobs, &(&1.id == job_id))
    {:reply, job, state}
  end

  def handle_call({:get_batch_size_prediction, job_id, attributes}, _from, %{jobs: jobs} = state) do
    predictions = Enum.find(jobs, &(&1.id == job_id)).predictions 
     
    best_value_prediction = predictions 
      |> Enum.map(fn(x) -> %{calculate_prediction_value(x, attributes) => x} end) 
      |> Enum.max_by(fn x -> Map.keys(x) end, fn -> %{ 0 => %{ "prediction" => 0}} end)

    final_prediction = best_value_prediction |> Map.values |> List.first

    {:reply, final_prediction["prediction"], state}
  end

  def calculate_prediction_value(prediction, attributes) do
    Map.keys(attributes) 
    |> Enum.reduce(0, fn item, acc ->
      if prediction[item] == attributes[item] do
        acc + (prediction["counter"] * 0.2)
      else
        acc
      end
    end )
  end

  def handle_cast({:update_start_time, job_id, time}, state) do
    job = Enum.find(state.jobs, fn j -> j.previous_job_id == job_id end)

    case job do
      nil -> {:noreply, state}
      _ ->
        job = %{job | start_time: time}
        new_jobs =
          [job | Enum.reject(state.jobs, fn j -> j.id == job_id end)]

        new_state = %{state | jobs: new_jobs}

        {:noreply, new_state}
    end
  end

  def handle_cast({:start_job, job}, state) do

    {[job], tasks} =
      divide_jobs_into_tasks([job])

    new_jobs =
      [job | Enum.reject(state.jobs, fn j ->
          j.id == job.id end)]

    TaskServer.add(tasks)

    new_state = %{state | jobs: new_jobs}

    {:noreply, new_state}
  end

  def handle_info(:fetch_jobs, %{jobs: jobs} = state) do
    fetched_jobs =
      @jobs_api.jobs().body
      |> Enum.map(&Job.from_map/1)
    new_jobs_to_split = fetched_jobs |> reject_processed_by_other_nodes()

    {new_jobs, new_tasks} = divide_jobs_into_tasks(new_jobs_to_split -- jobs)

    updated_jobs = Enum.filter(jobs, fn x -> Enum.any?(fetched_jobs, fn y -> y.id == x.id end) end) |> Enum.map(fn x -> Map.put(x, :predictions, Enum.find(fetched_jobs, fn y -> y.id == x.id end, fn z -> x end).predictions) end)
    
    all_jobs = Enum.uniq_by(updated_jobs ++ jobs ++ new_jobs, &(&1.id))
    TaskServer.add(new_tasks)

    new_state = %{state | jobs: all_jobs}

    interval = :random.uniform(@interval)
    Process.send_after(self(), :fetch_jobs, interval)

    {:noreply, new_state}
  end

  defp divide_jobs_into_tasks(jobs) do
    jobs
    |> Enum.reduce({[], []}, fn (job, {jobs_acc, tasks_acc}) ->
      tasks = JobDivider.divide_job_into_tasks(job)
      tasks_count = length(tasks)

      updated_job = %{job | required_results_count: tasks_count}

      {[updated_job | jobs_acc], tasks ++ tasks_acc}
    end)
  end

  defp reject_processed_by_other_nodes(jobs) do
    Enum.filter(jobs, fn job ->
      case JobTracker.start_job(job) do
        :ok ->
          IO.puts "starting - #{job.id}"
          true
        _ ->
          IO.puts "rejecting - #{job.id}"
          false
      end
    end)
  end
end

