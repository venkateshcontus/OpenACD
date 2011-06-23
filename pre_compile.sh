#!/bin/sh

if [ ! -d ebin ]; then
	mkdir ebin
fi

for file in proto_src/*.proto
do
	nameBase=`echo "$file" | sed -e "s/^proto_src\///"`
	nameBase=`echo "$nameBase" | sed -e "s/\.proto$//"`
	hrlFile="include/${nameBase}_pb.hrl"
	if [ $file -nt $hrlFile ]
	then
		cp $file src/
	fi
done

# hack for reltool
if [ ! -d OpenACD ]; then
	mkdir OpenACD
	ln -sf ../ebin OpenACD/ebin
	ln -sf ../src OpenACD/src
	ln -sf ../include OpenACD/include
	ln -sf ../priv OpenACD/priv
	ln -sf ../deps OpenACD/deps
fi

# record what commit/version openacd is at
OPENACD_COMMIT=`git log -1 --pretty=format:%H`
echo "%% automaticall generated by OpenACD precompile script.  Editing means
%% it will just get overwritten again.

-define(OPENACD_COMMIT, \"$OPENACD_COMMIT\")." > include/commit_ver.hrl
