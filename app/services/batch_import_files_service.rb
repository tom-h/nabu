class BatchImportFilesService
  def self.run(verbose, force_update, dir_list)
    dir_list.each do |upload_directory|
      next unless File.directory?(upload_directory)
      dir_contents = Dir.entries(upload_directory)

      # for each essence file, find its collection & item
      # by matching the pattern
      # "#{collection_id}-#{item_id}-xxx.xxx"
      dir_contents.each do |file|
        ImportFileService.run(verbose, force_update, upload_directory, file)
      end
    end
  end
end
