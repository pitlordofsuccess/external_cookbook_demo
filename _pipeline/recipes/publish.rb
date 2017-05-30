#
# Cookbook:: _pipeline
# Recipe:: publish
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

DeliverySugar::ChefServer.new(delivery_knife_rb).with_server_config do
  cookbook_directory = File.join(node['delivery']['workspace']['cache'], 'cookbooks')

  Chef::Log.info("pwd:: #{::Dir.getwd}")
  Chef::Log.info("repo:: #{delivery_workspace_repo}")
  Chef::Log.info("cache:: #{delivery_workspace_cache}")
  external = JSON.parse(::File.read("#{delivery_workspace_repo}/external_cookbooks.json"))

  execute 'git config --global user.email "builder@cerny.cc"' do
    not_if 'git config --get user.email | grep builder@cerny.cc'
  end

  execute 'git config --global user.name "cerny-cc automated build"' do
    not_if 'git config --get user.name | grep "cerny-cc automated build"'
  end

  directory "#{cookbook_directory}/.delivery" do
    recursive true
  end

  file "#{cookbook_directory}/.delivery/cli.toml" do
    content <<-EOF
      api_protocol = "https"
      enterprise = "#{node['delivery']['change']['enterprise']}"
      git_port = "8989"
      organization = "external"
      pipeline = "master"
      server = "automate-test.cerny.cc"
      user = "builder"
    EOF
  end

  change = ::JSON.parse(::File.read(::File.expand_path('../../../../../../../change.json', node['delivery_builder']['workspace'])))
  directory "#{ENV['HOME']}/.delivery"
  file "#{ENV['HOME']}/.delivery/api-tokens" do
    content "automate-test.cerny.cc,#{node['delivery']['change']['enterprise']},builder|#{change['token']}"
  end

  external.each do |cb_source, val|
    next if cb_source.to_sym.eql?(:id)
    val.each do |cb_name, cb_opts|
      cookbook_pipeline cb_name do
        cwd cookbook_directory
        source cb_source.to_sym
        opts cb_opts || {}
      end
    end
  end
end

include_recipe '_build::publish'
