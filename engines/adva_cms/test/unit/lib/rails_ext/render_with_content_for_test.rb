require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class ContentForTestController < ActionController::Base
  content_for(:sidebar, :except => { :action => :show }) { 'foo' }
  
  def index
    render :inline => "<%= yield :sidebar %>"
  end
end

ActionController::Routing::Routes.draw do |map|
  map.connect 'content_for_test/:action/:id', :controller => 'content_for_test'
end

class RenderWithContentForTest < ActionController::TestCase
  tests ContentForTestController
  
  test "it renders to content_for symbol" do
    @controller.process(@request, @response)
    @response.body.should == 'foo'
  end
end

class RenderWithContentForConditionsTest < ActionController::TestCase
  tests ContentForTestController
  
  def setup
    super
    @controller.action_name = 'index'
    @view = Object.new
    stub(@view).template_format.returns(:html)
  end
  
  test "registers content_for options" do
    content = @controller.registered_contents.first
    content.options[:except][:action].should == :show
    content.content.should be_kind_of(Proc)
  end
  
  test "applies when no options were given" do
    content = RegisteredContent.new :foo
    content.applies?(@controller, @view).should be_true
  end
  
  test "applies when controller was included and no action excluded" do
    content = RegisteredContent.new :foo, :only => { :controller => 'content_for_test' }
    content.applies?(@controller, @view).should be_true
  end
  
  test "applies when action was included and no controller excluded" do
    content = RegisteredContent.new :foo, :only => { :action => 'index' }
    content.applies?(@controller, @view).should be_true
  end
  
  test "does not apply when a different controller was included" do
    content = RegisteredContent.new :foo, :only => { :controller => 'something_else' }
    content.applies?(@controller, @view).should be_false
  end
  
  test "does not apply when a different action was included" do
    content = RegisteredContent.new :foo, :only => { :action => 'something_else' }
    content.applies?(@controller, @view).should be_false
  end
  
  test "does not apply when controller was excluded" do
    content = RegisteredContent.new :foo, :except => { :controller => 'content_for_test' }
    content.applies?(@controller, @view).should be_false
  end
  
  test "does not apply when action was excluded" do
    content = RegisteredContent.new :foo, :except => { :action => 'index' }
    content.applies?(@controller, @view).should be_false
  end
end