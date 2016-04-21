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

$masters = filter_nodes(hiera('nodes'), 'role', 'saltstack')
$master_ip = $masters[0]['internal_address']

package {'salt-minion':
  ensure => present,
}

$minion_conf = "master: ${master_ip}
id: ${::hostname}"
# elasticsearch:
#   host: '10.109.41.6:9200'
#

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
