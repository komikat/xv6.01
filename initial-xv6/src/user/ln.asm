
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	add	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00000597          	auipc	a1,0x0
  14:	7f058593          	add	a1,a1,2032 # 800 <malloc+0xea>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	616080e7          	jalr	1558(ra) # 630 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2c2080e7          	jalr	706(ra) # 2e6 <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	314080e7          	jalr	788(ra) # 346 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2a6080e7          	jalr	678(ra) # 2e6 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00000597          	auipc	a1,0x0
  50:	7cc58593          	add	a1,a1,1996 # 818 <malloc+0x102>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5da080e7          	jalr	1498(ra) # 630 <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  60:	1141                	add	sp,sp,-16
  62:	e406                	sd	ra,8(sp)
  64:	e022                	sd	s0,0(sp)
  66:	0800                	add	s0,sp,16
  extern int main();
  main();
  68:	00000097          	auipc	ra,0x0
  6c:	f98080e7          	jalr	-104(ra) # 0 <main>
  exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	274080e7          	jalr	628(ra) # 2e6 <exit>

000000000000007a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7a:	1141                	add	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  80:	87aa                	mv	a5,a0
  82:	0585                	add	a1,a1,1
  84:	0785                	add	a5,a5,1
  86:	fff5c703          	lbu	a4,-1(a1)
  8a:	fee78fa3          	sb	a4,-1(a5)
  8e:	fb75                	bnez	a4,82 <strcpy+0x8>
    ;
  return os;
}
  90:	6422                	ld	s0,8(sp)
  92:	0141                	add	sp,sp,16
  94:	8082                	ret

0000000000000096 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  96:	1141                	add	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cb91                	beqz	a5,b4 <strcmp+0x1e>
  a2:	0005c703          	lbu	a4,0(a1)
  a6:	00f71763          	bne	a4,a5,b4 <strcmp+0x1e>
    p++, q++;
  aa:	0505                	add	a0,a0,1
  ac:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	fbe5                	bnez	a5,a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b4:	0005c503          	lbu	a0,0(a1)
}
  b8:	40a7853b          	subw	a0,a5,a0
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	add	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strlen>:

