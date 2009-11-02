class Module
  # The connection specification for the module. Use Module#establish_connection to
  # establish a database connection.
  attr_reader :connection_spec

  # Given a connection spec (key name, hash of connection data, etc.) and an optional boolean
  # this function establishes the module as an MMC module, and sets up the module with all the necessary
  # methods and variables to force its children ActiveRecord models to use the connection spec passed in.
  #
  # The optional parameter 'namespace_reflections_mirror_db', takes a boolean and dictates the
  # behaviour of relationships. If set to true, when an MMC modle is declared in the module where
  # the original model has relationship to models in the same namespace, will automatically reset
  # those relationships to models in the same MMC module.  For a clear example look at
  # test/test_mmc_associations.rb (ttest_namespace_associations()).
  #
  #    
  def establish_connection(connection_spec, namespace_reflections_mirror_db = true)
    include MagicMultiConnection::Connected
    instance_variable_set '@connection_spec', connection_spec
    instance_variable_set '@namespace_reflections_mirror_db', namespace_reflections_mirror_db
    update_active_records unless MagicMultiConnection.using_connection_pool?
  end
  if self.method_defined? :parent
    alias_method :parent_module, :parent
  else
    def parent_module
      parent = self.name.split('::')[0..-2].join('::')
      parent = 'Object' if parent.blank?
      parent.constantize
    end
  end


  private
  def update_active_records
    self.constants.each do |c_str|
      #      puts "Checking constant #{c_str}"
      # c = "#{self.name}::#{c_str}".constantize
      c = self.const_get(c_str)
      next unless c.is_a? Class
      next unless c.new.is_a? ActiveRecord::Base
      c.establish_connection connection_spec
    end
  end
end