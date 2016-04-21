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

package {'salt-master':
  ensure => present,
}
package {'salt-api':
  ensure  => present,
  require => Package['salt-master'],
}

$master_conf = "
file_recv: True
"
#file_recv_max_size: 100
#interface: 0.0.0.0
#publish_port: 4505
#ret_port: 4506
#root_dir: /
#worker_threads: 5

file { '/etc/salt/master':
  ensure  => file,
  backup  => true,
  content => $master_conf,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  notify  => Service['salt-master'],
}

service {'salt-master':
  ensure  => running,
  enable  => true,
#  require => Package['salt-master'],
  require => File['/etc/salt/master'],
}

# salt 'node-23' tls.create_self_signed_cert CN='node-23'
# /etc/pki/tls/certs/node-23.key
# /etc/pki/tls/certs/node-23.crt
#
service {'salt-api':
  ensure  => running,
  enable  => true,
  require => File['/etc/salt/master'],
}
