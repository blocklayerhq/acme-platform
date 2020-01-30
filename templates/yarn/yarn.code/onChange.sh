export YARN_CACHE_FOLDER=cache/yarn
mkdir -p tmp/src
rsync -aH input/ tmp/src/

if [ "$(get setting loadEnv)" = 1 ]; then
    export $(cat tmp/env | xargs)
fi
(
    cd tmp/src
    yarn install --network-timeout 1000000
    yarn run "$(setting buildScript)"
)
rsync -aH tmp/src/"$(get setting buildDirectory)"/ output/
