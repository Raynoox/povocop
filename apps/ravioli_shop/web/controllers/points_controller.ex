defmodule RavioliShop.PointsController do
  use RavioliShop.Web, :controller
  alias RavioliShop.{Auth}
  def update(conn, %{"user_id" => fingerprint, "job_id" => job_id, "pfc" => pfc, "email" => nil, "pfc_count" => pfc_count}) do
  	user = Auth.find_user_or_create_new_fingerprint(fingerprint, "Password123")
  	RavioliShop.UserPoints.update_pfc(user.id, job_id , pfc, pfc_count)

    send_resp(conn, 200, "")
  end

  def update(conn, %{"user_id" => user_id, "job_id" => job_id, "pfc" => pfc, "email" => email, "pfc_count" => pfc_count}) do
  	user = Auth.find_user_or_create_new(email, "Password123")
  	RavioliShop.UserPoints.update_pfc(user.id, job_id , pfc, pfc_count)

    send_resp(conn, 200, "")
  end
end
