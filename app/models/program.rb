class Program < ActiveRecord::Base
	Program.pluralize_table_names = false
	Program.set_table_name("transfers")
	belongs_to :field


	  def to_param
	  	program_id
	  end
end
