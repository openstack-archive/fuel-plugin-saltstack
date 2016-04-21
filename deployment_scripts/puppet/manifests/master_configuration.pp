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

$uid = hiera('uid')

exec {'accept_minion':
  command => "salt-key -y -a node-${uid}",
  path    => '/usr/bin:/bin',
  unless  => "salt-key -l accepted|grep -E 'node-${uid}'"
}

$master_conf = "
file_recv: True
worker_threads: 5
rest_cherrypy:
  port: 8888
  address: 0.0.0.0
  ssl_crt: /etc/pki/tls/certs/node-${uid}.crt
  ssl_key: /etc/pki/tls/certs/node-${uid}.key
  debug: True
  disable_ssl: False
  webhook_disable_auth: True
  webhook_url: /hook
"
file { '/etc/salt/master':
  ensure  => file,
  backup  => true,
  content => $master_conf,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  notify  => [Service['salt-master'], Service['salt-api']],
  require => Exec['install certificate'],
}

service { 'salt-master':
  ensure => running,
  enable => true,
}
service {'salt-api':
  ensure => running,
  enable => true,
}

# This creates certificate for salt-api here:
# /etc/pki/tls/certs/node-${uid}.key
# /etc/pki/tls/certs/node-${uid}.crt
exec { 'install certificate':
  command => "salt 'node-${uid}' tls.create_self_signed_cert CN='node-${uid}'",
  path    => '/usr/bin:/bin',
  require => Exec['accept_minion'],
}
