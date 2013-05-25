class AddTransfers < ActiveRecord::Migration
	def change
		change_table :transfers do |t|
		  t.string :changeName
		  t.integer :requestTypeCode
		  t.string :requestTypeName
		  t.decimal :conditionalExpense
		  t.decimal :intendedIncome
		  t.decimal :permissiontoCommit
		  t.integer :maxHR
		  t.date :aprovalDate
		  t.integer :changeCode
		end
	end
end