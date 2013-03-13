class Field < ActiveRecord::Base
	Field.pluralize_table_names = false
	Field.set_table_name("transfers")
	has_many :program
	belongs_to :section


	  def to_param
	  	field_id
	  end
end
