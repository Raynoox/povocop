defmodule RavioliShop.Repo.Migrations.AddWasm do
  use Ecto.Migration

  def change do

    
    alter table(:jobs) do
      add :wasm_file, :string
    end

  end
end