uint
strlen(const char *s)
{
  c2:	1141                	add	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cf91                	beqz	a5,e8 <strlen+0x26>
  ce:	0505                	add	a0,a0,1
  d0:	87aa                	mv	a5,a0
  d2:	86be                	mv	a3,a5
  d4:	0785                	add	a5,a5,1
  d6:	fff7c703          	lbu	a4,-1(a5)
  da:	ff65                	bnez	a4,d2 <strlen+0x10>
  dc:	40a6853b          	subw	a0,a3,a0
  e0:	2505                	addw	a0,a0,1
    ;
  return n;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	add	sp,sp,16
  e6:	8082                	ret
  for(n = 0; s[n]; n++)
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strlen+0x20>

00000000000000ec <memset>:

void*
memset(void *dst, int c, uint n)
{
  ec:	1141                	add	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f2:	ca19                	beqz	a2,108 <memset+0x1c>
  f4:	87aa                	mv	a5,a0
  f6:	1602                	sll	a2,a2,0x20
  f8:	9201                	srl	a2,a2,0x20
  fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 102:	0785                	add	a5,a5,1
 104:	fee79de3          	bne	a5,a4,fe <memset+0x12>
  }
  return dst;
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	add	sp,sp,16
 10c:	8082                	ret

000000000000010e <strchr>:

char*
strchr(const char *s, char c)
{
 10e:	1141                	add	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	add	s0,sp,16
  for(; *s; s++)
 114:	00054783          	lbu	a5,0(a0)
 118:	cb99                	beqz	a5,12e <strchr+0x20>
    if(*s == c)
 11a:	00f58763          	beq	a1,a5,128 <strchr+0x1a>
  for(; *s; s++)
 11e:	0505                	add	a0,a0,1
 120:	00054783          	lbu	a5,0(a0)
 124:	fbfd                	bnez	a5,11a <strchr+0xc>
      return (char*)s;
  return 0;
 126:	4501                	li	a0,0
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	add	sp,sp,16
 12c:	8082                	ret
  return 0;
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strchr+0x1a>

0000000000000132 <gets>:

char*
gets(char *buf, int max)
{
 132:	711d                	add	sp,sp,-96
 134:	ec86                	sd	ra,88(sp)
 136:	e8a2                	sd	s0,80(sp)
 138:	e4a6                	sd	s1,72(sp)
 13a:	e0ca                	sd	s2,64(sp)
 13c:	fc4e                	sd	s3,56(sp)
 13e:	f852                	sd	s4,48(sp)
 140:	f456                	sd	s5,40(sp)
 142:	f05a                	sd	s6,32(sp)
 144:	ec5e                	sd	s7,24(sp)
 146:	1080                	add	s0,sp,96
 148:	8baa                	mv	s7,a0
 14a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14c:	892a                	mv	s2,a0
 14e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 150:	4aa9                	li	s5,10
 152:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 154:	89a6                	mv	s3,s1
 156:	2485                	addw	s1,s1,1
 158:	0344d863          	bge	s1,s4,188 <gets+0x56>
    cc = read(0, &c, 1);
 15c:	4605                	li	a2,1
 15e:	faf40593          	add	a1,s0,-81
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	19a080e7          	jalr	410(ra) # 2fe <read>
    if(cc < 1)
 16c:	00a05e63          	blez	a0,188 <gets+0x56>
    buf[i++] = c;
 170:	faf44783          	lbu	a5,-81(s0)
 174:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 178:	01578763          	beq	a5,s5,186 <gets+0x54>
 17c:	0905                	add	s2,s2,1
 17e:	fd679be3          	bne	a5,s6,154 <gets+0x22>
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	a011                	j	188 <gets+0x56>
 186:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 188:	99de                	add	s3,s3,s7
 18a:	00098023          	sb	zero,0(s3)
  return buf;
}
 18e:	855e                	mv	a0,s7
 190:	60e6                	ld	ra,88(sp)
 192:	6446                	ld	s0,80(sp)
 194:	64a6                	ld	s1,72(sp)
 196:	6906                	ld	s2,64(sp)
 198:	79e2                	ld	s3,56(sp)
 19a:	7a42                	ld	s4,48(sp)
 19c:	7aa2                	ld	s5,40(sp)
 19e:	7b02                	ld	s6,32(sp)
 1a0:	6be2                	ld	s7,24(sp)
 1a2:	6125                	add	sp,sp,96
 1a4:	8082                	ret

00000000000001a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a6:	1101                	add	sp,sp,-32
 1a8:	ec06                	sd	ra,24(sp)
 1aa:	e822                	sd	s0,16(sp)
 1ac:	e426                	sd	s1,8(sp)
 1ae:	e04a                	sd	s2,0(sp)
 1b0:	1000                	add	s0,sp,32
 1b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b4:	4581                	li	a1,0
 1b6:	00000097          	auipc	ra,0x0
 1ba:	170080e7          	jalr	368(ra) # 326 <open>
  if(fd < 0)
 1be:	02054563          	bltz	a0,1e8 <stat+0x42>
 1c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c4:	85ca                	mv	a1,s2
 1c6:	00000097          	auipc	ra,0x0
 1ca:	178080e7          	jalr	376(ra) # 33e <fstat>
 1ce:	892a                	mv	s2,a0
  close(fd);
 1d0:	8526                	mv	a0,s1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	13c080e7          	jalr	316(ra) # 30e <close>
  return r;
}
 1da:	854a                	mv	a0,s2
 1dc:	60e2                	ld	ra,24(sp)
 1de:	6442                	ld	s0,16(sp)
 1e0:	64a2                	ld	s1,8(sp)
 1e2:	6902                	ld	s2,0(sp)
 1e4:	6105                	add	sp,sp,32
 1e6:	8082                	ret
    return -1;
 1e8:	597d                	li	s2,-1
 1ea:	bfc5                	j	1da <stat+0x34>

00000000000001ec <atoi>:

int
atoi(const char *s)
{
 1ec:	1141                	add	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f2:	00054683          	lbu	a3,0(a0)
 1f6:	fd06879b          	addw	a5,a3,-48
 1fa:	0ff7f793          	zext.b	a5,a5
 1fe:	4625                	li	a2,9
 200:	02f66863          	bltu	a2,a5,230 <atoi+0x44>
 204:	872a                	mv	a4,a0
  n = 0;
 206:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 208:	0705                	add	a4,a4,1
 20a:	0025179b          	sllw	a5,a0,0x2
 20e:	9fa9                	addw	a5,a5,a0
 210:	0017979b          	sllw	a5,a5,0x1
 214:	9fb5                	addw	a5,a5,a3
 216:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21a:	00074683          	lbu	a3,0(a4)
 21e:	fd06879b          	addw	a5,a3,-48
 222:	0ff7f793          	zext.b	a5,a5
 226:	fef671e3          	bgeu	a2,a5,208 <atoi+0x1c>
  return n;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	add	sp,sp,16
 22e:	8082                	ret
  n = 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <atoi+0x3e>

0000000000000234 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 234:	1141                	add	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23a:	02b57463          	bgeu	a0,a1,262 <memmove+0x2e>
    while(n-- > 0)
 23e:	00c05f63          	blez	a2,25c <memmove+0x28>
 242:	1602                	sll	a2,a2,0x20
 244:	9201                	srl	a2,a2,0x20
 246:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24a:	872a                	mv	a4,a0
      *dst++ = *src++;
 24c:	0585                	add	a1,a1,1
 24e:	0705                	add	a4,a4,1
 250:	fff5c683          	lbu	a3,-1(a1)
 254:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 258:	fee79ae3          	bne	a5,a4,24c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	add	sp,sp,16
 260:	8082                	ret
    dst += n;
 262:	00c50733          	add	a4,a0,a2
    src += n;
 266:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 268:	fec05ae3          	blez	a2,25c <memmove+0x28>
 26c:	fff6079b          	addw	a5,a2,-1
 270:	1782                	sll	a5,a5,0x20
 272:	9381                	srl	a5,a5,0x20
 274:	fff7c793          	not	a5,a5
 278:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27a:	15fd                	add	a1,a1,-1
 27c:	177d                	add	a4,a4,-1
 27e:	0005c683          	lbu	a3,0(a1)
 282:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x46>
 28a:	bfc9                	j	25c <memmove+0x28>

000000000000028c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28c:	1141                	add	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 292:	ca05                	beqz	a2,2c2 <memcmp+0x36>
 294:	fff6069b          	addw	a3,a2,-1
 298:	1682                	sll	a3,a3,0x20
 29a:	9281                	srl	a3,a3,0x20
 29c:	0685                	add	a3,a3,1
 29e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00e79863          	bne	a5,a4,2b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ac:	0505                	add	a0,a0,1
    p2++;
 2ae:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2b0:	fed518e3          	bne	a0,a3,2a0 <memcmp+0x14>
  }
  return 0;
 2b4:	4501                	li	a0,0
 2b6:	a019                	j	2bc <memcmp+0x30>
      return *p1 - *p2;
 2b8:	40e7853b          	subw	a0,a5,a4
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	add	sp,sp,16
 2c0:	8082                	ret
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <memcmp+0x30>

00000000000002c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c6:	1141                	add	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2ce:	00000097          	auipc	ra,0x0
 2d2:	f66080e7          	jalr	-154(ra) # 234 <memmove>
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	add	sp,sp,16
 2dc:	8082                	ret

00000000000002de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2de:	4885                	li	a7,1
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e6:	4889                	li	a7,2
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ee:	488d                	li	a7,3
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f6:	4891                	li	a7,4
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <read>:
.global read
read:
 li a7, SYS_read
 2fe:	4895                	li	a7,5
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <write>:
.global write
write:
 li a7, SYS_write
 306:	48c1                	li	a7,16
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <close>:
.global close
close:
 li a7, SYS_close
 30e:	48d5                	li	a7,21
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <kill>:
.global kill
kill:
 li a7, SYS_kill
 316:	4899                	li	a7,6
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exec>:
.global exec
exec:
 li a7, SYS_exec
 31e:	489d                	li	a7,7
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <open>:
.global open
open:
 li a7, SYS_open
 326:	48bd                	li	a7,15
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32e:	48c5                	li	a7,17
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 336:	48c9                	li	a7,18
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33e:	48a1                	li	a7,8
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <link>:
.global link
link:
 li a7, SYS_link
 346:	48cd                	li	a7,19
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34e:	48d1                	li	a7,20
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 356:	48a5                	li	a7,9
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <dup>:
.global dup
dup:
 li a7, SYS_dup
 35e:	48a9                	li	a7,10
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 366:	48ad                	li	a7,11
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 36e:	48b1                	li	a7,12
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 376:	48b5                	li	a7,13
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37e:	48b9                	li	a7,14
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 386:	48d9                	li	a7,22
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 38e:	48dd                	li	a7,23
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 396:	1101                	add	sp,sp,-32
 398:	ec06                	sd	ra,24(sp)
 39a:	e822                	sd	s0,16(sp)
 39c:	1000                	add	s0,sp,32
 39e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a2:	4605                	li	a2,1
 3a4:	fef40593          	add	a1,s0,-17
 3a8:	00000097          	auipc	ra,0x0
 3ac:	f5e080e7          	jalr	-162(ra) # 306 <write>
}
 3b0:	60e2                	ld	ra,24(sp)
 3b2:	6442                	ld	s0,16(sp)
 3b4:	6105                	add	sp,sp,32
 3b6:	8082                	ret

