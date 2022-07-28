kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml


 kubectl get pods -A

  kubectl get svc -A

configurar haproxy
  



cat /etc/haproxy/haproxy.cfg

  frontend http_front
  bind *:80
  stats uri /haproxy?stats
  default_backend http_back

backend http_back
  balance roundrobin
  server kube worker22:32743
  server kube worker23:32743