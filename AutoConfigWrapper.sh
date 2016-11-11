#!/bin/bash

set -x

config=CONFIG_BOKAI_TEST

in_file=class.c
patch=diff.patch
out_file=out_file.c

org_file=/tmp/org_file
diff_file=/tmp/diff_file

function check {
	[ $# -lt 2 ] && echo "Usage: $0  <error>  <line_number>" && exit -1

	local error=$1
	shift
	local line_number=$1

	[ $error -ne 0 ] && echo "($line_number) error !!" && exit -1
}

function add_text {
	[ $# -lt 4 ] && echo "Usage: $0  <edit_file>  <27>  <in_fil>  <30,33>" && exit -1

	local edit_file=$1
	shift
	local line=$1
	shift
	local in_file=$1
	shift
	local range=$1

	local add_text=/tmp/add_text
	
	sed -n $range'p' $in_file > $add_text
	check $? $LINENO

	sed -i '' $line'r '$add_text $edit_file
	check $? $LINENO

	return 0
}

function add_ifdef {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	sed -i '' $line'a\'$'\n#ifdef '$config$'\n' $edit_file
	check $? $LINENO

	return 0
}

function add_else {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	sed -i '' $line'a\'$'\n#else /* '$config' */'$'\n' $edit_file
	check $? $LINENO

	return 0
}

function add_endif {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	sed -i '' $line'a\'$'\n#endif /* '$config' */'$'\n' $edit_file
	check $? $LINENO

	return 0
}

cp $in_file $org_file
check $? $LINENO

git apply $patch
check $? $LINENO

diff $org_file $in_file | awk -f ../parse_diff.awk | sed -n '1!G;h;$p' > $diff_file
check $? $LINENO

cp $org_file $out_file
check $? $LINENO

while IFS='' read -r line || [[ -n "$line" ]]; do
	IFS=' ' read  op p1 p2 p3 <<< $line
	if [ "a" == $op ]; then
		add_endif 	$out_file $p1
		add_text 	$out_file $p1 $in_file $p2
		add_ifdef	$out_file $p1
	elif [ "d" == $op ]; then
		add_endif 	$out_file $p2
		add_else 	$out_file $p1
		add_ifdef	$out_file $p1
	elif [ "c" == $op ]; then
		add_endif 	$out_file $p2
		add_else 	$out_file $p1
		add_text 	$out_file $p1 $in_file $p3
		add_ifdef	$out_file $p1
	fi
done < $diff_file

mv $out_file $in_file
check $? $LINENO

exit 0;
