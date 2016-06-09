class ImportFileService
  def self.run(verbose, force_update, upload_directory, file)
    return unless File.file? "#{upload_directory}/#{file}"

    # skip files of size 0 bytes
    unless File.size?("#{upload_directory}/#{file}")
      puts "WARNING: file #{file} skipped, since it is empty" if verbose
      return
    end

    # skip files that can't be read
    unless File.readable?("#{upload_directory}/#{file}")
      puts "ERROR: file #{file} skipped, since it's not readable" if verbose
      return
    end

    # Skip files that are currently uploading
    last_updated = File.stat("#{upload_directory}/#{file}").mtime
    if (Time.now - last_updated) < 60*10
      return
    end

    basename, extension, coll_id, item_id, collection, item = ParseFileNameService.parse_file_name(verbose, file)
    return unless (collection && item)

    # skip files with item_id longer than 30 chars, because OLAC can't deal with them
    if item_id.length > 30
      puts "WARNING: file #{file} skipped - item id longer than 30 chars (OLAC incompatible)" if verbose
      return
    end

    puts '---------------------------------------------------------------'

    # make sure the archive directory for the collection and item exists
    # and move the file there
    begin
      destination_path = Nabu::Application.config.archive_directory + "#{coll_id}/#{item_id}/"
      FileUtils.mkdir_p(destination_path)
    rescue
      puts "WARNING: file #{file} skipped - not able to create directory #{destination_path}" if verbose
      return
    end

    begin
      FileUtils.cp(upload_directory + file, destination_path + file)
    rescue
      puts "WARNING: file #{file} skipped - not able to read it or write to #{destination_path + file}" if verbose
      return
    end

    puts "INFO: file #{file} copied into archive at #{destination_path}"

    # move old style CAT and df files to the new naming scheme
    if basename.split('-').last == "CAT" || basename.split('-').last == "df"
      FileUtils.mv(destination_path + file, destination_path + "/" + basename + "-PDSC_ADMIN." + extension)
    end

    # files of the pattern "#{collection_id}-#{item_id}-xxx-PDSC_ADMIN.xxx"
    # will be copied, but not added to the list of imported files in Nabu.
    if basename.split('-').last != "PDSC_ADMIN"
      # extract media metadata from file
      puts "Inspecting file #{file}..."
      begin
        import_metadata(destination_path, file, item, extension, force_update)
      rescue => e
        puts "WARNING: file #{file} skipped - error importing metadata [#{e.message}]" if verbose
        puts " >> #{e.backtrace}"
        return
      end
    end

    # if everything went well, remove file from original directory
    FileUtils.rm(upload_directory + file)
    puts "...done"
  end

  def self.import_metadata(path, file, item, extension, force_update)
    # since everything operates off of the full path, construct it here
    full_file_path = path + "/" + file

    # extract media metadata from file
    media = Nabu::Media.new full_file_path
    unless media
      puts "ERROR: was not able to parse #{full_file_path} of type #{extension} - skipping"
      return
    end

    # find essence file in Nabu DB; if there is none, create a new one
    essence = Essence.where(:item_id => item, :filename => file).first
    unless essence
      essence = Essence.new(:item => item, :filename => file)
    end

    #attempt to generate derived files such as lower quality versions or thumbnails, continue even if this fails
    generate_derived_files(full_file_path, item, essence, extension, media)

    # update essence entry with metadata from file
    begin
      essence.mimetype   = media.mimetype
      essence.size       = media.size
      essence.bitrate    = media.bitrate
      essence.samplerate = media.samplerate
      essence.duration   = number_with_precision(media.duration, :precision => 3)
      essence.channels   = media.channels
      essence.fps        = media.fps
    rescue => e
      puts "ERROR: unable to process file #{file} - skipping"
      puts" #{e}"
      return
    end

    unless essence.valid?
      puts "ERROR: invalid metadata for #{file} of type #{extension} - skipping"
      essence.errors.each { |field, msg| puts "#{field}: #{msg}" }
      return
    end
    if essence.new_record? || (essence.changed? && force_update)
      essence.save!
      puts "SUCCESS: file #{file} metadata imported into Nabu"
    end
    if essence.changed? && !force_update
      puts "WARNING: file #{file} metadata is different to DB - use 'FORCE=true archive:update_file' to update"
      puts essence.changes.inspect
    end
  end


  # this method tries to avoid regenerating any files that already exist
  def self.generate_derived_files(full_file_path, item, essence, extension, media)
    ImageTransformerService.new(media, full_file_path, item, essence, ".#{extension}").perform_conversions
  end
end
