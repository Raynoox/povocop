defmodule RavioliCook.Results.Reporter do
  use GenServer

  @name :results_reporter

  alias RavioliCook.Results

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    {:ok, nil}
  end

  def report_progress(job_id, required, received, user_id, email, pfc) do
    GenServer.cast(@name, {:report_progress, job_id, received, required, user_id, email, pfc})
  end

  def report_results(job_id, results, duration) do
    GenServer.cast(@name, {:report_results, job_id, results, duration})
  end

  def handle_cast({:report_progress, job_id, received, 0, user_id, email, pfc}, state) do
    {:noreply, state}
  end

  def handle_cast({:report_progress, job_id, received, required, user_id, email, pfc}, state) do
    batch_size = 5

    if batch_size < 1 || rem(received, batch_size) == 0 || received == required do
      progress = received / required
      Results.Api.send_progress(job_id, progress)
      Results.Api.send_pfc(user_id, job_id, email, pfc, batch_size)
    else
    end

    {:noreply, state}
  end

  def handle_cast({:report_results, job_id, results, duration}, state) do
    json = Poison.encode!(results)

    Results.Api.send_results(job_id, json, duration)

    {:noreply, state}
  end
end
