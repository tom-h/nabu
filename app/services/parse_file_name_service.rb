module ParseFileNameService
  def self.parse_file_name(verbose, file, file_extension=nil)
    extension = file.split('.').last
    return if file_extension && file_extension != extension
    basename = File.basename(file, "." + extension)

    #use basename to avoid having item_id contain the extension
    coll_id, item_id, *remainder = basename.split('-')
    unless item_id
      puts "ERROR: could not parse collection id and item id for file #{file} - skipping" if verbose
      return [basename, extension, coll_id, item_id, nil, nil]
    end

    # force case sensitivity in MySQL - see https://dev.mysql.com/doc/refman/5.7/en/case-sensitivity.html
    collection = Collection.where('BINARY identifier = ?', coll_id).first
    unless collection
      puts "ERROR: could not find collection id=#{coll_id} for file #{file} - skipping" if verbose
      return [basename, extension, coll_id, item_id, nil, nil]
    end

    # force case sensitivity in MySQL - see https://dev.mysql.com/doc/refman/5.7/en/case-sensitivity.html
    item = collection.items.where('BINARY identifier = ?', item_id).first
    unless item
      puts "ERROR: could not find item pid=#{coll_id}-#{item_id} for file #{file} - skipping" if verbose
      return [basename, extension, coll_id, item_id, nil, nil]
    end

    is_correctly_named_file = remainder.count == 1 && remainder.none?(&:empty?)
    is_admin_file = %w(CAT df PDSC_ADMIN).include?(remainder.last)

    # don't allow too few or too many dashes
    unless is_correctly_named_file || is_admin_file
      puts "ERROR: invalid filename for file #{file} - skipping" if verbose
      return [basename, extension, coll_id, item_id, nil, nil]
    end

    [basename, extension, coll_id, item_id, collection, item]
  end
end