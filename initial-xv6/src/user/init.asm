
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	add	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	89250513          	add	a0,a0,-1902 # 8a0 <malloc+0xf2>
  16:	00000097          	auipc	ra,0x0
  1a:	3a8080e7          	jalr	936(ra) # 3be <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3d2080e7          	jalr	978(ra) # 3f6 <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3c8080e7          	jalr	968(ra) # 3f6 <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	87290913          	add	s2,s2,-1934 # 8a8 <malloc+0xfa>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	6b6080e7          	jalr	1718(ra) # 6f6 <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	32e080e7          	jalr	814(ra) # 376 <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	32c080e7          	jalr	812(ra) # 386 <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	88e50513          	add	a0,a0,-1906 # 8f8 <malloc+0x14a>
  72:	00000097          	auipc	ra,0x0
  76:	684080e7          	jalr	1668(ra) # 6f6 <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	302080e7          	jalr	770(ra) # 37e <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	81850513          	add	a0,a0,-2024 # 8a0 <malloc+0xf2>
  90:	00000097          	auipc	ra,0x0
  94:	336080e7          	jalr	822(ra) # 3c6 <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00001517          	auipc	a0,0x1
  9e:	80650513          	add	a0,a0,-2042 # 8a0 <malloc+0xf2>
  a2:	00000097          	auipc	ra,0x0
  a6:	31c080e7          	jalr	796(ra) # 3be <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	81450513          	add	a0,a0,-2028 # 8c0 <malloc+0x112>
  b4:	00000097          	auipc	ra,0x0
  b8:	642080e7          	jalr	1602(ra) # 6f6 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2c0080e7          	jalr	704(ra) # 37e <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	f3a58593          	add	a1,a1,-198 # 1000 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	80a50513          	add	a0,a0,-2038 # 8d8 <malloc+0x12a>
  d6:	00000097          	auipc	ra,0x0
  da:	2e0080e7          	jalr	736(ra) # 3b6 <exec>
      printf("init: exec sh failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	80250513          	add	a0,a0,-2046 # 8e0 <malloc+0x132>
  e6:	00000097          	auipc	ra,0x0
  ea:	610080e7          	jalr	1552(ra) # 6f6 <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	28e080e7          	jalr	654(ra) # 37e <exit>

00000000000000f8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f8:	1141                	add	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	add	s0,sp,16
  extern int main();
  main();
 100:	00000097          	auipc	ra,0x0
 104:	f00080e7          	jalr	-256(ra) # 0 <main>
  exit(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	274080e7          	jalr	628(ra) # 37e <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	add	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	add	a1,a1,1
 11c:	0785                	add	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0x8>
    ;
  return os;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	add	sp,sp,16
 12c:	8082                	ret

000000000000012e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12e:	1141                	add	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb91                	beqz	a5,14c <strcmp+0x1e>
 13a:	0005c703          	lbu	a4,0(a1)
 13e:	00f71763          	bne	a4,a5,14c <strcmp+0x1e>
    p++, q++;
 142:	0505                	add	a0,a0,1
 144:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbe5                	bnez	a5,13a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14c:	0005c503          	lbu	a0,0(a1)
}
 150:	40a7853b          	subw	a0,a5,a0
 154:	6422                	ld	s0,8(sp)
 156:	0141                	add	sp,sp,16
 158:	8082                	ret

000000000000015a <strlen>:

uint
strlen(const char *s)
{
 15a:	1141                	add	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x26>
 166:	0505                	add	a0,a0,1
 168:	87aa                	mv	a5,a0
 16a:	86be                	mv	a3,a5
 16c:	0785                	add	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	ff65                	bnez	a4,16a <strlen+0x10>
 174:	40a6853b          	subw	a0,a3,a0
 178:	2505                	addw	a0,a0,1
    ;
  return n;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	add	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	add	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1c>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	sll	a2,a2,0x20
 190:	9201                	srl	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	add	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x12>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	add	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	add	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	add	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	add	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	add	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	add	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	add	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addw	s1,s1,1
 1f0:	0344d863          	bge	s1,s4,220 <gets+0x56>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	add	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	19a080e7          	jalr	410(ra) # 396 <read>
    if(cc < 1)
 204:	00a05e63          	blez	a0,220 <gets+0x56>
    buf[i++] = c;
 208:	faf44783          	lbu	a5,-81(s0)
 20c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 210:	01578763          	beq	a5,s5,21e <gets+0x54>
 214:	0905                	add	s2,s2,1
 216:	fd679be3          	bne	a5,s6,1ec <gets+0x22>
  for(i=0; i+1 < max; ){
 21a:	89a6                	mv	s3,s1
 21c:	a011                	j	220 <gets+0x56>
 21e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 220:	99de                	add	s3,s3,s7
 222:	00098023          	sb	zero,0(s3)
  return buf;
}
 226:	855e                	mv	a0,s7
 228:	60e6                	ld	ra,88(sp)
 22a:	6446                	ld	s0,80(sp)
 22c:	64a6                	ld	s1,72(sp)
 22e:	6906                	ld	s2,64(sp)
 230:	79e2                	ld	s3,56(sp)
 232:	7a42                	ld	s4,48(sp)
 234:	7aa2                	ld	s5,40(sp)
 236:	7b02                	ld	s6,32(sp)
 238:	6be2                	ld	s7,24(sp)
 23a:	6125                	add	sp,sp,96
 23c:	8082                	ret

000000000000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	1101                	add	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	e426                	sd	s1,8(sp)
 246:	e04a                	sd	s2,0(sp)
 248:	1000                	add	s0,sp,32
 24a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24c:	4581                	li	a1,0
 24e:	00000097          	auipc	ra,0x0
 252:	170080e7          	jalr	368(ra) # 3be <open>
  if(fd < 0)
 256:	02054563          	bltz	a0,280 <stat+0x42>
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	00000097          	auipc	ra,0x0
 262:	178080e7          	jalr	376(ra) # 3d6 <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	13c080e7          	jalr	316(ra) # 3a6 <close>
  return r;
}
 272:	854a                	mv	a0,s2
 274:	60e2                	ld	ra,24(sp)
 276:	6442                	ld	s0,16(sp)
 278:	64a2                	ld	s1,8(sp)
 27a:	6902                	ld	s2,0(sp)
 27c:	6105                	add	sp,sp,32
 27e:	8082                	ret
    return -1;
 280:	597d                	li	s2,-1
 282:	bfc5                	j	272 <stat+0x34>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	add	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28a:	00054683          	lbu	a3,0(a0)
 28e:	fd06879b          	addw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	4625                	li	a2,9
 298:	02f66863          	bltu	a2,a5,2c8 <atoi+0x44>
 29c:	872a                	mv	a4,a0
  n = 0;
 29e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a0:	0705                	add	a4,a4,1
 2a2:	0025179b          	sllw	a5,a0,0x2
 2a6:	9fa9                	addw	a5,a5,a0
 2a8:	0017979b          	sllw	a5,a5,0x1
 2ac:	9fb5                	addw	a5,a5,a3
 2ae:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b2:	00074683          	lbu	a3,0(a4)
 2b6:	fd06879b          	addw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	fef671e3          	bgeu	a2,a5,2a0 <atoi+0x1c>
  return n;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	add	sp,sp,16
 2c6:	8082                	ret
  n = 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <atoi+0x3e>

00000000000002cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2cc:	1141                	add	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d2:	02b57463          	bgeu	a0,a1,2fa <memmove+0x2e>
    while(n-- > 0)
 2d6:	00c05f63          	blez	a2,2f4 <memmove+0x28>
 2da:	1602                	sll	a2,a2,0x20
 2dc:	9201                	srl	a2,a2,0x20
 2de:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e4:	0585                	add	a1,a1,1
 2e6:	0705                	add	a4,a4,1
 2e8:	fff5c683          	lbu	a3,-1(a1)
 2ec:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f0:	fee79ae3          	bne	a5,a4,2e4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	add	sp,sp,16
 2f8:	8082                	ret
    dst += n;
 2fa:	00c50733          	add	a4,a0,a2
    src += n;
 2fe:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 300:	fec05ae3          	blez	a2,2f4 <memmove+0x28>
 304:	fff6079b          	addw	a5,a2,-1
 308:	1782                	sll	a5,a5,0x20
 30a:	9381                	srl	a5,a5,0x20
 30c:	fff7c793          	not	a5,a5
 310:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 312:	15fd                	add	a1,a1,-1
 314:	177d                	add	a4,a4,-1
 316:	0005c683          	lbu	a3,0(a1)
 31a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31e:	fee79ae3          	bne	a5,a4,312 <memmove+0x46>
 322:	bfc9                	j	2f4 <memmove+0x28>

0000000000000324 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 324:	1141                	add	sp,sp,-16
 326:	e422                	sd	s0,8(sp)
 328:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 32a:	ca05                	beqz	a2,35a <memcmp+0x36>
 32c:	fff6069b          	addw	a3,a2,-1
 330:	1682                	sll	a3,a3,0x20
 332:	9281                	srl	a3,a3,0x20
 334:	0685                	add	a3,a3,1
 336:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 338:	00054783          	lbu	a5,0(a0)
 33c:	0005c703          	lbu	a4,0(a1)
 340:	00e79863          	bne	a5,a4,350 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 344:	0505                	add	a0,a0,1
    p2++;
 346:	0585                	add	a1,a1,1
  while (n-- > 0) {
 348:	fed518e3          	bne	a0,a3,338 <memcmp+0x14>
  }
  return 0;
 34c:	4501                	li	a0,0
 34e:	a019                	j	354 <memcmp+0x30>
      return *p1 - *p2;
 350:	40e7853b          	subw	a0,a5,a4
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	add	sp,sp,16
 358:	8082                	ret
  return 0;
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <memcmp+0x30>

000000000000035e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35e:	1141                	add	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 366:	00000097          	auipc	ra,0x0
 36a:	f66080e7          	jalr	-154(ra) # 2cc <memmove>
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	add	sp,sp,16
 374:	8082                	ret

0000000000000376 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 376:	4885                	li	a7,1
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <exit>:
.global exit
exit:
 li a7, SYS_exit
 37e:	4889                	li	a7,2
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <wait>:
.global wait
wait:
 li a7, SYS_wait
 386:	488d                	li	a7,3
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38e:	4891                	li	a7,4
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <read>:
.global read
read:
 li a7, SYS_read
 396:	4895                	li	a7,5
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <write>:
.global write
write:
 li a7, SYS_write
 39e:	48c1                	li	a7,16
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <close>:
.global close
close:
 li a7, SYS_close
 3a6:	48d5                	li	a7,21
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ae:	4899                	li	a7,6
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b6:	489d                	li	a7,7
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <open>:
.global open
open:
 li a7, SYS_open
 3be:	48bd                	li	a7,15
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c6:	48c5                	li	a7,17
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ce:	48c9                	li	a7,18
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d6:	48a1                	li	a7,8
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <link>:
.global link
link:
 li a7, SYS_link
 3de:	48cd                	li	a7,19
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e6:	48d1                	li	a7,20
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ee:	48a5                	li	a7,9
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f6:	48a9                	li	a7,10
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fe:	48ad                	li	a7,11
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 406:	48b1                	li	a7,12
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40e:	48b5                	li	a7,13
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 416:	48b9                	li	a7,14
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 41e:	48d9                	li	a7,22
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 426:	48dd                	li	a7,23
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42e:	1101                	add	sp,sp,-32
 430:	ec06                	sd	ra,24(sp)
 432:	e822                	sd	s0,16(sp)
 434:	1000                	add	s0,sp,32
 436:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43a:	4605                	li	a2,1
 43c:	fef40593          	add	a1,s0,-17
 440:	00000097          	auipc	ra,0x0
 444:	f5e080e7          	jalr	-162(ra) # 39e <write>
}
 448:	60e2                	ld	ra,24(sp)
 44a:	6442                	ld	s0,16(sp)
 44c:	6105                	add	sp,sp,32
 44e:	8082                	ret

