#!/bin/bash

#set -x

[ $# -lt 1 ] && echo "Usage: $0 <config.sh>" && exit -1
source $1

function check {
	[ $# -lt 2 ] && echo "Usage: $0  <error>  <line_number>" && exit -1

	local error=$1
	shift
	local line_number=$1

	[ $error -ne 0 ] && echo "($line_number) error !!" && exit -1
}

function append_text {
	[ $# -lt 4 ] && echo "Usage: $0  <edit_file>  <27>  <in_fil>  <30,33>" && exit -1

	local edit_file=$1
	shift
	local line=$1
	shift
	local in_file=$1
	shift
	local range=$1

	local add_text=/tmp/add_text
	local temp_file=/tmp/temp_file

	sed -n $range'p' $in_file > $add_text
	check $? $LINENO

	if [ 0 == $line ]; then
		cat $add_text $edit_file > $temp_file
		check $? $LINENO

		mv $temp_file $edit_file
		check $? $LINENO
	else
		sed -i '' $line'r '$add_text $edit_file
		check $? $LINENO
	fi

	return 0
}

function append_ifdef {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	if [ 0 == $line ]; then
		sed -i '' '1i\'$'\n#ifdef '$config$'\n' $edit_file
		check $? $LINENO
	else
		sed -i '' $line'a\'$'\n#ifdef '$config$'\n' $edit_file
		check $? $LINENO
	fi

	return 0
}

function append_else {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	if [ 0 == $line ]; then
		sed -i '' '1i\'$'\n#else /* '$config' */'$'\n' $edit_file
		check $? $LINENO
	else
		sed -i '' $line'a\'$'\n#else /* '$config' */'$'\n' $edit_file
		check $? $LINENO
	fi

	return 0
}

function append_endif {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <27>" && exit -1

	local edit_file=$1
	shift
	local line=$1

	if [ 0 == $line ]; then
		sed -i '' '1i\'$'\n#endif /* '$config' */'$'\n' $edit_file
		check $? $LINENO
	else
		sed -i '' $line'a\'$'\n#endif /* '$config' */'$'\n' $edit_file
		check $? $LINENO
	fi

	return 0
}

function remove_additional_empty_line {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <org_file>" && exit -1

	local edit_file=$1
	shift
	local org_file=$1

	local diff_file=/tmp/diff_file
	local empty_line_file=/tmp/empty_line_file

	diff $org_file $edit_file > $diff_file
	check `expr $? - 1` $LINENO

	awk -f add_empty.awk $diff_file > $empty_line_file
	check $? $LINENO

	for add_empty_line in `cat $empty_line_file`; do
		sed -i '' $add_empty_line'd' $edit_file
		check $? $LINENO
	done

	return 0
}

function append_deletional_empty_line {
	[ $# -lt 2 ] && echo "Usage: $0  <edit_file>  <org_file>" && exit -1

	local edit_file=$1
	shift
	local org_file=$1

	local diff_file=/tmp/diff_file
	local empty_line_file=/tmp/empty_line_file

	diff $org_file $edit_file > $diff_file
	check `expr $? - 1` $LINENO

	awk -f del_empty.awk $diff_file > $empty_line_file
	check $? $LINENO

	while IFS='' read -r line || [[ -n "$line" ]]; do
		IFS=' ' read  del_line add_line <<< $line
		append_text $edit_file $add_line $org_file $del_line
	done < $empty_line_file

	return 0
}

function append_config {
	[ $# -lt 2 ] && echo "Usage: $0  <modified_file>  <org_file>" && exit -1

	local modified_file=$1
	shift
	local org_file=$1

	local diff_file=/tmp/diff_file
	local modify_cmd=/tmp/modify_cmd

	diff $org_file $modified_file > $diff_file
	check `expr $? - 1` $LINENO

	awk -f parse_diff.awk $diff_file | sed -n '1!G;h;$p' > $modify_cmd
	check $? $LINENO

	while IFS='' read -r line || [[ -n "$line" ]]; do
		IFS=' ' read  op p1 p2 p3 <<< $line
		if [ "a" == $op ]; then
			append_endif 	$org_file $p1
			append_text 	$org_file $p1 $modified_file $p2
			append_ifdef	$org_file $p1
		elif [ "d" == $op ]; then
			append_endif 	$org_file $p2
			append_else 	$org_file $p1
			append_ifdef	$org_file $p1
		elif [ "c" == $op ]; then
			append_endif 	$org_file $p2
			append_else 	$org_file $p1
			append_text 	$org_file $p1 $modified_file $p3
			append_ifdef	$org_file $p1
		fi
	done < $modify_cmd

	return 0
}

[[ -e /tmp/$project_folder ]] && rm -rf /tmp/$project_folder
cp -r $project_folder /tmp/
check $? $LINENO

cd /tmp/$project_folder
check $? $LINENO

[[ $(git diff) ]] && echo "Please clean your git diff in your project!" && exit -1

git apply $patch
check $? $LINENO

cd -
check $? $LINENO

for file in $files; do
	org_file=$project_folder/$file
	in_file=/tmp/$project_folder/$file

	[[ ! -f $org_file ]] && echo $org_file' does NOT exist!' && exit -1
	[[ ! -f $in_file ]] && echo $in_file' does NOT exist!' && exit -1

	remove_additional_empty_line $in_file $org_file
	append_deletional_empty_line $in_file $org_file
	append_config $in_file $org_file
done

exit 0;
