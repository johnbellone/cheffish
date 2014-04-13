require 'cheffish'
require 'chef/resource/lwrp_base'

class Chef::Resource::ChefDataBag < Chef::Resource::LWRPBase
  self.resource_name = 'chef_data_bag'

  actions :create, :delete, :nothing
  default_action :create

  def initialize(*args)
    super
    chef_server Cheffish.enclosing_chef_server
  end

  attribute :name, :kind_of => String, :regex => Cheffish::NAME_REGEX, :name_attribute => true

  attribute :chef_server, :kind_of => Hash

  Cheffish.rights_attributes(self)
end