00000000000003b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b8:	7139                	add	sp,sp,-64
 3ba:	fc06                	sd	ra,56(sp)
 3bc:	f822                	sd	s0,48(sp)
 3be:	f426                	sd	s1,40(sp)
 3c0:	f04a                	sd	s2,32(sp)
 3c2:	ec4e                	sd	s3,24(sp)
 3c4:	0080                	add	s0,sp,64
 3c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c8:	c299                	beqz	a3,3ce <printint+0x16>
 3ca:	0805c963          	bltz	a1,45c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ce:	2581                	sext.w	a1,a1
  neg = 0;
 3d0:	4881                	li	a7,0
 3d2:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3d8:	2601                	sext.w	a2,a2
 3da:	00000517          	auipc	a0,0x0
 3de:	4b650513          	add	a0,a0,1206 # 890 <digits>
 3e2:	883a                	mv	a6,a4
 3e4:	2705                	addw	a4,a4,1
 3e6:	02c5f7bb          	remuw	a5,a1,a2
 3ea:	1782                	sll	a5,a5,0x20
 3ec:	9381                	srl	a5,a5,0x20
 3ee:	97aa                	add	a5,a5,a0
 3f0:	0007c783          	lbu	a5,0(a5)
 3f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3f8:	0005879b          	sext.w	a5,a1
 3fc:	02c5d5bb          	divuw	a1,a1,a2
 400:	0685                	add	a3,a3,1
 402:	fec7f0e3          	bgeu	a5,a2,3e2 <printint+0x2a>
  if(neg)
 406:	00088c63          	beqz	a7,41e <printint+0x66>
    buf[i++] = '-';
 40a:	fd070793          	add	a5,a4,-48
 40e:	00878733          	add	a4,a5,s0
 412:	02d00793          	li	a5,45
 416:	fef70823          	sb	a5,-16(a4)
 41a:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 41e:	02e05863          	blez	a4,44e <printint+0x96>
 422:	fc040793          	add	a5,s0,-64
 426:	00e78933          	add	s2,a5,a4
 42a:	fff78993          	add	s3,a5,-1
 42e:	99ba                	add	s3,s3,a4
 430:	377d                	addw	a4,a4,-1
 432:	1702                	sll	a4,a4,0x20
 434:	9301                	srl	a4,a4,0x20
 436:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 43a:	fff94583          	lbu	a1,-1(s2)
 43e:	8526                	mv	a0,s1
 440:	00000097          	auipc	ra,0x0
 444:	f56080e7          	jalr	-170(ra) # 396 <putc>
  while(--i >= 0)
 448:	197d                	add	s2,s2,-1
 44a:	ff3918e3          	bne	s2,s3,43a <printint+0x82>
}
 44e:	70e2                	ld	ra,56(sp)
 450:	7442                	ld	s0,48(sp)
 452:	74a2                	ld	s1,40(sp)
 454:	7902                	ld	s2,32(sp)
 456:	69e2                	ld	s3,24(sp)
 458:	6121                	add	sp,sp,64
 45a:	8082                	ret
    x = -xx;
 45c:	40b005bb          	negw	a1,a1
    neg = 1;
 460:	4885                	li	a7,1
    x = -xx;
 462:	bf85                	j	3d2 <printint+0x1a>

