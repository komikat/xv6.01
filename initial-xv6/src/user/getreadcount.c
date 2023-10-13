#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int
main(){
	printf("%d\n", getreadcount());
	return 1;
}
