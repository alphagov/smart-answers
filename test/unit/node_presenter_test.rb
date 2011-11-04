# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class NodePresenterTest < ActiveSupport::TestCase
    def setup
      @old_load_path = I18n.config.load_path.dup
      @example_translation_file = 
        File.expand_path('../../fixtures/node_presenter_test/example.yml', __FILE__)
      I18n.config.load_path.unshift(@example_translation_file)
    end
    
    def teardown
      I18n.config.load_path = @old_load_path
    end
  
    test "Node display name looked up from translation file" do
      question = Question::Date.new(:example_question?)
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal 'Foo', presenter.display_name
    end
    
    test "Node body looked up from translation file, rendered using govspeak" do
      question = Question::Date.new(:example_question?)
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "<p>The body copy</p>\n", presenter.body
    end
    
    test "Can check if a node has body" do
      assert NodePresenter.new("flow.test", Question::Date.new(:example_question?)).has_body?
      assert ! NodePresenter.new("flow.test", Question::Date.new(:missing)).has_body?
    end
    
    test "Options can be looked up from translation file" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option yes: :yay
      question.option no: :nay
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "Oui", presenter.options[0].label
      assert_equal "Non", presenter.options[1].label
      assert_equal "yes", presenter.options[0].value
      assert_equal "no", presenter.options[1].value
    end
    
    test "Options can be looked up from default values in translation file" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option maybe: :mumble
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "Mebbe", presenter.options[0].label
    end
    
    test "Options label falls back to option value" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option something: :mumble
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "something", presenter.options[0].label
    end
    
    test "Can lookup a response label" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option yes: :yay
      question.option no: :nay
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "Oui", presenter.response_label("yes")
    end
  end
end