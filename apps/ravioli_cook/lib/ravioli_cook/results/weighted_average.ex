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
    "email" => email,
    "duration" => duration,
    "clientInfo" => clientInfo
  }}, state) do
  update_state(numerator, denominator, task_id, pfc, nil, email, duration, clientInfo, state)
end

def handle_cast({:add_result, %{
    "numerator" => numerator,
    "denominator" => denominator,
    "task_id" => task_id,
    "pfc" => pfc,
    "fingerprint" => fingerprint,
    "duration" => duration,
    "clientInfo" => clientInfo
  }}, state) do
  update_state(numerator, denominator, task_id, pfc, fingerprint, nil, duration, clientInfo, state)
end




def update_state(numerator, denominator, task_id, pfc, user_id, email, duration, clientInfo, state) do
    numerator = state.numerator + to_int(numerator)
    denominator = state.denominator + to_int(denominator)
    tasks_ids = Enum.uniq([task_id | state.tasks_ids])

    job_id = TaskServer.get(task_id)["job_id"]
    TaskServer.remove(task_id)

    received_count = length(tasks_ids)

    Reporter.report_progress(job_id, state.required_results_count, received_count, user_id, email, pfc, trunc(1000/duration), clientInfo)

    if length(tasks_ids) == state.required_results_count do
      IO.puts "FINISH"
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
