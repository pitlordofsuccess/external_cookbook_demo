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

changed_cookbooks.each do |cookbook|
  ignore_rules = node['delivery']['config']['delivery-truck']['lint']['foodcritic']['ignore_rules'] || []
  if ::File.exist?("#{cookbook.path}/.foodcritic")
    ignore_rules << ::File.readlines("#{cookbook.path}/.foodcritic").collect { |l| l.gsub(/^~|\n$/, '') }
  end
  node.default['delivery']['config']['delivery-truck']['lint']['foodcritic']['ignore_rules'] = ignore_rules
end
include_recipe 'delivery-truck::lint'
