define Article do
  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments
  
  belongs_to :site
  belongs_to :section
  belongs_to :author, stub_user

  methods  :id => 1,
           :type => 'Article',
           :title => 'An article',
           :permalink => 'an-article',
           :full_permalink => {:year => 2008, :month => 1, :day => 1, :permalink => 'an-article'},
           :excerpt => 'excerpt',
           :excerpt_html => 'excerpt html',
           :body => 'body',
           :body_html => 'body html',
           :tag_list => 'foo bar',
           :version => 1,
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :comment_filter => 'textile-filter',
           :comment_age => 0,
           :accept_comments? => true,
           :has_excerpt? => true,
           :published_at => Time.now,
           :filter => nil,
           :attributes= => nil,
           :save => true, 
           :save_without_revision => true, 
           :update_attributes => true, 
           :has_attribute? => true,
           :destroy => true,
           :save_version_on_create => nil,
           :increment_counter => nil,
           :decrement_counter => nil

  instance :article           
end
  
scenario :article do 
  @article = stub_article
  @articles = stub_articles
  
  @article.stub!(:[]).with('type').and_return 'Article'
  Article.stub!(:find).and_return @article
end

scenario :article_exists do
  scenario :site, :section, :user
  @article = Article.new :author => stub_user, :site_id => 1, :section_id => 1, :title => 'title', :body => 'body'
  stub_methods @article, :new_record? => false, :save_version? => false
end

scenario :article_created do
  scenario :article_exists
  stub_methods @article, :new_record? => true
end

scenario :article_revised do
  scenario :article_exists
  stub_methods @article, :save_version? => true
end

scenario :article_published do
  scenario :article_exists
  stub_methods @article, :published? => true
  stub_methods @article, :published_at_changed? => true
end

scenario :article_unpublished do
  scenario :article_exists
  stub_methods @article, :published? => false
  stub_methods @article, :published_at_changed? => true
end

scenario :article_destroyed do
  scenario :article_exists
  stub_methods @article, :frozen? => true
end

