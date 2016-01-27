# Move of essence file with an incorrect item folder
class MoveWrongItemFolderEssenceFileService
  def self.run(essence_filename)
    move_wrong_item_folder_essence_file_service = new(essence_filename)
    move_wrong_item_folder_essence_file_service.run
  end

  def initialize(essence_filename)
    @essence_filename = essence_filename
    parse_file_name
  end

  def parse_file_name
    extension = @essence_filename.split('.').last
    basename = File.basename(@essence_filename, "." + extension)

    @known_non_essence_file = basename.include?('PDSC_ADMIN')

    #use basename to avoid having item_id contain the extension
    coll_id, item_id = basename.split('-')
    return unless item_id

    # Unlike current version of archive rake tasks, don't force case sensitivity
    @collection = Collection.find_by_identifier coll_id
    return unless @collection

    # Unlike current version of archive rake tasks, don't force case sensitivity
    @item = @collection.items.find_by_identifier item_id
    return unless @item

    @known_non_essence_file ||= (@essence_filename == @item.path.gsub('//', '/'))

    # force case sensitivity in MySQL - see https://dev.mysql.com/doc/refman/5.7/en/case-sensitivity.html
    @essence = @item.essences.where('BINARY filename = ?', File.basename(@essence_filename)).first
  end

  def run
    # case
    # when @known_non_essence_file
    #   # puts "Known admin file - skip for now"
    # when !@collection || !@item || !@essence
    #   puts "#{@essence_filename.inspect}\tCan't determine collection, item or essence - giving up"
    # when @essence_filename == @essence.path
    #   # puts "#{@essence_filename.inspect}\tActual filename matches expected filename - no need to do anything"
    # else
    #   puts "#{@essence_filename.inspect}\tProblem scenario"
    # end
    *higher_level_folders, item_folder_name, basename = @essence_filename.split('/')
    if @item
      proposed_fix_filename = (higher_level_folders + [@item.identifier, basename]).join('/')
    end
    case
    when !@item
      puts "#{@essence_filename.inspect}\tUnknown item"
    when item_folder_name == @item.identifier
      # Item folder name correct
    when File.exist?(proposed_fix_filename)
      puts "#{@essence_filename.inspect}\tClashes with #{proposed_fix_filename.inspect}"
    when item_folder_name.casecmp(@item.identifier).zero?
      puts "#{@essence_filename.inspect}\tIncorrect capitalisation"
    else
      puts "#{@essence_filename.inspect}\tOther problem"
    end
  end
end