0000000000000450 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 450:	7139                	add	sp,sp,-64
 452:	fc06                	sd	ra,56(sp)
 454:	f822                	sd	s0,48(sp)
 456:	f426                	sd	s1,40(sp)
 458:	f04a                	sd	s2,32(sp)
 45a:	ec4e                	sd	s3,24(sp)
 45c:	0080                	add	s0,sp,64
 45e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 460:	c299                	beqz	a3,466 <printint+0x16>
 462:	0805c963          	bltz	a1,4f4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 466:	2581                	sext.w	a1,a1
  neg = 0;
 468:	4881                	li	a7,0
 46a:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 46e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 470:	2601                	sext.w	a2,a2
 472:	00000517          	auipc	a0,0x0
 476:	50650513          	add	a0,a0,1286 # 978 <digits>
 47a:	883a                	mv	a6,a4
 47c:	2705                	addw	a4,a4,1
 47e:	02c5f7bb          	remuw	a5,a1,a2
 482:	1782                	sll	a5,a5,0x20
 484:	9381                	srl	a5,a5,0x20
 486:	97aa                	add	a5,a5,a0
 488:	0007c783          	lbu	a5,0(a5)
 48c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 490:	0005879b          	sext.w	a5,a1
 494:	02c5d5bb          	divuw	a1,a1,a2
 498:	0685                	add	a3,a3,1
 49a:	fec7f0e3          	bgeu	a5,a2,47a <printint+0x2a>
  if(neg)
 49e:	00088c63          	beqz	a7,4b6 <printint+0x66>
    buf[i++] = '-';
 4a2:	fd070793          	add	a5,a4,-48
 4a6:	00878733          	add	a4,a5,s0
 4aa:	02d00793          	li	a5,45
 4ae:	fef70823          	sb	a5,-16(a4)
 4b2:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4b6:	02e05863          	blez	a4,4e6 <printint+0x96>
 4ba:	fc040793          	add	a5,s0,-64
 4be:	00e78933          	add	s2,a5,a4
 4c2:	fff78993          	add	s3,a5,-1
 4c6:	99ba                	add	s3,s3,a4
 4c8:	377d                	addw	a4,a4,-1
 4ca:	1702                	sll	a4,a4,0x20
 4cc:	9301                	srl	a4,a4,0x20
 4ce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4d2:	fff94583          	lbu	a1,-1(s2)
 4d6:	8526                	mv	a0,s1
 4d8:	00000097          	auipc	ra,0x0
 4dc:	f56080e7          	jalr	-170(ra) # 42e <putc>
  while(--i >= 0)
 4e0:	197d                	add	s2,s2,-1
 4e2:	ff3918e3          	bne	s2,s3,4d2 <printint+0x82>
}
 4e6:	70e2                	ld	ra,56(sp)
 4e8:	7442                	ld	s0,48(sp)
 4ea:	74a2                	ld	s1,40(sp)
 4ec:	7902                	ld	s2,32(sp)
 4ee:	69e2                	ld	s3,24(sp)
 4f0:	6121                	add	sp,sp,64
 4f2:	8082                	ret
    x = -xx;
 4f4:	40b005bb          	negw	a1,a1
    neg = 1;
 4f8:	4885                	li	a7,1
    x = -xx;
 4fa:	bf85                	j	46a <printint+0x1a>

