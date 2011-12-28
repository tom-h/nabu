class University < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true

  attr_accessible :name

  paginates_per 10
end