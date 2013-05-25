namespace :db do
require 'csv'
  desc "load user data from csv"
  task :load_csv_data  => :environment do
   
    Transfer.delete_all
    CSV.foreach("transfers_2005_to_2011_testing.csv" , :col_sep => ",", :quote_char => "\x00") do |row|
      Transfer.create(
      :transfer_id => row[21],
      :pniya_id => row[14],
      :year => row[0],
      :section_id => row[2],
      :section_name => row[3], 
      :field_id => row[4],
      :field_name => row[5],
      :program_id => row[6],
      :program_name => row[7],
      :request_desc => row[9], 
      :changeCode => row[10],
      :changeName => row[11],
      :requestTypeCode => row[12],
      :requestTypeName => row[13],
      :net => row[15],
      :conditionalExpense => row[16],
      :intendedIncome => row[17],
      :permissiontoCommit => row[18],
      :maxHR => row[19]#,
      #:aprovalDate => Date.parse(row[22])
      )
    end
  end
end