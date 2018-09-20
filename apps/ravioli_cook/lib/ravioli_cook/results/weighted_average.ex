defmodule RavioliCook.Results.WeightedAverage do
  @moduledoc """
    Let us not worry about docs right now
  """

  use GenServer

  alias RavioliCook.JobFetcher
  alias RavioliCook.TaskServer
  alias RavioliCook.Results.Reporter

  defmodule Results do
    defstruct numerator: 0, denominator: 0, tasks_ids: [],
              required_results_count: nil, start_time: nil
  end

  def start_link(required_results_count) do
    GenServer.start_link(__MODULE__, required_results_count, [])
  end

  def init(required_results_count) do
    start_time = :os.timestamp()
    {:ok, %Results{
        required_results_count: required_results_count,
        start_time: start_time
     }}
  end

def handle_cast({:add_result, %{
    "numerator" => numerator,
    "denominator" => denominator,
    "task_id" => task_id,
    "pfc" => pfc,
    "email" => email
  }}, state) do
  IO.puts "email"
  update_state(numerator, denominator, task_id, pfc, nil, email, state)
end

def handle_cast({:add_result, %{
    "numerator" => numerator,
    "denominator" => denominator,
    "task_id" => task_id,
    "pfc" => pfc,
    "fingerprint" => fingerprint
  }}, state) do
  IO.puts "fingerprint"
  update_state(numerator, denominator, task_id, pfc, fingerprint, nil, state)
end




def update_state(numerator, denominator, task_id, pfc, user_id, email, state) do
    IO.puts "custom func"
    numerator = state.numerator + to_int(numerator)
    denominator = state.denominator + to_int(denominator)
    tasks_ids = Enum.uniq([task_id | state.tasks_ids])

    job_id = TaskServer.get(task_id)["job_id"]
    TaskServer.remove(task_id)

    IO.puts "add result, task_id: #{task_id}, pid: #{inspect self()}"
    IO.puts length(tasks_ids)



    received_count = length(tasks_ids)

    IO.puts "report progress, #{job_id}"

    Reporter.report_progress(job_id, state.required_results_count, received_count, user_id, email, pfc)

    if length(tasks_ids) == state.required_results_count do
      IO.puts "current value: #{numerator / denominator}"
      duration = :timer.now_diff(:os.timestamp, state.start_time)

      IO.puts "duration: #{inspect duration}"
      Reporter.report_results(job_id, numerator/denominator, duration / 1000)
      TaskServer.finish_job(job_id)
      {:stop, :normal, []}
    else
      new_state = %{state |
                    numerator: numerator,
                    denominator: denominator,
                    tasks_ids: tasks_ids
                   }

      {:noreply, new_state}
    end


  end


  def handle_cast({:add_result, %{
    "numerator" => numerator,
    "denominator" => denominator,
    "task_id" => task_id,
    "pfc" => pfc
  }}, state) do
    numerator = state.numerator + to_int(numerator)
    denominator = state.denominator + to_int(denominator)
    tasks_ids = Enum.uniq([task_id | state.tasks_ids])

    job_id = TaskServer.get(task_id)["job_id"]
    TaskServer.remove(task_id)

    IO.puts "add result, task_id: #{task_id}, pid: #{inspect self()}"
    IO.puts length(tasks_ids)



    received_count = length(tasks_ids)

    IO.puts "report progress, #{job_id}"

    Reporter.report_progress(job_id, state.required_results_count, received_count)

    if length(tasks_ids) == state.required_results_count do
      IO.puts "current value: #{numerator / denominator}"
      duration = :timer.now_diff(:os.timestamp, state.start_time)

      IO.puts "duration: #{inspect duration}"
      Reporter.report_results(job_id, numerator/denominator, duration / 1000)
      TaskServer.finish_job(job_id)
      {:stop, :normal, []}
    else
      new_state = %{state |
                    numerator: numerator,
                    denominator: denominator,
                    tasks_ids: tasks_ids
                   }

      {:noreply, new_state}
    end


  end
  def handle_cast({:add_result, _}, state) do
    {:noreply, state}
  end

  def to_int(i) when is_integer(i), do: i
  def to_int(s), do: String.to_integer(s)
end
