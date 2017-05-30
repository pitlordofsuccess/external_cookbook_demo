#
# Cookbook:: _pipeline
# Resource:: build_cookbook
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

resource_name 'build_cookbook'
default_action :create

property :name, String, name_property: true
property :cwd, String, required: true
property :git_branch, [Symbol, String], default: :master

alias :branch :git_branch

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-users'].index(/^#{username}$/)
end

action :create do
  directory "#{new_resource.cwd}/.delivery/build_cookbook/recipes" do
    recursive true
    action :create
    owner 'dbuild'
    group 'dbuild'
  end

  %w(default deploy functional lint provision publish quality security smoke syntax unit).each do |phase|
    template "#{new_resource.cwd}/.delivery/build_cookbook/recipes/#{phase}.rb" do
      source 'recipe.erb'
      owner 'dbuild'
      group 'dbuild'
      variables phase: phase
    end
  end

  %w(chefignore LICENSE metadata.rb Berksfile).each do |f|
    cookbook_file "#{new_resource.cwd}/.delivery/build_cookbook/#{f}" do
      source f
      owner 'dbuild'
      group 'dbuild'
    end
  end

  %w(config.json project.toml).each do |f|
    cookbook_file "#{new_resource.cwd}/.delivery/#{f}" do
      source f
      owner 'dbuild'
      group 'dbuild'
    end
  end

  execute "#{new_resource.name} :: Commit build cookbook" do
    command <<-EOF
      git add .delivery
      git commit -m 'Update Automate Workflow build_cookbook'
    EOF
    cwd "#{new_resource.cwd}/#{new_resource.name}"
    only_if { new_resource.resource_updated? }
  end
end
