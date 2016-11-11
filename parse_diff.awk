BEGIN {
}
/^[^<>-]/{
	n = split($0, a, /[adc]/);
	if (2 != n) {
		printf("error !!\n");
		exit -1;
	}
	if (0 != match($0, /a/)) {
		m = split(a[2], c, ",");
		if (1 == m) {
			printf("a %s %s\n", a[1], c[1]);
		} else if (2 == m) {
			printf("a %s %s,%s\n", a[1], c[1], c[2]);
		} else {
			printf("error !!\n");
			exit -1;
		}
	} else if (0 != match($0, /d/)) {
		n = split(a[1], b, ",");
		if (1 == n) {
			printf("d %s %s\n", b[1]-1, b[1]);
		} else if (2 == n) {
			printf("d %s %s\n", b[1]-1, b[2]);
		} else {
			printf("error !!\n");
			exit -1;
		}
	} else if (0 != match($0, /c/)) {
		n = split(a[1], b, ",");
		m = split(a[2], c, ",");
		if (1 == n && 1 == m) {
			printf("c %s %s %s\n", b[1]-1, b[1], c[1]);
		} else if (1 == n && 2 == m) {
			printf("c %s %s %s,%s\n", b[1]-1, b[1], c[1], c[2]);
		} else if (2 == n && 1 == m) {
			printf("c %s %s %s\n", b[1]-1, b[2], c[1]);
		} else if (2 == n && 2 == m) {
			printf("c %s %s %s,%s\n", b[1]-1, b[2], c[1], c[2]);
		} else {
			printf("error !!\n");
			exit -1;
		}
	}
}
END {
}
