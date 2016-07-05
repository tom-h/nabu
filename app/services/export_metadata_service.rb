class ExportMetadataService
  # Inheriting avoids NoMethodError: undefined method `abstract?' for Object:Class
  class ItemOfflineTemplate < AbstractController::Base
    # Used for render_to_string
    include AbstractController::Rendering
    # Both of the following lines are required for cancan, and have to be in the correct order.
    include AbstractController::Helpers
    include CanCan::ControllerAdditions

    attr_accessor :item

    def initialize
      # No evidence of being required, but probably good practice.
      super()
      # Avoids ActionView::MissingTemplate
      lookup_context.view_paths = Rails.root.join('app', 'views')
    end

    # CanCan requires a current_user
    def current_user
      @current_user ||= User.admins.first
    end
  end

  def self.run(file, basename, coll_id, item_id, item, verbose)
    export_metadata_service = new(file, basename, coll_id, item_id, item, verbose)
    export_metadata_service.run
  end

  def initialize(file, basename, coll_id, item_id, item, verbose)
    @file = file
    @basename = basename
    @coll_id = coll_id
    @item_id = item_id
    @item = item
    @verbose = verbose
  end

  def run
    # if metadata files exist, skip to the next file
    metadata_filename_imp = Nabu::Application.config.write_imp + @basename + ".imp.xml"
    metadata_filename_id3 = Nabu::Application.config.write_id3 + @basename + ".id3.v2_3.xml"
    return if (File.file? "#{metadata_filename_imp}") && (File.file? "#{metadata_filename_id3}")

    # check if the item's "metadata ready for export" flag is set
    # raise a warning if not and skip file
    if !@item.metadata_exportable
      puts "ERROR: metadata of item pid=#{@coll_id}-#{@item_id} is not complete for file #{@file} - skipping" if @verbose
      return
    end

    template = ItemOfflineTemplate.new
    template.item = @item
    data_imp = template.render_to_string :template => "items/show.imp.xml"
    data_id3 = template.render_to_string :template => "items/show.id3.xml"

    File.open(metadata_filename_imp, 'w') {|f| f.write(data_imp)}
    File.open(metadata_filename_id3, 'w') {|f| f.write(data_id3)}
    puts "SUCCESS: metadata files\n #{metadata_filename_imp},\n #{metadata_filename_id3}\n created for #{@file}"
  end
end
