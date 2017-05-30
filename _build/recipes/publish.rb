#
# Cookbook:: _build
# Recipe:: default
#
# Copyright:: 2017, Nathan Cerny
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# We don't want to publish cookbooks from berks.
if upload_cookbook_to_chef_server?
  changed_cookbooks.each do |cookbook|
    file "#{cookbook.name}_Berksfile" do
      action :nothing
      path ::File.join(cookbook.path, 'Berksfile')
      only_if { ::File.exist?(::File.join(cookbook.path, 'Berksfile')) }
    end.run_action(:delete)
  end
end

include_recipe 'delivery-truck::publish'
