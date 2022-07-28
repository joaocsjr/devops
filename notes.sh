




cat >> /etc/haproxy/haproxy.cfg <<EOF

frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend

backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server kmaster1 192.168.122.61:6443 check fall 3 rise 2
    server kmaster2 192.168.122.62:6443 check fall 3 rise 2
    server kmaster3 192.168.122.63:6443 check fall 3 rise 2

EOF

 kubeadm join 192.168.122.100:6443 --token xq4hcj.bkai3a0ik9gnc6no --discovery-token-ca-cert-hash sha256:3e5327e99a1799da2c2b656a92e4e32b09e198d916ee6af74a36f5704e109899 --control-plane --certificate-key e404540ebbbd3d91d38a87e06ced3de044a33d65ba9cf6688c38223f8276e4ac

kubeadm init --control-plane-endpoint="192.168.122.100:6443" --upload-certs --apiserver-advertise-address=192.168.122.61 --pod-network-cidr=10.10.0.0/16
