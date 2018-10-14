defmodule RavioliShop.UserPoints do
  alias RavioliShop.{Repo, User, Job, Jobs, UserPoint, Auth}

  def get_user_job_point(user_id, job_id) do
      Repo.get_by(UserPoint, user_id: user_id, job_id: job_id)
  end
  
  def get_user_points(user_id) do
    user_points = Repo.all(UserPoint) 
    	|> Enum.filter( fn(u) -> u.user_id == user_id end)
  end

  def create_new_user_points(user_id, job_id, pfc, pfc_count) do
    changeset = UserPoint.changeset(
      %UserPoint{}, %{"user_id" => user_id, "job_id" => job_id, "pfc_count" => 0, "pfc_sum" => 0})
         |> Repo.insert
    IO.puts "update all points after creation"
    update_all_points(0, user_id, job_id, pfc, pfc_count)
  end

  def get_user_pfc_average(user_id) do
     div(get_user_sum_pfc(user_id), get_user_count_pfc(user_id))

  end

  def get_user_count_pfc(user_id) do
  	get_user_points(user_id) |> Enum.map(fn(user_point) -> user_point.pfc_count end) 
    	|> Enum.sum
  end

  def get_user_sum_pfc(user_id) do 
	get_user_points(user_id) |> Enum.map(fn(user_point) -> user_point.pfc_sum end) 
    	|> Enum.sum
  end
  
  def get_user_point(user_points_id) do
  	Repo.get(UserPoint, user_points_id)
  end

  def update_pfc(user_id, job_id, pfc, pfc_count) do

    case calculate_points(user_id, job_id, pfc, pfc_count) do
      {:error, :cheater_prevention} ->
        IO.puts "Cheater detected"
      {:error, :not_found} ->
        create_new_user_points(user_id, job_id, pfc, pfc_count)
      points_to_add when is_integer(points_to_add) ->
        update_all_points(points_to_add, user_id, job_id, pfc, pfc_count)
    end
  end
  defp update_all_points(points_to_add, user_id, job_id, pfc, pfc_count) do 

        Auth.add_user_points(user_id, points_to_add)
        Jobs.update_pfc(job_id, pfc, pfc_count)

        user_point_id = get_user_job_point(user_id, job_id).id 
        update_pfc_query(user_point_id, pfc, pfc_count)
  end
  defp update_pfc_query(user_points_id, pfc_sum, pfc_count) do
    case Repo.get(UserPoint, user_points_id) do
      %UserPoint{} = user_point ->
        IO.inspect user_point
        user_point
        |> UserPoint.changeset(
        	%{pfc_sum: trunc(user_point.pfc_sum + pfc_sum),
        	 pfc_count: user_point.pfc_count + pfc_count })
        |> Repo.update
      nil ->
        {:error, :not_found}
    end
  end

  def calculate_points(user_id, job_id, pfc, pfc_count) do
    job = Repo.get(Job, job_id) 
    cond do
      (!!job.pfc_count && job.pfc_count > 0) ->
        IO.inspect job
        cond do
          (job.pfc_count > 10 && div(trunc(pfc), pfc_count) > 2*div(job.pfc_sum,job.pfc_count)) ->
            IO.puts "got #{pfc}, but limit is #{2*div(job.pfc_sum,job.pfc_count)}"
            {:error, :cheater_prevention}
          true -> case get_user_job_point(user_id, job_id) do
            %UserPoint{} = user_point ->
              IO.puts "job pfc #{job.pfc_sum}"
              IO.puts "job count #{job.pfc_count}"
              IO.puts "user pfc #{user_point.pfc_sum}"
              IO.puts "user count #{user_point.pfc_count} "
             cond do
              (user_point.pfc_count == 0 || user_point.pfc_sum == 0) ->
                0
              true ->
                Decimal.mult(trunc(pfc),Decimal.div(Decimal.div(job.pfc_sum,job.pfc_count),Decimal.div(user_point.pfc_sum,user_point.pfc_count))) 
                |> Decimal.round |> Decimal.to_integer
              end
            nil ->
              {:error, :not_found}
          end
        end
      true -> 
        case get_user_job_point(user_id, job_id) do
          %UserPoint{} = user_point -> 0
          nil -> {:error, :not_found}
        end
    end
  end
end