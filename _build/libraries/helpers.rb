#
# Cookbook:: _build
# Library:: helpers
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

def external?(cb)
  node.run_state['not_external_pipeline'] ||= []
  if node.run_state['not_external_pipeline'].empty?
    delivery_api(:get, 'orgs')['orgs'].each do |org|
      delivery_api(:get, "orgs/#{org['name']}/projects").each do |project|
        node.run_state['not_external_pipeline'] << project['name']
      end unless org['name'].eql?('external')
    end
  end
  !node.run_state['not_external_pipeline'].include?(cb)
end

def delivery_api(method = :get, path = '/_status', data = '')
  ent_name = node['delivery']['change']['enterprise']
  request_url = "/api/v0/e/#{ent_name}/#{path}"
  change = ::JSON.parse(::File.read(::File.expand_path('../../../../../../../change.json', node['delivery_builder']['workspace'])))
  uri = URI.parse(change['delivery_api_url'])
  http_client = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http_client.use_ssl = true
    http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  headers = {
    'chef-delivery-token' => change['token'],
    'chef-delivery-user' => 'builder',
  }
  if method.eql?(:post)
    (http_client.send method, request_url, data, headers).body
  elsif method.eql?(:get)
    JSON.parse((http_client.send method, request_url, headers).body.delete("\n"))
  else
    (http_client.send method, request_url, headers).body
  end
end

def external_cookbooks_json(deps)
  cookbook_directory = ::File.join(node['delivery']['workspace']['cache'], 'cookbooks')
  src = JSON.parse(::File.read("#{cookbook_directory}/_pipeline/external_cookbooks.json"))
  hash = Chef::Mixin::DeepMerge.deep_merge(src, deps)
  hash = hash.sort.to_h
  hash.each do |k, v|
    v.sort! if v.is_a?(Array)
    hash[k] = v.sort.to_h if v.is_a?(Hash)
  end
  JSON.pretty_generate(hash)
end
