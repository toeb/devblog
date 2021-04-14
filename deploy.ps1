param($msg)

if($msg -eq $null)
{
	$msg = "updated page"
}

hugo -D

# Go To Public folder
pushd public

# Add 'public' (Github Pages repo) changes to git and commit/push.

git add .
git commit -m "$msg"
git push origin master

# Add this repos changes to git and commit/push. First 'cd' out of public
popd

git add .
git commit -m "$msg"
git push origin master