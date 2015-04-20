class AddForeignKeys < ActiveRecord::Migration
    def change
        change_table :pins do |t|
          t.references :user
        end

				change_table :comments do |t|
					t.references :user
					t.references :pin
				end
    end
end
