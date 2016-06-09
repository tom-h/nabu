require 'media'
include ActionView::Helpers::NumberHelper

require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper


class OfflineTemplate < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Helpers
  #include AbstractController::Layouts
  include CanCan::ControllerAdditions

  def initialize(*args)
    super()
    lookup_context.view_paths = Rails.root.join('app', 'views')
  end

  def current_user
    @current_user ||= User.admins.first
  end

  #def params
  #  {}
  #end
end

class ItemOfflineTemplate < OfflineTemplate
  attr_accessor :item
end

# Coding style for log messages:
# # Only use SUCCESS if an entire action has been completed successfully, not part of the action
# # Use INFO for progress through part of an action
# # WARNING and ERROR have their usual meaning
# # No need for a keyword for announcing a particular action is about to start,
# # or has just finished
namespace :archive do

  desc 'Provide essence files in scan_directory with metadata for sealing'
  task :export_metadata => :environment do
    verbose = ENV['VERBOSE'] ? true : false
    scan_directory = Nabu::Application.config.scan_directory

    BatchExportMetadataService.run(scan_directory, verbose)
  end


  desc 'Import files into the archive'
  task :import_files => :environment do
    verbose = ENV['VERBOSE'] ? true : false
    # Always update metadata
    force_update = true

    # find essence files in Nabu::Application.config.upload_directories
    dir_list = Nabu::Application.config.upload_directories

    BatchImportFilesService.run(verbose, force_update, dir_list)
  end

  desc "Mint DOIs for objects that don't have one"
  task :mint_dois => :environment do
    batch_size = Integer(ENV['MINT_DOIS_BATCH_SIZE'] || 100)
    BatchDoiMintingService.run(batch_size)
  end

  desc "Perform image transformations for all image essences"
  task :transform_images => :environment do
    batch_size = Integer(ENV['IMAGE_TRANSFORMER_BATCH_SIZE'] || 100)
    verbose = true
    BatchImageTransformerService.run(batch_size, verbose)
  end

  desc "Update catalog details of items"
  task :update_item_catalogs => :environment do
    offline_template = OfflineTemplate.new
    BatchItemCatalogService.run(offline_template)
  end

  desc "Transcode essence files into required formats"
  task :transcode_essence_files => :environment do
    batch_size = Integer(ENV['TRANSCODE_ESSENCE_FILES_BATCH_SIZE'] || 100)
    BatchTranscodeEssenceFileService.run(batch_size)
  end
end
