$puppetserver = 'puppet.lab.example.com'

node 'node1.lab.example.com' {
    include resolvconf
}
