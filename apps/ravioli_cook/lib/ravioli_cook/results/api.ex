defmodule RavioliCook.Results.Api do
  use Tesla

  plug Tesla.Middleware.BaseUrl, Application.get_env(:ravioli_cook, :shop_url)
  plug Tesla.Middleware.JSON

  def send_progress(job_id, progress) do
    put("/cook/progress", %{job_id: job_id, progress: progress})
  end

  def send_results(job_id, results, duration) do
    put("/cook/results", %{job_id: job_id, results: results, duration: duration})
  end

  def send_pfc(user_id, job_id, email, pfc, batch_size) do
    post("/points", %{"user_id": user_id, "job_id": job_id, "pfc": pfc, "email": email, "pfc_count": batch_size})
  end
end
