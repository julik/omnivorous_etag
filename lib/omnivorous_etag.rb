require "base64"

module OmnivorousEtag
  VERSION = '1.0.0'
  
  # The etag method that takes anything, with the following behavior quirks
  def etag(anything)
    data = if anything.respond_to?(:each)
      anything.map{|e| etag(e) }.join(";")
    elsif anything.respond_to?(:to_param) && OmnivorousEtag.is_versioned?(anything)
      etag([anything.class.to_s, anything.to_param, OmnivorousEtag.extract_version(anything)])
    elsif anything.is_a?(String) || anything.is_a?(Numeric) || anything.is_a?(Symbol)
      anything.to_s
    else
      Marshal.dump(anything)
    end
    
    if defined?(super)
      super(Base64.encode64(data))
    else
      Base64.encode64(data)
    end
  end
  
  def self.extract_version(object)
    if object.respond_to?(:new_record) && object.new_record?
      "new"
    # http://rubydoc.info/gems/acts_as_revisable
    elsif object.respond_to?(:revision_number)
      object.revision_number
    # http://rubydoc.info/gems/vestal_versions
    # http://rubydoc.info/gems/acts_as_versioned
    elsif object.respond_to?(:version)
      object.version
    end
    nil
  end
  
  # Tells whether the passed AR record object is using a versioning plugin (in which case we
  # can serve ourselves with the version tag it carries)
  def self.is_versioned?(object)
    extract_version(object) != nil
  end
end