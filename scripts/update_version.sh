version=$(grep version trace2.gemspec | awk '{ print $3 }' | tr -d "'")

echo "Current version: $version"
echo "What will be the next version?"
read new_version
sed -i "s/$version/$new_version/" lib/trace2/version.rb
sed -i "s/$version/$new_version/" trace2.gemspec
