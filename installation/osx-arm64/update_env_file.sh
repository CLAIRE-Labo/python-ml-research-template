OSX64_DIR="installation/osx-arm64"
conda activate "my-project"
conda env export --no-builds --file "$OSX64_DIR/environment.yml"
# Delete the path line.
sed -i '' -e '$ d' "$OSX64_DIR/environment.yml"
# Set the package to a local installation.
sed -i '' 's$my-project==.*$ -e ../..$g' "$OSX64_DIR/environment.yml"
