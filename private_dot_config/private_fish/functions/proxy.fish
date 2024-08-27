function proxy
    switch $argv[1]
        case 'on'
            if set -q argv[2]
                # Set system proxy
                set -gx http_proxy "http://$argv[2]:$argv[3]"
                set -gx https_proxy "http://$argv[2]:$argv[3]"
                set -gx HTTP_PROXY "http://$argv[2]:$argv[3]"
                set -gx HTTPS_PROXY "http://$argv[2]:$argv[3]"
                echo "System Proxy enabled: $argv[2]:$argv[3]"
                
                # Set Git proxy
                git config --global http.proxy "http://$argv[2]:$argv[3]"
                git config --global https.proxy "http://$argv[2]:$argv[3]"
                echo "Git Proxy enabled: $argv[2]:$argv[3]"
            else
                echo "Usage: proxy on <host_ip> <port>"
            end

        case 'off'
            # Unset system proxy
            set -e http_proxy
            set -e https_proxy
            set -e HTTP_PROXY
            set -e HTTPS_PROXY
            echo "System Proxy disabled"
            
            # Unset Git proxy
            git config --global --unset http.proxy
            git config --global --unset https.proxy
            echo "Git Proxy disabled"

        case 'status'
            # System proxy status
            if set -q HTTP_PROXY
                echo "HTTP System Proxy is set to $HTTP_PROXY"
            else
                echo "HTTP System Proxy is not set"
            end
            if set -q HTTPS_PROXY
                echo "HTTPS System Proxy is set to $HTTPS_PROXY"
            else
                echo "HTTPS System Proxy is not set"
            end
            
            # Git proxy status
            set -l git_http_proxy (git config --global http.proxy)
            set -l git_https_proxy (git config --global https.proxy)
            if test -n "$git_http_proxy"
                echo "Git HTTP Proxy is set to $git_http_proxy"
            else
                echo "Git HTTP Proxy is not set"
            end
            if test -n "$git_https_proxy"
                echo "Git HTTPS Proxy is set to $git_https_proxy"
            else
                echo "Git HTTPS Proxy is not set"
            end

        case '*'
            echo "Usage: proxy on|off|status [host_ip] [port]"
    end
end

function gateway_ip
  ip route show | grep -i default | awk '{print $3}'
end

function local_ip
  hostname -I | awk '{print $1}'
end