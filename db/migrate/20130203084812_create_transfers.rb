class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :transfer_id
      t.integer :pniya_id
      t.integer :year
      t.string :section_id
      t.string :section_name
      t.string :field_id
      t.string :field_name
      t.string :program_id
      t.string :program_name
      t.string :request_desc
      t.decimal :net

      t.timestamps
    end
  end
end
