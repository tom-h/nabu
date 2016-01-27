# Batch moving of essence files with its item folder wrong
# For handling of an individual essence file, see MoveWrongItemFolderEssenceFileService
class BatchMoveWrongItemFolderEssenceFileService
  def self.run
    batch_move_wrong_item_folder_essence_file_service = new
    batch_move_wrong_item_folder_essence_file_service.run
  end

  def initialize
    @essence_filenames = find_essence_filenames
  end

  def find_essence_filenames
    glob = File.join(Nabu::Application.config.archive_directory, '**', '*')
    Dir.glob(glob).find_all(&File.method(:file?)).tap {|o| puts "#{o.size} files"}
  end

  def run
    @essence_filenames.each do |essence_filename|
      process_essence_filename(essence_filename)
    end
  end

  def process_essence_filename(essence_filename)
    move_wrong_item_folder_essence_file_service = MoveWrongItemFolderEssenceFileService.new(essence_filename)
    move_wrong_item_folder_essence_file_service.run
  end
end