00000000000004fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fc:	715d                	add	sp,sp,-80
 4fe:	e486                	sd	ra,72(sp)
 500:	e0a2                	sd	s0,64(sp)
 502:	fc26                	sd	s1,56(sp)
 504:	f84a                	sd	s2,48(sp)
 506:	f44e                	sd	s3,40(sp)
 508:	f052                	sd	s4,32(sp)
 50a:	ec56                	sd	s5,24(sp)
 50c:	e85a                	sd	s6,16(sp)
 50e:	e45e                	sd	s7,8(sp)
 510:	e062                	sd	s8,0(sp)
 512:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 514:	0005c903          	lbu	s2,0(a1)
 518:	18090c63          	beqz	s2,6b0 <vprintf+0x1b4>
 51c:	8aaa                	mv	s5,a0
 51e:	8bb2                	mv	s7,a2
 520:	00158493          	add	s1,a1,1
  state = 0;
 524:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 526:	02500a13          	li	s4,37
 52a:	4b55                	li	s6,21
 52c:	a839                	j	54a <vprintf+0x4e>
        putc(fd, c);
 52e:	85ca                	mv	a1,s2
 530:	8556                	mv	a0,s5
 532:	00000097          	auipc	ra,0x0
 536:	efc080e7          	jalr	-260(ra) # 42e <putc>
 53a:	a019                	j	540 <vprintf+0x44>
    } else if(state == '%'){
 53c:	01498d63          	beq	s3,s4,556 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 540:	0485                	add	s1,s1,1
 542:	fff4c903          	lbu	s2,-1(s1)
 546:	16090563          	beqz	s2,6b0 <vprintf+0x1b4>
    if(state == 0){
 54a:	fe0999e3          	bnez	s3,53c <vprintf+0x40>
      if(c == '%'){
 54e:	ff4910e3          	bne	s2,s4,52e <vprintf+0x32>
        state = '%';
 552:	89d2                	mv	s3,s4
 554:	b7f5                	j	540 <vprintf+0x44>
      if(c == 'd'){
 556:	13490263          	beq	s2,s4,67a <vprintf+0x17e>
 55a:	f9d9079b          	addw	a5,s2,-99
 55e:	0ff7f793          	zext.b	a5,a5
 562:	12fb6563          	bltu	s6,a5,68c <vprintf+0x190>
 566:	f9d9079b          	addw	a5,s2,-99
 56a:	0ff7f713          	zext.b	a4,a5
 56e:	10eb6f63          	bltu	s6,a4,68c <vprintf+0x190>
 572:	00271793          	sll	a5,a4,0x2
 576:	00000717          	auipc	a4,0x0
 57a:	3aa70713          	add	a4,a4,938 # 920 <malloc+0x172>
 57e:	97ba                	add	a5,a5,a4
 580:	439c                	lw	a5,0(a5)
 582:	97ba                	add	a5,a5,a4
 584:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 586:	008b8913          	add	s2,s7,8
 58a:	4685                	li	a3,1
 58c:	4629                	li	a2,10
 58e:	000ba583          	lw	a1,0(s7)
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	ebc080e7          	jalr	-324(ra) # 450 <printint>
 59c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b745                	j	540 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a2:	008b8913          	add	s2,s7,8
 5a6:	4681                	li	a3,0
 5a8:	4629                	li	a2,10
 5aa:	000ba583          	lw	a1,0(s7)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	ea0080e7          	jalr	-352(ra) # 450 <printint>
 5b8:	8bca                	mv	s7,s2
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	b751                	j	540 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5be:	008b8913          	add	s2,s7,8
 5c2:	4681                	li	a3,0
 5c4:	4641                	li	a2,16
 5c6:	000ba583          	lw	a1,0(s7)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	e84080e7          	jalr	-380(ra) # 450 <printint>
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b7a5                	j	540 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5da:	008b8c13          	add	s8,s7,8
 5de:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5e2:	03000593          	li	a1,48
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e46080e7          	jalr	-442(ra) # 42e <putc>
  putc(fd, 'x');
 5f0:	07800593          	li	a1,120
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e38080e7          	jalr	-456(ra) # 42e <putc>
 5fe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 600:	00000b97          	auipc	s7,0x0
 604:	378b8b93          	add	s7,s7,888 # 978 <digits>
 608:	03c9d793          	srl	a5,s3,0x3c
 60c:	97de                	add	a5,a5,s7
 60e:	0007c583          	lbu	a1,0(a5)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e1a080e7          	jalr	-486(ra) # 42e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61c:	0992                	sll	s3,s3,0x4
 61e:	397d                	addw	s2,s2,-1
 620:	fe0914e3          	bnez	s2,608 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 624:	8be2                	mv	s7,s8
      state = 0;
 626:	4981                	li	s3,0
 628:	bf21                	j	540 <vprintf+0x44>
        s = va_arg(ap, char*);
 62a:	008b8993          	add	s3,s7,8
 62e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 632:	02090163          	beqz	s2,654 <vprintf+0x158>
        while(*s != 0){
 636:	00094583          	lbu	a1,0(s2)
 63a:	c9a5                	beqz	a1,6aa <vprintf+0x1ae>
          putc(fd, *s);
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	df0080e7          	jalr	-528(ra) # 42e <putc>
          s++;
 646:	0905                	add	s2,s2,1
        while(*s != 0){
 648:	00094583          	lbu	a1,0(s2)
 64c:	f9e5                	bnez	a1,63c <vprintf+0x140>
        s = va_arg(ap, char*);
 64e:	8bce                	mv	s7,s3
      state = 0;
 650:	4981                	li	s3,0
 652:	b5fd                	j	540 <vprintf+0x44>
          s = "(null)";
 654:	00000917          	auipc	s2,0x0
 658:	2c490913          	add	s2,s2,708 # 918 <malloc+0x16a>
        while(*s != 0){
 65c:	02800593          	li	a1,40
 660:	bff1                	j	63c <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 662:	008b8913          	add	s2,s7,8
 666:	000bc583          	lbu	a1,0(s7)
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	dc2080e7          	jalr	-574(ra) # 42e <putc>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	b5e1                	j	540 <vprintf+0x44>
        putc(fd, c);
 67a:	02500593          	li	a1,37
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	dae080e7          	jalr	-594(ra) # 42e <putc>
      state = 0;
 688:	4981                	li	s3,0
 68a:	bd5d                	j	540 <vprintf+0x44>
        putc(fd, '%');
 68c:	02500593          	li	a1,37
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	d9c080e7          	jalr	-612(ra) # 42e <putc>
        putc(fd, c);
 69a:	85ca                	mv	a1,s2
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	d90080e7          	jalr	-624(ra) # 42e <putc>
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bd61                	j	540 <vprintf+0x44>
        s = va_arg(ap, char*);
 6aa:	8bce                	mv	s7,s3
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bd49                	j	540 <vprintf+0x44>
    }
  }
}
 6b0:	60a6                	ld	ra,72(sp)
 6b2:	6406                	ld	s0,64(sp)
 6b4:	74e2                	ld	s1,56(sp)
 6b6:	7942                	ld	s2,48(sp)
 6b8:	79a2                	ld	s3,40(sp)
 6ba:	7a02                	ld	s4,32(sp)
 6bc:	6ae2                	ld	s5,24(sp)
 6be:	6b42                	ld	s6,16(sp)
 6c0:	6ba2                	ld	s7,8(sp)
 6c2:	6c02                	ld	s8,0(sp)
 6c4:	6161                	add	sp,sp,80
 6c6:	8082                	ret

00000000000006c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c8:	715d                	add	sp,sp,-80
 6ca:	ec06                	sd	ra,24(sp)
 6cc:	e822                	sd	s0,16(sp)
 6ce:	1000                	add	s0,sp,32
 6d0:	e010                	sd	a2,0(s0)
 6d2:	e414                	sd	a3,8(s0)
 6d4:	e818                	sd	a4,16(s0)
 6d6:	ec1c                	sd	a5,24(s0)
 6d8:	03043023          	sd	a6,32(s0)
 6dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6e4:	8622                	mv	a2,s0
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e16080e7          	jalr	-490(ra) # 4fc <vprintf>
}
 6ee:	60e2                	ld	ra,24(sp)
 6f0:	6442                	ld	s0,16(sp)
 6f2:	6161                	add	sp,sp,80
 6f4:	8082                	ret

00000000000006f6 <printf>:

void
printf(const char *fmt, ...)
{
 6f6:	711d                	add	sp,sp,-96
 6f8:	ec06                	sd	ra,24(sp)
 6fa:	e822                	sd	s0,16(sp)
 6fc:	1000                	add	s0,sp,32
 6fe:	e40c                	sd	a1,8(s0)
 700:	e810                	sd	a2,16(s0)
 702:	ec14                	sd	a3,24(s0)
 704:	f018                	sd	a4,32(s0)
 706:	f41c                	sd	a5,40(s0)
 708:	03043823          	sd	a6,48(s0)
 70c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 710:	00840613          	add	a2,s0,8
 714:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 718:	85aa                	mv	a1,a0
 71a:	4505                	li	a0,1
 71c:	00000097          	auipc	ra,0x0
 720:	de0080e7          	jalr	-544(ra) # 4fc <vprintf>
}
 724:	60e2                	ld	ra,24(sp)
 726:	6442                	ld	s0,16(sp)
 728:	6125                	add	sp,sp,96
 72a:	8082                	ret

000000000000072c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72c:	1141                	add	sp,sp,-16
 72e:	e422                	sd	s0,8(sp)
 730:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 732:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	00001797          	auipc	a5,0x1
 73a:	8da7b783          	ld	a5,-1830(a5) # 1010 <freep>
 73e:	a02d                	j	768 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 740:	4618                	lw	a4,8(a2)
 742:	9f2d                	addw	a4,a4,a1
 744:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 748:	6398                	ld	a4,0(a5)
 74a:	6310                	ld	a2,0(a4)
 74c:	a83d                	j	78a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 74e:	ff852703          	lw	a4,-8(a0)
 752:	9f31                	addw	a4,a4,a2
 754:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 756:	ff053683          	ld	a3,-16(a0)
 75a:	a091                	j	79e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75c:	6398                	ld	a4,0(a5)
 75e:	00e7e463          	bltu	a5,a4,766 <free+0x3a>
 762:	00e6ea63          	bltu	a3,a4,776 <free+0x4a>
{
 766:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	fed7fae3          	bgeu	a5,a3,75c <free+0x30>
 76c:	6398                	ld	a4,0(a5)
 76e:	00e6e463          	bltu	a3,a4,776 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	fee7eae3          	bltu	a5,a4,766 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 776:	ff852583          	lw	a1,-8(a0)
 77a:	6390                	ld	a2,0(a5)
 77c:	02059813          	sll	a6,a1,0x20
 780:	01c85713          	srl	a4,a6,0x1c
 784:	9736                	add	a4,a4,a3
 786:	fae60de3          	beq	a2,a4,740 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 78a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 78e:	4790                	lw	a2,8(a5)
 790:	02061593          	sll	a1,a2,0x20
 794:	01c5d713          	srl	a4,a1,0x1c
 798:	973e                	add	a4,a4,a5
 79a:	fae68ae3          	beq	a3,a4,74e <free+0x22>
    p->s.ptr = bp->s.ptr;
 79e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a0:	00001717          	auipc	a4,0x1
 7a4:	86f73823          	sd	a5,-1936(a4) # 1010 <freep>
}
 7a8:	6422                	ld	s0,8(sp)
 7aa:	0141                	add	sp,sp,16
 7ac:	8082                	ret

00000000000007ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ae:	7139                	add	sp,sp,-64
 7b0:	fc06                	sd	ra,56(sp)
 7b2:	f822                	sd	s0,48(sp)
 7b4:	f426                	sd	s1,40(sp)
 7b6:	f04a                	sd	s2,32(sp)
 7b8:	ec4e                	sd	s3,24(sp)
 7ba:	e852                	sd	s4,16(sp)
 7bc:	e456                	sd	s5,8(sp)
 7be:	e05a                	sd	s6,0(sp)
 7c0:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	02051493          	sll	s1,a0,0x20
 7c6:	9081                	srl	s1,s1,0x20
 7c8:	04bd                	add	s1,s1,15
 7ca:	8091                	srl	s1,s1,0x4
 7cc:	0014899b          	addw	s3,s1,1
 7d0:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7d2:	00001517          	auipc	a0,0x1
 7d6:	83e53503          	ld	a0,-1986(a0) # 1010 <freep>
 7da:	c515                	beqz	a0,806 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7de:	4798                	lw	a4,8(a5)
 7e0:	02977f63          	bgeu	a4,s1,81e <malloc+0x70>
  if(nu < 4096)
 7e4:	8a4e                	mv	s4,s3
 7e6:	0009871b          	sext.w	a4,s3
 7ea:	6685                	lui	a3,0x1
 7ec:	00d77363          	bgeu	a4,a3,7f2 <malloc+0x44>
 7f0:	6a05                	lui	s4,0x1
 7f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f6:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fa:	00001917          	auipc	s2,0x1
 7fe:	81690913          	add	s2,s2,-2026 # 1010 <freep>
  if(p == (char*)-1)
 802:	5afd                	li	s5,-1
 804:	a895                	j	878 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 806:	00001797          	auipc	a5,0x1
 80a:	81a78793          	add	a5,a5,-2022 # 1020 <base>
 80e:	00001717          	auipc	a4,0x1
 812:	80f73123          	sd	a5,-2046(a4) # 1010 <freep>
 816:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 818:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81c:	b7e1                	j	7e4 <malloc+0x36>
      if(p->s.size == nunits)
 81e:	02e48c63          	beq	s1,a4,856 <malloc+0xa8>
        p->s.size -= nunits;
 822:	4137073b          	subw	a4,a4,s3
 826:	c798                	sw	a4,8(a5)
        p += p->s.size;
 828:	02071693          	sll	a3,a4,0x20
 82c:	01c6d713          	srl	a4,a3,0x1c
 830:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 832:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 836:	00000717          	auipc	a4,0x0
 83a:	7ca73d23          	sd	a0,2010(a4) # 1010 <freep>
      return (void*)(p + 1);
 83e:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 842:	70e2                	ld	ra,56(sp)
 844:	7442                	ld	s0,48(sp)
 846:	74a2                	ld	s1,40(sp)
 848:	7902                	ld	s2,32(sp)
 84a:	69e2                	ld	s3,24(sp)
 84c:	6a42                	ld	s4,16(sp)
 84e:	6aa2                	ld	s5,8(sp)
 850:	6b02                	ld	s6,0(sp)
 852:	6121                	add	sp,sp,64
 854:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 856:	6398                	ld	a4,0(a5)
 858:	e118                	sd	a4,0(a0)
 85a:	bff1                	j	836 <malloc+0x88>
  hp->s.size = nu;
 85c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 860:	0541                	add	a0,a0,16
 862:	00000097          	auipc	ra,0x0
 866:	eca080e7          	jalr	-310(ra) # 72c <free>
  return freep;
 86a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86e:	d971                	beqz	a0,842 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	fa9775e3          	bgeu	a4,s1,81e <malloc+0x70>
    if(p == freep)
 878:	00093703          	ld	a4,0(s2)
 87c:	853e                	mv	a0,a5
 87e:	fef719e3          	bne	a4,a5,870 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 882:	8552                	mv	a0,s4
 884:	00000097          	auipc	ra,0x0
 888:	b82080e7          	jalr	-1150(ra) # 406 <sbrk>
  if(p == (char*)-1)
 88c:	fd5518e3          	bne	a0,s5,85c <malloc+0xae>
        return 0;
 890:	4501                	li	a0,0
 892:	bf45                	j	842 <malloc+0x94>
