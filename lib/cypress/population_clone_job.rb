module Cypress
  # This is Resque job that will create records for a ProductTest. Currently you have the choice between doing a full clone of the test deck
  # or a specific subset to cover the 3 core measures. In the near future we will support more options to make very customized TD subsets.
  # For now, a subset_id of 'core20' will mean the 3 core measures. If that parameter does not exist, we copy the whole deck. For example:
  #
  #    Cypress::PopulationCloneJob.create(:subset_id => 'core20', :test_id => 'ID of vendor to which these patients belong')
  #
  #    Cypress::PopulationCloneJob.create(:patient_ids => [1,2,7,9,221], :test_id => 'ID of vendor to which these patients belong')
  # This will return a uuid which can be used to check in on the status of a job. More details on this can be found
  # at the {Resque Stats project page}[https://github.com/quirkey/resque-status].
  class PopulationCloneJob

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def perform

      # Clone AMA records from Mongo
      @test = ProductTest.find(options["test_id"])
      patients=[]
      File.open('/home/cypress/testfile', 'w') do |f|      
        f.puts "test1"    
        end     
isAmb = true
#ambulatory
if isAmb
 options['patient_ids'] = ["2678a4e396aaec03b860d5aeadcad8e6", "8130b2ff5774f1593c86eba8dca4c37b", "470f57b022eaeffd4d599078e851a56d", "0dbaf9336f7aa1590265250a0eebe548", "ce83c561f62e245ad4e0ca648e9de0dd", "61aa020431420dce8f53b74352a990fe", "bd2d8e0fd774e32f623e1fe5ad44781f", "511b530c8662f8df97eb97b3eefa0618", "d156a6d38e10efc30eda3cace7456537", "88130abfa702d8f53ac7be76e9d24a58", "91bd37f9cebf7b6ef9f72d7fd6148a81", "b54a4e3ab37de7e5f8094793afb8a699", "e05ff19bd33566173fd742d4b9831f1f", "5407e0ea5126420644b503c66153eb3c", "d045df54952043573bb6a94c374c8420", "258ee9087c5a5fe359ceb3aafff0dd76", "bc8f60f4cbde3d6c28974971b6880792"];
else
 #inpatient
 options['patient_ids'] = ["f03f9bf5cc4bfa7298ae1a4804cc7e5f", "c6bbb7342c4cf4ebeeaf1a417646db69", "d7108ec0329f792ea437d5051c88a314", "649910f4a9da359b17d7c1b012decc17", "caf50e70e548d61d097c68e9001ded60", "b03719c7f99502b7990918baf4640f70", "116c5a883ccdc89b2531bcbae3a403ab", "1ef57c0a5ac2ef5a2b50b3f4bb04d76c", "cce692bcfd3d4dc602a052190bb30d8b", "86c61730a8776ec14e06b3ed08cad129", "879223b7a0d9fee24b76afac7e1ce268", "fed736f9b98e0a4bcc8e7401b20cf7a5", "e9f710b1f129c10bf69d3c29432e166f"];
end
# clone each of the patients identified in the :patient_ids parameter
patients = @test.bundle.records.where(:test_id => nil).in(medical_record_number: options['patient_ids']).to_a
if isAmb
 #ambulatory
 duplicate_ids = ["2678a4e396aaec03b860d5aeadcad8e6", "511b530c8662f8df97eb97b3eefa0618"] # A, Heart_Adult; B, GP_Adult (ambulatorY)
else
 #inpatient
 duplicate_ids = [ "caf50e70e548d61d097c68e9001ded60", "879223b7a0d9fee24b76afac7e1ce268", "b03719c7f99502b7990918baf4640f70", "116c5a883ccdc89b2531bcbae3a403ab"] # A, AMI_ADULT; A, STROKE_ADULT; C, AMI_ADULT; D, AMI_ADULT (inpatient)
end
patients += @test.bundle.records.where(:test_id => nil).in(medical_record_number: duplicate_ids).to_a
if isAmb
 # ambulatory
 randomization_ids = ["5f118631f09abdbdeb1962dc28bfeb27"]
 random_records = @test.bundle.records.where(:test_id => nil).in(medical_record_number: randomization_ids).to_a
random_records.each do |patient|
 date_shift = -60*60*24*6 # secs per min * min per hour * hours in day * 6 days
 patient.shift_dates(date_shift)
 patients << patient
end
end   


      patients.each do |patient|
        clone_and_save_record(patient)
      end

    end


    def clone_and_save_record(record,  date_shift=nil)
        cloned_patient = record.clone
        cloned_patient[:original_medical_record_number] = cloned_patient.medical_record_number
        cloned_patient.medical_record_number = next_medical_record_number
        randomize_name(cloned_patient) if options['randomize_names']
        cloned_patient.shift_dates(date_shift) if date_shift
        cloned_patient.test_id = options['test_id']
        patch_insurance_provider(record)
        cloned_patient.entries.each do |entry|
          entry.id = Moped::BSON::ObjectId.new
        end
        cloned_patient.save!
    end

    def randomize_name(record)
      @used_names ||= {}
      @used_names[record.gender] ||= []
      begin
        record.first = APP_CONFIG["randomization"]["names"]["first"][record.gender].sample
        record.last = APP_CONFIG["randomization"]["names"]["last"].sample
      end while(@used_names[record.gender].find("#{record.first}-#{record.last}").nil?)
      @used_names[record.gender] << "#{record.first}-#{record.last}"
    end



    def next_medical_record_number
      @rand_prefix ||= Time.new.to_i
      @current_index ||= 0
      @current_index += 1
       "#{@rand_prefix}_#{@current_index}"
    end


     def patch_insurance_provider(patient)
      insurance_codes = {
      'MA' => '1',
      'MC' => '2',
      'OT' => '349'
      }
      patient.insurance_providers.each do |ip|
        if ip.codes.empty?
          ip.codes["SOP"] = [insurance_codes[ip.type]]
        end
      end

    end

  end

end
