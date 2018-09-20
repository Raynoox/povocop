defmodule RavioliShop.UserPoint do
  @moduledoc """
    Model describing points for user for given job
  """
  use RavioliShop.Web, :schema
  alias RavioliShop.Job
  alias Comeonin.Bcrypt

  schema "user_job_points" do
    belongs_to :job, Job
    belongs_to :user, User
    field :pfc_count, :integer
    field :pfc_sum, :integer
    

    timestamps()
  end

  @attrs [
    :job_id, :user_id, :pfc_count, :pfc_sum
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attrs)
    |> validate_required([:user_id, :job_id, :pfc_count, :pfc_sum])
  end


end