0000000000000464 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 464:	715d                	add	sp,sp,-80
 466:	e486                	sd	ra,72(sp)
 468:	e0a2                	sd	s0,64(sp)
 46a:	fc26                	sd	s1,56(sp)
 46c:	f84a                	sd	s2,48(sp)
 46e:	f44e                	sd	s3,40(sp)
 470:	f052                	sd	s4,32(sp)
 472:	ec56                	sd	s5,24(sp)
 474:	e85a                	sd	s6,16(sp)
 476:	e45e                	sd	s7,8(sp)
 478:	e062                	sd	s8,0(sp)
 47a:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47c:	0005c903          	lbu	s2,0(a1)
 480:	18090c63          	beqz	s2,618 <vprintf+0x1b4>
 484:	8aaa                	mv	s5,a0
 486:	8bb2                	mv	s7,a2
 488:	00158493          	add	s1,a1,1
  state = 0;
 48c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 48e:	02500a13          	li	s4,37
 492:	4b55                	li	s6,21
 494:	a839                	j	4b2 <vprintf+0x4e>
        putc(fd, c);
 496:	85ca                	mv	a1,s2
 498:	8556                	mv	a0,s5
 49a:	00000097          	auipc	ra,0x0
 49e:	efc080e7          	jalr	-260(ra) # 396 <putc>
 4a2:	a019                	j	4a8 <vprintf+0x44>
    } else if(state == '%'){
 4a4:	01498d63          	beq	s3,s4,4be <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4a8:	0485                	add	s1,s1,1
 4aa:	fff4c903          	lbu	s2,-1(s1)
 4ae:	16090563          	beqz	s2,618 <vprintf+0x1b4>
    if(state == 0){
 4b2:	fe0999e3          	bnez	s3,4a4 <vprintf+0x40>
      if(c == '%'){
 4b6:	ff4910e3          	bne	s2,s4,496 <vprintf+0x32>
        state = '%';
 4ba:	89d2                	mv	s3,s4
 4bc:	b7f5                	j	4a8 <vprintf+0x44>
      if(c == 'd'){
 4be:	13490263          	beq	s2,s4,5e2 <vprintf+0x17e>
 4c2:	f9d9079b          	addw	a5,s2,-99
 4c6:	0ff7f793          	zext.b	a5,a5
 4ca:	12fb6563          	bltu	s6,a5,5f4 <vprintf+0x190>
 4ce:	f9d9079b          	addw	a5,s2,-99
 4d2:	0ff7f713          	zext.b	a4,a5
 4d6:	10eb6f63          	bltu	s6,a4,5f4 <vprintf+0x190>
 4da:	00271793          	sll	a5,a4,0x2
 4de:	00000717          	auipc	a4,0x0
 4e2:	35a70713          	add	a4,a4,858 # 838 <malloc+0x122>
 4e6:	97ba                	add	a5,a5,a4
 4e8:	439c                	lw	a5,0(a5)
 4ea:	97ba                	add	a5,a5,a4
 4ec:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4ee:	008b8913          	add	s2,s7,8
 4f2:	4685                	li	a3,1
 4f4:	4629                	li	a2,10
 4f6:	000ba583          	lw	a1,0(s7)
 4fa:	8556                	mv	a0,s5
 4fc:	00000097          	auipc	ra,0x0
 500:	ebc080e7          	jalr	-324(ra) # 3b8 <printint>
 504:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 506:	4981                	li	s3,0
 508:	b745                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 50a:	008b8913          	add	s2,s7,8
 50e:	4681                	li	a3,0
 510:	4629                	li	a2,10
 512:	000ba583          	lw	a1,0(s7)
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	ea0080e7          	jalr	-352(ra) # 3b8 <printint>
 520:	8bca                	mv	s7,s2
      state = 0;
 522:	4981                	li	s3,0
 524:	b751                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 526:	008b8913          	add	s2,s7,8
 52a:	4681                	li	a3,0
 52c:	4641                	li	a2,16
 52e:	000ba583          	lw	a1,0(s7)
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	e84080e7          	jalr	-380(ra) # 3b8 <printint>
 53c:	8bca                	mv	s7,s2
      state = 0;
 53e:	4981                	li	s3,0
 540:	b7a5                	j	4a8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 542:	008b8c13          	add	s8,s7,8
 546:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 54a:	03000593          	li	a1,48
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	e46080e7          	jalr	-442(ra) # 396 <putc>
  putc(fd, 'x');
 558:	07800593          	li	a1,120
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e38080e7          	jalr	-456(ra) # 396 <putc>
 566:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 568:	00000b97          	auipc	s7,0x0
 56c:	328b8b93          	add	s7,s7,808 # 890 <digits>
 570:	03c9d793          	srl	a5,s3,0x3c
 574:	97de                	add	a5,a5,s7
 576:	0007c583          	lbu	a1,0(a5)
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e1a080e7          	jalr	-486(ra) # 396 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 584:	0992                	sll	s3,s3,0x4
 586:	397d                	addw	s2,s2,-1
 588:	fe0914e3          	bnez	s2,570 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 58c:	8be2                	mv	s7,s8
      state = 0;
 58e:	4981                	li	s3,0
 590:	bf21                	j	4a8 <vprintf+0x44>
        s = va_arg(ap, char*);
 592:	008b8993          	add	s3,s7,8
 596:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 59a:	02090163          	beqz	s2,5bc <vprintf+0x158>
        while(*s != 0){
 59e:	00094583          	lbu	a1,0(s2)
 5a2:	c9a5                	beqz	a1,612 <vprintf+0x1ae>
          putc(fd, *s);
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	df0080e7          	jalr	-528(ra) # 396 <putc>
          s++;
 5ae:	0905                	add	s2,s2,1
        while(*s != 0){
 5b0:	00094583          	lbu	a1,0(s2)
 5b4:	f9e5                	bnez	a1,5a4 <vprintf+0x140>
        s = va_arg(ap, char*);
 5b6:	8bce                	mv	s7,s3
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	b5fd                	j	4a8 <vprintf+0x44>
          s = "(null)";
 5bc:	00000917          	auipc	s2,0x0
 5c0:	27490913          	add	s2,s2,628 # 830 <malloc+0x11a>
        while(*s != 0){
 5c4:	02800593          	li	a1,40
 5c8:	bff1                	j	5a4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5ca:	008b8913          	add	s2,s7,8
 5ce:	000bc583          	lbu	a1,0(s7)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	dc2080e7          	jalr	-574(ra) # 396 <putc>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b5e1                	j	4a8 <vprintf+0x44>
        putc(fd, c);
 5e2:	02500593          	li	a1,37
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	dae080e7          	jalr	-594(ra) # 396 <putc>
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	bd5d                	j	4a8 <vprintf+0x44>
        putc(fd, '%');
 5f4:	02500593          	li	a1,37
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	d9c080e7          	jalr	-612(ra) # 396 <putc>
        putc(fd, c);
 602:	85ca                	mv	a1,s2
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	d90080e7          	jalr	-624(ra) # 396 <putc>
      state = 0;
 60e:	4981                	li	s3,0
 610:	bd61                	j	4a8 <vprintf+0x44>
        s = va_arg(ap, char*);
 612:	8bce                	mv	s7,s3
      state = 0;
 614:	4981                	li	s3,0
 616:	bd49                	j	4a8 <vprintf+0x44>
    }
  }
}
 618:	60a6                	ld	ra,72(sp)
 61a:	6406                	ld	s0,64(sp)
 61c:	74e2                	ld	s1,56(sp)
 61e:	7942                	ld	s2,48(sp)
 620:	79a2                	ld	s3,40(sp)
 622:	7a02                	ld	s4,32(sp)
 624:	6ae2                	ld	s5,24(sp)
 626:	6b42                	ld	s6,16(sp)
 628:	6ba2                	ld	s7,8(sp)
 62a:	6c02                	ld	s8,0(sp)
 62c:	6161                	add	sp,sp,80
 62e:	8082                	ret

0000000000000630 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 630:	715d                	add	sp,sp,-80
 632:	ec06                	sd	ra,24(sp)
 634:	e822                	sd	s0,16(sp)
 636:	1000                	add	s0,sp,32
 638:	e010                	sd	a2,0(s0)
 63a:	e414                	sd	a3,8(s0)
 63c:	e818                	sd	a4,16(s0)
 63e:	ec1c                	sd	a5,24(s0)
 640:	03043023          	sd	a6,32(s0)
 644:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 648:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 64c:	8622                	mv	a2,s0
 64e:	00000097          	auipc	ra,0x0
 652:	e16080e7          	jalr	-490(ra) # 464 <vprintf>
}
 656:	60e2                	ld	ra,24(sp)
 658:	6442                	ld	s0,16(sp)
 65a:	6161                	add	sp,sp,80
 65c:	8082                	ret

000000000000065e <printf>:

void
printf(const char *fmt, ...)
{
 65e:	711d                	add	sp,sp,-96
 660:	ec06                	sd	ra,24(sp)
 662:	e822                	sd	s0,16(sp)
 664:	1000                	add	s0,sp,32
 666:	e40c                	sd	a1,8(s0)
 668:	e810                	sd	a2,16(s0)
 66a:	ec14                	sd	a3,24(s0)
 66c:	f018                	sd	a4,32(s0)
 66e:	f41c                	sd	a5,40(s0)
 670:	03043823          	sd	a6,48(s0)
 674:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 678:	00840613          	add	a2,s0,8
 67c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 680:	85aa                	mv	a1,a0
 682:	4505                	li	a0,1
 684:	00000097          	auipc	ra,0x0
 688:	de0080e7          	jalr	-544(ra) # 464 <vprintf>
}
 68c:	60e2                	ld	ra,24(sp)
 68e:	6442                	ld	s0,16(sp)
 690:	6125                	add	sp,sp,96
 692:	8082                	ret

0000000000000694 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 694:	1141                	add	sp,sp,-16
 696:	e422                	sd	s0,8(sp)
 698:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 69a:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69e:	00001797          	auipc	a5,0x1
 6a2:	9627b783          	ld	a5,-1694(a5) # 1000 <freep>
 6a6:	a02d                	j	6d0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a8:	4618                	lw	a4,8(a2)
 6aa:	9f2d                	addw	a4,a4,a1
 6ac:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b0:	6398                	ld	a4,0(a5)
 6b2:	6310                	ld	a2,0(a4)
 6b4:	a83d                	j	6f2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6b6:	ff852703          	lw	a4,-8(a0)
 6ba:	9f31                	addw	a4,a4,a2
 6bc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6be:	ff053683          	ld	a3,-16(a0)
 6c2:	a091                	j	706 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c4:	6398                	ld	a4,0(a5)
 6c6:	00e7e463          	bltu	a5,a4,6ce <free+0x3a>
 6ca:	00e6ea63          	bltu	a3,a4,6de <free+0x4a>
{
 6ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d0:	fed7fae3          	bgeu	a5,a3,6c4 <free+0x30>
 6d4:	6398                	ld	a4,0(a5)
 6d6:	00e6e463          	bltu	a3,a4,6de <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6da:	fee7eae3          	bltu	a5,a4,6ce <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6de:	ff852583          	lw	a1,-8(a0)
 6e2:	6390                	ld	a2,0(a5)
 6e4:	02059813          	sll	a6,a1,0x20
 6e8:	01c85713          	srl	a4,a6,0x1c
 6ec:	9736                	add	a4,a4,a3
 6ee:	fae60de3          	beq	a2,a4,6a8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6f6:	4790                	lw	a2,8(a5)
 6f8:	02061593          	sll	a1,a2,0x20
 6fc:	01c5d713          	srl	a4,a1,0x1c
 700:	973e                	add	a4,a4,a5
 702:	fae68ae3          	beq	a3,a4,6b6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 706:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 708:	00001717          	auipc	a4,0x1
 70c:	8ef73c23          	sd	a5,-1800(a4) # 1000 <freep>
}
 710:	6422                	ld	s0,8(sp)
 712:	0141                	add	sp,sp,16
 714:	8082                	ret

0000000000000716 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 716:	7139                	add	sp,sp,-64
 718:	fc06                	sd	ra,56(sp)
 71a:	f822                	sd	s0,48(sp)
 71c:	f426                	sd	s1,40(sp)
 71e:	f04a                	sd	s2,32(sp)
 720:	ec4e                	sd	s3,24(sp)
 722:	e852                	sd	s4,16(sp)
 724:	e456                	sd	s5,8(sp)
 726:	e05a                	sd	s6,0(sp)
 728:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72a:	02051493          	sll	s1,a0,0x20
 72e:	9081                	srl	s1,s1,0x20
 730:	04bd                	add	s1,s1,15
 732:	8091                	srl	s1,s1,0x4
 734:	0014899b          	addw	s3,s1,1
 738:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 73a:	00001517          	auipc	a0,0x1
 73e:	8c653503          	ld	a0,-1850(a0) # 1000 <freep>
 742:	c515                	beqz	a0,76e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 744:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 746:	4798                	lw	a4,8(a5)
 748:	02977f63          	bgeu	a4,s1,786 <malloc+0x70>
  if(nu < 4096)
 74c:	8a4e                	mv	s4,s3
 74e:	0009871b          	sext.w	a4,s3
 752:	6685                	lui	a3,0x1
 754:	00d77363          	bgeu	a4,a3,75a <malloc+0x44>
 758:	6a05                	lui	s4,0x1
 75a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 75e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 762:	00001917          	auipc	s2,0x1
 766:	89e90913          	add	s2,s2,-1890 # 1000 <freep>
  if(p == (char*)-1)
 76a:	5afd                	li	s5,-1
 76c:	a895                	j	7e0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 76e:	00001797          	auipc	a5,0x1
 772:	8a278793          	add	a5,a5,-1886 # 1010 <base>
 776:	00001717          	auipc	a4,0x1
 77a:	88f73523          	sd	a5,-1910(a4) # 1000 <freep>
 77e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 780:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 784:	b7e1                	j	74c <malloc+0x36>
      if(p->s.size == nunits)
 786:	02e48c63          	beq	s1,a4,7be <malloc+0xa8>
        p->s.size -= nunits;
 78a:	4137073b          	subw	a4,a4,s3
 78e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 790:	02071693          	sll	a3,a4,0x20
 794:	01c6d713          	srl	a4,a3,0x1c
 798:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 79a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 79e:	00001717          	auipc	a4,0x1
 7a2:	86a73123          	sd	a0,-1950(a4) # 1000 <freep>
      return (void*)(p + 1);
 7a6:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7aa:	70e2                	ld	ra,56(sp)
 7ac:	7442                	ld	s0,48(sp)
 7ae:	74a2                	ld	s1,40(sp)
 7b0:	7902                	ld	s2,32(sp)
 7b2:	69e2                	ld	s3,24(sp)
 7b4:	6a42                	ld	s4,16(sp)
 7b6:	6aa2                	ld	s5,8(sp)
 7b8:	6b02                	ld	s6,0(sp)
 7ba:	6121                	add	sp,sp,64
 7bc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7be:	6398                	ld	a4,0(a5)
 7c0:	e118                	sd	a4,0(a0)
 7c2:	bff1                	j	79e <malloc+0x88>
  hp->s.size = nu;
 7c4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7c8:	0541                	add	a0,a0,16
 7ca:	00000097          	auipc	ra,0x0
 7ce:	eca080e7          	jalr	-310(ra) # 694 <free>
  return freep;
 7d2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7d6:	d971                	beqz	a0,7aa <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7da:	4798                	lw	a4,8(a5)
 7dc:	fa9775e3          	bgeu	a4,s1,786 <malloc+0x70>
    if(p == freep)
 7e0:	00093703          	ld	a4,0(s2)
 7e4:	853e                	mv	a0,a5
 7e6:	fef719e3          	bne	a4,a5,7d8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7ea:	8552                	mv	a0,s4
 7ec:	00000097          	auipc	ra,0x0
 7f0:	b82080e7          	jalr	-1150(ra) # 36e <sbrk>
  if(p == (char*)-1)
 7f4:	fd5518e3          	bne	a0,s5,7c4 <malloc+0xae>
        return 0;
 7f8:	4501                	li	a0,0
 7fa:	bf45                	j	7aa <malloc+0x94>
