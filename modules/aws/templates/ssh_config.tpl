Host k3s-init-server 
  Hostname ${init_server_ip}
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop

Host k3s-server-0
  Hostname ${server_ip_0}
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop

Host k3s-server-1 
  Hostname ${server_ip_1}
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop
