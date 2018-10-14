defmodule RavioliShop.PredictionController do
  use RavioliShop.Web, :controller
  alias RavioliShop.{Auth}

  def update(conn, %{"job_id" => job_id, "client_info" => client_info, "avg_duration" => avg_duration}) do
  	IO.puts "add prediction"
  	RavioliShop.Predictions.add(job_id, client_info , avg_duration)

    send_resp(conn, 200, "")
  end
end
