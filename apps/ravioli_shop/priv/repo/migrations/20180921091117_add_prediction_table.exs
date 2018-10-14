defmodule RavioliShop.Repo.Migrations.AddPredictionTable do
  use Ecto.Migration

  def change do
    create table(:predictions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :job_id, references(:jobs, on_delete: :delete_all, type: :uuid)
      add :prediction, :integer
      add :counter, :integer
      add :browser, :string
      add :browser_version, :string
      add :system, :string
      add :system_version, :string
      add :subnet, :string
      timestamps()
    end

    create unique_index(:predictions, [:prediction, :browser, :browser_version, :system, :system_version, :subnet])
  end
end
