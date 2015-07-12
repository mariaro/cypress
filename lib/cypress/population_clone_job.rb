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
      if options['patient_ids']
        # clone each of the patients identified in the :patient_ids parameter
        patients = @test.bundle.records.where(:test_id => nil).in(medical_record_number: options['patient_ids']).to_a
      else
        patients = @test.bundle.records.where(:test_id => nil).to_a
      end

      # grab a random number of records and then randomize the dates between +- 10 days
      if options["randomization_ids"]
        how_many = rand(5) + 1
        randomization_ids = options["randomization_ids"].shuffle[0..how_many]
        random_records = @test.bundle.records.where(:test_id => nil).in(medical_record_number: randomization_ids).to_a

        random_records.each do |patient|
          seconds = 60*60*24*10 # secs per min * min per hour * hours in day * 10 days
          plus_minus = rand(2) == 0 ? 1 : -1 # use this to make move dates forward or backwards
          date_shift = rand(seconds) * plus_minus
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
        #record.first = APP_CONFIG["randomization"]["names"]["first"][record.gender].sample
        #record.last = APP_CONFIG["randomization"]["names"]["last"].sample
        if (record.original_medical_record_number ==  "2678a4e396aaec03b860d5aeadcad8e6")
          record.first = "Jose"
          record.last = "Atkins"
        end
        if (record.original_medical_record_number ==  "bc8f60f4cbde3d6c28974971b6880792")
          record.first = "Virgil"
          record.last = "Sandoval"
        end
        if (record.original_medical_record_number ==  "e05ff19bd33566173fd742d4b9831f1f")
          record.first = "Anthony"
          record.last = "Moody"
        end
        if (record.original_medical_record_number ==  "5f118631f09abdbdeb1962dc28bfeb27")
          record.first = "Manuel"
          record.last = "Clarke"
        end
        if (record.original_medical_record_number ==  "b54a4e3ab37de7e5f8094793afb8a699")
          record.first = "Joan"
          record.last = "Matthews"
        end
        if (record.original_medical_record_number ==  "d045df54952043573bb6a94c374c8420")
          record.first = "Kristina"
          record.last = "Rogers"
        end
        if (record.original_medical_record_number ==  "2678a4e396aaec03b860d5aeadcad8e6")
          record.first = "Gilbert"
          record.last = "Dean"
        end
        if (record.original_medical_record_number ==  "61aa020431420dce8f53b74352a990fe")
          record.first = "Dianne"
          record.last = "Holt"
        end
        if (record.original_medical_record_number ==  "91bd37f9cebf7b6ef9f72d7fd6148a81")
          record.first = "Joe"
          record.last = "Lewis"
        end
        if (record.original_medical_record_number ==  "511b530c8662f8df97eb97b3eefa0618")
          record.first = "Jennifer"
          record.last = "Jennings"
        end
        if (record.original_medical_record_number ==  "511b530c8662f8df97eb97b3eefa0618")
          record.first = "Stella"
          record.last = "Spencer"
        end
        if (record.original_medical_record_number ==  "470f57b022eaeffd4d599078e851a56d")
          record.first = "Anthony"
          record.last = "Gibson"
        end
        if (record.original_medical_record_number ==  "0dbaf9336f7aa1590265250a0eebe548")
          record.first = "Caroline"
          record.last = "Hill"
        end
        if (record.original_medical_record_number ==  "bd2d8e0fd774e32f623e1fe5ad44781f")
          record.first = "Alberto"
          record.last = "Howell"
        end
        if (record.original_medical_record_number ==  "88130abfa702d8f53ac7be76e9d24a58")
          record.first = "Dianne"
          record.last = "Kelley"
        end
        if (record.original_medical_record_number ==  "d156a6d38e10efc30eda3cace7456537")
          record.first = "Helen"
          record.last = "Jensen"
        end
        if (record.original_medical_record_number ==  "5407e0ea5126420644b503c66153eb3c")
          record.first = "Sheila"
          record.last = "Riley"
        end
        if (record.original_medical_record_number ==  "8130b2ff5774f1593c86eba8dca4c37b")
          record.first = "Larry"
          record.last = "Dixon"
        end
        if (record.original_medical_record_number ==  "258ee9087c5a5fe359ceb3aafff0dd76")
          record.first = "Brent"
          record.last = "Russell"
        end
        if (record.original_medical_record_number ==  "ce83c561f62e245ad4e0ca648e9de0dd")
          record.first = "Edgar"
          record.last = "Holmes"
        end
        if (record.original_medical_record_number ==  "f03f9bf5cc4bfa7298ae1a4804cc7e5f")
          record.first = "Delores"
          record.last = "Ballard"
        end
        if (record.original_medical_record_number ==  "c6bbb7342c4cf4ebeeaf1a417646db69")
          record.first = "Becky"
          record.last = "Brewer"
        end
        if (record.original_medical_record_number ==  "d7108ec0329f792ea437d5051c88a314")
          record.first = "Clara"
          record.last = "Burton"
        end
        if (record.original_medical_record_number ==  "649910f4a9da359b17d7c1b012decc17")
          record.first = "Gail"
          record.last = "Butler"
        end
        if (record.original_medical_record_number ==  "caf50e70e548d61d097c68e9001ded60")
          record.first = "Judy"
          record.last = "Carson"
        end
        if (record.original_medical_record_number ==  "b03719c7f99502b7990918baf4640f70")
          record.first = "Phyllis"
          record.last = "Collier"
        end
        if (record.original_medical_record_number ==  "116c5a883ccdc89b2531bcbae3a403ab")
          record.first = "Minnie"
          record.last = "Copeland"
        end
        if (record.original_medical_record_number ==  "1ef57c0a5ac2ef5a2b50b3f4bb04d76c")
          record.first = "Amy"
          record.last = "Floyd"
        end
        if (record.original_medical_record_number ==  "b03719c7f99502b7990918baf4640f70")
          record.first = "Crystal"
          record.last = "Griffin"
        end
        if (record.original_medical_record_number ==  "cce692bcfd3d4dc602a052190bb30d8b")
          record.first = "Andy"
          record.last = "Long"
        end
        if (record.original_medical_record_number ==  "86c61730a8776ec14e06b3ed08cad129")
          record.first = "Erica"
          record.last = "Moran"
        end
        if (record.original_medical_record_number ==  "caf50e70e548d61d097c68e9001ded60")
          record.first = "Beverly"
          record.last = "Patrick"
        end
        if (record.original_medical_record_number ==  "116c5a883ccdc89b2531bcbae3a403ab")
          record.first = "Florence"
          record.last = "Poole"
        end
        if (record.original_medical_record_number ==  "879223b7a0d9fee24b76afac7e1ce268")
          record.first = "Donald"
          record.last = "Roberson"
        end
        if (record.original_medical_record_number ==  "fed736f9b98e0a4bcc8e7401b20cf7a5")
          record.first = "Jerry"
          record.last = "Stanley"
        end
        if (record.original_medical_record_number ==  "e9f710b1f129c10bf69d3c29432e166f")
          record.first = "Ellen"
          record.last = "Walton"
        end
        if (record.original_medical_record_number ==  "879223b7a0d9fee24b76afac7e1ce268")
          record.first = "Fernando"
          record.last = "Ward"
        end
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
