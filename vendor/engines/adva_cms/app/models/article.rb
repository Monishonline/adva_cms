class Article < Content
  class Jail < Safemode::Jail
    allow :title, :full_permalink, :excerpt_html, :body_html, :published_at, 
          :section, :categories, :tags, :approved_comments, :accept_comments?,
          :comments_count, :has_excerpt?
  end  
  
  filters_attributes :sanitize => [:excerpt, :excerpt_html, :body, :body_html]
  
  write_inheritable_attribute :default_find_options, { :order => 'contents.published_at desc' }
  
  before_create :set_position

  class << self
    def find_by_permalink(*args)
      options = args.extract_options! 
      if args.size > 1
        permalink = args.pop
        with_time_delta(*args) do super(permalink, options) end
      else
        super args.first, options
      end
    end
    
    # TODO There's something similar in Content. Are these both equivalent?
    # def find_every(options)
    #   options = default_find_options.merge(options)
    #   if tags = options.delete(:tags)
    #     find_tagged_with(tags, options.update(:match_all => true))
    #   else
    #     super options
    #   end
    # end
  end

  def full_permalink
    raise "can not create full_permalink for an article that belongs to a non-blog section" unless section.is_a? Blog
    raise "can not create full_permalink for an unpublished article" unless published?
    Hash[:permalink, permalink, *[:year, :month, :day].map {|key| [key, published_at.send(key)] }.flatten]
  end
  
  def accept_comments?
    published? && (comment_age > -1) && (comment_age == 0 || comments_expired_at > Time.zone.now)
  end

  def has_excerpt?
    !excerpt.blank?
  end
  
  def published_month
    Time.local published_at.year, published_at.month, 1
  end
  
  def draft?
    published_at.nil?
  end

  def pending?
    !published?
  end
  
  def published?
    !published_at.nil? and published_at <= Time.zone.now
  end
  
  def state
    pending? ? :pending : :published
  end

  def previous
    section.articles.find_published :first, :conditions => ['published_at < ?', published_at], :order => :published_at
  end

  def next
    section.articles.find_published :first, :conditions => ['published_at > ?', published_at], :order => :published_at
  end
  
  protected
  
    def set_position
      self.position ||= section.articles.maximum(:position).to_i + 1
    end
end