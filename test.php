<?php


#$mode = 'FINAL-Flow';
$mode = 'FINAL-Neos';

$content = array();
exec('cd tmp/' . $mode . '/; git tag', $content);

$allTags = array();
$result = array();
foreach ($content as $el) {
	$allTags[] = $el;

	$folders = array();
	exec('cd tmp/' . $mode . '/; git branch tmp; git checkout tmp; git reset --hard ' . $el . ' > /dev/null; ls', $folders);

	foreach ($folders as $folder) {
		$result[$folder]['tags'][] = $el;
	}
}

$content = array();
exec('cd tmp/' . $mode . '/; git branch -r', $content);

$allBranches = array();
foreach ($content as $el) {
	$folders = array();
	$el = trim($el, " \t\n\r\0\x0B*");

	$allBranches[] = preg_replace('/origin\\//', '', $el);
	if (preg_match('/(detached from|flow-cms|composer|GSoC2009|l10n|trunk|tmp)/', $el)) {
		continue;
	}

	exec('cd tmp/' . $mode . '/; git reset --hard ' . $el . ' > /dev/null; ls', $folders);

	$el = preg_replace('/origin\\//', '', $el);

	foreach ($folders as $folder) {
		$result[$folder]['branches'][] = $el;
	}


}

foreach ($result as $k => $package) {
	//echo '../git-subsplit/git-subsplit.sh publish --heads="' . implode(' ', $package['branches']) . '" --tags="' . implode(' ', $package['tags']) . '" ' . $k . ':git@github.com:Neos-GitHub-Test-ReadOnlyPackages/' . $k . '.git' . chr(10);
}

foreach ($result as $k => $package) {
	echo "\n\n";
	echo "rm -Rf tmp/split/$k\n";
	echo "cp -R tmp/$mode tmp/split/$k\n";
	echo "cd tmp/split/$k\n";
	echo "git remote rm origin\n";
	$tagsToRemove = array_diff($allTags, $package['tags']);
	foreach ($tagsToRemove as $t) {
		echo "git tag -d $t\n";
	}

	echo "git checkout master\n";
	echo "git branch -D tmp\n";
	$branchesToRemove = array_diff($allBranches, $package['branches']);
	foreach ($branchesToRemove as $t) {
		echo "git branch -D $t\n";
	}

	echo "git filter-branch --subdirectory-filter $k --tag-name-filter cat --prune-empty -- --all\n";
	echo "git reflog expire --expire=now --all\n";
  echo "git gc --prune=now --aggressive\n";
	echo 'git remote add origin git@github.com:Neos-GitHub-Test-ReadOnlyPackages/' . $k . '.git' . "\n";
	#echo "git push origin --force --all\n";
	#echo "git push origin --force --tags\n";
	echo "git push origin --all\n";
	echo "git push origin --tags\n";
	echo "cd ../../../\n";


	//echo '../git-subsplit/git-subsplit.sh publish --heads="' . implode(' ', $package['branches']) . '" --tags="' . implode(' ', $package['tags']) . '" ' . $k . ':git@github.com:Neos-GitHub-Test-ReadOnlyPackages/' . $k . '.git' . chr(10);
}