#
# Cookbook:: _build
# Library:: delivery_push_job
#
# Copyright:: 2017, Nathan Cerny
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
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

module DeliverySugar
  #
  # This class replaces the DeliverySugar::PushJob class from Chef Software's delivery sugar.
  # It overides it to use remote powershell with an ssh transport.  As much of the code is constant
  #
  class PushJob
    require 'train'

    attr_reader :chef_server, :command, :nodes, :job_uri, :job, :quorum

    # Variables for the Job itself
    attr_reader :id, :status, :created_at, :updated_at, :results

    # How long to wait between each refresh during #wait
    PAUSE_SECONDS = 5 unless const_defined?(:PAUSE_SECONDS)

    #
    # Create a new PushJob object
    #
    # @param chef_config_file [String]
    #   The fully-qualified path to a chef config file to load settings from.
    # @param command [String]
    #   The white-listed command to execute via push jobs
    # @param nodes [Array#String]
    #   An array of node names to run the push job against
    # @param timeout [Integer]
    #   How long to wait before timing out
    # @param quorum [Integer]
    #   How many nodes that must acknowledge for the job to run
    #   (default: length of nodes)
    #
    # @return [DeliverySugar::PushJob]
    #
    def initialize(_, command, nodes, timeout, _)
      raise "[#{self.class}] Expected nodes Array#String" unless valid_node_value?(nodes)
      @command = command
      @nodes = nodes
      @timeout = timeout
      @results = Mash.new(succeeded: [], failed: [], stdout: [], stderr: [])
    end

    #
    # Trigger the push job
    #
    def dispatch
      @nodes.each do |node|
        conn = begin
                 Train.create('ssh', host: node, port: 22, user: 'Administrator@cerny.cc', key_files: '/var/opt/delivery/workspace/.ssh/id_rsa').connection
               rescue
                 Train.create('ssh', host: node, port: 22, user: 'root', key_files: '/var/opt/delivery/workspace/.ssh/id_rsa').connection
               end
        result = conn.run_command(@command)
        (result.exit_status.eql?(0) ? @results['succeeded'] << node : @results['failed'] << node)
        puts result.stdout
        puts result.stderr
        # @results.stdout << result.stdout
        # @results.stderr << result.stderr
        conn.close
      end
    end

    #
    # Loop until the push job succeeds, errors, or times out.
    #
    def wait
      true
    end

    #
    # Return whether or not a push job has completed or not
    #
    # @return [true, false]
    #
    def complete?
      true
    end

    #
    # Return whether or not the completed push job was successful.
    #
    # @return [true, false]
    #
    def successful?
      complete? && all_nodes_succeeded?
    end

    #
    # Return whether or not the completed push job failed.
    #
    # @return [true, false]
    #
    def failed?
      complete? && !all_nodes_succeeded?
    end

    #
    # Determine if the push job has been running longer than the timeout
    # would otherwise allow. We do this as a backup to the timeout in the
    # Push Job API itself.
    #
    # @return [true, false]
    #
    def timed_out?
      @status == 'timed_out' || (@created_at + @timeout < current_time)
    end

    private

    #
    # Determine if the nodes are valid node objects
    #
    # @return [true,false]
    #
    def valid_node_value?(nodes)
      nodes == [] || array_of(nodes, String)
    end

    #
    # Return the current time
    #
    # @return [DateTime]
    #
    def current_time
      DateTime.now
    end

    #
    # Return whether or not all nodes are marked as successful.
    #
    # @return [true, false]
    #
    def all_nodes_succeeded?
      @results['succeeded'] && @results['succeeded'].length == @nodes.length
    end

    #
    # Implement our method of pausing before we get the status of the
    # push job again.
    #
    def pause
      sleep PAUSE_SECONDS
    end

    #
    # Validate that an Array is built of an specific `class` kind
    #
    # @param array [Array] The Array to validate
    # @param klass [Class] Class to compare
    #
    # @return [true, false]
    #
    def array_of(array, klass)
      array.any? { |i| i.class == klass }
    end
  end
end
