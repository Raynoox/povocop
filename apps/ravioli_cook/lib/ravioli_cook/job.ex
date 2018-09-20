defmodule RavioliCook.Job do
  defstruct id: nil, type: nil, input: nil, result: nil,
    script_file: nil, user_id: nil, divide_server_url: nil,
    division_type: nil, aggregation_type: nil, required_results_count: nil,
    randomized_results: false, replication_rate: 0, metadata: "",
    previous_job_id: nil, start_time: nil, pfc_count: nil, pfc_sum: nil, wasm_file

  def from_map(params) do
    %RavioliCook.Job
{      id: params["id"],
      type: params["type"],
      input: params["input"],
      result: params["result"],
      script_file: params["script_file"],
      user_id: params["user_id"],
      divide_server_url: params["divide_server_url"],
      division_type: params["division_type"],
      aggregation_type: params["aggregation_type"],
      replication_rate: params["replication_rate"] || 0,
      randomized_results: params["randomized_results"] || false,
      metadata: params["metadata"] || Poison.encode!(""),
      previous_job_id: params["previous_job_id"],
      pfc_count: params["pfc_count"],
      pfc_sum: params["pfc_sum"],
      wasm_file: params["wasm_file"]
    }
  end
end
