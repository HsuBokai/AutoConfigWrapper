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

function insert {
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

function insert_ifdef {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	sed -i '' $line'a\'$'\n#ifdef '$config$'\n' $edit_file
	check $? $LINENO

	return 0
}

function insert_else {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	sed -i '' $line'a\'$'\n#else /* '$config' */'$'\n' $edit_file
	check $? $LINENO

	return 0
}

function insert_endif {
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

diff $org_file $in_file > $diff_file
check `expr $? - 1` $LINENO

cp $org_file $out_file
check $? $LINENO

insert_endif 	$out_file 33
insert 		$out_file 33 $in_file 35
insert_ifdef	$out_file 33

insert_endif 	$out_file 31
insert 		$out_file 31 $in_file 30,32
insert_ifdef	$out_file 31

insert_endif 	$out_file 27
insert_else 	$out_file 23
insert 		$out_file 23 $in_file 24,25
insert_ifdef	$out_file 23

insert_endif 	$out_file 18
insert_else 	$out_file 17
insert 		$out_file 17 $in_file 16,18
insert_ifdef	$out_file 17

insert_endif 	$out_file 5
insert_else 	$out_file 3
insert_ifdef	$out_file 3

mv $out_file $in_file
check $? $LINENO

exit 0;
