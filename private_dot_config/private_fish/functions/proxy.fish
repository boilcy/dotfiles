#!/usr/bin/env fish

function proxy -d "Set network proxy"
  set -l hostip (ip route show | grep -i default | awk '{ print $3}')
  set -l localip (hostname -I | awk '{print $1}')
  if test -z "$argv[2]"
      set port 4780
  else
      set port $argv[2]
  end

  set -l PROXY_HTTP "http://$hostip:$port"

  switch "$argv[1]"
    case set
      set -xg http_proxy $PROXY_HTTP
      set -xg HTTP_PROXY $PROXY_HTTP
  
      set -xg https_proxy $PROXY_HTTP
      set -xg HTTPS_proxy $PROXY_HTTP
  
      git config --global http.proxy $PROXY_HTTP
      git config --global https.proxy $PROXY_HTTP

      test_proxy
    case unset
      set -e http_proxy
      set -e HTTP_PROXY

      set -e https_proxy
      set -e HTTPS_PROXY

      git config --global --unset http.proxy
      git config --global --unset https.proxy

      test_proxy
    case test
      test_proxy
    case '*'
        echo "Unsupported arguments."
  end

end

function test_proxy
  set -l hostip (ip route show | grep -i default | awk '{ print $3}')
  set -l localip (hostname -I | awk '{print $1}')

  echo "Host ip: . . . . . . ." $hostip
  echo "Local ip:. . . . . . ." $localip
  echo "Current proxy: . . . ." $https_proxy
end