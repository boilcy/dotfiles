function dockal -d "Private docker registry tag and push"
    # 检查是否传入了正确的参数
    if test (count $argv) -eq 0
        echo "Usage:  dockal COMMAND"
        echo "Common Commands:"
        echo "  images       List private docker registry images"
        echo "  info         Display private docker registry information"
        echo "  push         Download an image from local registry & tag & untag origin"
        echo "  pull         Tag & upload an image to a registry & untag"
        echo "  setrepo      Set private docker registry & add to insecure registry"
        return 1
    end

    set registry (set -q DOCKER_PRIVATE_REGISTRY; and echo $DOCKER_PRIVATE_REGISTRY; or echo "172.16.23.60:5000")

    switch "$argv[1]"
        case images
            echo "Listing images in private docker registry..."
            curl -X GET "http://$registry/v2/_catalog" | jq '.repositories[]'
        case info
            echo "Displaying private docker registry information..."
            curl -X GET "http://$registry/v2/"
        case push
            if test (count $argv) -lt 2
                echo "Usage: dockal push IMAGE"
                return 1
            end
            set image $argv[2]
            echo "Pulling image $image from local registry..."
            docker pull $image
            echo "Tagging image $image..."
            docker tag $image $registry/$image
            echo "Pushing image to private registry..."
            docker push $registry/$image
            echo "Untagging original image $image..."
            docker rmi $registry/$image
        case pull
            if test (count $argv) -lt 2
                echo "Usage: dockal pull IMAGE"
                return 1
            end
            set image $argv[2]
            echo "Pulling image $image from private registry..."
            docker pull $registry/$image
            echo "Tagging image $image..."
            docker tag $registry/$image $image
            echo "Untagging private registry image $image..."
            docker rmi $registry/$image
        case setrepo
            if test (count $argv) -lt 2
                echo "Usage: dockal setrepo REPO"
                return 1
            end
            set repo $argv[2]
            echo "Setting private docker registry to $repo..."
            set -U DOCKER_PRIVATE_REGISTRY $repo
            echo "Adding $repo to insecure registries..."
            set --universal --append DOCKER_OPTS "--insecure-registry $repo"
        case '*'
            echo "Unsupported arguments."
    end

    # 获取传入的镜像名称和标签
    #set IMAGE_TAG $argv[1]
    #set IMAGE_NAME (echo $IMAGE_TAG | cut -d':' -f1)
    #set TAG (echo $IMAGE_TAG | cut -d':' -f2)
end
