# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class PhraseListTest < ActiveSupport::TestCase

    test "the constructor arguments used as initial phrase keys" do
      phrase_list = PhraseList.new(:cat, :dog)
      
      assert_equal [:cat, :dog], phrase_list.phrase_keys
    end      
    
    test "the plus operation returns a new phrase list with the given phrase added" do
      phrase_list = PhraseList.new(:one) + :two
      
      assert_equal [:one, :two], phrase_list.phrase_keys
    end
    
  end
end