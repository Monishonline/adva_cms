require File.dirname(__FILE__) + '/../spec_helper'

describe Article do
  include Stubby
  
  before :each do
    scenario :site, :section, :category, :user

    @article = Article.new :published_at => Time.now    
    @article.stub!(:new_record?).and_return(false)
    @article.stub!(:section).and_return Section.new
    @attributes = {:title => 'An article', :body => 'body', :section => @section, :author => stub_user}
  end
  
  describe "class extensions:" do
    it "sanitizes all attributes except excerpt, excerpt_html, body and body_html"
  end
  
  describe "callbacks:" do
    it "sets the position before create" do
      Article.before_create.should include(:set_position)
    end
  end
  
  describe "class methods:" do
    describe "#find_by_permalink" do
      it "does not add a with_time_delta scope if only one argument is passed" do
        Article.should_not_receive :with_time_delta
        Article.find_by_permalink 'a-permalink'
      end
      
      # wtf ... move this spec to the top and it will fail?
      it "adds a with_time_delta scope if more than one argument is passed" do
        Article.should_receive :with_time_delta
        Article.find_by_permalink '2008', '1', '1', 'a-permalink', :include => :author
      end
      
      # implement with fixtures:
      it "finds a record when the passed date scope matches the article's published date"
      it "does not find a record when the passed date scope does not match the article's published date"
      it "finds a record when no date scope is passed"
    end
  end
  
  describe 'instance methods:' do  
    describe '#full_permalink' do
      it 'returns a hash with the year, month, day and permalink'
      it 'raises an exception when the article does not belong to a Blog'
      it 'raises an exception when the article is not published'
    end
    
    describe '#has_excerpt?' do
      it 'returns true when the excerpt is not blank' do
        @article.excerpt = 'excerpt'
        @article.has_excerpt?.should be_true
      end
      
      it 'returns false when the excerpt is nil' do
        @article.excerpt = nil
        @article.has_excerpt?.should be_false
      end
      
      it 'returns false when the excerpt is an empty string' do
        @article.excerpt = ''
        @article.has_excerpt?.should be_false
      end
    end
    
    it '#published_month returns a time object for the first day of the month the article was published in'
    it '#draft? returns true when the article is not published'
    
    describe '#accept_comments?' do
      it "accept comments when comments never expire" do
        @article.should_receive(:comment_age).any_number_of_times.and_return(0)
        @article.should_receive(:published_at).any_number_of_times.and_return(2.days.ago)
        @article.accept_comments?.should be_true
      end
  
      it "accept comments when comments are allowed and not expired" do
        @article.should_receive(:comment_age).any_number_of_times.and_return(3)
        @article.should_receive(:published_at).any_number_of_times.and_return(2.days.ago)
        @article.accept_comments?.should be_true 
      end
  
      it "not accept comments when comments are allowed but expired" do
        @article.should_receive(:comment_age).any_number_of_times.and_return(2)
        @article.should_receive(:published_at).any_number_of_times.and_return(3.days.ago)
        @article.accept_comments?.should be_false
      end
  
      it "not accept comments when comments are not allowed" do
        @article.should_receive(:comment_age).any_number_of_times.and_return(-1)
        @article.should_receive(:published_at).any_number_of_times.and_return(2.days.ago)
        @article.accept_comments?.should be_false
      end
  
      it "not accept comments when the article is not published" do
        @article.should_receive(:published_at).any_number_of_times.and_return(nil)
        @article.accept_comments?.should be_false
      end
    end
    
    describe '#published?' do
      it "be published when published_at equals the current time" do
        @article.should_receive(:published_at).any_number_of_times.and_return(Time.zone.now)
        @article.published?.should be_true
      end
  
      it "be published when published_at is a past date" do
        @article.should_receive(:published_at).any_number_of_times.and_return(1.day.ago)
        @article.published?.should be_true
      end
  
      it "not be published when published_at is a future date" do
        @article.should_receive(:published_at).any_number_of_times.and_return(1.day.from_now)
        @article.published?.should be_false
      end
  
      it "not be published when published_at is nil" do
        @article.should_receive(:published_at).any_number_of_times.and_return(nil)
        @article.published?.should be_false
      end
    end
  
    it "#previous finds the previous published article in the article's section" do
      options = {:conditions => ["published_at < ?", @article.published_at], :order=>:published_at}
      Article.should_receive(:find_published).with :first, options
      @article.previous
    end
  
    it "#next finds the next published article in the article's section" do
      options = {:conditions => ["published_at > ?", @article.published_at], :order=>:published_at}
      Article.should_receive(:find_published).with :first, options
      @article.next
    end
  
    it "#set_position sorts the article to the bottom of the list (sets to max(position) + 1)" do
      @section.articles.should_receive(:maximum).and_return 5
      article = Article.create! @attributes
      article.position.should == 6
    end
  end  
end