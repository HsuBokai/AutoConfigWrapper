function push_cache_to_arr()
{
	for (i = 1; i <= cache_num; ++i) {
		a_arr[++a_num] = cache[i];
	}
	is_cache = 0;
	cache_num = 0;
}
BEGIN{
	line = 0;
	offset = 0;
	a_num = 0;
	is_cache = 0;
	cache_num = 0;
}
/^[^<>-]/{
	push_cache_to_arr();
	offset = 0;
	if (0 != match($0, /[ac]/)) {
		n = split($0, range, /[ac]/);
		if (2 != n) {
			printf("error !!\n");
			exit -1;
		}
		m = split(range[2], a_range, ",");
		line = a_range[1];
	}
}
/^>/{
	value = line + offset;
	if (0 != match(substr($0,2), /^[ \t]*$/)) {
		if (1 == is_cache) {
			cache[++cache_num] = value;
		} else {
			a_arr[++a_num] = value;
		}
	} else {
		is_cache = 1;
		cache_num = 0;
	}
	offset++;
}
END{
	push_cache_to_arr();
	for (i = a_num; 1 <= i; --i) {
		printf("%d ", a_arr[i]);
	}
	printf("\n");
}
