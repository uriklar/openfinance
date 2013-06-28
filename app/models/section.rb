class Section < ActiveRecord::Base
	Section.pluralize_table_names = false
	self.table_name = 'transfers'
	has_many :field
	belongs_to :transer


	  def to_param
	  	section_id
	  end
end
