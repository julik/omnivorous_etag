require "test/unit"
require "omnivorous_etag"

class TestOmnivorousEtag < Test::Unit::TestCase
  class Bearer
    def etag(string)
      raise "Not a string" unless string.is_a?(String)
      return string
    end
  end
  
  class RaisingBearer
    def etag(something)
      throw(:caught)
    end
  end
  
  class App < Bearer
    include OmnivorousEtag
  end
  
  class RaisingApp < RaisingBearer
  end
  
  def test_with_string
    app = App.new
    assert_equal "Mw==\n", app.etag(3)
  end
  
  def test_work_on_blank_object_should_just_return
     o = Object.new
     class << o; include OmnivorousEtag; end
     assert_equal "Mw==\n", o.etag(3)
  end
  
  def test_work_on_object_that_supports_super_should_callout_to_super
     assert_throws(:caught) { RaisingApp.new.etag(3) }
  end
  
  def test_work_on_blank_object_should_just_return
     o = Object.new
     class << o; include OmnivorousEtag; end
     assert_equal "Mw==\n", o.etag(3)
  end
  
  def test_with_float
    app = App.new
    assert_equal "My4zNQ==\n", app.etag(3.35)
  end
  
  def test_with_int
    assert_equal "MQ==\n", App.new.etag(1)
  end
  
  def test_with_symbol
    assert_equal "YQ==\n", App.new.etag(:a)
  end
  
  def test_with_string
    assert_equal "RXhwZXJpbWVudGFs\n", App.new.etag("Experimental")
  end
  
  def test_with_array
    assert_equal "TVE9PQo7TWc9PQo7TXc9PQo=\n", App.new.etag([1,2,3])
  end
  
  def test_with_array
    assert_equal "TVE9PQo7TWc9PQo7TXc9PQo=\n", App.new.etag([1,2,3])
  end
  
  def test_with_version_activerecord_using_acts_as_versioned
    r = Struct.new(:version, :to_param).new(1, "1-my-blog_entry")
    r_newer = Struct.new(:version, :to_param).new(2, "1-my-blog_entry")
    assert_equal "TVE9PQo7TVMxdGVTMWliRzluWDJWdWRISjUK\n", App.new.etag(r)
    assert_equal "TWc9PQo7TVMxdGVTMWliRzluWDJWdWRISjUK\n", App.new.etag(r_newer)
  end
  
  def test_with_version_activerecord_using_revisions
    r = Struct.new(:revision_number, :to_param).new(1, "1-my-blog_entry")
    r_newer = Struct.new(:revision_number, :to_param).new(2, "1-my-blog_entry")
    assert_equal "TVE9PQo7TVMxdGVTMWliRzluWDJWdWRISjUK\n", App.new.etag(r)
    assert_equal "TWc9PQo7TVMxdGVTMWliRzluWDJWdWRISjUK\n", App.new.etag(r_newer)
  end
  
  class Arbtrary < Struct.new(:a,:foo,:bar)
  end
  
  class Another < Arbtrary
  end
  
  def test_arbitraty_object_carries_class_name
    a = Arbtrary.new("foo", "bar", "baz")
    another = Another.new("foo", "bar", "baz")
    assert_not_equal App.new.etag(a), App.new.etag(another),
      "Objects of different classes should produce different etags"
  end
end
