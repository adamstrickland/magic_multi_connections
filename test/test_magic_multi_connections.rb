require File.dirname(__FILE__) + '/test_helper.rb'

module NormalModule; end

class TestMagicMultiConnection < ActiveSupport::TestCase

  def setup
    create_fixtures :people, :addresses
  end
  
  def test_classes
    assert_nothing_raised(Exception) { Person }
#    require 'pp'
#    pp Person.connection
#    raise Person.connection.inspect
    assert_equal(ActiveRecord::Base.configurations['production'], Person.connection.instance_variable_get(:@config))
    assert(normal_person = Person.find(1), "Cannot get Person instances")
    assert_nothing_raised(Exception) { ContactRepository::Person }
    assert_equal(Person, ContactRepository::Person.superclass)
    assert_equal('ContactRepository::Person', ContactRepository::Person.name)
    assert_equal(ActiveRecord::Base.configurations['contact_repo'], ContactRepository::Person.connection.instance_variable_get(:@config))  
    assert_equal(0, ContactRepository::Person.count)
  end
  
  def test_normal_modules_shouldnt_do_anything
    assert_raise(NameError) { NormalModule::Person }
    
  end
  
end
