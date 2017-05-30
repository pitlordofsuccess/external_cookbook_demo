#
# Cookbook:: _pipeline
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
    JSON.parse((http_client.send method, request_url, headers).body)
  else
    (http_client.send method, request_url, headers).body
  end
end

def supermarket_api(method = :get, path = '', data = '', headers = {}, supermarket_url = 'https://supermarket.chef.io/')
  uri = URI.parse(supermarket_url)
  http_client = Net::HTTP.new(uri.host, uri.port)

  http_client.use_ssl = true if uri.scheme == 'https'

  result = if method.eql?(:post)
             http_client.send method, path, data, headers
           else
             http_client.send method, path, headers
           end
  JSON.parse(result.body)
end
