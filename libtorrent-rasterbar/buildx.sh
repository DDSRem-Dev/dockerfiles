#!/usr/bin/env bash

version=$1
registry="git.evine.press:53123/evine"
image=libtorrent-rasterbar
repo="$registry/$image"
arches="s390x ppc64le"
for arch in $arches; do
    echo "Start build linux/$arch..."
    docker buildx build \
        --tag $repo:$version-${arch//\//} \
        --build-arg JNPROC=1 \
        --build-arg LIBTORRENT_VERSION=$version \
        --platform linux/$arch \
        --file Dockerfile \
        --push \
        .
done

# images=()
# for arch in $arches; do
#     images+=( "$repo:$version-${arch//\//}" )
# done
# docker manifest create "$repo:$version" "${images[@]}"
# docker manifest push --purge "$repo:$version"
# skopeo copy -a docker://"$repo:$version" docker://dcoker.io/nevinee/$image:${version}
# skopeo copy -a docker://"$repo:$version" docker://dcoker.io/nevinee/$image:${version::1}
