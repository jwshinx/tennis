class Post < ActiveRecord::Base
  validates_presence_of :name, :title, :content
  validates_length_of :title, :minimum => 5
  has_many :comments

  #named_scope :only_n_person, lambda { |person| :condition =>
  #  [ 'name < ?', name ] }

  def before_save
    logger.info "=====> Post.before_save 1"
    logger.debug "=====> Post.before_save 2"
  end
end
