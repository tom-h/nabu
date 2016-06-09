# scan for WAV files .wav and create .imp.xml & id3.xml
class BatchExportMetadataService
  def self.run(scan_directory, verbose)
    dir_contents = Dir.entries(scan_directory)

    # for each essence file, find its collection & item
    # by matching the pattern
    # "#{collection_id}-#{item_id}-xxx.xxx"
    dir_contents.each do |file|
      next unless File.file? "#{Nabu::Application.config.scan_directory}/#{file}"
      basename, _, coll_id, item_id, collection, item = ParseFileNameService.parse_file_name(verbose, file, 'wav')
      next if !collection || !item

      # if metadata files exist, skip to the next file
      metadata_filename_imp = Nabu::Application.config.write_imp + basename + ".imp.xml"
      metadata_filename_id3 = Nabu::Application.config.write_id3 + basename + ".id3.v2_3.xml"
      next if (File.file? "#{metadata_filename_imp}") && (File.file? "#{metadata_filename_id3}")

      # check if the item's "metadata ready for export" flag is set
      # raise a warning if not and skip file
      if !item.metadata_exportable
        puts "ERROR: metadata of item pid=#{coll_id}-#{item_id} is not complete for file #{file} - skipping" if verbose
        next
      end

      template = ItemOfflineTemplate.new
      template.item = item
      data_imp = template.render_to_string :template => "items/show.imp.xml"
      data_id3 = template.render_to_string :template => "items/show.id3.xml"

      File.open(metadata_filename_imp, 'w') {|f| f.write(data_imp)}
      File.open(metadata_filename_id3, 'w') {|f| f.write(data_id3)}
      puts "SUCCESS: metadata files\n #{metadata_filename_imp},\n #{metadata_filename_id3}\n created for #{file}"
    end
  end
end
