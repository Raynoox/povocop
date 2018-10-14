defmodule RavioliShop.Prediction do
  @moduledoc """
    Model describing predictions for given job
  """
  use RavioliShop.Web, :schema
  alias RavioliShop.Job
  alias Comeonin.Bcrypt
  
  @attrs [
    :id, :job_id, :prediction, :counter, :browser, :browser_version, :system, :system_version, :subnet
  ]
  
  @derive {Poison.Encoder, only: @attrs}
  schema "predictions" do
    belongs_to :job, Job
    field :prediction, :integer
    field :counter, :integer
    field :browser, :string
    field :browser_version, :string
    field :system, :string
    field :system_version, :string
    field :subnet, :string

    timestamps()
  end



  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attrs)
    |> validate_required([:job_id, :prediction, :counter, :browser, :browser_version, :system, :system_version, :subnet])
  end


end
