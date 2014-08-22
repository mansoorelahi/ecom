class AddNameUsers < ActiveRecord::Migration
  def change
    add_column(:users, :first_name, :string, :after => :provider)
    add_column(:users, :last_name, :string, :after => :first_name)
  end
end
