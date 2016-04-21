#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#

prepare_network_config(hiera('network_scheme'))
$master = get_node_to_ipaddr_map_by_network_role(get_nodes_hash_by_roles(hiera('network_metadata'), ['saltstack']), 'management')
$master_ip = values($master)

package {'salt-minion':
  ensure => present,
}

$minion_conf = "master: ${master_ip}
id: ${::hostname}"

file { '/etc/salt/minion':
  ensure  => file,
  backup  => true,
  content => $minion_conf,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  notify  => Service['salt-minion'],
}

service {'salt-minion':
  ensure  => running,
  enable  => true,
  require => Package['salt-minion'],
}
