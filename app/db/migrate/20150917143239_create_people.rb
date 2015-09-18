class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.text :name
      t.text :credit_card_encrypted

      t.timestamps null: false
    end
  end
end
