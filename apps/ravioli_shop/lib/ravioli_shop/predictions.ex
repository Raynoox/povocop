defmodule RavioliShop.Predictions do
  alias RavioliShop.{Repo, Prediction}
# :job_id, :prediction, :counter, :browser, :browser_version, :system, :system_version, :subnet

  def add(job_id, client_info, value) do
      case Repo.get_by(Prediction, prediction: value, job_id: job_id, browser: client_info["browser"], browser_version: to_string(client_info["browser_version"]),
       system: client_info["os"], system_version: to_string(client_info["os_version"]), subnet: client_info["subnet"]) do
      %Prediction{} = prediction ->
        IO.inspect prediction
        |> Prediction.changeset(
          %{counter: prediction.counter+1})
        |> Repo.update
      nil ->
        create(job_id, client_info, value)
    end
  end

  def create(job_id, client_info, prediction) do
    changeset = Prediction.changeset(
      %Prediction{}, %{"job_id" => job_id, "prediction" => prediction, "browser" => client_info["browser"], "browser_version" => to_string(client_info["browser_version"]),
       "system" => client_info["os"], "system_version" => to_string(client_info["os_version"]), "subnet" => client_info["subnet"], "counter" => 1})
         |> Repo.insert
    IO.puts "create new prediction"
  end

end
