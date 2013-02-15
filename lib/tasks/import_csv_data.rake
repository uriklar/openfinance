namespace :db do
require 'csv'
  desc "load user data from csv"
  task :load_csv_data  => :environment do
   
    Transfer.delete_all
    CSV.foreach("transfers.csv") do |row|
      Transfer.create(
      :transfer_id => row[0],
      :pniya_id => row[1],
      :year => row[2],
      :section_id => row[3],
      :section_name => row[4], 
      :field_id => row[5],
      :field_name => row[6],
      :program_id => row[7],
      :program_name => row[8],
      :request_desc => row[9], 
      :net => row[10]
      )
    end
  end
end