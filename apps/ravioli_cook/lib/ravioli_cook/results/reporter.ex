defmodule RavioliCook.Results.Reporter do
  use GenServer

  @name :results_reporter

  alias RavioliCook.Results

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  defmodule ResultsState do
    defstruct duration: 0, pfc: 0
  end

  def init(_) do
    {:ok, %ResultsState{
     }}
  end

  def report_progress(job_id, required, received, user_id, email, pfc, duration, clientInfo) do
    GenServer.cast(@name, {:report_progress, job_id, received, required, user_id, email, pfc, duration, clientInfo})
  end

  def report_results(job_id, results, duration) do
    GenServer.cast(@name, {:report_results, job_id, results, duration})
  end

  def handle_cast({:report_progress, job_id, received, 0, user_id, email, pfc, duration, clientInfo}, state) do
    {:noreply, state}
  end

  def handle_cast({:report_progress, job_id, received, required, user_id, email, pfc, duration, clientInfo}, state) do
    batch_size = 20

    new_pfc = state.pfc+pfc
    new_duration = state.duration+duration
    
    if batch_size < 1 || rem(received, batch_size) == 0 || received == required do
      #IO.puts "rec #{received} req #{required}" 
      progress = received / required
      Results.Api.send_progress(job_id, progress)
      Results.Api.send_pfc(user_id, job_id, email, new_pfc, batch_size)
      #IO.puts "update prediction send - avg_duration = #{new_duration/batch_size}"
      Results.Api.update_predictions(job_id, clientInfo, trunc(new_duration/batch_size))
    end

    points_state = reset_points_state(new_pfc, new_duration, batch_size, received, required)
    new_state = %{state |
                    pfc: points_state.new_pfc,
                    duration: points_state.new_duration
                   }

    {:noreply, new_state}
  end

  defp reset_points_state(pfc, duration, batch_size, received, required) do
    cond do
      batch_size < 1 || rem(received, batch_size) == 0 || received == required ->  
        %{new_pfc: 0, new_duration: 0}  
      true ->
        %{new_pfc: pfc, new_duration: duration}
    end    
  end
          





  def handle_cast({:report_results, job_id, results, duration}, state) do
    json = Poison.encode!(results)

    Results.Api.send_results(job_id, json, duration)

    {:noreply, state}
  end
end
