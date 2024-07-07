
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9f010113          	add	sp,sp,-1552 # 800089f0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	86070713          	add	a4,a4,-1952 # 800088b0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	ebe78793          	add	a5,a5,-322 # 80005f20 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc4c7>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	43e080e7          	jalr	1086(ra) # 80002568 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	86c50513          	add	a0,a0,-1940 # 800109f0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	85c48493          	add	s1,s1,-1956 # 800109f0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	8ec90913          	add	s2,s2,-1812 # 80010a88 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	802080e7          	jalr	-2046(ra) # 800019b6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	1f6080e7          	jalr	502(ra) # 800023b2 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f34080e7          	jalr	-204(ra) # 800020fe <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	81270713          	add	a4,a4,-2030 # 800109f0 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	302080e7          	jalr	770(ra) # 80002512 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00010517          	auipc	a0,0x10
    8000022c:	7c850513          	add	a0,a0,1992 # 800109f0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00010517          	auipc	a0,0x10
    80000242:	7b250513          	add	a0,a0,1970 # 800109f0 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	80f72d23          	sw	a5,-2022(a4) # 80010a88 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	72850513          	add	a0,a0,1832 # 800109f0 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	2d0080e7          	jalr	720(ra) # 800025be <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	6fa50513          	add	a0,a0,1786 # 800109f0 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	6d670713          	add	a4,a4,1750 # 800109f0 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	6ac78793          	add	a5,a5,1708 # 800109f0 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7167a783          	lw	a5,1814(a5) # 80010a88 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	66a70713          	add	a4,a4,1642 # 800109f0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	65a48493          	add	s1,s1,1626 # 800109f0 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	61e70713          	add	a4,a4,1566 # 800109f0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	6af72423          	sw	a5,1704(a4) # 80010a90 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	5e278793          	add	a5,a5,1506 # 800109f0 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	64c7ad23          	sw	a2,1626(a5) # 80010a8c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	64e50513          	add	a0,a0,1614 # 80010a88 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d20080e7          	jalr	-736(ra) # 80002162 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	59450513          	add	a0,a0,1428 # 800109f0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	d1478793          	add	a5,a5,-748 # 80021188 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5607a423          	sw	zero,1384(a5) # 80010ab0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b6e50513          	add	a0,a0,-1170 # 800080d8 <digits+0x98>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	2ef72a23          	sw	a5,756(a4) # 80008870 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	add	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	4f8dad83          	lw	s11,1272(s11) # 80010ab0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	4a250513          	add	a0,a0,1186 # 80010a98 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	add	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	add	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	add	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	34450513          	add	a0,a0,836 # 80010a98 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	32848493          	add	s1,s1,808 # 80010a98 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	2e850513          	add	a0,a0,744 # 80010ab8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0747a783          	lw	a5,116(a5) # 80008870 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	and	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0447b783          	ld	a5,68(a5) # 80008878 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	04473703          	ld	a4,68(a4) # 80008880 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	25aa0a13          	add	s4,s4,602 # 80010ab8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	01248493          	add	s1,s1,18 # 80008878 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	01298993          	add	s3,s3,18 # 80008880 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	8d2080e7          	jalr	-1838(ra) # 80002162 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	1ec50513          	add	a0,a0,492 # 80010ab8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	f947a783          	lw	a5,-108(a5) # 80008870 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	f9a73703          	ld	a4,-102(a4) # 80008880 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	f8a7b783          	ld	a5,-118(a5) # 80008878 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	1be98993          	add	s3,s3,446 # 80010ab8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	f7648493          	add	s1,s1,-138 # 80008878 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	f7690913          	add	s2,s2,-138 # 80008880 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7e4080e7          	jalr	2020(ra) # 800020fe <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	18848493          	add	s1,s1,392 # 80010ab8 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	f2e7be23          	sd	a4,-196(a5) # 80008880 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	add	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	10248493          	add	s1,s1,258 # 80010ab8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	94078793          	add	a5,a5,-1728 # 80022338 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	0d890913          	add	s2,s2,216 # 80010af0 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	03a50513          	add	a0,a0,58 # 80010af0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	86e50513          	add	a0,a0,-1938 # 80022338 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	00448493          	add	s1,s1,4 # 80010af0 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	fec50513          	add	a0,a0,-20 # 80010af0 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	fc050513          	add	a0,a0,-64 # 80010af0 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e2e080e7          	jalr	-466(ra) # 8000199a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dfc080e7          	jalr	-516(ra) # 8000199a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	df0080e7          	jalr	-528(ra) # 8000199a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dd8080e7          	jalr	-552(ra) # 8000199a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d98080e7          	jalr	-616(ra) # 8000199a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d6c080e7          	jalr	-660(ra) # 8000199a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdccc9>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:


// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b10080e7          	jalr	-1264(ra) # 8000198a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a0670713          	add	a4,a4,-1530 # 80008888 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	af4080e7          	jalr	-1292(ra) # 8000198a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	22850513          	add	a0,a0,552 # 800080c8 <digits+0x88>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e8080e7          	jalr	232(ra) # 80000f98 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	9e6080e7          	jalr	-1562(ra) # 8000289e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	0a0080e7          	jalr	160(ra) # 80005f60 <plicinithart>
  }

 scheduler();
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	004080e7          	jalr	4(ra) # 80001ecc <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1f850513          	add	a0,a0,504 # 800080d8 <digits+0x98>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("Using mlfq!\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1b850513          	add	a0,a0,440 # 800080b8 <digits+0x78>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    printf("\n");
    80000f10:	00007517          	auipc	a0,0x7
    80000f14:	1c850513          	add	a0,a0,456 # 800080d8 <digits+0x98>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	66e080e7          	jalr	1646(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	b86080e7          	jalr	-1146(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	326080e7          	jalr	806(ra) # 8000124e <kvminit>
    kvminithart();   // turn on paging
    80000f30:	00000097          	auipc	ra,0x0
    80000f34:	068080e7          	jalr	104(ra) # 80000f98 <kvminithart>
    procinit();      // process table
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	99e080e7          	jalr	-1634(ra) # 800018d6 <procinit>
    trapinit();      // trap vectors
    80000f40:	00002097          	auipc	ra,0x2
    80000f44:	936080e7          	jalr	-1738(ra) # 80002876 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f48:	00002097          	auipc	ra,0x2
    80000f4c:	956080e7          	jalr	-1706(ra) # 8000289e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f50:	00005097          	auipc	ra,0x5
    80000f54:	ffa080e7          	jalr	-6(ra) # 80005f4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f58:	00005097          	auipc	ra,0x5
    80000f5c:	008080e7          	jalr	8(ra) # 80005f60 <plicinithart>
    binit();         // buffer cache
    80000f60:	00002097          	auipc	ra,0x2
    80000f64:	1bc080e7          	jalr	444(ra) # 8000311c <binit>
    iinit();         // inode table
    80000f68:	00003097          	auipc	ra,0x3
    80000f6c:	85a080e7          	jalr	-1958(ra) # 800037c2 <iinit>
    fileinit();      // file table
    80000f70:	00003097          	auipc	ra,0x3
    80000f74:	7d0080e7          	jalr	2000(ra) # 80004740 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f78:	00005097          	auipc	ra,0x5
    80000f7c:	0f0080e7          	jalr	240(ra) # 80006068 <virtio_disk_init>
    userinit();      // first user process
    80000f80:	00001097          	auipc	ra,0x1
    80000f84:	d2e080e7          	jalr	-722(ra) # 80001cae <userinit>
    __sync_synchronize();
    80000f88:	0ff0000f          	fence
    started = 1;
    80000f8c:	4785                	li	a5,1
    80000f8e:	00008717          	auipc	a4,0x8
    80000f92:	8ef72d23          	sw	a5,-1798(a4) # 80008888 <started>
    80000f96:	bf0d                	j	80000ec8 <main+0x56>

0000000080000f98 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f98:	1141                	add	sp,sp,-16
    80000f9a:	e422                	sd	s0,8(sp)
    80000f9c:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa2:	00008797          	auipc	a5,0x8
    80000fa6:	8ee7b783          	ld	a5,-1810(a5) # 80008890 <kernel_pagetable>
    80000faa:	83b1                	srl	a5,a5,0xc
    80000fac:	577d                	li	a4,-1
    80000fae:	177e                	sll	a4,a4,0x3f
    80000fb0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fb6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fba:	6422                	ld	s0,8(sp)
    80000fbc:	0141                	add	sp,sp,16
    80000fbe:	8082                	ret

0000000080000fc0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc0:	7139                	add	sp,sp,-64
    80000fc2:	fc06                	sd	ra,56(sp)
    80000fc4:	f822                	sd	s0,48(sp)
    80000fc6:	f426                	sd	s1,40(sp)
    80000fc8:	f04a                	sd	s2,32(sp)
    80000fca:	ec4e                	sd	s3,24(sp)
    80000fcc:	e852                	sd	s4,16(sp)
    80000fce:	e456                	sd	s5,8(sp)
    80000fd0:	e05a                	sd	s6,0(sp)
    80000fd2:	0080                	add	s0,sp,64
    80000fd4:	84aa                	mv	s1,a0
    80000fd6:	89ae                	mv	s3,a1
    80000fd8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fda:	57fd                	li	a5,-1
    80000fdc:	83e9                	srl	a5,a5,0x1a
    80000fde:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe2:	04b7f263          	bgeu	a5,a1,80001026 <walk+0x66>
    panic("walk");
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	0fa50513          	add	a0,a0,250 # 800080e0 <digits+0xa0>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	54e080e7          	jalr	1358(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff6:	060a8663          	beqz	s5,80001062 <walk+0xa2>
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	ae8080e7          	jalr	-1304(ra) # 80000ae2 <kalloc>
    80001002:	84aa                	mv	s1,a0
    80001004:	c529                	beqz	a0,8000104e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001006:	6605                	lui	a2,0x1
    80001008:	4581                	li	a1,0
    8000100a:	00000097          	auipc	ra,0x0
    8000100e:	cc4080e7          	jalr	-828(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srl	a5,s1,0xc
    80001016:	07aa                	sll	a5,a5,0xa
    80001018:	0017e793          	or	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001020:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdccbf>
    80001022:	036a0063          	beq	s4,s6,80001042 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001026:	0149d933          	srl	s2,s3,s4
    8000102a:	1ff97913          	and	s2,s2,511
    8000102e:	090e                	sll	s2,s2,0x3
    80001030:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001032:	00093483          	ld	s1,0(s2)
    80001036:	0014f793          	and	a5,s1,1
    8000103a:	dfd5                	beqz	a5,80000ff6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103c:	80a9                	srl	s1,s1,0xa
    8000103e:	04b2                	sll	s1,s1,0xc
    80001040:	b7c5                	j	80001020 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001042:	00c9d513          	srl	a0,s3,0xc
    80001046:	1ff57513          	and	a0,a0,511
    8000104a:	050e                	sll	a0,a0,0x3
    8000104c:	9526                	add	a0,a0,s1
}
    8000104e:	70e2                	ld	ra,56(sp)
    80001050:	7442                	ld	s0,48(sp)
    80001052:	74a2                	ld	s1,40(sp)
    80001054:	7902                	ld	s2,32(sp)
    80001056:	69e2                	ld	s3,24(sp)
    80001058:	6a42                	ld	s4,16(sp)
    8000105a:	6aa2                	ld	s5,8(sp)
    8000105c:	6b02                	ld	s6,0(sp)
    8000105e:	6121                	add	sp,sp,64
    80001060:	8082                	ret
        return 0;
    80001062:	4501                	li	a0,0
    80001064:	b7ed                	j	8000104e <walk+0x8e>

0000000080001066 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001066:	57fd                	li	a5,-1
    80001068:	83e9                	srl	a5,a5,0x1a
    8000106a:	00b7f463          	bgeu	a5,a1,80001072 <walkaddr+0xc>
    return 0;
    8000106e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001070:	8082                	ret
{
    80001072:	1141                	add	sp,sp,-16
    80001074:	e406                	sd	ra,8(sp)
    80001076:	e022                	sd	s0,0(sp)
    80001078:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000107a:	4601                	li	a2,0
    8000107c:	00000097          	auipc	ra,0x0
    80001080:	f44080e7          	jalr	-188(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001084:	c105                	beqz	a0,800010a4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001086:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001088:	0117f693          	and	a3,a5,17
    8000108c:	4745                	li	a4,17
    return 0;
    8000108e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001090:	00e68663          	beq	a3,a4,8000109c <walkaddr+0x36>
}
    80001094:	60a2                	ld	ra,8(sp)
    80001096:	6402                	ld	s0,0(sp)
    80001098:	0141                	add	sp,sp,16
    8000109a:	8082                	ret
  pa = PTE2PA(*pte);
    8000109c:	83a9                	srl	a5,a5,0xa
    8000109e:	00c79513          	sll	a0,a5,0xc
  return pa;
    800010a2:	bfcd                	j	80001094 <walkaddr+0x2e>
    return 0;
    800010a4:	4501                	li	a0,0
    800010a6:	b7fd                	j	80001094 <walkaddr+0x2e>

00000000800010a8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a8:	715d                	add	sp,sp,-80
    800010aa:	e486                	sd	ra,72(sp)
    800010ac:	e0a2                	sd	s0,64(sp)
    800010ae:	fc26                	sd	s1,56(sp)
    800010b0:	f84a                	sd	s2,48(sp)
    800010b2:	f44e                	sd	s3,40(sp)
    800010b4:	f052                	sd	s4,32(sp)
    800010b6:	ec56                	sd	s5,24(sp)
    800010b8:	e85a                	sd	s6,16(sp)
    800010ba:	e45e                	sd	s7,8(sp)
    800010bc:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010be:	c639                	beqz	a2,8000110c <mappages+0x64>
    800010c0:	8aaa                	mv	s5,a0
    800010c2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010c4:	777d                	lui	a4,0xfffff
    800010c6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ca:	fff58993          	add	s3,a1,-1
    800010ce:	99b2                	add	s3,s3,a2
    800010d0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d4:	893e                	mv	s2,a5
    800010d6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010da:	6b85                	lui	s7,0x1
    800010dc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e0:	4605                	li	a2,1
    800010e2:	85ca                	mv	a1,s2
    800010e4:	8556                	mv	a0,s5
    800010e6:	00000097          	auipc	ra,0x0
    800010ea:	eda080e7          	jalr	-294(ra) # 80000fc0 <walk>
    800010ee:	cd1d                	beqz	a0,8000112c <mappages+0x84>
    if(*pte & PTE_V)
    800010f0:	611c                	ld	a5,0(a0)
    800010f2:	8b85                	and	a5,a5,1
    800010f4:	e785                	bnez	a5,8000111c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f6:	80b1                	srl	s1,s1,0xc
    800010f8:	04aa                	sll	s1,s1,0xa
    800010fa:	0164e4b3          	or	s1,s1,s6
    800010fe:	0014e493          	or	s1,s1,1
    80001102:	e104                	sd	s1,0(a0)
    if(a == last)
    80001104:	05390063          	beq	s2,s3,80001144 <mappages+0x9c>
    a += PGSIZE;
    80001108:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110a:	bfc9                	j	800010dc <mappages+0x34>
    panic("mappages: size");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	add	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000111c:	00007517          	auipc	a0,0x7
    80001120:	fdc50513          	add	a0,a0,-36 # 800080f8 <digits+0xb8>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	418080e7          	jalr	1048(ra) # 8000053c <panic>
      return -1;
    8000112c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112e:	60a6                	ld	ra,72(sp)
    80001130:	6406                	ld	s0,64(sp)
    80001132:	74e2                	ld	s1,56(sp)
    80001134:	7942                	ld	s2,48(sp)
    80001136:	79a2                	ld	s3,40(sp)
    80001138:	7a02                	ld	s4,32(sp)
    8000113a:	6ae2                	ld	s5,24(sp)
    8000113c:	6b42                	ld	s6,16(sp)
    8000113e:	6ba2                	ld	s7,8(sp)
    80001140:	6161                	add	sp,sp,80
    80001142:	8082                	ret
  return 0;
    80001144:	4501                	li	a0,0
    80001146:	b7e5                	j	8000112e <mappages+0x86>

0000000080001148 <kvmmap>:
{
    80001148:	1141                	add	sp,sp,-16
    8000114a:	e406                	sd	ra,8(sp)
    8000114c:	e022                	sd	s0,0(sp)
    8000114e:	0800                	add	s0,sp,16
    80001150:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001152:	86b2                	mv	a3,a2
    80001154:	863e                	mv	a2,a5
    80001156:	00000097          	auipc	ra,0x0
    8000115a:	f52080e7          	jalr	-174(ra) # 800010a8 <mappages>
    8000115e:	e509                	bnez	a0,80001168 <kvmmap+0x20>
}
    80001160:	60a2                	ld	ra,8(sp)
    80001162:	6402                	ld	s0,0(sp)
    80001164:	0141                	add	sp,sp,16
    80001166:	8082                	ret
    panic("kvmmap");
    80001168:	00007517          	auipc	a0,0x7
    8000116c:	fa050513          	add	a0,a0,-96 # 80008108 <digits+0xc8>
    80001170:	fffff097          	auipc	ra,0xfffff
    80001174:	3cc080e7          	jalr	972(ra) # 8000053c <panic>

0000000080001178 <kvmmake>:
{
    80001178:	1101                	add	sp,sp,-32
    8000117a:	ec06                	sd	ra,24(sp)
    8000117c:	e822                	sd	s0,16(sp)
    8000117e:	e426                	sd	s1,8(sp)
    80001180:	e04a                	sd	s2,0(sp)
    80001182:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001184:	00000097          	auipc	ra,0x0
    80001188:	95e080e7          	jalr	-1698(ra) # 80000ae2 <kalloc>
    8000118c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118e:	6605                	lui	a2,0x1
    80001190:	4581                	li	a1,0
    80001192:	00000097          	auipc	ra,0x0
    80001196:	b3c080e7          	jalr	-1220(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	6685                	lui	a3,0x1
    8000119e:	10000637          	lui	a2,0x10000
    800011a2:	100005b7          	lui	a1,0x10000
    800011a6:	8526                	mv	a0,s1
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	fa0080e7          	jalr	-96(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	6685                	lui	a3,0x1
    800011b4:	10001637          	lui	a2,0x10001
    800011b8:	100015b7          	lui	a1,0x10001
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f8a080e7          	jalr	-118(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c6:	4719                	li	a4,6
    800011c8:	004006b7          	lui	a3,0x400
    800011cc:	0c000637          	lui	a2,0xc000
    800011d0:	0c0005b7          	lui	a1,0xc000
    800011d4:	8526                	mv	a0,s1
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	f72080e7          	jalr	-142(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011de:	00007917          	auipc	s2,0x7
    800011e2:	e2290913          	add	s2,s2,-478 # 80008000 <etext>
    800011e6:	4729                	li	a4,10
    800011e8:	80007697          	auipc	a3,0x80007
    800011ec:	e1868693          	add	a3,a3,-488 # 8000 <_entry-0x7fff8000>
    800011f0:	4605                	li	a2,1
    800011f2:	067e                	sll	a2,a2,0x1f
    800011f4:	85b2                	mv	a1,a2
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	f50080e7          	jalr	-176(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	46c5                	li	a3,17
    80001204:	06ee                	sll	a3,a3,0x1b
    80001206:	412686b3          	sub	a3,a3,s2
    8000120a:	864a                	mv	a2,s2
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8526                	mv	a0,s1
    80001210:	00000097          	auipc	ra,0x0
    80001214:	f38080e7          	jalr	-200(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001218:	4729                	li	a4,10
    8000121a:	6685                	lui	a3,0x1
    8000121c:	00006617          	auipc	a2,0x6
    80001220:	de460613          	add	a2,a2,-540 # 80007000 <_trampoline>
    80001224:	040005b7          	lui	a1,0x4000
    80001228:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000122a:	05b2                	sll	a1,a1,0xc
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f1a080e7          	jalr	-230(ra) # 80001148 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001236:	8526                	mv	a0,s1
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	608080e7          	jalr	1544(ra) # 80001840 <proc_mapstacks>
}
    80001240:	8526                	mv	a0,s1
    80001242:	60e2                	ld	ra,24(sp)
    80001244:	6442                	ld	s0,16(sp)
    80001246:	64a2                	ld	s1,8(sp)
    80001248:	6902                	ld	s2,0(sp)
    8000124a:	6105                	add	sp,sp,32
    8000124c:	8082                	ret

000000008000124e <kvminit>:
{
    8000124e:	1141                	add	sp,sp,-16
    80001250:	e406                	sd	ra,8(sp)
    80001252:	e022                	sd	s0,0(sp)
    80001254:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f22080e7          	jalr	-222(ra) # 80001178 <kvmmake>
    8000125e:	00007797          	auipc	a5,0x7
    80001262:	62a7b923          	sd	a0,1586(a5) # 80008890 <kernel_pagetable>
}
    80001266:	60a2                	ld	ra,8(sp)
    80001268:	6402                	ld	s0,0(sp)
    8000126a:	0141                	add	sp,sp,16
    8000126c:	8082                	ret

000000008000126e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000126e:	715d                	add	sp,sp,-80
    80001270:	e486                	sd	ra,72(sp)
    80001272:	e0a2                	sd	s0,64(sp)
    80001274:	fc26                	sd	s1,56(sp)
    80001276:	f84a                	sd	s2,48(sp)
    80001278:	f44e                	sd	s3,40(sp)
    8000127a:	f052                	sd	s4,32(sp)
    8000127c:	ec56                	sd	s5,24(sp)
    8000127e:	e85a                	sd	s6,16(sp)
    80001280:	e45e                	sd	s7,8(sp)
    80001282:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001284:	03459793          	sll	a5,a1,0x34
    80001288:	e795                	bnez	a5,800012b4 <uvmunmap+0x46>
    8000128a:	8a2a                	mv	s4,a0
    8000128c:	892e                	mv	s2,a1
    8000128e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001290:	0632                	sll	a2,a2,0xc
    80001292:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001296:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	6b05                	lui	s6,0x1
    8000129a:	0735e263          	bltu	a1,s3,800012fe <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000129e:	60a6                	ld	ra,72(sp)
    800012a0:	6406                	ld	s0,64(sp)
    800012a2:	74e2                	ld	s1,56(sp)
    800012a4:	7942                	ld	s2,48(sp)
    800012a6:	79a2                	ld	s3,40(sp)
    800012a8:	7a02                	ld	s4,32(sp)
    800012aa:	6ae2                	ld	s5,24(sp)
    800012ac:	6b42                	ld	s6,16(sp)
    800012ae:	6ba2                	ld	s7,8(sp)
    800012b0:	6161                	add	sp,sp,80
    800012b2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e5c50513          	add	a0,a0,-420 # 80008110 <digits+0xd0>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	add	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6450513          	add	a0,a0,-412 # 80008138 <digits+0xf8>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012e4:	00007517          	auipc	a0,0x7
    800012e8:	e6c50513          	add	a0,a0,-404 # 80008150 <digits+0x110>
    800012ec:	fffff097          	auipc	ra,0xfffff
    800012f0:	250080e7          	jalr	592(ra) # 8000053c <panic>
    *pte = 0;
    800012f4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f8:	995a                	add	s2,s2,s6
    800012fa:	fb3972e3          	bgeu	s2,s3,8000129e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012fe:	4601                	li	a2,0
    80001300:	85ca                	mv	a1,s2
    80001302:	8552                	mv	a0,s4
    80001304:	00000097          	auipc	ra,0x0
    80001308:	cbc080e7          	jalr	-836(ra) # 80000fc0 <walk>
    8000130c:	84aa                	mv	s1,a0
    8000130e:	d95d                	beqz	a0,800012c4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001310:	6108                	ld	a0,0(a0)
    80001312:	00157793          	and	a5,a0,1
    80001316:	dfdd                	beqz	a5,800012d4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001318:	3ff57793          	and	a5,a0,1023
    8000131c:	fd7784e3          	beq	a5,s7,800012e4 <uvmunmap+0x76>
    if(do_free){
    80001320:	fc0a8ae3          	beqz	s5,800012f4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001324:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001326:	0532                	sll	a0,a0,0xc
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	6bc080e7          	jalr	1724(ra) # 800009e4 <kfree>
    80001330:	b7d1                	j	800012f4 <uvmunmap+0x86>

0000000080001332 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001332:	1101                	add	sp,sp,-32
    80001334:	ec06                	sd	ra,24(sp)
    80001336:	e822                	sd	s0,16(sp)
    80001338:	e426                	sd	s1,8(sp)
    8000133a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133c:	fffff097          	auipc	ra,0xfffff
    80001340:	7a6080e7          	jalr	1958(ra) # 80000ae2 <kalloc>
    80001344:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001346:	c519                	beqz	a0,80001354 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001348:	6605                	lui	a2,0x1
    8000134a:	4581                	li	a1,0
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	982080e7          	jalr	-1662(ra) # 80000cce <memset>
  return pagetable;
}
    80001354:	8526                	mv	a0,s1
    80001356:	60e2                	ld	ra,24(sp)
    80001358:	6442                	ld	s0,16(sp)
    8000135a:	64a2                	ld	s1,8(sp)
    8000135c:	6105                	add	sp,sp,32
    8000135e:	8082                	ret

0000000080001360 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001360:	7179                	add	sp,sp,-48
    80001362:	f406                	sd	ra,40(sp)
    80001364:	f022                	sd	s0,32(sp)
    80001366:	ec26                	sd	s1,24(sp)
    80001368:	e84a                	sd	s2,16(sp)
    8000136a:	e44e                	sd	s3,8(sp)
    8000136c:	e052                	sd	s4,0(sp)
    8000136e:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001370:	6785                	lui	a5,0x1
    80001372:	04f67863          	bgeu	a2,a5,800013c2 <uvmfirst+0x62>
    80001376:	8a2a                	mv	s4,a0
    80001378:	89ae                	mv	s3,a1
    8000137a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000137c:	fffff097          	auipc	ra,0xfffff
    80001380:	766080e7          	jalr	1894(ra) # 80000ae2 <kalloc>
    80001384:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	944080e7          	jalr	-1724(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001392:	4779                	li	a4,30
    80001394:	86ca                	mv	a3,s2
    80001396:	6605                	lui	a2,0x1
    80001398:	4581                	li	a1,0
    8000139a:	8552                	mv	a0,s4
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	d0c080e7          	jalr	-756(ra) # 800010a8 <mappages>
  memmove(mem, src, sz);
    800013a4:	8626                	mv	a2,s1
    800013a6:	85ce                	mv	a1,s3
    800013a8:	854a                	mv	a0,s2
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	980080e7          	jalr	-1664(ra) # 80000d2a <memmove>
}
    800013b2:	70a2                	ld	ra,40(sp)
    800013b4:	7402                	ld	s0,32(sp)
    800013b6:	64e2                	ld	s1,24(sp)
    800013b8:	6942                	ld	s2,16(sp)
    800013ba:	69a2                	ld	s3,8(sp)
    800013bc:	6a02                	ld	s4,0(sp)
    800013be:	6145                	add	sp,sp,48
    800013c0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c2:	00007517          	auipc	a0,0x7
    800013c6:	da650513          	add	a0,a0,-602 # 80008168 <digits+0x128>
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	172080e7          	jalr	370(ra) # 8000053c <panic>

00000000800013d2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d2:	1101                	add	sp,sp,-32
    800013d4:	ec06                	sd	ra,24(sp)
    800013d6:	e822                	sd	s0,16(sp)
    800013d8:	e426                	sd	s1,8(sp)
    800013da:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013dc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013de:	00b67d63          	bgeu	a2,a1,800013f8 <uvmdealloc+0x26>
    800013e2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e4:	6785                	lui	a5,0x1
    800013e6:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013e8:	00f60733          	add	a4,a2,a5
    800013ec:	76fd                	lui	a3,0xfffff
    800013ee:	8f75                	and	a4,a4,a3
    800013f0:	97ae                	add	a5,a5,a1
    800013f2:	8ff5                	and	a5,a5,a3
    800013f4:	00f76863          	bltu	a4,a5,80001404 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f8:	8526                	mv	a0,s1
    800013fa:	60e2                	ld	ra,24(sp)
    800013fc:	6442                	ld	s0,16(sp)
    800013fe:	64a2                	ld	s1,8(sp)
    80001400:	6105                	add	sp,sp,32
    80001402:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001404:	8f99                	sub	a5,a5,a4
    80001406:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001408:	4685                	li	a3,1
    8000140a:	0007861b          	sext.w	a2,a5
    8000140e:	85ba                	mv	a1,a4
    80001410:	00000097          	auipc	ra,0x0
    80001414:	e5e080e7          	jalr	-418(ra) # 8000126e <uvmunmap>
    80001418:	b7c5                	j	800013f8 <uvmdealloc+0x26>

000000008000141a <uvmalloc>:
  if(newsz < oldsz)
    8000141a:	0ab66563          	bltu	a2,a1,800014c4 <uvmalloc+0xaa>
{
    8000141e:	7139                	add	sp,sp,-64
    80001420:	fc06                	sd	ra,56(sp)
    80001422:	f822                	sd	s0,48(sp)
    80001424:	f426                	sd	s1,40(sp)
    80001426:	f04a                	sd	s2,32(sp)
    80001428:	ec4e                	sd	s3,24(sp)
    8000142a:	e852                	sd	s4,16(sp)
    8000142c:	e456                	sd	s5,8(sp)
    8000142e:	e05a                	sd	s6,0(sp)
    80001430:	0080                	add	s0,sp,64
    80001432:	8aaa                	mv	s5,a0
    80001434:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001436:	6785                	lui	a5,0x1
    80001438:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000143a:	95be                	add	a1,a1,a5
    8000143c:	77fd                	lui	a5,0xfffff
    8000143e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001442:	08c9f363          	bgeu	s3,a2,800014c8 <uvmalloc+0xae>
    80001446:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001448:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	696080e7          	jalr	1686(ra) # 80000ae2 <kalloc>
    80001454:	84aa                	mv	s1,a0
    if(mem == 0){
    80001456:	c51d                	beqz	a0,80001484 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001458:	6605                	lui	a2,0x1
    8000145a:	4581                	li	a1,0
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	872080e7          	jalr	-1934(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001464:	875a                	mv	a4,s6
    80001466:	86a6                	mv	a3,s1
    80001468:	6605                	lui	a2,0x1
    8000146a:	85ca                	mv	a1,s2
    8000146c:	8556                	mv	a0,s5
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	c3a080e7          	jalr	-966(ra) # 800010a8 <mappages>
    80001476:	e90d                	bnez	a0,800014a8 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001478:	6785                	lui	a5,0x1
    8000147a:	993e                	add	s2,s2,a5
    8000147c:	fd4968e3          	bltu	s2,s4,8000144c <uvmalloc+0x32>
  return newsz;
    80001480:	8552                	mv	a0,s4
    80001482:	a809                	j	80001494 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001484:	864e                	mv	a2,s3
    80001486:	85ca                	mv	a1,s2
    80001488:	8556                	mv	a0,s5
    8000148a:	00000097          	auipc	ra,0x0
    8000148e:	f48080e7          	jalr	-184(ra) # 800013d2 <uvmdealloc>
      return 0;
    80001492:	4501                	li	a0,0
}
    80001494:	70e2                	ld	ra,56(sp)
    80001496:	7442                	ld	s0,48(sp)
    80001498:	74a2                	ld	s1,40(sp)
    8000149a:	7902                	ld	s2,32(sp)
    8000149c:	69e2                	ld	s3,24(sp)
    8000149e:	6a42                	ld	s4,16(sp)
    800014a0:	6aa2                	ld	s5,8(sp)
    800014a2:	6b02                	ld	s6,0(sp)
    800014a4:	6121                	add	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	53a080e7          	jalr	1338(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f1a080e7          	jalr	-230(ra) # 800013d2 <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfc9                	j	80001494 <uvmalloc+0x7a>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7e9                	j	80001494 <uvmalloc+0x7a>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	add	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	add	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a829                	j	80001500 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014ea:	00c79513          	sll	a0,a5,0xc
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	fde080e7          	jalr	-34(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014fa:	04a1                	add	s1,s1,8
    800014fc:	03248163          	beq	s1,s2,8000151e <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001500:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001502:	00f7f713          	and	a4,a5,15
    80001506:	ff3701e3          	beq	a4,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000150a:	8b85                	and	a5,a5,1
    8000150c:	d7fd                	beqz	a5,800014fa <freewalk+0x2e>
      panic("freewalk: leaf");
    8000150e:	00007517          	auipc	a0,0x7
    80001512:	c7a50513          	add	a0,a0,-902 # 80008188 <digits+0x148>
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	026080e7          	jalr	38(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000151e:	8552                	mv	a0,s4
    80001520:	fffff097          	auipc	ra,0xfffff
    80001524:	4c4080e7          	jalr	1220(ra) # 800009e4 <kfree>
}
    80001528:	70a2                	ld	ra,40(sp)
    8000152a:	7402                	ld	s0,32(sp)
    8000152c:	64e2                	ld	s1,24(sp)
    8000152e:	6942                	ld	s2,16(sp)
    80001530:	69a2                	ld	s3,8(sp)
    80001532:	6a02                	ld	s4,0(sp)
    80001534:	6145                	add	sp,sp,48
    80001536:	8082                	ret

0000000080001538 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001538:	1101                	add	sp,sp,-32
    8000153a:	ec06                	sd	ra,24(sp)
    8000153c:	e822                	sd	s0,16(sp)
    8000153e:	e426                	sd	s1,8(sp)
    80001540:	1000                	add	s0,sp,32
    80001542:	84aa                	mv	s1,a0
  if(sz > 0)
    80001544:	e999                	bnez	a1,8000155a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001546:	8526                	mv	a0,s1
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	f84080e7          	jalr	-124(ra) # 800014cc <freewalk>
}
    80001550:	60e2                	ld	ra,24(sp)
    80001552:	6442                	ld	s0,16(sp)
    80001554:	64a2                	ld	s1,8(sp)
    80001556:	6105                	add	sp,sp,32
    80001558:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000155a:	6785                	lui	a5,0x1
    8000155c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000155e:	95be                	add	a1,a1,a5
    80001560:	4685                	li	a3,1
    80001562:	00c5d613          	srl	a2,a1,0xc
    80001566:	4581                	li	a1,0
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	d06080e7          	jalr	-762(ra) # 8000126e <uvmunmap>
    80001570:	bfd9                	j	80001546 <uvmfree+0xe>

0000000080001572 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001572:	c679                	beqz	a2,80001640 <uvmcopy+0xce>
{
    80001574:	715d                	add	sp,sp,-80
    80001576:	e486                	sd	ra,72(sp)
    80001578:	e0a2                	sd	s0,64(sp)
    8000157a:	fc26                	sd	s1,56(sp)
    8000157c:	f84a                	sd	s2,48(sp)
    8000157e:	f44e                	sd	s3,40(sp)
    80001580:	f052                	sd	s4,32(sp)
    80001582:	ec56                	sd	s5,24(sp)
    80001584:	e85a                	sd	s6,16(sp)
    80001586:	e45e                	sd	s7,8(sp)
    80001588:	0880                	add	s0,sp,80
    8000158a:	8b2a                	mv	s6,a0
    8000158c:	8aae                	mv	s5,a1
    8000158e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001590:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001592:	4601                	li	a2,0
    80001594:	85ce                	mv	a1,s3
    80001596:	855a                	mv	a0,s6
    80001598:	00000097          	auipc	ra,0x0
    8000159c:	a28080e7          	jalr	-1496(ra) # 80000fc0 <walk>
    800015a0:	c531                	beqz	a0,800015ec <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015a2:	6118                	ld	a4,0(a0)
    800015a4:	00177793          	and	a5,a4,1
    800015a8:	cbb1                	beqz	a5,800015fc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015aa:	00a75593          	srl	a1,a4,0xa
    800015ae:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015b2:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	52c080e7          	jalr	1324(ra) # 80000ae2 <kalloc>
    800015be:	892a                	mv	s2,a0
    800015c0:	c939                	beqz	a0,80001616 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85de                	mv	a1,s7
    800015c6:	fffff097          	auipc	ra,0xfffff
    800015ca:	764080e7          	jalr	1892(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ce:	8726                	mv	a4,s1
    800015d0:	86ca                	mv	a3,s2
    800015d2:	6605                	lui	a2,0x1
    800015d4:	85ce                	mv	a1,s3
    800015d6:	8556                	mv	a0,s5
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	ad0080e7          	jalr	-1328(ra) # 800010a8 <mappages>
    800015e0:	e515                	bnez	a0,8000160c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015e2:	6785                	lui	a5,0x1
    800015e4:	99be                	add	s3,s3,a5
    800015e6:	fb49e6e3          	bltu	s3,s4,80001592 <uvmcopy+0x20>
    800015ea:	a081                	j	8000162a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bac50513          	add	a0,a0,-1108 # 80008198 <digits+0x158>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015fc:	00007517          	auipc	a0,0x7
    80001600:	bbc50513          	add	a0,a0,-1092 # 800081b8 <digits+0x178>
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	f38080e7          	jalr	-200(ra) # 8000053c <panic>
      kfree(mem);
    8000160c:	854a                	mv	a0,s2
    8000160e:	fffff097          	auipc	ra,0xfffff
    80001612:	3d6080e7          	jalr	982(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001616:	4685                	li	a3,1
    80001618:	00c9d613          	srl	a2,s3,0xc
    8000161c:	4581                	li	a1,0
    8000161e:	8556                	mv	a0,s5
    80001620:	00000097          	auipc	ra,0x0
    80001624:	c4e080e7          	jalr	-946(ra) # 8000126e <uvmunmap>
  return -1;
    80001628:	557d                	li	a0,-1
}
    8000162a:	60a6                	ld	ra,72(sp)
    8000162c:	6406                	ld	s0,64(sp)
    8000162e:	74e2                	ld	s1,56(sp)
    80001630:	7942                	ld	s2,48(sp)
    80001632:	79a2                	ld	s3,40(sp)
    80001634:	7a02                	ld	s4,32(sp)
    80001636:	6ae2                	ld	s5,24(sp)
    80001638:	6b42                	ld	s6,16(sp)
    8000163a:	6ba2                	ld	s7,8(sp)
    8000163c:	6161                	add	sp,sp,80
    8000163e:	8082                	ret
  return 0;
    80001640:	4501                	li	a0,0
}
    80001642:	8082                	ret

0000000080001644 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001644:	1141                	add	sp,sp,-16
    80001646:	e406                	sd	ra,8(sp)
    80001648:	e022                	sd	s0,0(sp)
    8000164a:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000164c:	4601                	li	a2,0
    8000164e:	00000097          	auipc	ra,0x0
    80001652:	972080e7          	jalr	-1678(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001656:	c901                	beqz	a0,80001666 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001658:	611c                	ld	a5,0(a0)
    8000165a:	9bbd                	and	a5,a5,-17
    8000165c:	e11c                	sd	a5,0(a0)
}
    8000165e:	60a2                	ld	ra,8(sp)
    80001660:	6402                	ld	s0,0(sp)
    80001662:	0141                	add	sp,sp,16
    80001664:	8082                	ret
    panic("uvmclear");
    80001666:	00007517          	auipc	a0,0x7
    8000166a:	b7250513          	add	a0,a0,-1166 # 800081d8 <digits+0x198>
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	ece080e7          	jalr	-306(ra) # 8000053c <panic>

0000000080001676 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001676:	c6bd                	beqz	a3,800016e4 <copyout+0x6e>
{
    80001678:	715d                	add	sp,sp,-80
    8000167a:	e486                	sd	ra,72(sp)
    8000167c:	e0a2                	sd	s0,64(sp)
    8000167e:	fc26                	sd	s1,56(sp)
    80001680:	f84a                	sd	s2,48(sp)
    80001682:	f44e                	sd	s3,40(sp)
    80001684:	f052                	sd	s4,32(sp)
    80001686:	ec56                	sd	s5,24(sp)
    80001688:	e85a                	sd	s6,16(sp)
    8000168a:	e45e                	sd	s7,8(sp)
    8000168c:	e062                	sd	s8,0(sp)
    8000168e:	0880                	add	s0,sp,80
    80001690:	8b2a                	mv	s6,a0
    80001692:	8c2e                	mv	s8,a1
    80001694:	8a32                	mv	s4,a2
    80001696:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001698:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000169a:	6a85                	lui	s5,0x1
    8000169c:	a015                	j	800016c0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169e:	9562                	add	a0,a0,s8
    800016a0:	0004861b          	sext.w	a2,s1
    800016a4:	85d2                	mv	a1,s4
    800016a6:	41250533          	sub	a0,a0,s2
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	680080e7          	jalr	1664(ra) # 80000d2a <memmove>

    len -= n;
    800016b2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016bc:	02098263          	beqz	s3,800016e0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016c0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c4:	85ca                	mv	a1,s2
    800016c6:	855a                	mv	a0,s6
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	99e080e7          	jalr	-1634(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800016d0:	cd01                	beqz	a0,800016e8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016d2:	418904b3          	sub	s1,s2,s8
    800016d6:	94d6                	add	s1,s1,s5
    800016d8:	fc99f3e3          	bgeu	s3,s1,8000169e <copyout+0x28>
    800016dc:	84ce                	mv	s1,s3
    800016de:	b7c1                	j	8000169e <copyout+0x28>
  }
  return 0;
    800016e0:	4501                	li	a0,0
    800016e2:	a021                	j	800016ea <copyout+0x74>
    800016e4:	4501                	li	a0,0
}
    800016e6:	8082                	ret
      return -1;
    800016e8:	557d                	li	a0,-1
}
    800016ea:	60a6                	ld	ra,72(sp)
    800016ec:	6406                	ld	s0,64(sp)
    800016ee:	74e2                	ld	s1,56(sp)
    800016f0:	7942                	ld	s2,48(sp)
    800016f2:	79a2                	ld	s3,40(sp)
    800016f4:	7a02                	ld	s4,32(sp)
    800016f6:	6ae2                	ld	s5,24(sp)
    800016f8:	6b42                	ld	s6,16(sp)
    800016fa:	6ba2                	ld	s7,8(sp)
    800016fc:	6c02                	ld	s8,0(sp)
    800016fe:	6161                	add	sp,sp,80
    80001700:	8082                	ret

0000000080001702 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001702:	caa5                	beqz	a3,80001772 <copyin+0x70>
{
    80001704:	715d                	add	sp,sp,-80
    80001706:	e486                	sd	ra,72(sp)
    80001708:	e0a2                	sd	s0,64(sp)
    8000170a:	fc26                	sd	s1,56(sp)
    8000170c:	f84a                	sd	s2,48(sp)
    8000170e:	f44e                	sd	s3,40(sp)
    80001710:	f052                	sd	s4,32(sp)
    80001712:	ec56                	sd	s5,24(sp)
    80001714:	e85a                	sd	s6,16(sp)
    80001716:	e45e                	sd	s7,8(sp)
    80001718:	e062                	sd	s8,0(sp)
    8000171a:	0880                	add	s0,sp,80
    8000171c:	8b2a                	mv	s6,a0
    8000171e:	8a2e                	mv	s4,a1
    80001720:	8c32                	mv	s8,a2
    80001722:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001724:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001726:	6a85                	lui	s5,0x1
    80001728:	a01d                	j	8000174e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000172a:	018505b3          	add	a1,a0,s8
    8000172e:	0004861b          	sext.w	a2,s1
    80001732:	412585b3          	sub	a1,a1,s2
    80001736:	8552                	mv	a0,s4
    80001738:	fffff097          	auipc	ra,0xfffff
    8000173c:	5f2080e7          	jalr	1522(ra) # 80000d2a <memmove>

    len -= n;
    80001740:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001744:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001746:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000174a:	02098263          	beqz	s3,8000176e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000174e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001752:	85ca                	mv	a1,s2
    80001754:	855a                	mv	a0,s6
    80001756:	00000097          	auipc	ra,0x0
    8000175a:	910080e7          	jalr	-1776(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    8000175e:	cd01                	beqz	a0,80001776 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001760:	418904b3          	sub	s1,s2,s8
    80001764:	94d6                	add	s1,s1,s5
    80001766:	fc99f2e3          	bgeu	s3,s1,8000172a <copyin+0x28>
    8000176a:	84ce                	mv	s1,s3
    8000176c:	bf7d                	j	8000172a <copyin+0x28>
  }
  return 0;
    8000176e:	4501                	li	a0,0
    80001770:	a021                	j	80001778 <copyin+0x76>
    80001772:	4501                	li	a0,0
}
    80001774:	8082                	ret
      return -1;
    80001776:	557d                	li	a0,-1
}
    80001778:	60a6                	ld	ra,72(sp)
    8000177a:	6406                	ld	s0,64(sp)
    8000177c:	74e2                	ld	s1,56(sp)
    8000177e:	7942                	ld	s2,48(sp)
    80001780:	79a2                	ld	s3,40(sp)
    80001782:	7a02                	ld	s4,32(sp)
    80001784:	6ae2                	ld	s5,24(sp)
    80001786:	6b42                	ld	s6,16(sp)
    80001788:	6ba2                	ld	s7,8(sp)
    8000178a:	6c02                	ld	s8,0(sp)
    8000178c:	6161                	add	sp,sp,80
    8000178e:	8082                	ret

0000000080001790 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001790:	c2dd                	beqz	a3,80001836 <copyinstr+0xa6>
{
    80001792:	715d                	add	sp,sp,-80
    80001794:	e486                	sd	ra,72(sp)
    80001796:	e0a2                	sd	s0,64(sp)
    80001798:	fc26                	sd	s1,56(sp)
    8000179a:	f84a                	sd	s2,48(sp)
    8000179c:	f44e                	sd	s3,40(sp)
    8000179e:	f052                	sd	s4,32(sp)
    800017a0:	ec56                	sd	s5,24(sp)
    800017a2:	e85a                	sd	s6,16(sp)
    800017a4:	e45e                	sd	s7,8(sp)
    800017a6:	0880                	add	s0,sp,80
    800017a8:	8a2a                	mv	s4,a0
    800017aa:	8b2e                	mv	s6,a1
    800017ac:	8bb2                	mv	s7,a2
    800017ae:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017b0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017b2:	6985                	lui	s3,0x1
    800017b4:	a02d                	j	800017de <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ba:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017bc:	37fd                	addw	a5,a5,-1
    800017be:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017c2:	60a6                	ld	ra,72(sp)
    800017c4:	6406                	ld	s0,64(sp)
    800017c6:	74e2                	ld	s1,56(sp)
    800017c8:	7942                	ld	s2,48(sp)
    800017ca:	79a2                	ld	s3,40(sp)
    800017cc:	7a02                	ld	s4,32(sp)
    800017ce:	6ae2                	ld	s5,24(sp)
    800017d0:	6b42                	ld	s6,16(sp)
    800017d2:	6ba2                	ld	s7,8(sp)
    800017d4:	6161                	add	sp,sp,80
    800017d6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017dc:	c8a9                	beqz	s1,8000182e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017de:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017e2:	85ca                	mv	a1,s2
    800017e4:	8552                	mv	a0,s4
    800017e6:	00000097          	auipc	ra,0x0
    800017ea:	880080e7          	jalr	-1920(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800017ee:	c131                	beqz	a0,80001832 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017f0:	417906b3          	sub	a3,s2,s7
    800017f4:	96ce                	add	a3,a3,s3
    800017f6:	00d4f363          	bgeu	s1,a3,800017fc <copyinstr+0x6c>
    800017fa:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017fc:	955e                	add	a0,a0,s7
    800017fe:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001802:	daf9                	beqz	a3,800017d8 <copyinstr+0x48>
    80001804:	87da                	mv	a5,s6
    80001806:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001808:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000180c:	96da                	add	a3,a3,s6
    8000180e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001810:	00f60733          	add	a4,a2,a5
    80001814:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdccc8>
    80001818:	df59                	beqz	a4,800017b6 <copyinstr+0x26>
        *dst = *p;
    8000181a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000181e:	0785                	add	a5,a5,1
    while(n > 0){
    80001820:	fed797e3          	bne	a5,a3,8000180e <copyinstr+0x7e>
    80001824:	14fd                	add	s1,s1,-1
    80001826:	94c2                	add	s1,s1,a6
      --max;
    80001828:	8c8d                	sub	s1,s1,a1
      dst++;
    8000182a:	8b3e                	mv	s6,a5
    8000182c:	b775                	j	800017d8 <copyinstr+0x48>
    8000182e:	4781                	li	a5,0
    80001830:	b771                	j	800017bc <copyinstr+0x2c>
      return -1;
    80001832:	557d                	li	a0,-1
    80001834:	b779                	j	800017c2 <copyinstr+0x32>
  int got_null = 0;
    80001836:	4781                	li	a5,0
  if(got_null){
    80001838:	37fd                	addw	a5,a5,-1
    8000183a:	0007851b          	sext.w	a0,a5
}
    8000183e:	8082                	ret

0000000080001840 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001840:	7139                	add	sp,sp,-64
    80001842:	fc06                	sd	ra,56(sp)
    80001844:	f822                	sd	s0,48(sp)
    80001846:	f426                	sd	s1,40(sp)
    80001848:	f04a                	sd	s2,32(sp)
    8000184a:	ec4e                	sd	s3,24(sp)
    8000184c:	e852                	sd	s4,16(sp)
    8000184e:	e456                	sd	s5,8(sp)
    80001850:	e05a                	sd	s6,0(sp)
    80001852:	0080                	add	s0,sp,64
    80001854:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001856:	0000f497          	auipc	s1,0xf
    8000185a:	6ea48493          	add	s1,s1,1770 # 80010f40 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000185e:	8b26                	mv	s6,s1
    80001860:	00006a97          	auipc	s5,0x6
    80001864:	7a0a8a93          	add	s5,s5,1952 # 80008000 <etext>
    80001868:	04000937          	lui	s2,0x4000
    8000186c:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000186e:	0932                	sll	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001870:	00015a17          	auipc	s4,0x15
    80001874:	6d0a0a13          	add	s4,s4,1744 # 80016f40 <tickslock>
    char *pa = kalloc();
    80001878:	fffff097          	auipc	ra,0xfffff
    8000187c:	26a080e7          	jalr	618(ra) # 80000ae2 <kalloc>
    80001880:	862a                	mv	a2,a0
    if (pa == 0)
    80001882:	c131                	beqz	a0,800018c6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001884:	416485b3          	sub	a1,s1,s6
    80001888:	859d                	sra	a1,a1,0x7
    8000188a:	000ab783          	ld	a5,0(s5)
    8000188e:	02f585b3          	mul	a1,a1,a5
    80001892:	2585                	addw	a1,a1,1
    80001894:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001898:	4719                	li	a4,6
    8000189a:	6685                	lui	a3,0x1
    8000189c:	40b905b3          	sub	a1,s2,a1
    800018a0:	854e                	mv	a0,s3
    800018a2:	00000097          	auipc	ra,0x0
    800018a6:	8a6080e7          	jalr	-1882(ra) # 80001148 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018aa:	18048493          	add	s1,s1,384
    800018ae:	fd4495e3          	bne	s1,s4,80001878 <proc_mapstacks+0x38>
  }
}
    800018b2:	70e2                	ld	ra,56(sp)
    800018b4:	7442                	ld	s0,48(sp)
    800018b6:	74a2                	ld	s1,40(sp)
    800018b8:	7902                	ld	s2,32(sp)
    800018ba:	69e2                	ld	s3,24(sp)
    800018bc:	6a42                	ld	s4,16(sp)
    800018be:	6aa2                	ld	s5,8(sp)
    800018c0:	6b02                	ld	s6,0(sp)
    800018c2:	6121                	add	sp,sp,64
    800018c4:	8082                	ret
      panic("kalloc");
    800018c6:	00007517          	auipc	a0,0x7
    800018ca:	92250513          	add	a0,a0,-1758 # 800081e8 <digits+0x1a8>
    800018ce:	fffff097          	auipc	ra,0xfffff
    800018d2:	c6e080e7          	jalr	-914(ra) # 8000053c <panic>

00000000800018d6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018d6:	7139                	add	sp,sp,-64
    800018d8:	fc06                	sd	ra,56(sp)
    800018da:	f822                	sd	s0,48(sp)
    800018dc:	f426                	sd	s1,40(sp)
    800018de:	f04a                	sd	s2,32(sp)
    800018e0:	ec4e                	sd	s3,24(sp)
    800018e2:	e852                	sd	s4,16(sp)
    800018e4:	e456                	sd	s5,8(sp)
    800018e6:	e05a                	sd	s6,0(sp)
    800018e8:	0080                	add	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018ea:	00007597          	auipc	a1,0x7
    800018ee:	90658593          	add	a1,a1,-1786 # 800081f0 <digits+0x1b0>
    800018f2:	0000f517          	auipc	a0,0xf
    800018f6:	21e50513          	add	a0,a0,542 # 80010b10 <pid_lock>
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	248080e7          	jalr	584(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001902:	00007597          	auipc	a1,0x7
    80001906:	8f658593          	add	a1,a1,-1802 # 800081f8 <digits+0x1b8>
    8000190a:	0000f517          	auipc	a0,0xf
    8000190e:	21e50513          	add	a0,a0,542 # 80010b28 <wait_lock>
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	230080e7          	jalr	560(ra) # 80000b42 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000191a:	0000f497          	auipc	s1,0xf
    8000191e:	62648493          	add	s1,s1,1574 # 80010f40 <proc>
  {
    initlock(&p->lock, "proc");
    80001922:	00007b17          	auipc	s6,0x7
    80001926:	8e6b0b13          	add	s6,s6,-1818 # 80008208 <digits+0x1c8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000192a:	8aa6                	mv	s5,s1
    8000192c:	00006a17          	auipc	s4,0x6
    80001930:	6d4a0a13          	add	s4,s4,1748 # 80008000 <etext>
    80001934:	04000937          	lui	s2,0x4000
    80001938:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000193a:	0932                	sll	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000193c:	00015997          	auipc	s3,0x15
    80001940:	60498993          	add	s3,s3,1540 # 80016f40 <tickslock>
    initlock(&p->lock, "proc");
    80001944:	85da                	mv	a1,s6
    80001946:	8526                	mv	a0,s1
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	1fa080e7          	jalr	506(ra) # 80000b42 <initlock>
    p->state = UNUSED;
    80001950:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001954:	415487b3          	sub	a5,s1,s5
    80001958:	879d                	sra	a5,a5,0x7
    8000195a:	000a3703          	ld	a4,0(s4)
    8000195e:	02e787b3          	mul	a5,a5,a4
    80001962:	2785                	addw	a5,a5,1
    80001964:	00d7979b          	sllw	a5,a5,0xd
    80001968:	40f907b3          	sub	a5,s2,a5
    8000196c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000196e:	18048493          	add	s1,s1,384
    80001972:	fd3499e3          	bne	s1,s3,80001944 <procinit+0x6e>
  }
}
    80001976:	70e2                	ld	ra,56(sp)
    80001978:	7442                	ld	s0,48(sp)
    8000197a:	74a2                	ld	s1,40(sp)
    8000197c:	7902                	ld	s2,32(sp)
    8000197e:	69e2                	ld	s3,24(sp)
    80001980:	6a42                	ld	s4,16(sp)
    80001982:	6aa2                	ld	s5,8(sp)
    80001984:	6b02                	ld	s6,0(sp)
    80001986:	6121                	add	sp,sp,64
    80001988:	8082                	ret

000000008000198a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000198a:	1141                	add	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001990:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001992:	2501                	sext.w	a0,a0
    80001994:	6422                	ld	s0,8(sp)
    80001996:	0141                	add	sp,sp,16
    80001998:	8082                	ret

000000008000199a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000199a:	1141                	add	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	add	s0,sp,16
    800019a0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a2:	2781                	sext.w	a5,a5
    800019a4:	079e                	sll	a5,a5,0x7
  return c;
}
    800019a6:	0000f517          	auipc	a0,0xf
    800019aa:	19a50513          	add	a0,a0,410 # 80010b40 <cpus>
    800019ae:	953e                	add	a0,a0,a5
    800019b0:	6422                	ld	s0,8(sp)
    800019b2:	0141                	add	sp,sp,16
    800019b4:	8082                	ret

00000000800019b6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019b6:	1101                	add	sp,sp,-32
    800019b8:	ec06                	sd	ra,24(sp)
    800019ba:	e822                	sd	s0,16(sp)
    800019bc:	e426                	sd	s1,8(sp)
    800019be:	1000                	add	s0,sp,32
  push_off();
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	1c6080e7          	jalr	454(ra) # 80000b86 <push_off>
    800019c8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ca:	2781                	sext.w	a5,a5
    800019cc:	079e                	sll	a5,a5,0x7
    800019ce:	0000f717          	auipc	a4,0xf
    800019d2:	14270713          	add	a4,a4,322 # 80010b10 <pid_lock>
    800019d6:	97ba                	add	a5,a5,a4
    800019d8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	24c080e7          	jalr	588(ra) # 80000c26 <pop_off>
  return p;
}
    800019e2:	8526                	mv	a0,s1
    800019e4:	60e2                	ld	ra,24(sp)
    800019e6:	6442                	ld	s0,16(sp)
    800019e8:	64a2                	ld	s1,8(sp)
    800019ea:	6105                	add	sp,sp,32
    800019ec:	8082                	ret

00000000800019ee <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019ee:	1141                	add	sp,sp,-16
    800019f0:	e406                	sd	ra,8(sp)
    800019f2:	e022                	sd	s0,0(sp)
    800019f4:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f6:	00000097          	auipc	ra,0x0
    800019fa:	fc0080e7          	jalr	-64(ra) # 800019b6 <myproc>
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	288080e7          	jalr	648(ra) # 80000c86 <release>

  if (first)
    80001a06:	00007797          	auipc	a5,0x7
    80001a0a:	e0a7a783          	lw	a5,-502(a5) # 80008810 <first.1>
    80001a0e:	eb89                	bnez	a5,80001a20 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a10:	00001097          	auipc	ra,0x1
    80001a14:	ea6080e7          	jalr	-346(ra) # 800028b6 <usertrapret>
}
    80001a18:	60a2                	ld	ra,8(sp)
    80001a1a:	6402                	ld	s0,0(sp)
    80001a1c:	0141                	add	sp,sp,16
    80001a1e:	8082                	ret
    first = 0;
    80001a20:	00007797          	auipc	a5,0x7
    80001a24:	de07a823          	sw	zero,-528(a5) # 80008810 <first.1>
    fsinit(ROOTDEV);
    80001a28:	4505                	li	a0,1
    80001a2a:	00002097          	auipc	ra,0x2
    80001a2e:	d18080e7          	jalr	-744(ra) # 80003742 <fsinit>
    80001a32:	bff9                	j	80001a10 <forkret+0x22>

0000000080001a34 <allocpid>:
{
    80001a34:	1101                	add	sp,sp,-32
    80001a36:	ec06                	sd	ra,24(sp)
    80001a38:	e822                	sd	s0,16(sp)
    80001a3a:	e426                	sd	s1,8(sp)
    80001a3c:	e04a                	sd	s2,0(sp)
    80001a3e:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a40:	0000f917          	auipc	s2,0xf
    80001a44:	0d090913          	add	s2,s2,208 # 80010b10 <pid_lock>
    80001a48:	854a                	mv	a0,s2
    80001a4a:	fffff097          	auipc	ra,0xfffff
    80001a4e:	188080e7          	jalr	392(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a52:	00007797          	auipc	a5,0x7
    80001a56:	dc278793          	add	a5,a5,-574 # 80008814 <nextpid>
    80001a5a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a5c:	0014871b          	addw	a4,s1,1
    80001a60:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a62:	854a                	mv	a0,s2
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	222080e7          	jalr	546(ra) # 80000c86 <release>
}
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	60e2                	ld	ra,24(sp)
    80001a70:	6442                	ld	s0,16(sp)
    80001a72:	64a2                	ld	s1,8(sp)
    80001a74:	6902                	ld	s2,0(sp)
    80001a76:	6105                	add	sp,sp,32
    80001a78:	8082                	ret

0000000080001a7a <proc_pagetable>:
{
    80001a7a:	1101                	add	sp,sp,-32
    80001a7c:	ec06                	sd	ra,24(sp)
    80001a7e:	e822                	sd	s0,16(sp)
    80001a80:	e426                	sd	s1,8(sp)
    80001a82:	e04a                	sd	s2,0(sp)
    80001a84:	1000                	add	s0,sp,32
    80001a86:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a88:	00000097          	auipc	ra,0x0
    80001a8c:	8aa080e7          	jalr	-1878(ra) # 80001332 <uvmcreate>
    80001a90:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a92:	c121                	beqz	a0,80001ad2 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a94:	4729                	li	a4,10
    80001a96:	00005697          	auipc	a3,0x5
    80001a9a:	56a68693          	add	a3,a3,1386 # 80007000 <_trampoline>
    80001a9e:	6605                	lui	a2,0x1
    80001aa0:	040005b7          	lui	a1,0x4000
    80001aa4:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa6:	05b2                	sll	a1,a1,0xc
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	600080e7          	jalr	1536(ra) # 800010a8 <mappages>
    80001ab0:	02054863          	bltz	a0,80001ae0 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ab4:	4719                	li	a4,6
    80001ab6:	05893683          	ld	a3,88(s2)
    80001aba:	6605                	lui	a2,0x1
    80001abc:	020005b7          	lui	a1,0x2000
    80001ac0:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac2:	05b6                	sll	a1,a1,0xd
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	5e2080e7          	jalr	1506(ra) # 800010a8 <mappages>
    80001ace:	02054163          	bltz	a0,80001af0 <proc_pagetable+0x76>
}
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6902                	ld	s2,0(sp)
    80001adc:	6105                	add	sp,sp,32
    80001ade:	8082                	ret
    uvmfree(pagetable, 0);
    80001ae0:	4581                	li	a1,0
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	00000097          	auipc	ra,0x0
    80001ae8:	a54080e7          	jalr	-1452(ra) # 80001538 <uvmfree>
    return 0;
    80001aec:	4481                	li	s1,0
    80001aee:	b7d5                	j	80001ad2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001af0:	4681                	li	a3,0
    80001af2:	4605                	li	a2,1
    80001af4:	040005b7          	lui	a1,0x4000
    80001af8:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001afa:	05b2                	sll	a1,a1,0xc
    80001afc:	8526                	mv	a0,s1
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	770080e7          	jalr	1904(ra) # 8000126e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b06:	4581                	li	a1,0
    80001b08:	8526                	mv	a0,s1
    80001b0a:	00000097          	auipc	ra,0x0
    80001b0e:	a2e080e7          	jalr	-1490(ra) # 80001538 <uvmfree>
    return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	bf7d                	j	80001ad2 <proc_pagetable+0x58>

0000000080001b16 <proc_freepagetable>:
{
    80001b16:	1101                	add	sp,sp,-32
    80001b18:	ec06                	sd	ra,24(sp)
    80001b1a:	e822                	sd	s0,16(sp)
    80001b1c:	e426                	sd	s1,8(sp)
    80001b1e:	e04a                	sd	s2,0(sp)
    80001b20:	1000                	add	s0,sp,32
    80001b22:	84aa                	mv	s1,a0
    80001b24:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b26:	4681                	li	a3,0
    80001b28:	4605                	li	a2,1
    80001b2a:	040005b7          	lui	a1,0x4000
    80001b2e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b30:	05b2                	sll	a1,a1,0xc
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	73c080e7          	jalr	1852(ra) # 8000126e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	020005b7          	lui	a1,0x2000
    80001b42:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b44:	05b6                	sll	a1,a1,0xd
    80001b46:	8526                	mv	a0,s1
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	726080e7          	jalr	1830(ra) # 8000126e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b50:	85ca                	mv	a1,s2
    80001b52:	8526                	mv	a0,s1
    80001b54:	00000097          	auipc	ra,0x0
    80001b58:	9e4080e7          	jalr	-1564(ra) # 80001538 <uvmfree>
}
    80001b5c:	60e2                	ld	ra,24(sp)
    80001b5e:	6442                	ld	s0,16(sp)
    80001b60:	64a2                	ld	s1,8(sp)
    80001b62:	6902                	ld	s2,0(sp)
    80001b64:	6105                	add	sp,sp,32
    80001b66:	8082                	ret

0000000080001b68 <freeproc>:
{
    80001b68:	1101                	add	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	1000                	add	s0,sp,32
    80001b72:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b74:	6d28                	ld	a0,88(a0)
    80001b76:	c509                	beqz	a0,80001b80 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	e6c080e7          	jalr	-404(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b80:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b84:	68a8                	ld	a0,80(s1)
    80001b86:	c511                	beqz	a0,80001b92 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b88:	64ac                	ld	a1,72(s1)
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	f8c080e7          	jalr	-116(ra) # 80001b16 <proc_freepagetable>
  p->pagetable = 0;
    80001b92:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b96:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b9a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001baa:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bae:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb2:	0004ac23          	sw	zero,24(s1)
}
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6105                	add	sp,sp,32
    80001bbe:	8082                	ret

0000000080001bc0 <allocproc>:
{
    80001bc0:	1101                	add	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	e426                	sd	s1,8(sp)
    80001bc8:	e04a                	sd	s2,0(sp)
    80001bca:	1000                	add	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bcc:	0000f497          	auipc	s1,0xf
    80001bd0:	37448493          	add	s1,s1,884 # 80010f40 <proc>
    80001bd4:	00015917          	auipc	s2,0x15
    80001bd8:	36c90913          	add	s2,s2,876 # 80016f40 <tickslock>
    acquire(&p->lock);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	ff4080e7          	jalr	-12(ra) # 80000bd2 <acquire>
    if (p->state == UNUSED)
    80001be6:	4c9c                	lw	a5,24(s1)
    80001be8:	cf81                	beqz	a5,80001c00 <allocproc+0x40>
      release(&p->lock);
    80001bea:	8526                	mv	a0,s1
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	09a080e7          	jalr	154(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf4:	18048493          	add	s1,s1,384
    80001bf8:	ff2492e3          	bne	s1,s2,80001bdc <allocproc+0x1c>
  return 0;
    80001bfc:	4481                	li	s1,0
    80001bfe:	a88d                	j	80001c70 <allocproc+0xb0>
  p->pid = allocpid();
    80001c00:	00000097          	auipc	ra,0x0
    80001c04:	e34080e7          	jalr	-460(ra) # 80001a34 <allocpid>
    80001c08:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c0a:	4785                	li	a5,1
    80001c0c:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	ed4080e7          	jalr	-300(ra) # 80000ae2 <kalloc>
    80001c16:	892a                	mv	s2,a0
    80001c18:	eca8                	sd	a0,88(s1)
    80001c1a:	c135                	beqz	a0,80001c7e <allocproc+0xbe>
  p->pagetable = proc_pagetable(p);
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	e5c080e7          	jalr	-420(ra) # 80001a7a <proc_pagetable>
    80001c26:	892a                	mv	s2,a0
    80001c28:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c2a:	c535                	beqz	a0,80001c96 <allocproc+0xd6>
  memset(&p->context, 0, sizeof(p->context));
    80001c2c:	07000613          	li	a2,112
    80001c30:	4581                	li	a1,0
    80001c32:	06048513          	add	a0,s1,96
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	098080e7          	jalr	152(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c3e:	00000797          	auipc	a5,0x0
    80001c42:	db078793          	add	a5,a5,-592 # 800019ee <forkret>
    80001c46:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c48:	60bc                	ld	a5,64(s1)
    80001c4a:	6705                	lui	a4,0x1
    80001c4c:	97ba                	add	a5,a5,a4
    80001c4e:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c50:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c54:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c58:	00007797          	auipc	a5,0x7
    80001c5c:	c487a783          	lw	a5,-952(a5) # 800088a0 <ticks>
    80001c60:	16f4a623          	sw	a5,364(s1)
  p->priority = 0;    // assign the highest priority when process is spawned
    80001c64:	1604aa23          	sw	zero,372(s1)
  p->entry = ticks;   // has joined the queue at this point of time
    80001c68:	16f4ac23          	sw	a5,376(s1)
  p->wait = 0;       // hasn't really waited at all
    80001c6c:	1604ae23          	sw	zero,380(s1)
}
    80001c70:	8526                	mv	a0,s1
    80001c72:	60e2                	ld	ra,24(sp)
    80001c74:	6442                	ld	s0,16(sp)
    80001c76:	64a2                	ld	s1,8(sp)
    80001c78:	6902                	ld	s2,0(sp)
    80001c7a:	6105                	add	sp,sp,32
    80001c7c:	8082                	ret
    freeproc(p);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	ee8080e7          	jalr	-280(ra) # 80001b68 <freeproc>
    release(&p->lock);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	ffc080e7          	jalr	-4(ra) # 80000c86 <release>
    return 0;
    80001c92:	84ca                	mv	s1,s2
    80001c94:	bff1                	j	80001c70 <allocproc+0xb0>
    freeproc(p);
    80001c96:	8526                	mv	a0,s1
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	ed0080e7          	jalr	-304(ra) # 80001b68 <freeproc>
    release(&p->lock);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	fe4080e7          	jalr	-28(ra) # 80000c86 <release>
    return 0;
    80001caa:	84ca                	mv	s1,s2
    80001cac:	b7d1                	j	80001c70 <allocproc+0xb0>

0000000080001cae <userinit>:
{
    80001cae:	1101                	add	sp,sp,-32
    80001cb0:	ec06                	sd	ra,24(sp)
    80001cb2:	e822                	sd	s0,16(sp)
    80001cb4:	e426                	sd	s1,8(sp)
    80001cb6:	1000                	add	s0,sp,32
  p = allocproc();
    80001cb8:	00000097          	auipc	ra,0x0
    80001cbc:	f08080e7          	jalr	-248(ra) # 80001bc0 <allocproc>
    80001cc0:	84aa                	mv	s1,a0
  initproc = p;
    80001cc2:	00007797          	auipc	a5,0x7
    80001cc6:	bca7bb23          	sd	a0,-1066(a5) # 80008898 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cca:	03400613          	li	a2,52
    80001cce:	00007597          	auipc	a1,0x7
    80001cd2:	b5258593          	add	a1,a1,-1198 # 80008820 <initcode>
    80001cd6:	6928                	ld	a0,80(a0)
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	688080e7          	jalr	1672(ra) # 80001360 <uvmfirst>
  p->sz = PGSIZE;
    80001ce0:	6785                	lui	a5,0x1
    80001ce2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001ce4:	6cb8                	ld	a4,88(s1)
    80001ce6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cea:	6cb8                	ld	a4,88(s1)
    80001cec:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cee:	4641                	li	a2,16
    80001cf0:	00006597          	auipc	a1,0x6
    80001cf4:	52058593          	add	a1,a1,1312 # 80008210 <digits+0x1d0>
    80001cf8:	15848513          	add	a0,s1,344
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	11a080e7          	jalr	282(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d04:	00006517          	auipc	a0,0x6
    80001d08:	51c50513          	add	a0,a0,1308 # 80008220 <digits+0x1e0>
    80001d0c:	00002097          	auipc	ra,0x2
    80001d10:	454080e7          	jalr	1108(ra) # 80004160 <namei>
    80001d14:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d18:	478d                	li	a5,3
    80001d1a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	f68080e7          	jalr	-152(ra) # 80000c86 <release>
}
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6105                	add	sp,sp,32
    80001d2e:	8082                	ret

0000000080001d30 <growproc>:
{
    80001d30:	1101                	add	sp,sp,-32
    80001d32:	ec06                	sd	ra,24(sp)
    80001d34:	e822                	sd	s0,16(sp)
    80001d36:	e426                	sd	s1,8(sp)
    80001d38:	e04a                	sd	s2,0(sp)
    80001d3a:	1000                	add	s0,sp,32
    80001d3c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d3e:	00000097          	auipc	ra,0x0
    80001d42:	c78080e7          	jalr	-904(ra) # 800019b6 <myproc>
    80001d46:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d48:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d4a:	01204c63          	bgtz	s2,80001d62 <growproc+0x32>
  else if (n < 0)
    80001d4e:	02094663          	bltz	s2,80001d7a <growproc+0x4a>
  p->sz = sz;
    80001d52:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d54:	4501                	li	a0,0
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	add	sp,sp,32
    80001d60:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d62:	4691                	li	a3,4
    80001d64:	00b90633          	add	a2,s2,a1
    80001d68:	6928                	ld	a0,80(a0)
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	6b0080e7          	jalr	1712(ra) # 8000141a <uvmalloc>
    80001d72:	85aa                	mv	a1,a0
    80001d74:	fd79                	bnez	a0,80001d52 <growproc+0x22>
      return -1;
    80001d76:	557d                	li	a0,-1
    80001d78:	bff9                	j	80001d56 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d7a:	00b90633          	add	a2,s2,a1
    80001d7e:	6928                	ld	a0,80(a0)
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	652080e7          	jalr	1618(ra) # 800013d2 <uvmdealloc>
    80001d88:	85aa                	mv	a1,a0
    80001d8a:	b7e1                	j	80001d52 <growproc+0x22>

0000000080001d8c <fork>:
{
    80001d8c:	7139                	add	sp,sp,-64
    80001d8e:	fc06                	sd	ra,56(sp)
    80001d90:	f822                	sd	s0,48(sp)
    80001d92:	f426                	sd	s1,40(sp)
    80001d94:	f04a                	sd	s2,32(sp)
    80001d96:	ec4e                	sd	s3,24(sp)
    80001d98:	e852                	sd	s4,16(sp)
    80001d9a:	e456                	sd	s5,8(sp)
    80001d9c:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001d9e:	00000097          	auipc	ra,0x0
    80001da2:	c18080e7          	jalr	-1000(ra) # 800019b6 <myproc>
    80001da6:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001da8:	00000097          	auipc	ra,0x0
    80001dac:	e18080e7          	jalr	-488(ra) # 80001bc0 <allocproc>
    80001db0:	10050c63          	beqz	a0,80001ec8 <fork+0x13c>
    80001db4:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001db6:	048ab603          	ld	a2,72(s5)
    80001dba:	692c                	ld	a1,80(a0)
    80001dbc:	050ab503          	ld	a0,80(s5)
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	7b2080e7          	jalr	1970(ra) # 80001572 <uvmcopy>
    80001dc8:	04054863          	bltz	a0,80001e18 <fork+0x8c>
  np->sz = p->sz;
    80001dcc:	048ab783          	ld	a5,72(s5)
    80001dd0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dd4:	058ab683          	ld	a3,88(s5)
    80001dd8:	87b6                	mv	a5,a3
    80001dda:	058a3703          	ld	a4,88(s4)
    80001dde:	12068693          	add	a3,a3,288
    80001de2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001de6:	6788                	ld	a0,8(a5)
    80001de8:	6b8c                	ld	a1,16(a5)
    80001dea:	6f90                	ld	a2,24(a5)
    80001dec:	01073023          	sd	a6,0(a4)
    80001df0:	e708                	sd	a0,8(a4)
    80001df2:	eb0c                	sd	a1,16(a4)
    80001df4:	ef10                	sd	a2,24(a4)
    80001df6:	02078793          	add	a5,a5,32
    80001dfa:	02070713          	add	a4,a4,32
    80001dfe:	fed792e3          	bne	a5,a3,80001de2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e02:	058a3783          	ld	a5,88(s4)
    80001e06:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e0a:	0d0a8493          	add	s1,s5,208
    80001e0e:	0d0a0913          	add	s2,s4,208
    80001e12:	150a8993          	add	s3,s5,336
    80001e16:	a00d                	j	80001e38 <fork+0xac>
    freeproc(np);
    80001e18:	8552                	mv	a0,s4
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	d4e080e7          	jalr	-690(ra) # 80001b68 <freeproc>
    release(&np->lock);
    80001e22:	8552                	mv	a0,s4
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	e62080e7          	jalr	-414(ra) # 80000c86 <release>
    return -1;
    80001e2c:	597d                	li	s2,-1
    80001e2e:	a059                	j	80001eb4 <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001e30:	04a1                	add	s1,s1,8
    80001e32:	0921                	add	s2,s2,8
    80001e34:	01348b63          	beq	s1,s3,80001e4a <fork+0xbe>
    if (p->ofile[i])
    80001e38:	6088                	ld	a0,0(s1)
    80001e3a:	d97d                	beqz	a0,80001e30 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e3c:	00003097          	auipc	ra,0x3
    80001e40:	996080e7          	jalr	-1642(ra) # 800047d2 <filedup>
    80001e44:	00a93023          	sd	a0,0(s2)
    80001e48:	b7e5                	j	80001e30 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e4a:	150ab503          	ld	a0,336(s5)
    80001e4e:	00002097          	auipc	ra,0x2
    80001e52:	b2e080e7          	jalr	-1234(ra) # 8000397c <idup>
    80001e56:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e5a:	4641                	li	a2,16
    80001e5c:	158a8593          	add	a1,s5,344
    80001e60:	158a0513          	add	a0,s4,344
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	fb2080e7          	jalr	-78(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e6c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e70:	8552                	mv	a0,s4
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	e14080e7          	jalr	-492(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e7a:	0000f497          	auipc	s1,0xf
    80001e7e:	cae48493          	add	s1,s1,-850 # 80010b28 <wait_lock>
    80001e82:	8526                	mv	a0,s1
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	d4e080e7          	jalr	-690(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e8c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e90:	8526                	mv	a0,s1
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	df4080e7          	jalr	-524(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e9a:	8552                	mv	a0,s4
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	d36080e7          	jalr	-714(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001ea4:	478d                	li	a5,3
    80001ea6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eaa:	8552                	mv	a0,s4
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	dda080e7          	jalr	-550(ra) # 80000c86 <release>
}
    80001eb4:	854a                	mv	a0,s2
    80001eb6:	70e2                	ld	ra,56(sp)
    80001eb8:	7442                	ld	s0,48(sp)
    80001eba:	74a2                	ld	s1,40(sp)
    80001ebc:	7902                	ld	s2,32(sp)
    80001ebe:	69e2                	ld	s3,24(sp)
    80001ec0:	6a42                	ld	s4,16(sp)
    80001ec2:	6aa2                	ld	s5,8(sp)
    80001ec4:	6121                	add	sp,sp,64
    80001ec6:	8082                	ret
    return -1;
    80001ec8:	597d                	li	s2,-1
    80001eca:	b7ed                	j	80001eb4 <fork+0x128>

0000000080001ecc <scheduler>:
{
    80001ecc:	7139                	add	sp,sp,-64
    80001ece:	fc06                	sd	ra,56(sp)
    80001ed0:	f822                	sd	s0,48(sp)
    80001ed2:	f426                	sd	s1,40(sp)
    80001ed4:	f04a                	sd	s2,32(sp)
    80001ed6:	ec4e                	sd	s3,24(sp)
    80001ed8:	e852                	sd	s4,16(sp)
    80001eda:	e456                	sd	s5,8(sp)
    80001edc:	0080                	add	s0,sp,64
    80001ede:	8792                	mv	a5,tp
  int id = r_tp();
    80001ee0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ee2:	00779a93          	sll	s5,a5,0x7
    80001ee6:	0000f717          	auipc	a4,0xf
    80001eea:	c2a70713          	add	a4,a4,-982 # 80010b10 <pid_lock>
    80001eee:	9756                	add	a4,a4,s5
    80001ef0:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &highestp->context);
    80001ef4:	0000f717          	auipc	a4,0xf
    80001ef8:	c5470713          	add	a4,a4,-940 # 80010b48 <cpus+0x8>
    80001efc:	9aba                	add	s5,s5,a4
        if ((p->priority>0) && (ticks - p->etime > TOO_LONG)) {
    80001efe:	49a5                	li	s3,9
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f00:	00015497          	auipc	s1,0x15
    80001f04:	04048493          	add	s1,s1,64 # 80016f40 <tickslock>
      c->proc = highestp;
    80001f08:	079e                	sll	a5,a5,0x7
    80001f0a:	0000fa17          	auipc	s4,0xf
    80001f0e:	c06a0a13          	add	s4,s4,-1018 # 80010b10 <pid_lock>
    80001f12:	9a3e                	add	s4,s4,a5
    80001f14:	a85d                	j	80001fca <scheduler+0xfe>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f16:	18078793          	add	a5,a5,384
    80001f1a:	02978663          	beq	a5,s1,80001f46 <scheduler+0x7a>
      if (p->state == RUNNABLE) {
    80001f1e:	4f94                	lw	a3,24(a5)
    80001f20:	fee69be3          	bne	a3,a4,80001f16 <scheduler+0x4a>
        if ((p->priority>0) && (ticks - p->etime > TOO_LONG)) {
    80001f24:	1747a683          	lw	a3,372(a5)
    80001f28:	d6fd                	beqz	a3,80001f16 <scheduler+0x4a>
    80001f2a:	1707a603          	lw	a2,368(a5)
    80001f2e:	40c5863b          	subw	a2,a1,a2
    80001f32:	fec9f2e3          	bgeu	s3,a2,80001f16 <scheduler+0x4a>
          p->priority--;
    80001f36:	36fd                	addw	a3,a3,-1
    80001f38:	16d7aa23          	sw	a3,372(a5)
          p->etime = ticks;
    80001f3c:	16b7a823          	sw	a1,368(a5)
          p->wait = 0;
    80001f40:	1607ae23          	sw	zero,380(a5)
    80001f44:	bfc9                	j	80001f16 <scheduler+0x4a>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f46:	0000f797          	auipc	a5,0xf
    80001f4a:	ffa78793          	add	a5,a5,-6 # 80010f40 <proc>
    struct proc *highestp = 0, *p = 0;
    80001f4e:	892a                	mv	s2,a0
    80001f50:	a815                	j	80001f84 <scheduler+0xb8>
        if (highestp == 0) {
    80001f52:	02090263          	beqz	s2,80001f76 <scheduler+0xaa>
        if (p->priority < highestp->priority || (p->priority == highestp ->priority && p->entry < highestp->entry))
    80001f56:	1747a603          	lw	a2,372(a5)
    80001f5a:	17492683          	lw	a3,372(s2)
    80001f5e:	00d66e63          	bltu	a2,a3,80001f7a <scheduler+0xae>
    80001f62:	00d61d63          	bne	a2,a3,80001f7c <scheduler+0xb0>
    80001f66:	1787a603          	lw	a2,376(a5)
    80001f6a:	17892683          	lw	a3,376(s2)
    80001f6e:	00d67763          	bgeu	a2,a3,80001f7c <scheduler+0xb0>
    80001f72:	893e                	mv	s2,a5
    80001f74:	a021                	j	80001f7c <scheduler+0xb0>
    80001f76:	893e                	mv	s2,a5
    80001f78:	a011                	j	80001f7c <scheduler+0xb0>
    80001f7a:	893e                	mv	s2,a5
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	18078793          	add	a5,a5,384
    80001f80:	00978b63          	beq	a5,s1,80001f96 <scheduler+0xca>
      if (p->state == RUNNABLE) {
    80001f84:	4f94                	lw	a3,24(a5)
    80001f86:	fce686e3          	beq	a3,a4,80001f52 <scheduler+0x86>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f8a:	18078793          	add	a5,a5,384
    80001f8e:	fe979be3          	bne	a5,s1,80001f84 <scheduler+0xb8>
    if (highestp != 0) {
    80001f92:	04090263          	beqz	s2,80001fd6 <scheduler+0x10a>
      acquire(&highestp->lock);
    80001f96:	854a                	mv	a0,s2
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	c3a080e7          	jalr	-966(ra) # 80000bd2 <acquire>
      highestp->state = RUNNING;
    80001fa0:	4791                	li	a5,4
    80001fa2:	00f92c23          	sw	a5,24(s2)
      highestp->wait = 0;
    80001fa6:	16092e23          	sw	zero,380(s2)
      c->proc = highestp;
    80001faa:	032a3823          	sd	s2,48(s4)
      swtch(&c->context, &highestp->context);
    80001fae:	06090593          	add	a1,s2,96
    80001fb2:	8556                	mv	a0,s5
    80001fb4:	00001097          	auipc	ra,0x1
    80001fb8:	858080e7          	jalr	-1960(ra) # 8000280c <swtch>
      c->proc = 0;
    80001fbc:	020a3823          	sd	zero,48(s4)
      release(&highestp->lock);
    80001fc0:	854a                	mv	a0,s2
    80001fc2:	fffff097          	auipc	ra,0xfffff
    80001fc6:	cc4080e7          	jalr	-828(ra) # 80000c86 <release>
        if ((p->priority>0) && (ticks - p->etime > TOO_LONG)) {
    80001fca:	00007597          	auipc	a1,0x7
    80001fce:	8d65a583          	lw	a1,-1834(a1) # 800088a0 <ticks>
      if (p->state == RUNNABLE) {
    80001fd2:	470d                	li	a4,3
    struct proc *highestp = 0, *p = 0;
    80001fd4:	4501                	li	a0,0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fda:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fde:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fe2:	0000f797          	auipc	a5,0xf
    80001fe6:	f5e78793          	add	a5,a5,-162 # 80010f40 <proc>
    80001fea:	bf15                	j	80001f1e <scheduler+0x52>

0000000080001fec <sched>:
{
    80001fec:	7179                	add	sp,sp,-48
    80001fee:	f406                	sd	ra,40(sp)
    80001ff0:	f022                	sd	s0,32(sp)
    80001ff2:	ec26                	sd	s1,24(sp)
    80001ff4:	e84a                	sd	s2,16(sp)
    80001ff6:	e44e                	sd	s3,8(sp)
    80001ff8:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001ffa:	00000097          	auipc	ra,0x0
    80001ffe:	9bc080e7          	jalr	-1604(ra) # 800019b6 <myproc>
    80002002:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	b54080e7          	jalr	-1196(ra) # 80000b58 <holding>
    8000200c:	c93d                	beqz	a0,80002082 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002010:	2781                	sext.w	a5,a5
    80002012:	079e                	sll	a5,a5,0x7
    80002014:	0000f717          	auipc	a4,0xf
    80002018:	afc70713          	add	a4,a4,-1284 # 80010b10 <pid_lock>
    8000201c:	97ba                	add	a5,a5,a4
    8000201e:	0a87a703          	lw	a4,168(a5)
    80002022:	4785                	li	a5,1
    80002024:	06f71763          	bne	a4,a5,80002092 <sched+0xa6>
  if (p->state == RUNNING)
    80002028:	4c98                	lw	a4,24(s1)
    8000202a:	4791                	li	a5,4
    8000202c:	06f70b63          	beq	a4,a5,800020a2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002030:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002034:	8b89                	and	a5,a5,2
  if (intr_get())
    80002036:	efb5                	bnez	a5,800020b2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002038:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000203a:	0000f917          	auipc	s2,0xf
    8000203e:	ad690913          	add	s2,s2,-1322 # 80010b10 <pid_lock>
    80002042:	2781                	sext.w	a5,a5
    80002044:	079e                	sll	a5,a5,0x7
    80002046:	97ca                	add	a5,a5,s2
    80002048:	0ac7a983          	lw	s3,172(a5)
    8000204c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204e:	2781                	sext.w	a5,a5
    80002050:	079e                	sll	a5,a5,0x7
    80002052:	0000f597          	auipc	a1,0xf
    80002056:	af658593          	add	a1,a1,-1290 # 80010b48 <cpus+0x8>
    8000205a:	95be                	add	a1,a1,a5
    8000205c:	06048513          	add	a0,s1,96
    80002060:	00000097          	auipc	ra,0x0
    80002064:	7ac080e7          	jalr	1964(ra) # 8000280c <swtch>
    80002068:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000206a:	2781                	sext.w	a5,a5
    8000206c:	079e                	sll	a5,a5,0x7
    8000206e:	993e                	add	s2,s2,a5
    80002070:	0b392623          	sw	s3,172(s2)
}
    80002074:	70a2                	ld	ra,40(sp)
    80002076:	7402                	ld	s0,32(sp)
    80002078:	64e2                	ld	s1,24(sp)
    8000207a:	6942                	ld	s2,16(sp)
    8000207c:	69a2                	ld	s3,8(sp)
    8000207e:	6145                	add	sp,sp,48
    80002080:	8082                	ret
    panic("sched p->lock");
    80002082:	00006517          	auipc	a0,0x6
    80002086:	1a650513          	add	a0,a0,422 # 80008228 <digits+0x1e8>
    8000208a:	ffffe097          	auipc	ra,0xffffe
    8000208e:	4b2080e7          	jalr	1202(ra) # 8000053c <panic>
    panic("sched locks");
    80002092:	00006517          	auipc	a0,0x6
    80002096:	1a650513          	add	a0,a0,422 # 80008238 <digits+0x1f8>
    8000209a:	ffffe097          	auipc	ra,0xffffe
    8000209e:	4a2080e7          	jalr	1186(ra) # 8000053c <panic>
    panic("sched running");
    800020a2:	00006517          	auipc	a0,0x6
    800020a6:	1a650513          	add	a0,a0,422 # 80008248 <digits+0x208>
    800020aa:	ffffe097          	auipc	ra,0xffffe
    800020ae:	492080e7          	jalr	1170(ra) # 8000053c <panic>
    panic("sched interruptible");
    800020b2:	00006517          	auipc	a0,0x6
    800020b6:	1a650513          	add	a0,a0,422 # 80008258 <digits+0x218>
    800020ba:	ffffe097          	auipc	ra,0xffffe
    800020be:	482080e7          	jalr	1154(ra) # 8000053c <panic>

00000000800020c2 <yield>:
{
    800020c2:	1101                	add	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020cc:	00000097          	auipc	ra,0x0
    800020d0:	8ea080e7          	jalr	-1814(ra) # 800019b6 <myproc>
    800020d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	afc080e7          	jalr	-1284(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800020de:	478d                	li	a5,3
    800020e0:	cc9c                	sw	a5,24(s1)
  sched();
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	f0a080e7          	jalr	-246(ra) # 80001fec <sched>
  release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	b9a080e7          	jalr	-1126(ra) # 80000c86 <release>
}
    800020f4:	60e2                	ld	ra,24(sp)
    800020f6:	6442                	ld	s0,16(sp)
    800020f8:	64a2                	ld	s1,8(sp)
    800020fa:	6105                	add	sp,sp,32
    800020fc:	8082                	ret

00000000800020fe <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020fe:	7179                	add	sp,sp,-48
    80002100:	f406                	sd	ra,40(sp)
    80002102:	f022                	sd	s0,32(sp)
    80002104:	ec26                	sd	s1,24(sp)
    80002106:	e84a                	sd	s2,16(sp)
    80002108:	e44e                	sd	s3,8(sp)
    8000210a:	1800                	add	s0,sp,48
    8000210c:	89aa                	mv	s3,a0
    8000210e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002110:	00000097          	auipc	ra,0x0
    80002114:	8a6080e7          	jalr	-1882(ra) # 800019b6 <myproc>
    80002118:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	ab8080e7          	jalr	-1352(ra) # 80000bd2 <acquire>
  release(lk);
    80002122:	854a                	mv	a0,s2
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	b62080e7          	jalr	-1182(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000212c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002130:	4789                	li	a5,2
    80002132:	cc9c                	sw	a5,24(s1)

  sched();
    80002134:	00000097          	auipc	ra,0x0
    80002138:	eb8080e7          	jalr	-328(ra) # 80001fec <sched>

  // Tidy up.
  p->chan = 0;
    8000213c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	b44080e7          	jalr	-1212(ra) # 80000c86 <release>
  acquire(lk);
    8000214a:	854a                	mv	a0,s2
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	a86080e7          	jalr	-1402(ra) # 80000bd2 <acquire>
}
    80002154:	70a2                	ld	ra,40(sp)
    80002156:	7402                	ld	s0,32(sp)
    80002158:	64e2                	ld	s1,24(sp)
    8000215a:	6942                	ld	s2,16(sp)
    8000215c:	69a2                	ld	s3,8(sp)
    8000215e:	6145                	add	sp,sp,48
    80002160:	8082                	ret

0000000080002162 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002162:	7139                	add	sp,sp,-64
    80002164:	fc06                	sd	ra,56(sp)
    80002166:	f822                	sd	s0,48(sp)
    80002168:	f426                	sd	s1,40(sp)
    8000216a:	f04a                	sd	s2,32(sp)
    8000216c:	ec4e                	sd	s3,24(sp)
    8000216e:	e852                	sd	s4,16(sp)
    80002170:	e456                	sd	s5,8(sp)
    80002172:	0080                	add	s0,sp,64
    80002174:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002176:	0000f497          	auipc	s1,0xf
    8000217a:	dca48493          	add	s1,s1,-566 # 80010f40 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000217e:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002180:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002182:	00015917          	auipc	s2,0x15
    80002186:	dbe90913          	add	s2,s2,-578 # 80016f40 <tickslock>
    8000218a:	a811                	j	8000219e <wakeup+0x3c>
      }
      release(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	af8080e7          	jalr	-1288(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002196:	18048493          	add	s1,s1,384
    8000219a:	03248663          	beq	s1,s2,800021c6 <wakeup+0x64>
    if (p != myproc())
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	818080e7          	jalr	-2024(ra) # 800019b6 <myproc>
    800021a6:	fea488e3          	beq	s1,a0,80002196 <wakeup+0x34>
      acquire(&p->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	a26080e7          	jalr	-1498(ra) # 80000bd2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800021b4:	4c9c                	lw	a5,24(s1)
    800021b6:	fd379be3          	bne	a5,s3,8000218c <wakeup+0x2a>
    800021ba:	709c                	ld	a5,32(s1)
    800021bc:	fd4798e3          	bne	a5,s4,8000218c <wakeup+0x2a>
        p->state = RUNNABLE;
    800021c0:	0154ac23          	sw	s5,24(s1)
    800021c4:	b7e1                	j	8000218c <wakeup+0x2a>
    }
  }
}
    800021c6:	70e2                	ld	ra,56(sp)
    800021c8:	7442                	ld	s0,48(sp)
    800021ca:	74a2                	ld	s1,40(sp)
    800021cc:	7902                	ld	s2,32(sp)
    800021ce:	69e2                	ld	s3,24(sp)
    800021d0:	6a42                	ld	s4,16(sp)
    800021d2:	6aa2                	ld	s5,8(sp)
    800021d4:	6121                	add	sp,sp,64
    800021d6:	8082                	ret

00000000800021d8 <reparent>:
{
    800021d8:	7179                	add	sp,sp,-48
    800021da:	f406                	sd	ra,40(sp)
    800021dc:	f022                	sd	s0,32(sp)
    800021de:	ec26                	sd	s1,24(sp)
    800021e0:	e84a                	sd	s2,16(sp)
    800021e2:	e44e                	sd	s3,8(sp)
    800021e4:	e052                	sd	s4,0(sp)
    800021e6:	1800                	add	s0,sp,48
    800021e8:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021ea:	0000f497          	auipc	s1,0xf
    800021ee:	d5648493          	add	s1,s1,-682 # 80010f40 <proc>
      pp->parent = initproc;
    800021f2:	00006a17          	auipc	s4,0x6
    800021f6:	6a6a0a13          	add	s4,s4,1702 # 80008898 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021fa:	00015997          	auipc	s3,0x15
    800021fe:	d4698993          	add	s3,s3,-698 # 80016f40 <tickslock>
    80002202:	a029                	j	8000220c <reparent+0x34>
    80002204:	18048493          	add	s1,s1,384
    80002208:	01348d63          	beq	s1,s3,80002222 <reparent+0x4a>
    if (pp->parent == p)
    8000220c:	7c9c                	ld	a5,56(s1)
    8000220e:	ff279be3          	bne	a5,s2,80002204 <reparent+0x2c>
      pp->parent = initproc;
    80002212:	000a3503          	ld	a0,0(s4)
    80002216:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002218:	00000097          	auipc	ra,0x0
    8000221c:	f4a080e7          	jalr	-182(ra) # 80002162 <wakeup>
    80002220:	b7d5                	j	80002204 <reparent+0x2c>
}
    80002222:	70a2                	ld	ra,40(sp)
    80002224:	7402                	ld	s0,32(sp)
    80002226:	64e2                	ld	s1,24(sp)
    80002228:	6942                	ld	s2,16(sp)
    8000222a:	69a2                	ld	s3,8(sp)
    8000222c:	6a02                	ld	s4,0(sp)
    8000222e:	6145                	add	sp,sp,48
    80002230:	8082                	ret

0000000080002232 <exit>:
{
    80002232:	7179                	add	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	e052                	sd	s4,0(sp)
    80002240:	1800                	add	s0,sp,48
    80002242:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	772080e7          	jalr	1906(ra) # 800019b6 <myproc>
    8000224c:	89aa                	mv	s3,a0
  if (p == initproc)
    8000224e:	00006797          	auipc	a5,0x6
    80002252:	64a7b783          	ld	a5,1610(a5) # 80008898 <initproc>
    80002256:	0d050493          	add	s1,a0,208
    8000225a:	15050913          	add	s2,a0,336
    8000225e:	02a79363          	bne	a5,a0,80002284 <exit+0x52>
    panic("init exiting");
    80002262:	00006517          	auipc	a0,0x6
    80002266:	00e50513          	add	a0,a0,14 # 80008270 <digits+0x230>
    8000226a:	ffffe097          	auipc	ra,0xffffe
    8000226e:	2d2080e7          	jalr	722(ra) # 8000053c <panic>
      fileclose(f);
    80002272:	00002097          	auipc	ra,0x2
    80002276:	5b2080e7          	jalr	1458(ra) # 80004824 <fileclose>
      p->ofile[fd] = 0;
    8000227a:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    8000227e:	04a1                	add	s1,s1,8
    80002280:	01248563          	beq	s1,s2,8000228a <exit+0x58>
    if (p->ofile[fd])
    80002284:	6088                	ld	a0,0(s1)
    80002286:	f575                	bnez	a0,80002272 <exit+0x40>
    80002288:	bfdd                	j	8000227e <exit+0x4c>
  begin_op();
    8000228a:	00002097          	auipc	ra,0x2
    8000228e:	0d6080e7          	jalr	214(ra) # 80004360 <begin_op>
  iput(p->cwd);
    80002292:	1509b503          	ld	a0,336(s3)
    80002296:	00002097          	auipc	ra,0x2
    8000229a:	8de080e7          	jalr	-1826(ra) # 80003b74 <iput>
  end_op();
    8000229e:	00002097          	auipc	ra,0x2
    800022a2:	13c080e7          	jalr	316(ra) # 800043da <end_op>
  p->cwd = 0;
    800022a6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022aa:	0000f497          	auipc	s1,0xf
    800022ae:	87e48493          	add	s1,s1,-1922 # 80010b28 <wait_lock>
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	91e080e7          	jalr	-1762(ra) # 80000bd2 <acquire>
  reparent(p);
    800022bc:	854e                	mv	a0,s3
    800022be:	00000097          	auipc	ra,0x0
    800022c2:	f1a080e7          	jalr	-230(ra) # 800021d8 <reparent>
  wakeup(p->parent);
    800022c6:	0389b503          	ld	a0,56(s3)
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	e98080e7          	jalr	-360(ra) # 80002162 <wakeup>
  acquire(&p->lock);
    800022d2:	854e                	mv	a0,s3
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	8fe080e7          	jalr	-1794(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800022dc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e0:	4795                	li	a5,5
    800022e2:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800022e6:	00006797          	auipc	a5,0x6
    800022ea:	5ba7a783          	lw	a5,1466(a5) # 800088a0 <ticks>
    800022ee:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	992080e7          	jalr	-1646(ra) # 80000c86 <release>
  sched();
    800022fc:	00000097          	auipc	ra,0x0
    80002300:	cf0080e7          	jalr	-784(ra) # 80001fec <sched>
  panic("zombie exit");
    80002304:	00006517          	auipc	a0,0x6
    80002308:	f7c50513          	add	a0,a0,-132 # 80008280 <digits+0x240>
    8000230c:	ffffe097          	auipc	ra,0xffffe
    80002310:	230080e7          	jalr	560(ra) # 8000053c <panic>

0000000080002314 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002314:	7179                	add	sp,sp,-48
    80002316:	f406                	sd	ra,40(sp)
    80002318:	f022                	sd	s0,32(sp)
    8000231a:	ec26                	sd	s1,24(sp)
    8000231c:	e84a                	sd	s2,16(sp)
    8000231e:	e44e                	sd	s3,8(sp)
    80002320:	1800                	add	s0,sp,48
    80002322:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002324:	0000f497          	auipc	s1,0xf
    80002328:	c1c48493          	add	s1,s1,-996 # 80010f40 <proc>
    8000232c:	00015997          	auipc	s3,0x15
    80002330:	c1498993          	add	s3,s3,-1004 # 80016f40 <tickslock>
  {
    acquire(&p->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	89c080e7          	jalr	-1892(ra) # 80000bd2 <acquire>
    if (p->pid == pid)
    8000233e:	589c                	lw	a5,48(s1)
    80002340:	01278d63          	beq	a5,s2,8000235a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	940080e7          	jalr	-1728(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000234e:	18048493          	add	s1,s1,384
    80002352:	ff3491e3          	bne	s1,s3,80002334 <kill+0x20>
  }
  return -1;
    80002356:	557d                	li	a0,-1
    80002358:	a829                	j	80002372 <kill+0x5e>
      p->killed = 1;
    8000235a:	4785                	li	a5,1
    8000235c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000235e:	4c98                	lw	a4,24(s1)
    80002360:	4789                	li	a5,2
    80002362:	00f70f63          	beq	a4,a5,80002380 <kill+0x6c>
      release(&p->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	91e080e7          	jalr	-1762(ra) # 80000c86 <release>
      return 0;
    80002370:	4501                	li	a0,0
}
    80002372:	70a2                	ld	ra,40(sp)
    80002374:	7402                	ld	s0,32(sp)
    80002376:	64e2                	ld	s1,24(sp)
    80002378:	6942                	ld	s2,16(sp)
    8000237a:	69a2                	ld	s3,8(sp)
    8000237c:	6145                	add	sp,sp,48
    8000237e:	8082                	ret
        p->state = RUNNABLE;
    80002380:	478d                	li	a5,3
    80002382:	cc9c                	sw	a5,24(s1)
    80002384:	b7cd                	j	80002366 <kill+0x52>

0000000080002386 <setkilled>:

void setkilled(struct proc *p)
{
    80002386:	1101                	add	sp,sp,-32
    80002388:	ec06                	sd	ra,24(sp)
    8000238a:	e822                	sd	s0,16(sp)
    8000238c:	e426                	sd	s1,8(sp)
    8000238e:	1000                	add	s0,sp,32
    80002390:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	840080e7          	jalr	-1984(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000239a:	4785                	li	a5,1
    8000239c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	8e6080e7          	jalr	-1818(ra) # 80000c86 <release>
}
    800023a8:	60e2                	ld	ra,24(sp)
    800023aa:	6442                	ld	s0,16(sp)
    800023ac:	64a2                	ld	s1,8(sp)
    800023ae:	6105                	add	sp,sp,32
    800023b0:	8082                	ret

00000000800023b2 <killed>:

int killed(struct proc *p)
{
    800023b2:	1101                	add	sp,sp,-32
    800023b4:	ec06                	sd	ra,24(sp)
    800023b6:	e822                	sd	s0,16(sp)
    800023b8:	e426                	sd	s1,8(sp)
    800023ba:	e04a                	sd	s2,0(sp)
    800023bc:	1000                	add	s0,sp,32
    800023be:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	812080e7          	jalr	-2030(ra) # 80000bd2 <acquire>
  k = p->killed;
    800023c8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	8b8080e7          	jalr	-1864(ra) # 80000c86 <release>
  return k;
}
    800023d6:	854a                	mv	a0,s2
    800023d8:	60e2                	ld	ra,24(sp)
    800023da:	6442                	ld	s0,16(sp)
    800023dc:	64a2                	ld	s1,8(sp)
    800023de:	6902                	ld	s2,0(sp)
    800023e0:	6105                	add	sp,sp,32
    800023e2:	8082                	ret

00000000800023e4 <wait>:
{
    800023e4:	715d                	add	sp,sp,-80
    800023e6:	e486                	sd	ra,72(sp)
    800023e8:	e0a2                	sd	s0,64(sp)
    800023ea:	fc26                	sd	s1,56(sp)
    800023ec:	f84a                	sd	s2,48(sp)
    800023ee:	f44e                	sd	s3,40(sp)
    800023f0:	f052                	sd	s4,32(sp)
    800023f2:	ec56                	sd	s5,24(sp)
    800023f4:	e85a                	sd	s6,16(sp)
    800023f6:	e45e                	sd	s7,8(sp)
    800023f8:	e062                	sd	s8,0(sp)
    800023fa:	0880                	add	s0,sp,80
    800023fc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	5b8080e7          	jalr	1464(ra) # 800019b6 <myproc>
    80002406:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002408:	0000e517          	auipc	a0,0xe
    8000240c:	72050513          	add	a0,a0,1824 # 80010b28 <wait_lock>
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	7c2080e7          	jalr	1986(ra) # 80000bd2 <acquire>
    havekids = 0;
    80002418:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000241a:	4a15                	li	s4,5
        havekids = 1;
    8000241c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000241e:	00015997          	auipc	s3,0x15
    80002422:	b2298993          	add	s3,s3,-1246 # 80016f40 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002426:	0000ec17          	auipc	s8,0xe
    8000242a:	702c0c13          	add	s8,s8,1794 # 80010b28 <wait_lock>
    8000242e:	a0d1                	j	800024f2 <wait+0x10e>
          pid = pp->pid;
    80002430:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002434:	000b0e63          	beqz	s6,80002450 <wait+0x6c>
    80002438:	4691                	li	a3,4
    8000243a:	02c48613          	add	a2,s1,44
    8000243e:	85da                	mv	a1,s6
    80002440:	05093503          	ld	a0,80(s2)
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	232080e7          	jalr	562(ra) # 80001676 <copyout>
    8000244c:	04054163          	bltz	a0,8000248e <wait+0xaa>
          freeproc(pp);
    80002450:	8526                	mv	a0,s1
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	716080e7          	jalr	1814(ra) # 80001b68 <freeproc>
          release(&pp->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	82a080e7          	jalr	-2006(ra) # 80000c86 <release>
          release(&wait_lock);
    80002464:	0000e517          	auipc	a0,0xe
    80002468:	6c450513          	add	a0,a0,1732 # 80010b28 <wait_lock>
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	81a080e7          	jalr	-2022(ra) # 80000c86 <release>
}
    80002474:	854e                	mv	a0,s3
    80002476:	60a6                	ld	ra,72(sp)
    80002478:	6406                	ld	s0,64(sp)
    8000247a:	74e2                	ld	s1,56(sp)
    8000247c:	7942                	ld	s2,48(sp)
    8000247e:	79a2                	ld	s3,40(sp)
    80002480:	7a02                	ld	s4,32(sp)
    80002482:	6ae2                	ld	s5,24(sp)
    80002484:	6b42                	ld	s6,16(sp)
    80002486:	6ba2                	ld	s7,8(sp)
    80002488:	6c02                	ld	s8,0(sp)
    8000248a:	6161                	add	sp,sp,80
    8000248c:	8082                	ret
            release(&pp->lock);
    8000248e:	8526                	mv	a0,s1
    80002490:	ffffe097          	auipc	ra,0xffffe
    80002494:	7f6080e7          	jalr	2038(ra) # 80000c86 <release>
            release(&wait_lock);
    80002498:	0000e517          	auipc	a0,0xe
    8000249c:	69050513          	add	a0,a0,1680 # 80010b28 <wait_lock>
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	7e6080e7          	jalr	2022(ra) # 80000c86 <release>
            return -1;
    800024a8:	59fd                	li	s3,-1
    800024aa:	b7e9                	j	80002474 <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024ac:	18048493          	add	s1,s1,384
    800024b0:	03348463          	beq	s1,s3,800024d8 <wait+0xf4>
      if (pp->parent == p)
    800024b4:	7c9c                	ld	a5,56(s1)
    800024b6:	ff279be3          	bne	a5,s2,800024ac <wait+0xc8>
        acquire(&pp->lock);
    800024ba:	8526                	mv	a0,s1
    800024bc:	ffffe097          	auipc	ra,0xffffe
    800024c0:	716080e7          	jalr	1814(ra) # 80000bd2 <acquire>
        if (pp->state == ZOMBIE)
    800024c4:	4c9c                	lw	a5,24(s1)
    800024c6:	f74785e3          	beq	a5,s4,80002430 <wait+0x4c>
        release(&pp->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	7ba080e7          	jalr	1978(ra) # 80000c86 <release>
        havekids = 1;
    800024d4:	8756                	mv	a4,s5
    800024d6:	bfd9                	j	800024ac <wait+0xc8>
    if (!havekids || killed(p))
    800024d8:	c31d                	beqz	a4,800024fe <wait+0x11a>
    800024da:	854a                	mv	a0,s2
    800024dc:	00000097          	auipc	ra,0x0
    800024e0:	ed6080e7          	jalr	-298(ra) # 800023b2 <killed>
    800024e4:	ed09                	bnez	a0,800024fe <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024e6:	85e2                	mv	a1,s8
    800024e8:	854a                	mv	a0,s2
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	c14080e7          	jalr	-1004(ra) # 800020fe <sleep>
    havekids = 0;
    800024f2:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024f4:	0000f497          	auipc	s1,0xf
    800024f8:	a4c48493          	add	s1,s1,-1460 # 80010f40 <proc>
    800024fc:	bf65                	j	800024b4 <wait+0xd0>
      release(&wait_lock);
    800024fe:	0000e517          	auipc	a0,0xe
    80002502:	62a50513          	add	a0,a0,1578 # 80010b28 <wait_lock>
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	780080e7          	jalr	1920(ra) # 80000c86 <release>
      return -1;
    8000250e:	59fd                	li	s3,-1
    80002510:	b795                	j	80002474 <wait+0x90>

0000000080002512 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002512:	7179                	add	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	e052                	sd	s4,0(sp)
    80002520:	1800                	add	s0,sp,48
    80002522:	84aa                	mv	s1,a0
    80002524:	892e                	mv	s2,a1
    80002526:	89b2                	mv	s3,a2
    80002528:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	48c080e7          	jalr	1164(ra) # 800019b6 <myproc>
  if (user_dst)
    80002532:	c08d                	beqz	s1,80002554 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002534:	86d2                	mv	a3,s4
    80002536:	864e                	mv	a2,s3
    80002538:	85ca                	mv	a1,s2
    8000253a:	6928                	ld	a0,80(a0)
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	13a080e7          	jalr	314(ra) # 80001676 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002544:	70a2                	ld	ra,40(sp)
    80002546:	7402                	ld	s0,32(sp)
    80002548:	64e2                	ld	s1,24(sp)
    8000254a:	6942                	ld	s2,16(sp)
    8000254c:	69a2                	ld	s3,8(sp)
    8000254e:	6a02                	ld	s4,0(sp)
    80002550:	6145                	add	sp,sp,48
    80002552:	8082                	ret
    memmove((char *)dst, src, len);
    80002554:	000a061b          	sext.w	a2,s4
    80002558:	85ce                	mv	a1,s3
    8000255a:	854a                	mv	a0,s2
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	7ce080e7          	jalr	1998(ra) # 80000d2a <memmove>
    return 0;
    80002564:	8526                	mv	a0,s1
    80002566:	bff9                	j	80002544 <either_copyout+0x32>

0000000080002568 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002568:	7179                	add	sp,sp,-48
    8000256a:	f406                	sd	ra,40(sp)
    8000256c:	f022                	sd	s0,32(sp)
    8000256e:	ec26                	sd	s1,24(sp)
    80002570:	e84a                	sd	s2,16(sp)
    80002572:	e44e                	sd	s3,8(sp)
    80002574:	e052                	sd	s4,0(sp)
    80002576:	1800                	add	s0,sp,48
    80002578:	892a                	mv	s2,a0
    8000257a:	84ae                	mv	s1,a1
    8000257c:	89b2                	mv	s3,a2
    8000257e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	436080e7          	jalr	1078(ra) # 800019b6 <myproc>
  if (user_src)
    80002588:	c08d                	beqz	s1,800025aa <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000258a:	86d2                	mv	a3,s4
    8000258c:	864e                	mv	a2,s3
    8000258e:	85ca                	mv	a1,s2
    80002590:	6928                	ld	a0,80(a0)
    80002592:	fffff097          	auipc	ra,0xfffff
    80002596:	170080e7          	jalr	368(ra) # 80001702 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6a02                	ld	s4,0(sp)
    800025a6:	6145                	add	sp,sp,48
    800025a8:	8082                	ret
    memmove(dst, (char *)src, len);
    800025aa:	000a061b          	sext.w	a2,s4
    800025ae:	85ce                	mv	a1,s3
    800025b0:	854a                	mv	a0,s2
    800025b2:	ffffe097          	auipc	ra,0xffffe
    800025b6:	778080e7          	jalr	1912(ra) # 80000d2a <memmove>
    return 0;
    800025ba:	8526                	mv	a0,s1
    800025bc:	bff9                	j	8000259a <either_copyin+0x32>

00000000800025be <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025be:	7179                	add	sp,sp,-48
    800025c0:	f406                	sd	ra,40(sp)
    800025c2:	f022                	sd	s0,32(sp)
    800025c4:	ec26                	sd	s1,24(sp)
    800025c6:	e84a                	sd	s2,16(sp)
    800025c8:	e44e                	sd	s3,8(sp)
    800025ca:	1800                	add	s0,sp,48
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;

  printf("\n");
    800025cc:	00006517          	auipc	a0,0x6
    800025d0:	b0c50513          	add	a0,a0,-1268 # 800080d8 <digits+0x98>
    800025d4:	ffffe097          	auipc	ra,0xffffe
    800025d8:	fb2080e7          	jalr	-78(ra) # 80000586 <printf>


  char *state = "";
  printf("(%d", ticks);
    800025dc:	00006597          	auipc	a1,0x6
    800025e0:	2c45a583          	lw	a1,708(a1) # 800088a0 <ticks>
    800025e4:	00006517          	auipc	a0,0x6
    800025e8:	cac50513          	add	a0,a0,-852 # 80008290 <digits+0x250>
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	f9a080e7          	jalr	-102(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025f4:	0000f497          	auipc	s1,0xf
    800025f8:	94c48493          	add	s1,s1,-1716 # 80010f40 <proc>
      state = "???";
    if (0) {
      printf("pid: %d, %state", p->pid, state);
    }
#ifdef MLFQ
    printf(", (%d, %d)", p->pid, p->priority);
    800025fc:	00006997          	auipc	s3,0x6
    80002600:	c9c98993          	add	s3,s3,-868 # 80008298 <digits+0x258>
  for (p = proc; p < &proc[NPROC]; p++)
    80002604:	00015917          	auipc	s2,0x15
    80002608:	93c90913          	add	s2,s2,-1732 # 80016f40 <tickslock>
    8000260c:	a029                	j	80002616 <procdump+0x58>
    8000260e:	18048493          	add	s1,s1,384
    80002612:	01248d63          	beq	s1,s2,8000262c <procdump+0x6e>
    if (p->state == UNUSED)
    80002616:	4c9c                	lw	a5,24(s1)
    80002618:	dbfd                	beqz	a5,8000260e <procdump+0x50>
    printf(", (%d, %d)", p->pid, p->priority);
    8000261a:	1744a603          	lw	a2,372(s1)
    8000261e:	588c                	lw	a1,48(s1)
    80002620:	854e                	mv	a0,s3
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	f64080e7          	jalr	-156(ra) # 80000586 <printf>
    8000262a:	b7d5                	j	8000260e <procdump+0x50>

#ifdef DEFAULT
    printf("%s\n", state);
#endif
  }
  printf("),");
    8000262c:	00006517          	auipc	a0,0x6
    80002630:	c7c50513          	add	a0,a0,-900 # 800082a8 <digits+0x268>
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	f52080e7          	jalr	-174(ra) # 80000586 <printf>
}
    8000263c:	70a2                	ld	ra,40(sp)
    8000263e:	7402                	ld	s0,32(sp)
    80002640:	64e2                	ld	s1,24(sp)
    80002642:	6942                	ld	s2,16(sp)
    80002644:	69a2                	ld	s3,8(sp)
    80002646:	6145                	add	sp,sp,48
    80002648:	8082                	ret

000000008000264a <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000264a:	711d                	add	sp,sp,-96
    8000264c:	ec86                	sd	ra,88(sp)
    8000264e:	e8a2                	sd	s0,80(sp)
    80002650:	e4a6                	sd	s1,72(sp)
    80002652:	e0ca                	sd	s2,64(sp)
    80002654:	fc4e                	sd	s3,56(sp)
    80002656:	f852                	sd	s4,48(sp)
    80002658:	f456                	sd	s5,40(sp)
    8000265a:	f05a                	sd	s6,32(sp)
    8000265c:	ec5e                	sd	s7,24(sp)
    8000265e:	e862                	sd	s8,16(sp)
    80002660:	e466                	sd	s9,8(sp)
    80002662:	e06a                	sd	s10,0(sp)
    80002664:	1080                	add	s0,sp,96
    80002666:	8b2a                	mv	s6,a0
    80002668:	8bae                	mv	s7,a1
    8000266a:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000266c:	fffff097          	auipc	ra,0xfffff
    80002670:	34a080e7          	jalr	842(ra) # 800019b6 <myproc>
    80002674:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002676:	0000e517          	auipc	a0,0xe
    8000267a:	4b250513          	add	a0,a0,1202 # 80010b28 <wait_lock>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	554080e7          	jalr	1364(ra) # 80000bd2 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002686:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002688:	4a15                	li	s4,5
        havekids = 1;
    8000268a:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000268c:	00015997          	auipc	s3,0x15
    80002690:	8b498993          	add	s3,s3,-1868 # 80016f40 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002694:	0000ed17          	auipc	s10,0xe
    80002698:	494d0d13          	add	s10,s10,1172 # 80010b28 <wait_lock>
    8000269c:	a8e9                	j	80002776 <waitx+0x12c>
          pid = np->pid;
    8000269e:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800026a2:	1684a783          	lw	a5,360(s1)
    800026a6:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026aa:	16c4a703          	lw	a4,364(s1)
    800026ae:	9f3d                	addw	a4,a4,a5
    800026b0:	1704a783          	lw	a5,368(s1)
    800026b4:	9f99                	subw	a5,a5,a4
    800026b6:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdccc8>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026ba:	000b0e63          	beqz	s6,800026d6 <waitx+0x8c>
    800026be:	4691                	li	a3,4
    800026c0:	02c48613          	add	a2,s1,44
    800026c4:	85da                	mv	a1,s6
    800026c6:	05093503          	ld	a0,80(s2)
    800026ca:	fffff097          	auipc	ra,0xfffff
    800026ce:	fac080e7          	jalr	-84(ra) # 80001676 <copyout>
    800026d2:	04054363          	bltz	a0,80002718 <waitx+0xce>
          freeproc(np);
    800026d6:	8526                	mv	a0,s1
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	490080e7          	jalr	1168(ra) # 80001b68 <freeproc>
          release(&np->lock);
    800026e0:	8526                	mv	a0,s1
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	5a4080e7          	jalr	1444(ra) # 80000c86 <release>
          release(&wait_lock);
    800026ea:	0000e517          	auipc	a0,0xe
    800026ee:	43e50513          	add	a0,a0,1086 # 80010b28 <wait_lock>
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	594080e7          	jalr	1428(ra) # 80000c86 <release>
  }
}
    800026fa:	854e                	mv	a0,s3
    800026fc:	60e6                	ld	ra,88(sp)
    800026fe:	6446                	ld	s0,80(sp)
    80002700:	64a6                	ld	s1,72(sp)
    80002702:	6906                	ld	s2,64(sp)
    80002704:	79e2                	ld	s3,56(sp)
    80002706:	7a42                	ld	s4,48(sp)
    80002708:	7aa2                	ld	s5,40(sp)
    8000270a:	7b02                	ld	s6,32(sp)
    8000270c:	6be2                	ld	s7,24(sp)
    8000270e:	6c42                	ld	s8,16(sp)
    80002710:	6ca2                	ld	s9,8(sp)
    80002712:	6d02                	ld	s10,0(sp)
    80002714:	6125                	add	sp,sp,96
    80002716:	8082                	ret
            release(&np->lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	56c080e7          	jalr	1388(ra) # 80000c86 <release>
            release(&wait_lock);
    80002722:	0000e517          	auipc	a0,0xe
    80002726:	40650513          	add	a0,a0,1030 # 80010b28 <wait_lock>
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	55c080e7          	jalr	1372(ra) # 80000c86 <release>
            return -1;
    80002732:	59fd                	li	s3,-1
    80002734:	b7d9                	j	800026fa <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    80002736:	18048493          	add	s1,s1,384
    8000273a:	03348463          	beq	s1,s3,80002762 <waitx+0x118>
      if (np->parent == p)
    8000273e:	7c9c                	ld	a5,56(s1)
    80002740:	ff279be3          	bne	a5,s2,80002736 <waitx+0xec>
        acquire(&np->lock);
    80002744:	8526                	mv	a0,s1
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	48c080e7          	jalr	1164(ra) # 80000bd2 <acquire>
        if (np->state == ZOMBIE)
    8000274e:	4c9c                	lw	a5,24(s1)
    80002750:	f54787e3          	beq	a5,s4,8000269e <waitx+0x54>
        release(&np->lock);
    80002754:	8526                	mv	a0,s1
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	530080e7          	jalr	1328(ra) # 80000c86 <release>
        havekids = 1;
    8000275e:	8756                	mv	a4,s5
    80002760:	bfd9                	j	80002736 <waitx+0xec>
    if (!havekids || p->killed)
    80002762:	c305                	beqz	a4,80002782 <waitx+0x138>
    80002764:	02892783          	lw	a5,40(s2)
    80002768:	ef89                	bnez	a5,80002782 <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000276a:	85ea                	mv	a1,s10
    8000276c:	854a                	mv	a0,s2
    8000276e:	00000097          	auipc	ra,0x0
    80002772:	990080e7          	jalr	-1648(ra) # 800020fe <sleep>
    havekids = 0;
    80002776:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002778:	0000e497          	auipc	s1,0xe
    8000277c:	7c848493          	add	s1,s1,1992 # 80010f40 <proc>
    80002780:	bf7d                	j	8000273e <waitx+0xf4>
      release(&wait_lock);
    80002782:	0000e517          	auipc	a0,0xe
    80002786:	3a650513          	add	a0,a0,934 # 80010b28 <wait_lock>
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	4fc080e7          	jalr	1276(ra) # 80000c86 <release>
      return -1;
    80002792:	59fd                	li	s3,-1
    80002794:	b79d                	j	800026fa <waitx+0xb0>

0000000080002796 <update_time>:

void update_time()
{
    80002796:	7179                	add	sp,sp,-48
    80002798:	f406                	sd	ra,40(sp)
    8000279a:	f022                	sd	s0,32(sp)
    8000279c:	ec26                	sd	s1,24(sp)
    8000279e:	e84a                	sd	s2,16(sp)
    800027a0:	e44e                	sd	s3,8(sp)
    800027a2:	e052                	sd	s4,0(sp)
    800027a4:	1800                	add	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800027a6:	0000e497          	auipc	s1,0xe
    800027aa:	79a48493          	add	s1,s1,1946 # 80010f40 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800027ae:	4991                	li	s3,4
    {
      p->rtime++;
    }

#ifdef MLFQ
    if (p->state == RUNNABLE || p->state == SLEEPING)
    800027b0:	4a05                	li	s4,1
  for (p = proc; p < &proc[NPROC]; p++)
    800027b2:	00014917          	auipc	s2,0x14
    800027b6:	78e90913          	add	s2,s2,1934 # 80016f40 <tickslock>
    800027ba:	a02d                	j	800027e4 <update_time+0x4e>
      p->rtime++;
    800027bc:	1684a783          	lw	a5,360(s1)
    800027c0:	2785                	addw	a5,a5,1
    800027c2:	16f4a423          	sw	a5,360(s1)
    if (p->state == RUNNABLE || p->state == SLEEPING)
    800027c6:	a031                	j	800027d2 <update_time+0x3c>
    {
      p->wait++; // the process is waiting
    800027c8:	17c4a783          	lw	a5,380(s1)
    800027cc:	2785                	addw	a5,a5,1
    800027ce:	16f4ae23          	sw	a5,380(s1)
    }
#endif

    release(&p->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	4b2080e7          	jalr	1202(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027dc:	18048493          	add	s1,s1,384
    800027e0:	01248e63          	beq	s1,s2,800027fc <update_time+0x66>
    acquire(&p->lock);
    800027e4:	8526                	mv	a0,s1
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	3ec080e7          	jalr	1004(ra) # 80000bd2 <acquire>
    if (p->state == RUNNING)
    800027ee:	4c9c                	lw	a5,24(s1)
    800027f0:	fd3786e3          	beq	a5,s3,800027bc <update_time+0x26>
    if (p->state == RUNNABLE || p->state == SLEEPING)
    800027f4:	37f9                	addw	a5,a5,-2
    800027f6:	fcfa79e3          	bgeu	s4,a5,800027c8 <update_time+0x32>
    800027fa:	bfe1                	j	800027d2 <update_time+0x3c>
  }
}
    800027fc:	70a2                	ld	ra,40(sp)
    800027fe:	7402                	ld	s0,32(sp)
    80002800:	64e2                	ld	s1,24(sp)
    80002802:	6942                	ld	s2,16(sp)
    80002804:	69a2                	ld	s3,8(sp)
    80002806:	6a02                	ld	s4,0(sp)
    80002808:	6145                	add	sp,sp,48
    8000280a:	8082                	ret

000000008000280c <swtch>:
    8000280c:	00153023          	sd	ra,0(a0)
    80002810:	00253423          	sd	sp,8(a0)
    80002814:	e900                	sd	s0,16(a0)
    80002816:	ed04                	sd	s1,24(a0)
    80002818:	03253023          	sd	s2,32(a0)
    8000281c:	03353423          	sd	s3,40(a0)
    80002820:	03453823          	sd	s4,48(a0)
    80002824:	03553c23          	sd	s5,56(a0)
    80002828:	05653023          	sd	s6,64(a0)
    8000282c:	05753423          	sd	s7,72(a0)
    80002830:	05853823          	sd	s8,80(a0)
    80002834:	05953c23          	sd	s9,88(a0)
    80002838:	07a53023          	sd	s10,96(a0)
    8000283c:	07b53423          	sd	s11,104(a0)
    80002840:	0005b083          	ld	ra,0(a1)
    80002844:	0085b103          	ld	sp,8(a1)
    80002848:	6980                	ld	s0,16(a1)
    8000284a:	6d84                	ld	s1,24(a1)
    8000284c:	0205b903          	ld	s2,32(a1)
    80002850:	0285b983          	ld	s3,40(a1)
    80002854:	0305ba03          	ld	s4,48(a1)
    80002858:	0385ba83          	ld	s5,56(a1)
    8000285c:	0405bb03          	ld	s6,64(a1)
    80002860:	0485bb83          	ld	s7,72(a1)
    80002864:	0505bc03          	ld	s8,80(a1)
    80002868:	0585bc83          	ld	s9,88(a1)
    8000286c:	0605bd03          	ld	s10,96(a1)
    80002870:	0685bd83          	ld	s11,104(a1)
    80002874:	8082                	ret

0000000080002876 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002876:	1141                	add	sp,sp,-16
    80002878:	e406                	sd	ra,8(sp)
    8000287a:	e022                	sd	s0,0(sp)
    8000287c:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000287e:	00006597          	auipc	a1,0x6
    80002882:	a3258593          	add	a1,a1,-1486 # 800082b0 <digits+0x270>
    80002886:	00014517          	auipc	a0,0x14
    8000288a:	6ba50513          	add	a0,a0,1722 # 80016f40 <tickslock>
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	2b4080e7          	jalr	692(ra) # 80000b42 <initlock>
}
    80002896:	60a2                	ld	ra,8(sp)
    80002898:	6402                	ld	s0,0(sp)
    8000289a:	0141                	add	sp,sp,16
    8000289c:	8082                	ret

000000008000289e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    8000289e:	1141                	add	sp,sp,-16
    800028a0:	e422                	sd	s0,8(sp)
    800028a2:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a4:	00003797          	auipc	a5,0x3
    800028a8:	5ec78793          	add	a5,a5,1516 # 80005e90 <kernelvec>
    800028ac:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028b0:	6422                	ld	s0,8(sp)
    800028b2:	0141                	add	sp,sp,16
    800028b4:	8082                	ret

00000000800028b6 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028b6:	1141                	add	sp,sp,-16
    800028b8:	e406                	sd	ra,8(sp)
    800028ba:	e022                	sd	s0,0(sp)
    800028bc:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800028be:	fffff097          	auipc	ra,0xfffff
    800028c2:	0f8080e7          	jalr	248(ra) # 800019b6 <myproc>
  p->etime = ticks; // join back the same queue at the end
    800028c6:	00006797          	auipc	a5,0x6
    800028ca:	fda7a783          	lw	a5,-38(a5) # 800088a0 <ticks>
    800028ce:	16f52823          	sw	a5,368(a0)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028d6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028dc:	00004697          	auipc	a3,0x4
    800028e0:	72468693          	add	a3,a3,1828 # 80007000 <_trampoline>
    800028e4:	00004717          	auipc	a4,0x4
    800028e8:	71c70713          	add	a4,a4,1820 # 80007000 <_trampoline>
    800028ec:	8f15                	sub	a4,a4,a3
    800028ee:	040007b7          	lui	a5,0x4000
    800028f2:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028f4:	07b2                	sll	a5,a5,0xc
    800028f6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028fc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028fe:	18002673          	csrr	a2,satp
    80002902:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002904:	6d30                	ld	a2,88(a0)
    80002906:	6138                	ld	a4,64(a0)
    80002908:	6585                	lui	a1,0x1
    8000290a:	972e                	add	a4,a4,a1
    8000290c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000290e:	6d38                	ld	a4,88(a0)
    80002910:	00000617          	auipc	a2,0x0
    80002914:	14260613          	add	a2,a2,322 # 80002a52 <usertrap>
    80002918:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000291a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000291c:	8612                	mv	a2,tp
    8000291e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002920:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002924:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002928:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002930:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002932:	6f18                	ld	a4,24(a4)
    80002934:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002938:	6928                	ld	a0,80(a0)
    8000293a:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000293c:	00004717          	auipc	a4,0x4
    80002940:	76070713          	add	a4,a4,1888 # 8000709c <userret>
    80002944:	8f15                	sub	a4,a4,a3
    80002946:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002948:	577d                	li	a4,-1
    8000294a:	177e                	sll	a4,a4,0x3f
    8000294c:	8d59                	or	a0,a0,a4
    8000294e:	9782                	jalr	a5
}
    80002950:	60a2                	ld	ra,8(sp)
    80002952:	6402                	ld	s0,0(sp)
    80002954:	0141                	add	sp,sp,16
    80002956:	8082                	ret

0000000080002958 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002958:	1101                	add	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	e04a                	sd	s2,0(sp)
    80002962:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002964:	00014917          	auipc	s2,0x14
    80002968:	5dc90913          	add	s2,s2,1500 # 80016f40 <tickslock>
    8000296c:	854a                	mv	a0,s2
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	264080e7          	jalr	612(ra) # 80000bd2 <acquire>
  ticks++;
    80002976:	00006497          	auipc	s1,0x6
    8000297a:	f2a48493          	add	s1,s1,-214 # 800088a0 <ticks>
    8000297e:	409c                	lw	a5,0(s1)
    80002980:	2785                	addw	a5,a5,1
    80002982:	c09c                	sw	a5,0(s1)
  update_time();
    80002984:	00000097          	auipc	ra,0x0
    80002988:	e12080e7          	jalr	-494(ra) # 80002796 <update_time>
  //   // {
  //   //   p->wait++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    8000298c:	8526                	mv	a0,s1
    8000298e:	fffff097          	auipc	ra,0xfffff
    80002992:	7d4080e7          	jalr	2004(ra) # 80002162 <wakeup>
  release(&tickslock);
    80002996:	854a                	mv	a0,s2
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	2ee080e7          	jalr	750(ra) # 80000c86 <release>
}
    800029a0:	60e2                	ld	ra,24(sp)
    800029a2:	6442                	ld	s0,16(sp)
    800029a4:	64a2                	ld	s1,8(sp)
    800029a6:	6902                	ld	s2,0(sp)
    800029a8:	6105                	add	sp,sp,32
    800029aa:	8082                	ret

00000000800029ac <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ac:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    800029b0:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    800029b2:	0807df63          	bgez	a5,80002a50 <devintr+0xa4>
{
    800029b6:	1101                	add	sp,sp,-32
    800029b8:	ec06                	sd	ra,24(sp)
    800029ba:	e822                	sd	s0,16(sp)
    800029bc:	e426                	sd	s1,8(sp)
    800029be:	1000                	add	s0,sp,32
      (scause & 0xff) == 9)
    800029c0:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    800029c4:	46a5                	li	a3,9
    800029c6:	00d70d63          	beq	a4,a3,800029e0 <devintr+0x34>
  else if (scause == 0x8000000000000001L)
    800029ca:	577d                	li	a4,-1
    800029cc:	177e                	sll	a4,a4,0x3f
    800029ce:	0705                	add	a4,a4,1
    return 0;
    800029d0:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800029d2:	04e78e63          	beq	a5,a4,80002a2e <devintr+0x82>
  }
}
    800029d6:	60e2                	ld	ra,24(sp)
    800029d8:	6442                	ld	s0,16(sp)
    800029da:	64a2                	ld	s1,8(sp)
    800029dc:	6105                	add	sp,sp,32
    800029de:	8082                	ret
    int irq = plic_claim();
    800029e0:	00003097          	auipc	ra,0x3
    800029e4:	5b8080e7          	jalr	1464(ra) # 80005f98 <plic_claim>
    800029e8:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800029ea:	47a9                	li	a5,10
    800029ec:	02f50763          	beq	a0,a5,80002a1a <devintr+0x6e>
    else if (irq == VIRTIO0_IRQ)
    800029f0:	4785                	li	a5,1
    800029f2:	02f50963          	beq	a0,a5,80002a24 <devintr+0x78>
    return 1;
    800029f6:	4505                	li	a0,1
    else if (irq)
    800029f8:	dcf9                	beqz	s1,800029d6 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800029fa:	85a6                	mv	a1,s1
    800029fc:	00006517          	auipc	a0,0x6
    80002a00:	8bc50513          	add	a0,a0,-1860 # 800082b8 <digits+0x278>
    80002a04:	ffffe097          	auipc	ra,0xffffe
    80002a08:	b82080e7          	jalr	-1150(ra) # 80000586 <printf>
      plic_complete(irq);
    80002a0c:	8526                	mv	a0,s1
    80002a0e:	00003097          	auipc	ra,0x3
    80002a12:	5ae080e7          	jalr	1454(ra) # 80005fbc <plic_complete>
    return 1;
    80002a16:	4505                	li	a0,1
    80002a18:	bf7d                	j	800029d6 <devintr+0x2a>
      uartintr();
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	f7a080e7          	jalr	-134(ra) # 80000994 <uartintr>
    if (irq)
    80002a22:	b7ed                	j	80002a0c <devintr+0x60>
      virtio_disk_intr();
    80002a24:	00004097          	auipc	ra,0x4
    80002a28:	a5e080e7          	jalr	-1442(ra) # 80006482 <virtio_disk_intr>
    if (irq)
    80002a2c:	b7c5                	j	80002a0c <devintr+0x60>
    if (cpuid() == 0)
    80002a2e:	fffff097          	auipc	ra,0xfffff
    80002a32:	f5c080e7          	jalr	-164(ra) # 8000198a <cpuid>
    80002a36:	c901                	beqz	a0,80002a46 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a38:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a3c:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a3e:	14479073          	csrw	sip,a5
    return 2;
    80002a42:	4509                	li	a0,2
    80002a44:	bf49                	j	800029d6 <devintr+0x2a>
      clockintr();
    80002a46:	00000097          	auipc	ra,0x0
    80002a4a:	f12080e7          	jalr	-238(ra) # 80002958 <clockintr>
    80002a4e:	b7ed                	j	80002a38 <devintr+0x8c>
}
    80002a50:	8082                	ret

0000000080002a52 <usertrap>:
{
    80002a52:	1101                	add	sp,sp,-32
    80002a54:	ec06                	sd	ra,24(sp)
    80002a56:	e822                	sd	s0,16(sp)
    80002a58:	e426                	sd	s1,8(sp)
    80002a5a:	e04a                	sd	s2,0(sp)
    80002a5c:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a5e:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a62:	1007f793          	and	a5,a5,256
    80002a66:	e3b1                	bnez	a5,80002aaa <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a68:	00003797          	auipc	a5,0x3
    80002a6c:	42878793          	add	a5,a5,1064 # 80005e90 <kernelvec>
    80002a70:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	f42080e7          	jalr	-190(ra) # 800019b6 <myproc>
    80002a7c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a7e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a80:	14102773          	csrr	a4,sepc
    80002a84:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a86:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002a8a:	47a1                	li	a5,8
    80002a8c:	02f70763          	beq	a4,a5,80002aba <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002a90:	00000097          	auipc	ra,0x0
    80002a94:	f1c080e7          	jalr	-228(ra) # 800029ac <devintr>
    80002a98:	892a                	mv	s2,a0
    80002a9a:	c151                	beqz	a0,80002b1e <usertrap+0xcc>
  if (killed(p))
    80002a9c:	8526                	mv	a0,s1
    80002a9e:	00000097          	auipc	ra,0x0
    80002aa2:	914080e7          	jalr	-1772(ra) # 800023b2 <killed>
    80002aa6:	c929                	beqz	a0,80002af8 <usertrap+0xa6>
    80002aa8:	a099                	j	80002aee <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002aaa:	00006517          	auipc	a0,0x6
    80002aae:	82e50513          	add	a0,a0,-2002 # 800082d8 <digits+0x298>
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	a8a080e7          	jalr	-1398(ra) # 8000053c <panic>
    if (killed(p))
    80002aba:	00000097          	auipc	ra,0x0
    80002abe:	8f8080e7          	jalr	-1800(ra) # 800023b2 <killed>
    80002ac2:	e921                	bnez	a0,80002b12 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002ac4:	6cb8                	ld	a4,88(s1)
    80002ac6:	6f1c                	ld	a5,24(a4)
    80002ac8:	0791                	add	a5,a5,4
    80002aca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002acc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ad0:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad4:	10079073          	csrw	sstatus,a5
    syscall();
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	35c080e7          	jalr	860(ra) # 80002e34 <syscall>
  if (killed(p))
    80002ae0:	8526                	mv	a0,s1
    80002ae2:	00000097          	auipc	ra,0x0
    80002ae6:	8d0080e7          	jalr	-1840(ra) # 800023b2 <killed>
    80002aea:	c911                	beqz	a0,80002afe <usertrap+0xac>
    80002aec:	4901                	li	s2,0
    exit(-1);
    80002aee:	557d                	li	a0,-1
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	742080e7          	jalr	1858(ra) # 80002232 <exit>
  if (which_dev == 2)
    80002af8:	4789                	li	a5,2
    80002afa:	04f90f63          	beq	s2,a5,80002b58 <usertrap+0x106>
  usertrapret();
    80002afe:	00000097          	auipc	ra,0x0
    80002b02:	db8080e7          	jalr	-584(ra) # 800028b6 <usertrapret>
}
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6902                	ld	s2,0(sp)
    80002b0e:	6105                	add	sp,sp,32
    80002b10:	8082                	ret
      exit(-1);
    80002b12:	557d                	li	a0,-1
    80002b14:	fffff097          	auipc	ra,0xfffff
    80002b18:	71e080e7          	jalr	1822(ra) # 80002232 <exit>
    80002b1c:	b765                	j	80002ac4 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b22:	5890                	lw	a2,48(s1)
    80002b24:	00005517          	auipc	a0,0x5
    80002b28:	7d450513          	add	a0,a0,2004 # 800082f8 <digits+0x2b8>
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	a5a080e7          	jalr	-1446(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b34:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b38:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b3c:	00005517          	auipc	a0,0x5
    80002b40:	7ec50513          	add	a0,a0,2028 # 80008328 <digits+0x2e8>
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	a42080e7          	jalr	-1470(ra) # 80000586 <printf>
    setkilled(p);
    80002b4c:	8526                	mv	a0,s1
    80002b4e:	00000097          	auipc	ra,0x0
    80002b52:	838080e7          	jalr	-1992(ra) # 80002386 <setkilled>
    80002b56:	b769                	j	80002ae0 <usertrap+0x8e>
    struct proc* curr = myproc();
    80002b58:	fffff097          	auipc	ra,0xfffff
    80002b5c:	e5e080e7          	jalr	-418(ra) # 800019b6 <myproc>
    if ((ticks - curr->entry) >= qticks[curr->priority]) {
    80002b60:	00006617          	auipc	a2,0x6
    80002b64:	d4062603          	lw	a2,-704(a2) # 800088a0 <ticks>
    80002b68:	17452683          	lw	a3,372(a0)
    80002b6c:	17852783          	lw	a5,376(a0)
    80002b70:	02069713          	sll	a4,a3,0x20
    80002b74:	01e75593          	srl	a1,a4,0x1e
    80002b78:	00006717          	auipc	a4,0x6
    80002b7c:	ce070713          	add	a4,a4,-800 # 80008858 <qticks>
    80002b80:	972e                	add	a4,a4,a1
    80002b82:	40f607bb          	subw	a5,a2,a5
    80002b86:	4318                	lw	a4,0(a4)
    80002b88:	f6e7ebe3          	bltu	a5,a4,80002afe <usertrap+0xac>
      if (curr->priority < 3) {
    80002b8c:	4789                	li	a5,2
    80002b8e:	00d7e563          	bltu	a5,a3,80002b98 <usertrap+0x146>
        curr->priority++;
    80002b92:	2685                	addw	a3,a3,1
    80002b94:	16d52a23          	sw	a3,372(a0)
      curr->entry = ticks;
    80002b98:	16c52c23          	sw	a2,376(a0)
      yield();
    80002b9c:	fffff097          	auipc	ra,0xfffff
    80002ba0:	526080e7          	jalr	1318(ra) # 800020c2 <yield>
    80002ba4:	bfa9                	j	80002afe <usertrap+0xac>

0000000080002ba6 <kerneltrap>:
{
    80002ba6:	7179                	add	sp,sp,-48
    80002ba8:	f406                	sd	ra,40(sp)
    80002baa:	f022                	sd	s0,32(sp)
    80002bac:	ec26                	sd	s1,24(sp)
    80002bae:	e84a                	sd	s2,16(sp)
    80002bb0:	e44e                	sd	s3,8(sp)
    80002bb2:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bb4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bbc:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002bc0:	1004f793          	and	a5,s1,256
    80002bc4:	cb85                	beqz	a5,80002bf4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bca:	8b89                	and	a5,a5,2
  if (intr_get() != 0)
    80002bcc:	ef85                	bnez	a5,80002c04 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002bce:	00000097          	auipc	ra,0x0
    80002bd2:	dde080e7          	jalr	-546(ra) # 800029ac <devintr>
    80002bd6:	cd1d                	beqz	a0,80002c14 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bd8:	4789                	li	a5,2
    80002bda:	06f50a63          	beq	a0,a5,80002c4e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bde:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be2:	10049073          	csrw	sstatus,s1
}
    80002be6:	70a2                	ld	ra,40(sp)
    80002be8:	7402                	ld	s0,32(sp)
    80002bea:	64e2                	ld	s1,24(sp)
    80002bec:	6942                	ld	s2,16(sp)
    80002bee:	69a2                	ld	s3,8(sp)
    80002bf0:	6145                	add	sp,sp,48
    80002bf2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bf4:	00005517          	auipc	a0,0x5
    80002bf8:	75450513          	add	a0,a0,1876 # 80008348 <digits+0x308>
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	940080e7          	jalr	-1728(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002c04:	00005517          	auipc	a0,0x5
    80002c08:	76c50513          	add	a0,a0,1900 # 80008370 <digits+0x330>
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	930080e7          	jalr	-1744(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002c14:	85ce                	mv	a1,s3
    80002c16:	00005517          	auipc	a0,0x5
    80002c1a:	77a50513          	add	a0,a0,1914 # 80008390 <digits+0x350>
    80002c1e:	ffffe097          	auipc	ra,0xffffe
    80002c22:	968080e7          	jalr	-1688(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c26:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c2a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c2e:	00005517          	auipc	a0,0x5
    80002c32:	77250513          	add	a0,a0,1906 # 800083a0 <digits+0x360>
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	950080e7          	jalr	-1712(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	77a50513          	add	a0,a0,1914 # 800083b8 <digits+0x378>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	8f6080e7          	jalr	-1802(ra) # 8000053c <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	d68080e7          	jalr	-664(ra) # 800019b6 <myproc>
    80002c56:	d541                	beqz	a0,80002bde <kerneltrap+0x38>
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	d5e080e7          	jalr	-674(ra) # 800019b6 <myproc>
    80002c60:	4d18                	lw	a4,24(a0)
    80002c62:	4791                	li	a5,4
    80002c64:	f6f71de3          	bne	a4,a5,80002bde <kerneltrap+0x38>
    struct proc* curr = myproc();
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	d4e080e7          	jalr	-690(ra) # 800019b6 <myproc>
    if ((ticks - curr->entry) >= qticks[curr->priority]) {
    80002c70:	00006617          	auipc	a2,0x6
    80002c74:	c3062603          	lw	a2,-976(a2) # 800088a0 <ticks>
    80002c78:	17452683          	lw	a3,372(a0)
    80002c7c:	17852783          	lw	a5,376(a0)
    80002c80:	02069713          	sll	a4,a3,0x20
    80002c84:	01e75593          	srl	a1,a4,0x1e
    80002c88:	00006717          	auipc	a4,0x6
    80002c8c:	bd070713          	add	a4,a4,-1072 # 80008858 <qticks>
    80002c90:	972e                	add	a4,a4,a1
    80002c92:	40f607bb          	subw	a5,a2,a5
    80002c96:	4318                	lw	a4,0(a4)
    80002c98:	f4e7e3e3          	bltu	a5,a4,80002bde <kerneltrap+0x38>
      if (curr->priority < 3) {
    80002c9c:	4789                	li	a5,2
    80002c9e:	00d7e563          	bltu	a5,a3,80002ca8 <kerneltrap+0x102>
        curr->priority++;
    80002ca2:	2685                	addw	a3,a3,1
    80002ca4:	16d52a23          	sw	a3,372(a0)
      curr->entry = ticks;
    80002ca8:	16c52c23          	sw	a2,376(a0)
      yield();
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	416080e7          	jalr	1046(ra) # 800020c2 <yield>
    80002cb4:	b72d                	j	80002bde <kerneltrap+0x38>

0000000080002cb6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cb6:	1101                	add	sp,sp,-32
    80002cb8:	ec06                	sd	ra,24(sp)
    80002cba:	e822                	sd	s0,16(sp)
    80002cbc:	e426                	sd	s1,8(sp)
    80002cbe:	1000                	add	s0,sp,32
    80002cc0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	cf4080e7          	jalr	-780(ra) # 800019b6 <myproc>
  switch (n) {
    80002cca:	4795                	li	a5,5
    80002ccc:	0497e163          	bltu	a5,s1,80002d0e <argraw+0x58>
    80002cd0:	048a                	sll	s1,s1,0x2
    80002cd2:	00005717          	auipc	a4,0x5
    80002cd6:	71e70713          	add	a4,a4,1822 # 800083f0 <digits+0x3b0>
    80002cda:	94ba                	add	s1,s1,a4
    80002cdc:	409c                	lw	a5,0(s1)
    80002cde:	97ba                	add	a5,a5,a4
    80002ce0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ce2:	6d3c                	ld	a5,88(a0)
    80002ce4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6105                	add	sp,sp,32
    80002cee:	8082                	ret
    return p->trapframe->a1;
    80002cf0:	6d3c                	ld	a5,88(a0)
    80002cf2:	7fa8                	ld	a0,120(a5)
    80002cf4:	bfcd                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a2;
    80002cf6:	6d3c                	ld	a5,88(a0)
    80002cf8:	63c8                	ld	a0,128(a5)
    80002cfa:	b7f5                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a3;
    80002cfc:	6d3c                	ld	a5,88(a0)
    80002cfe:	67c8                	ld	a0,136(a5)
    80002d00:	b7dd                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a4;
    80002d02:	6d3c                	ld	a5,88(a0)
    80002d04:	6bc8                	ld	a0,144(a5)
    80002d06:	b7c5                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a5;
    80002d08:	6d3c                	ld	a5,88(a0)
    80002d0a:	6fc8                	ld	a0,152(a5)
    80002d0c:	bfe9                	j	80002ce6 <argraw+0x30>
  panic("argraw");
    80002d0e:	00005517          	auipc	a0,0x5
    80002d12:	6ba50513          	add	a0,a0,1722 # 800083c8 <digits+0x388>
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	826080e7          	jalr	-2010(ra) # 8000053c <panic>

0000000080002d1e <fetchaddr>:
{
    80002d1e:	1101                	add	sp,sp,-32
    80002d20:	ec06                	sd	ra,24(sp)
    80002d22:	e822                	sd	s0,16(sp)
    80002d24:	e426                	sd	s1,8(sp)
    80002d26:	e04a                	sd	s2,0(sp)
    80002d28:	1000                	add	s0,sp,32
    80002d2a:	84aa                	mv	s1,a0
    80002d2c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d2e:	fffff097          	auipc	ra,0xfffff
    80002d32:	c88080e7          	jalr	-888(ra) # 800019b6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d36:	653c                	ld	a5,72(a0)
    80002d38:	02f4f863          	bgeu	s1,a5,80002d68 <fetchaddr+0x4a>
    80002d3c:	00848713          	add	a4,s1,8
    80002d40:	02e7e663          	bltu	a5,a4,80002d6c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d44:	46a1                	li	a3,8
    80002d46:	8626                	mv	a2,s1
    80002d48:	85ca                	mv	a1,s2
    80002d4a:	6928                	ld	a0,80(a0)
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	9b6080e7          	jalr	-1610(ra) # 80001702 <copyin>
    80002d54:	00a03533          	snez	a0,a0
    80002d58:	40a00533          	neg	a0,a0
}
    80002d5c:	60e2                	ld	ra,24(sp)
    80002d5e:	6442                	ld	s0,16(sp)
    80002d60:	64a2                	ld	s1,8(sp)
    80002d62:	6902                	ld	s2,0(sp)
    80002d64:	6105                	add	sp,sp,32
    80002d66:	8082                	ret
    return -1;
    80002d68:	557d                	li	a0,-1
    80002d6a:	bfcd                	j	80002d5c <fetchaddr+0x3e>
    80002d6c:	557d                	li	a0,-1
    80002d6e:	b7fd                	j	80002d5c <fetchaddr+0x3e>

0000000080002d70 <fetchstr>:
{
    80002d70:	7179                	add	sp,sp,-48
    80002d72:	f406                	sd	ra,40(sp)
    80002d74:	f022                	sd	s0,32(sp)
    80002d76:	ec26                	sd	s1,24(sp)
    80002d78:	e84a                	sd	s2,16(sp)
    80002d7a:	e44e                	sd	s3,8(sp)
    80002d7c:	1800                	add	s0,sp,48
    80002d7e:	892a                	mv	s2,a0
    80002d80:	84ae                	mv	s1,a1
    80002d82:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	c32080e7          	jalr	-974(ra) # 800019b6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d8c:	86ce                	mv	a3,s3
    80002d8e:	864a                	mv	a2,s2
    80002d90:	85a6                	mv	a1,s1
    80002d92:	6928                	ld	a0,80(a0)
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	9fc080e7          	jalr	-1540(ra) # 80001790 <copyinstr>
    80002d9c:	00054e63          	bltz	a0,80002db8 <fetchstr+0x48>
  return strlen(buf);
    80002da0:	8526                	mv	a0,s1
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	0a6080e7          	jalr	166(ra) # 80000e48 <strlen>
}
    80002daa:	70a2                	ld	ra,40(sp)
    80002dac:	7402                	ld	s0,32(sp)
    80002dae:	64e2                	ld	s1,24(sp)
    80002db0:	6942                	ld	s2,16(sp)
    80002db2:	69a2                	ld	s3,8(sp)
    80002db4:	6145                	add	sp,sp,48
    80002db6:	8082                	ret
    return -1;
    80002db8:	557d                	li	a0,-1
    80002dba:	bfc5                	j	80002daa <fetchstr+0x3a>

0000000080002dbc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dbc:	1101                	add	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	1000                	add	s0,sp,32
    80002dc6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dc8:	00000097          	auipc	ra,0x0
    80002dcc:	eee080e7          	jalr	-274(ra) # 80002cb6 <argraw>
    80002dd0:	c088                	sw	a0,0(s1)
}
    80002dd2:	60e2                	ld	ra,24(sp)
    80002dd4:	6442                	ld	s0,16(sp)
    80002dd6:	64a2                	ld	s1,8(sp)
    80002dd8:	6105                	add	sp,sp,32
    80002dda:	8082                	ret

0000000080002ddc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ddc:	1101                	add	sp,sp,-32
    80002dde:	ec06                	sd	ra,24(sp)
    80002de0:	e822                	sd	s0,16(sp)
    80002de2:	e426                	sd	s1,8(sp)
    80002de4:	1000                	add	s0,sp,32
    80002de6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	ece080e7          	jalr	-306(ra) # 80002cb6 <argraw>
    80002df0:	e088                	sd	a0,0(s1)
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6105                	add	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dfc:	7179                	add	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	1800                	add	s0,sp,48
    80002e08:	84ae                	mv	s1,a1
    80002e0a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e0c:	fd840593          	add	a1,s0,-40
    80002e10:	00000097          	auipc	ra,0x0
    80002e14:	fcc080e7          	jalr	-52(ra) # 80002ddc <argaddr>
  return fetchstr(addr, buf, max);
    80002e18:	864a                	mv	a2,s2
    80002e1a:	85a6                	mv	a1,s1
    80002e1c:	fd843503          	ld	a0,-40(s0)
    80002e20:	00000097          	auipc	ra,0x0
    80002e24:	f50080e7          	jalr	-176(ra) # 80002d70 <fetchstr>
}
    80002e28:	70a2                	ld	ra,40(sp)
    80002e2a:	7402                	ld	s0,32(sp)
    80002e2c:	64e2                	ld	s1,24(sp)
    80002e2e:	6942                	ld	s2,16(sp)
    80002e30:	6145                	add	sp,sp,48
    80002e32:	8082                	ret

0000000080002e34 <syscall>:
[SYS_getreadcount] sys_getreadcount
};

void
syscall(void)
{
    80002e34:	1101                	add	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	e04a                	sd	s2,0(sp)
    80002e3e:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	b76080e7          	jalr	-1162(ra) # 800019b6 <myproc>
    80002e48:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e4a:	05853903          	ld	s2,88(a0)
    80002e4e:	0a893783          	ld	a5,168(s2)
    80002e52:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e56:	37fd                	addw	a5,a5,-1
    80002e58:	4759                	li	a4,22
    80002e5a:	00f76f63          	bltu	a4,a5,80002e78 <syscall+0x44>
    80002e5e:	00369713          	sll	a4,a3,0x3
    80002e62:	00005797          	auipc	a5,0x5
    80002e66:	5a678793          	add	a5,a5,1446 # 80008408 <syscalls>
    80002e6a:	97ba                	add	a5,a5,a4
    80002e6c:	639c                	ld	a5,0(a5)
    80002e6e:	c789                	beqz	a5,80002e78 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e70:	9782                	jalr	a5
    80002e72:	06a93823          	sd	a0,112(s2)
    80002e76:	a839                	j	80002e94 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e78:	15848613          	add	a2,s1,344
    80002e7c:	588c                	lw	a1,48(s1)
    80002e7e:	00005517          	auipc	a0,0x5
    80002e82:	55250513          	add	a0,a0,1362 # 800083d0 <digits+0x390>
    80002e86:	ffffd097          	auipc	ra,0xffffd
    80002e8a:	700080e7          	jalr	1792(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e8e:	6cbc                	ld	a5,88(s1)
    80002e90:	577d                	li	a4,-1
    80002e92:	fbb8                	sd	a4,112(a5)
  }
}
    80002e94:	60e2                	ld	ra,24(sp)
    80002e96:	6442                	ld	s0,16(sp)
    80002e98:	64a2                	ld	s1,8(sp)
    80002e9a:	6902                	ld	s2,0(sp)
    80002e9c:	6105                	add	sp,sp,32
    80002e9e:	8082                	ret

0000000080002ea0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ea0:	1101                	add	sp,sp,-32
    80002ea2:	ec06                	sd	ra,24(sp)
    80002ea4:	e822                	sd	s0,16(sp)
    80002ea6:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002ea8:	fec40593          	add	a1,s0,-20
    80002eac:	4501                	li	a0,0
    80002eae:	00000097          	auipc	ra,0x0
    80002eb2:	f0e080e7          	jalr	-242(ra) # 80002dbc <argint>
  exit(n);
    80002eb6:	fec42503          	lw	a0,-20(s0)
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	378080e7          	jalr	888(ra) # 80002232 <exit>
  return 0; // not reached
}
    80002ec2:	4501                	li	a0,0
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	6105                	add	sp,sp,32
    80002eca:	8082                	ret

0000000080002ecc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ecc:	1141                	add	sp,sp,-16
    80002ece:	e406                	sd	ra,8(sp)
    80002ed0:	e022                	sd	s0,0(sp)
    80002ed2:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002ed4:	fffff097          	auipc	ra,0xfffff
    80002ed8:	ae2080e7          	jalr	-1310(ra) # 800019b6 <myproc>
}
    80002edc:	5908                	lw	a0,48(a0)
    80002ede:	60a2                	ld	ra,8(sp)
    80002ee0:	6402                	ld	s0,0(sp)
    80002ee2:	0141                	add	sp,sp,16
    80002ee4:	8082                	ret

0000000080002ee6 <sys_fork>:

uint64
sys_fork(void)
{
    80002ee6:	1141                	add	sp,sp,-16
    80002ee8:	e406                	sd	ra,8(sp)
    80002eea:	e022                	sd	s0,0(sp)
    80002eec:	0800                	add	s0,sp,16
  return fork();
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	e9e080e7          	jalr	-354(ra) # 80001d8c <fork>
}
    80002ef6:	60a2                	ld	ra,8(sp)
    80002ef8:	6402                	ld	s0,0(sp)
    80002efa:	0141                	add	sp,sp,16
    80002efc:	8082                	ret

0000000080002efe <sys_wait>:

uint64
sys_wait(void)
{
    80002efe:	1101                	add	sp,sp,-32
    80002f00:	ec06                	sd	ra,24(sp)
    80002f02:	e822                	sd	s0,16(sp)
    80002f04:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f06:	fe840593          	add	a1,s0,-24
    80002f0a:	4501                	li	a0,0
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	ed0080e7          	jalr	-304(ra) # 80002ddc <argaddr>
  return wait(p);
    80002f14:	fe843503          	ld	a0,-24(s0)
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	4cc080e7          	jalr	1228(ra) # 800023e4 <wait>
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	6105                	add	sp,sp,32
    80002f26:	8082                	ret

0000000080002f28 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f28:	7179                	add	sp,sp,-48
    80002f2a:	f406                	sd	ra,40(sp)
    80002f2c:	f022                	sd	s0,32(sp)
    80002f2e:	ec26                	sd	s1,24(sp)
    80002f30:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f32:	fdc40593          	add	a1,s0,-36
    80002f36:	4501                	li	a0,0
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	e84080e7          	jalr	-380(ra) # 80002dbc <argint>
  addr = myproc()->sz;
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	a76080e7          	jalr	-1418(ra) # 800019b6 <myproc>
    80002f48:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002f4a:	fdc42503          	lw	a0,-36(s0)
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	de2080e7          	jalr	-542(ra) # 80001d30 <growproc>
    80002f56:	00054863          	bltz	a0,80002f66 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	70a2                	ld	ra,40(sp)
    80002f5e:	7402                	ld	s0,32(sp)
    80002f60:	64e2                	ld	s1,24(sp)
    80002f62:	6145                	add	sp,sp,48
    80002f64:	8082                	ret
    return -1;
    80002f66:	54fd                	li	s1,-1
    80002f68:	bfcd                	j	80002f5a <sys_sbrk+0x32>

0000000080002f6a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f6a:	7139                	add	sp,sp,-64
    80002f6c:	fc06                	sd	ra,56(sp)
    80002f6e:	f822                	sd	s0,48(sp)
    80002f70:	f426                	sd	s1,40(sp)
    80002f72:	f04a                	sd	s2,32(sp)
    80002f74:	ec4e                	sd	s3,24(sp)
    80002f76:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f78:	fcc40593          	add	a1,s0,-52
    80002f7c:	4501                	li	a0,0
    80002f7e:	00000097          	auipc	ra,0x0
    80002f82:	e3e080e7          	jalr	-450(ra) # 80002dbc <argint>
  acquire(&tickslock);
    80002f86:	00014517          	auipc	a0,0x14
    80002f8a:	fba50513          	add	a0,a0,-70 # 80016f40 <tickslock>
    80002f8e:	ffffe097          	auipc	ra,0xffffe
    80002f92:	c44080e7          	jalr	-956(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002f96:	00006917          	auipc	s2,0x6
    80002f9a:	90a92903          	lw	s2,-1782(s2) # 800088a0 <ticks>
  while (ticks - ticks0 < n)
    80002f9e:	fcc42783          	lw	a5,-52(s0)
    80002fa2:	cf9d                	beqz	a5,80002fe0 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fa4:	00014997          	auipc	s3,0x14
    80002fa8:	f9c98993          	add	s3,s3,-100 # 80016f40 <tickslock>
    80002fac:	00006497          	auipc	s1,0x6
    80002fb0:	8f448493          	add	s1,s1,-1804 # 800088a0 <ticks>
    if (killed(myproc()))
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	a02080e7          	jalr	-1534(ra) # 800019b6 <myproc>
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	3f6080e7          	jalr	1014(ra) # 800023b2 <killed>
    80002fc4:	ed15                	bnez	a0,80003000 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fc6:	85ce                	mv	a1,s3
    80002fc8:	8526                	mv	a0,s1
    80002fca:	fffff097          	auipc	ra,0xfffff
    80002fce:	134080e7          	jalr	308(ra) # 800020fe <sleep>
  while (ticks - ticks0 < n)
    80002fd2:	409c                	lw	a5,0(s1)
    80002fd4:	412787bb          	subw	a5,a5,s2
    80002fd8:	fcc42703          	lw	a4,-52(s0)
    80002fdc:	fce7ece3          	bltu	a5,a4,80002fb4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fe0:	00014517          	auipc	a0,0x14
    80002fe4:	f6050513          	add	a0,a0,-160 # 80016f40 <tickslock>
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	c9e080e7          	jalr	-866(ra) # 80000c86 <release>
  return 0;
    80002ff0:	4501                	li	a0,0
}
    80002ff2:	70e2                	ld	ra,56(sp)
    80002ff4:	7442                	ld	s0,48(sp)
    80002ff6:	74a2                	ld	s1,40(sp)
    80002ff8:	7902                	ld	s2,32(sp)
    80002ffa:	69e2                	ld	s3,24(sp)
    80002ffc:	6121                	add	sp,sp,64
    80002ffe:	8082                	ret
      release(&tickslock);
    80003000:	00014517          	auipc	a0,0x14
    80003004:	f4050513          	add	a0,a0,-192 # 80016f40 <tickslock>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	c7e080e7          	jalr	-898(ra) # 80000c86 <release>
      return -1;
    80003010:	557d                	li	a0,-1
    80003012:	b7c5                	j	80002ff2 <sys_sleep+0x88>

0000000080003014 <sys_kill>:

uint64
sys_kill(void)
{
    80003014:	1101                	add	sp,sp,-32
    80003016:	ec06                	sd	ra,24(sp)
    80003018:	e822                	sd	s0,16(sp)
    8000301a:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    8000301c:	fec40593          	add	a1,s0,-20
    80003020:	4501                	li	a0,0
    80003022:	00000097          	auipc	ra,0x0
    80003026:	d9a080e7          	jalr	-614(ra) # 80002dbc <argint>
  return kill(pid);
    8000302a:	fec42503          	lw	a0,-20(s0)
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	2e6080e7          	jalr	742(ra) # 80002314 <kill>
}
    80003036:	60e2                	ld	ra,24(sp)
    80003038:	6442                	ld	s0,16(sp)
    8000303a:	6105                	add	sp,sp,32
    8000303c:	8082                	ret

000000008000303e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000303e:	1101                	add	sp,sp,-32
    80003040:	ec06                	sd	ra,24(sp)
    80003042:	e822                	sd	s0,16(sp)
    80003044:	e426                	sd	s1,8(sp)
    80003046:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003048:	00014517          	auipc	a0,0x14
    8000304c:	ef850513          	add	a0,a0,-264 # 80016f40 <tickslock>
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	b82080e7          	jalr	-1150(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80003058:	00006497          	auipc	s1,0x6
    8000305c:	8484a483          	lw	s1,-1976(s1) # 800088a0 <ticks>
  release(&tickslock);
    80003060:	00014517          	auipc	a0,0x14
    80003064:	ee050513          	add	a0,a0,-288 # 80016f40 <tickslock>
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	c1e080e7          	jalr	-994(ra) # 80000c86 <release>
  return xticks;
}
    80003070:	02049513          	sll	a0,s1,0x20
    80003074:	9101                	srl	a0,a0,0x20
    80003076:	60e2                	ld	ra,24(sp)
    80003078:	6442                	ld	s0,16(sp)
    8000307a:	64a2                	ld	s1,8(sp)
    8000307c:	6105                	add	sp,sp,32
    8000307e:	8082                	ret

0000000080003080 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003080:	7139                	add	sp,sp,-64
    80003082:	fc06                	sd	ra,56(sp)
    80003084:	f822                	sd	s0,48(sp)
    80003086:	f426                	sd	s1,40(sp)
    80003088:	f04a                	sd	s2,32(sp)
    8000308a:	0080                	add	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000308c:	fd840593          	add	a1,s0,-40
    80003090:	4501                	li	a0,0
    80003092:	00000097          	auipc	ra,0x0
    80003096:	d4a080e7          	jalr	-694(ra) # 80002ddc <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000309a:	fd040593          	add	a1,s0,-48
    8000309e:	4505                	li	a0,1
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	d3c080e7          	jalr	-708(ra) # 80002ddc <argaddr>
  argaddr(2, &addr2);
    800030a8:	fc840593          	add	a1,s0,-56
    800030ac:	4509                	li	a0,2
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	d2e080e7          	jalr	-722(ra) # 80002ddc <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800030b6:	fc040613          	add	a2,s0,-64
    800030ba:	fc440593          	add	a1,s0,-60
    800030be:	fd843503          	ld	a0,-40(s0)
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	588080e7          	jalr	1416(ra) # 8000264a <waitx>
    800030ca:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800030cc:	fffff097          	auipc	ra,0xfffff
    800030d0:	8ea080e7          	jalr	-1814(ra) # 800019b6 <myproc>
    800030d4:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030d6:	4691                	li	a3,4
    800030d8:	fc440613          	add	a2,s0,-60
    800030dc:	fd043583          	ld	a1,-48(s0)
    800030e0:	6928                	ld	a0,80(a0)
    800030e2:	ffffe097          	auipc	ra,0xffffe
    800030e6:	594080e7          	jalr	1428(ra) # 80001676 <copyout>
    return -1;
    800030ea:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030ec:	00054f63          	bltz	a0,8000310a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800030f0:	4691                	li	a3,4
    800030f2:	fc040613          	add	a2,s0,-64
    800030f6:	fc843583          	ld	a1,-56(s0)
    800030fa:	68a8                	ld	a0,80(s1)
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	57a080e7          	jalr	1402(ra) # 80001676 <copyout>
    80003104:	00054a63          	bltz	a0,80003118 <sys_waitx+0x98>
    return -1;
  return ret;
    80003108:	87ca                	mv	a5,s2
    8000310a:	853e                	mv	a0,a5
    8000310c:	70e2                	ld	ra,56(sp)
    8000310e:	7442                	ld	s0,48(sp)
    80003110:	74a2                	ld	s1,40(sp)
    80003112:	7902                	ld	s2,32(sp)
    80003114:	6121                	add	sp,sp,64
    80003116:	8082                	ret
    return -1;
    80003118:	57fd                	li	a5,-1
    8000311a:	bfc5                	j	8000310a <sys_waitx+0x8a>

000000008000311c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000311c:	7179                	add	sp,sp,-48
    8000311e:	f406                	sd	ra,40(sp)
    80003120:	f022                	sd	s0,32(sp)
    80003122:	ec26                	sd	s1,24(sp)
    80003124:	e84a                	sd	s2,16(sp)
    80003126:	e44e                	sd	s3,8(sp)
    80003128:	e052                	sd	s4,0(sp)
    8000312a:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000312c:	00005597          	auipc	a1,0x5
    80003130:	39c58593          	add	a1,a1,924 # 800084c8 <syscalls+0xc0>
    80003134:	00014517          	auipc	a0,0x14
    80003138:	e2450513          	add	a0,a0,-476 # 80016f58 <bcache>
    8000313c:	ffffe097          	auipc	ra,0xffffe
    80003140:	a06080e7          	jalr	-1530(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003144:	0001c797          	auipc	a5,0x1c
    80003148:	e1478793          	add	a5,a5,-492 # 8001ef58 <bcache+0x8000>
    8000314c:	0001c717          	auipc	a4,0x1c
    80003150:	07470713          	add	a4,a4,116 # 8001f1c0 <bcache+0x8268>
    80003154:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003158:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000315c:	00014497          	auipc	s1,0x14
    80003160:	e1448493          	add	s1,s1,-492 # 80016f70 <bcache+0x18>
    b->next = bcache.head.next;
    80003164:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003166:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003168:	00005a17          	auipc	s4,0x5
    8000316c:	368a0a13          	add	s4,s4,872 # 800084d0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003170:	2b893783          	ld	a5,696(s2)
    80003174:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003176:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000317a:	85d2                	mv	a1,s4
    8000317c:	01048513          	add	a0,s1,16
    80003180:	00001097          	auipc	ra,0x1
    80003184:	496080e7          	jalr	1174(ra) # 80004616 <initsleeplock>
    bcache.head.next->prev = b;
    80003188:	2b893783          	ld	a5,696(s2)
    8000318c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000318e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003192:	45848493          	add	s1,s1,1112
    80003196:	fd349de3          	bne	s1,s3,80003170 <binit+0x54>
  }
}
    8000319a:	70a2                	ld	ra,40(sp)
    8000319c:	7402                	ld	s0,32(sp)
    8000319e:	64e2                	ld	s1,24(sp)
    800031a0:	6942                	ld	s2,16(sp)
    800031a2:	69a2                	ld	s3,8(sp)
    800031a4:	6a02                	ld	s4,0(sp)
    800031a6:	6145                	add	sp,sp,48
    800031a8:	8082                	ret

00000000800031aa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031aa:	7179                	add	sp,sp,-48
    800031ac:	f406                	sd	ra,40(sp)
    800031ae:	f022                	sd	s0,32(sp)
    800031b0:	ec26                	sd	s1,24(sp)
    800031b2:	e84a                	sd	s2,16(sp)
    800031b4:	e44e                	sd	s3,8(sp)
    800031b6:	1800                	add	s0,sp,48
    800031b8:	892a                	mv	s2,a0
    800031ba:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031bc:	00014517          	auipc	a0,0x14
    800031c0:	d9c50513          	add	a0,a0,-612 # 80016f58 <bcache>
    800031c4:	ffffe097          	auipc	ra,0xffffe
    800031c8:	a0e080e7          	jalr	-1522(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031cc:	0001c497          	auipc	s1,0x1c
    800031d0:	0444b483          	ld	s1,68(s1) # 8001f210 <bcache+0x82b8>
    800031d4:	0001c797          	auipc	a5,0x1c
    800031d8:	fec78793          	add	a5,a5,-20 # 8001f1c0 <bcache+0x8268>
    800031dc:	02f48f63          	beq	s1,a5,8000321a <bread+0x70>
    800031e0:	873e                	mv	a4,a5
    800031e2:	a021                	j	800031ea <bread+0x40>
    800031e4:	68a4                	ld	s1,80(s1)
    800031e6:	02e48a63          	beq	s1,a4,8000321a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031ea:	449c                	lw	a5,8(s1)
    800031ec:	ff279ce3          	bne	a5,s2,800031e4 <bread+0x3a>
    800031f0:	44dc                	lw	a5,12(s1)
    800031f2:	ff3799e3          	bne	a5,s3,800031e4 <bread+0x3a>
      b->refcnt++;
    800031f6:	40bc                	lw	a5,64(s1)
    800031f8:	2785                	addw	a5,a5,1
    800031fa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031fc:	00014517          	auipc	a0,0x14
    80003200:	d5c50513          	add	a0,a0,-676 # 80016f58 <bcache>
    80003204:	ffffe097          	auipc	ra,0xffffe
    80003208:	a82080e7          	jalr	-1406(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000320c:	01048513          	add	a0,s1,16
    80003210:	00001097          	auipc	ra,0x1
    80003214:	440080e7          	jalr	1088(ra) # 80004650 <acquiresleep>
      return b;
    80003218:	a8b9                	j	80003276 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000321a:	0001c497          	auipc	s1,0x1c
    8000321e:	fee4b483          	ld	s1,-18(s1) # 8001f208 <bcache+0x82b0>
    80003222:	0001c797          	auipc	a5,0x1c
    80003226:	f9e78793          	add	a5,a5,-98 # 8001f1c0 <bcache+0x8268>
    8000322a:	00f48863          	beq	s1,a5,8000323a <bread+0x90>
    8000322e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003230:	40bc                	lw	a5,64(s1)
    80003232:	cf81                	beqz	a5,8000324a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003234:	64a4                	ld	s1,72(s1)
    80003236:	fee49de3          	bne	s1,a4,80003230 <bread+0x86>
  panic("bget: no buffers");
    8000323a:	00005517          	auipc	a0,0x5
    8000323e:	29e50513          	add	a0,a0,670 # 800084d8 <syscalls+0xd0>
    80003242:	ffffd097          	auipc	ra,0xffffd
    80003246:	2fa080e7          	jalr	762(ra) # 8000053c <panic>
      b->dev = dev;
    8000324a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000324e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003252:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003256:	4785                	li	a5,1
    80003258:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000325a:	00014517          	auipc	a0,0x14
    8000325e:	cfe50513          	add	a0,a0,-770 # 80016f58 <bcache>
    80003262:	ffffe097          	auipc	ra,0xffffe
    80003266:	a24080e7          	jalr	-1500(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000326a:	01048513          	add	a0,s1,16
    8000326e:	00001097          	auipc	ra,0x1
    80003272:	3e2080e7          	jalr	994(ra) # 80004650 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003276:	409c                	lw	a5,0(s1)
    80003278:	cb89                	beqz	a5,8000328a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000327a:	8526                	mv	a0,s1
    8000327c:	70a2                	ld	ra,40(sp)
    8000327e:	7402                	ld	s0,32(sp)
    80003280:	64e2                	ld	s1,24(sp)
    80003282:	6942                	ld	s2,16(sp)
    80003284:	69a2                	ld	s3,8(sp)
    80003286:	6145                	add	sp,sp,48
    80003288:	8082                	ret
    virtio_disk_rw(b, 0);
    8000328a:	4581                	li	a1,0
    8000328c:	8526                	mv	a0,s1
    8000328e:	00003097          	auipc	ra,0x3
    80003292:	fc4080e7          	jalr	-60(ra) # 80006252 <virtio_disk_rw>
    b->valid = 1;
    80003296:	4785                	li	a5,1
    80003298:	c09c                	sw	a5,0(s1)
  return b;
    8000329a:	b7c5                	j	8000327a <bread+0xd0>

000000008000329c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000329c:	1101                	add	sp,sp,-32
    8000329e:	ec06                	sd	ra,24(sp)
    800032a0:	e822                	sd	s0,16(sp)
    800032a2:	e426                	sd	s1,8(sp)
    800032a4:	1000                	add	s0,sp,32
    800032a6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032a8:	0541                	add	a0,a0,16
    800032aa:	00001097          	auipc	ra,0x1
    800032ae:	440080e7          	jalr	1088(ra) # 800046ea <holdingsleep>
    800032b2:	cd01                	beqz	a0,800032ca <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032b4:	4585                	li	a1,1
    800032b6:	8526                	mv	a0,s1
    800032b8:	00003097          	auipc	ra,0x3
    800032bc:	f9a080e7          	jalr	-102(ra) # 80006252 <virtio_disk_rw>
}
    800032c0:	60e2                	ld	ra,24(sp)
    800032c2:	6442                	ld	s0,16(sp)
    800032c4:	64a2                	ld	s1,8(sp)
    800032c6:	6105                	add	sp,sp,32
    800032c8:	8082                	ret
    panic("bwrite");
    800032ca:	00005517          	auipc	a0,0x5
    800032ce:	22650513          	add	a0,a0,550 # 800084f0 <syscalls+0xe8>
    800032d2:	ffffd097          	auipc	ra,0xffffd
    800032d6:	26a080e7          	jalr	618(ra) # 8000053c <panic>

00000000800032da <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032da:	1101                	add	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	e426                	sd	s1,8(sp)
    800032e2:	e04a                	sd	s2,0(sp)
    800032e4:	1000                	add	s0,sp,32
    800032e6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032e8:	01050913          	add	s2,a0,16
    800032ec:	854a                	mv	a0,s2
    800032ee:	00001097          	auipc	ra,0x1
    800032f2:	3fc080e7          	jalr	1020(ra) # 800046ea <holdingsleep>
    800032f6:	c925                	beqz	a0,80003366 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800032f8:	854a                	mv	a0,s2
    800032fa:	00001097          	auipc	ra,0x1
    800032fe:	3ac080e7          	jalr	940(ra) # 800046a6 <releasesleep>

  acquire(&bcache.lock);
    80003302:	00014517          	auipc	a0,0x14
    80003306:	c5650513          	add	a0,a0,-938 # 80016f58 <bcache>
    8000330a:	ffffe097          	auipc	ra,0xffffe
    8000330e:	8c8080e7          	jalr	-1848(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003312:	40bc                	lw	a5,64(s1)
    80003314:	37fd                	addw	a5,a5,-1
    80003316:	0007871b          	sext.w	a4,a5
    8000331a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000331c:	e71d                	bnez	a4,8000334a <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000331e:	68b8                	ld	a4,80(s1)
    80003320:	64bc                	ld	a5,72(s1)
    80003322:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003324:	68b8                	ld	a4,80(s1)
    80003326:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003328:	0001c797          	auipc	a5,0x1c
    8000332c:	c3078793          	add	a5,a5,-976 # 8001ef58 <bcache+0x8000>
    80003330:	2b87b703          	ld	a4,696(a5)
    80003334:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003336:	0001c717          	auipc	a4,0x1c
    8000333a:	e8a70713          	add	a4,a4,-374 # 8001f1c0 <bcache+0x8268>
    8000333e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003340:	2b87b703          	ld	a4,696(a5)
    80003344:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003346:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000334a:	00014517          	auipc	a0,0x14
    8000334e:	c0e50513          	add	a0,a0,-1010 # 80016f58 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	934080e7          	jalr	-1740(ra) # 80000c86 <release>
}
    8000335a:	60e2                	ld	ra,24(sp)
    8000335c:	6442                	ld	s0,16(sp)
    8000335e:	64a2                	ld	s1,8(sp)
    80003360:	6902                	ld	s2,0(sp)
    80003362:	6105                	add	sp,sp,32
    80003364:	8082                	ret
    panic("brelse");
    80003366:	00005517          	auipc	a0,0x5
    8000336a:	19250513          	add	a0,a0,402 # 800084f8 <syscalls+0xf0>
    8000336e:	ffffd097          	auipc	ra,0xffffd
    80003372:	1ce080e7          	jalr	462(ra) # 8000053c <panic>

0000000080003376 <bpin>:

void
bpin(struct buf *b) {
    80003376:	1101                	add	sp,sp,-32
    80003378:	ec06                	sd	ra,24(sp)
    8000337a:	e822                	sd	s0,16(sp)
    8000337c:	e426                	sd	s1,8(sp)
    8000337e:	1000                	add	s0,sp,32
    80003380:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003382:	00014517          	auipc	a0,0x14
    80003386:	bd650513          	add	a0,a0,-1066 # 80016f58 <bcache>
    8000338a:	ffffe097          	auipc	ra,0xffffe
    8000338e:	848080e7          	jalr	-1976(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003392:	40bc                	lw	a5,64(s1)
    80003394:	2785                	addw	a5,a5,1
    80003396:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003398:	00014517          	auipc	a0,0x14
    8000339c:	bc050513          	add	a0,a0,-1088 # 80016f58 <bcache>
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	8e6080e7          	jalr	-1818(ra) # 80000c86 <release>
}
    800033a8:	60e2                	ld	ra,24(sp)
    800033aa:	6442                	ld	s0,16(sp)
    800033ac:	64a2                	ld	s1,8(sp)
    800033ae:	6105                	add	sp,sp,32
    800033b0:	8082                	ret

00000000800033b2 <bunpin>:

void
bunpin(struct buf *b) {
    800033b2:	1101                	add	sp,sp,-32
    800033b4:	ec06                	sd	ra,24(sp)
    800033b6:	e822                	sd	s0,16(sp)
    800033b8:	e426                	sd	s1,8(sp)
    800033ba:	1000                	add	s0,sp,32
    800033bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033be:	00014517          	auipc	a0,0x14
    800033c2:	b9a50513          	add	a0,a0,-1126 # 80016f58 <bcache>
    800033c6:	ffffe097          	auipc	ra,0xffffe
    800033ca:	80c080e7          	jalr	-2036(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800033ce:	40bc                	lw	a5,64(s1)
    800033d0:	37fd                	addw	a5,a5,-1
    800033d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033d4:	00014517          	auipc	a0,0x14
    800033d8:	b8450513          	add	a0,a0,-1148 # 80016f58 <bcache>
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	8aa080e7          	jalr	-1878(ra) # 80000c86 <release>
}
    800033e4:	60e2                	ld	ra,24(sp)
    800033e6:	6442                	ld	s0,16(sp)
    800033e8:	64a2                	ld	s1,8(sp)
    800033ea:	6105                	add	sp,sp,32
    800033ec:	8082                	ret

00000000800033ee <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033ee:	1101                	add	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	e426                	sd	s1,8(sp)
    800033f6:	e04a                	sd	s2,0(sp)
    800033f8:	1000                	add	s0,sp,32
    800033fa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033fc:	00d5d59b          	srlw	a1,a1,0xd
    80003400:	0001c797          	auipc	a5,0x1c
    80003404:	2347a783          	lw	a5,564(a5) # 8001f634 <sb+0x1c>
    80003408:	9dbd                	addw	a1,a1,a5
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	da0080e7          	jalr	-608(ra) # 800031aa <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003412:	0074f713          	and	a4,s1,7
    80003416:	4785                	li	a5,1
    80003418:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000341c:	14ce                	sll	s1,s1,0x33
    8000341e:	90d9                	srl	s1,s1,0x36
    80003420:	00950733          	add	a4,a0,s1
    80003424:	05874703          	lbu	a4,88(a4)
    80003428:	00e7f6b3          	and	a3,a5,a4
    8000342c:	c69d                	beqz	a3,8000345a <bfree+0x6c>
    8000342e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003430:	94aa                	add	s1,s1,a0
    80003432:	fff7c793          	not	a5,a5
    80003436:	8f7d                	and	a4,a4,a5
    80003438:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000343c:	00001097          	auipc	ra,0x1
    80003440:	0f6080e7          	jalr	246(ra) # 80004532 <log_write>
  brelse(bp);
    80003444:	854a                	mv	a0,s2
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	e94080e7          	jalr	-364(ra) # 800032da <brelse>
}
    8000344e:	60e2                	ld	ra,24(sp)
    80003450:	6442                	ld	s0,16(sp)
    80003452:	64a2                	ld	s1,8(sp)
    80003454:	6902                	ld	s2,0(sp)
    80003456:	6105                	add	sp,sp,32
    80003458:	8082                	ret
    panic("freeing free block");
    8000345a:	00005517          	auipc	a0,0x5
    8000345e:	0a650513          	add	a0,a0,166 # 80008500 <syscalls+0xf8>
    80003462:	ffffd097          	auipc	ra,0xffffd
    80003466:	0da080e7          	jalr	218(ra) # 8000053c <panic>

000000008000346a <balloc>:
{
    8000346a:	711d                	add	sp,sp,-96
    8000346c:	ec86                	sd	ra,88(sp)
    8000346e:	e8a2                	sd	s0,80(sp)
    80003470:	e4a6                	sd	s1,72(sp)
    80003472:	e0ca                	sd	s2,64(sp)
    80003474:	fc4e                	sd	s3,56(sp)
    80003476:	f852                	sd	s4,48(sp)
    80003478:	f456                	sd	s5,40(sp)
    8000347a:	f05a                	sd	s6,32(sp)
    8000347c:	ec5e                	sd	s7,24(sp)
    8000347e:	e862                	sd	s8,16(sp)
    80003480:	e466                	sd	s9,8(sp)
    80003482:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003484:	0001c797          	auipc	a5,0x1c
    80003488:	1987a783          	lw	a5,408(a5) # 8001f61c <sb+0x4>
    8000348c:	cff5                	beqz	a5,80003588 <balloc+0x11e>
    8000348e:	8baa                	mv	s7,a0
    80003490:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003492:	0001cb17          	auipc	s6,0x1c
    80003496:	186b0b13          	add	s6,s6,390 # 8001f618 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000349a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000349c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000349e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034a0:	6c89                	lui	s9,0x2
    800034a2:	a061                	j	8000352a <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034a4:	97ca                	add	a5,a5,s2
    800034a6:	8e55                	or	a2,a2,a3
    800034a8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	00001097          	auipc	ra,0x1
    800034b2:	084080e7          	jalr	132(ra) # 80004532 <log_write>
        brelse(bp);
    800034b6:	854a                	mv	a0,s2
    800034b8:	00000097          	auipc	ra,0x0
    800034bc:	e22080e7          	jalr	-478(ra) # 800032da <brelse>
  bp = bread(dev, bno);
    800034c0:	85a6                	mv	a1,s1
    800034c2:	855e                	mv	a0,s7
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	ce6080e7          	jalr	-794(ra) # 800031aa <bread>
    800034cc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034ce:	40000613          	li	a2,1024
    800034d2:	4581                	li	a1,0
    800034d4:	05850513          	add	a0,a0,88
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	7f6080e7          	jalr	2038(ra) # 80000cce <memset>
  log_write(bp);
    800034e0:	854a                	mv	a0,s2
    800034e2:	00001097          	auipc	ra,0x1
    800034e6:	050080e7          	jalr	80(ra) # 80004532 <log_write>
  brelse(bp);
    800034ea:	854a                	mv	a0,s2
    800034ec:	00000097          	auipc	ra,0x0
    800034f0:	dee080e7          	jalr	-530(ra) # 800032da <brelse>
}
    800034f4:	8526                	mv	a0,s1
    800034f6:	60e6                	ld	ra,88(sp)
    800034f8:	6446                	ld	s0,80(sp)
    800034fa:	64a6                	ld	s1,72(sp)
    800034fc:	6906                	ld	s2,64(sp)
    800034fe:	79e2                	ld	s3,56(sp)
    80003500:	7a42                	ld	s4,48(sp)
    80003502:	7aa2                	ld	s5,40(sp)
    80003504:	7b02                	ld	s6,32(sp)
    80003506:	6be2                	ld	s7,24(sp)
    80003508:	6c42                	ld	s8,16(sp)
    8000350a:	6ca2                	ld	s9,8(sp)
    8000350c:	6125                	add	sp,sp,96
    8000350e:	8082                	ret
    brelse(bp);
    80003510:	854a                	mv	a0,s2
    80003512:	00000097          	auipc	ra,0x0
    80003516:	dc8080e7          	jalr	-568(ra) # 800032da <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000351a:	015c87bb          	addw	a5,s9,s5
    8000351e:	00078a9b          	sext.w	s5,a5
    80003522:	004b2703          	lw	a4,4(s6)
    80003526:	06eaf163          	bgeu	s5,a4,80003588 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000352a:	41fad79b          	sraw	a5,s5,0x1f
    8000352e:	0137d79b          	srlw	a5,a5,0x13
    80003532:	015787bb          	addw	a5,a5,s5
    80003536:	40d7d79b          	sraw	a5,a5,0xd
    8000353a:	01cb2583          	lw	a1,28(s6)
    8000353e:	9dbd                	addw	a1,a1,a5
    80003540:	855e                	mv	a0,s7
    80003542:	00000097          	auipc	ra,0x0
    80003546:	c68080e7          	jalr	-920(ra) # 800031aa <bread>
    8000354a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000354c:	004b2503          	lw	a0,4(s6)
    80003550:	000a849b          	sext.w	s1,s5
    80003554:	8762                	mv	a4,s8
    80003556:	faa4fde3          	bgeu	s1,a0,80003510 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000355a:	00777693          	and	a3,a4,7
    8000355e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003562:	41f7579b          	sraw	a5,a4,0x1f
    80003566:	01d7d79b          	srlw	a5,a5,0x1d
    8000356a:	9fb9                	addw	a5,a5,a4
    8000356c:	4037d79b          	sraw	a5,a5,0x3
    80003570:	00f90633          	add	a2,s2,a5
    80003574:	05864603          	lbu	a2,88(a2)
    80003578:	00c6f5b3          	and	a1,a3,a2
    8000357c:	d585                	beqz	a1,800034a4 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000357e:	2705                	addw	a4,a4,1
    80003580:	2485                	addw	s1,s1,1
    80003582:	fd471ae3          	bne	a4,s4,80003556 <balloc+0xec>
    80003586:	b769                	j	80003510 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003588:	00005517          	auipc	a0,0x5
    8000358c:	f9050513          	add	a0,a0,-112 # 80008518 <syscalls+0x110>
    80003590:	ffffd097          	auipc	ra,0xffffd
    80003594:	ff6080e7          	jalr	-10(ra) # 80000586 <printf>
  return 0;
    80003598:	4481                	li	s1,0
    8000359a:	bfa9                	j	800034f4 <balloc+0x8a>

000000008000359c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000359c:	7179                	add	sp,sp,-48
    8000359e:	f406                	sd	ra,40(sp)
    800035a0:	f022                	sd	s0,32(sp)
    800035a2:	ec26                	sd	s1,24(sp)
    800035a4:	e84a                	sd	s2,16(sp)
    800035a6:	e44e                	sd	s3,8(sp)
    800035a8:	e052                	sd	s4,0(sp)
    800035aa:	1800                	add	s0,sp,48
    800035ac:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035ae:	47ad                	li	a5,11
    800035b0:	02b7e863          	bltu	a5,a1,800035e0 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800035b4:	02059793          	sll	a5,a1,0x20
    800035b8:	01e7d593          	srl	a1,a5,0x1e
    800035bc:	00b504b3          	add	s1,a0,a1
    800035c0:	0504a903          	lw	s2,80(s1)
    800035c4:	06091e63          	bnez	s2,80003640 <bmap+0xa4>
      addr = balloc(ip->dev);
    800035c8:	4108                	lw	a0,0(a0)
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	ea0080e7          	jalr	-352(ra) # 8000346a <balloc>
    800035d2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035d6:	06090563          	beqz	s2,80003640 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800035da:	0524a823          	sw	s2,80(s1)
    800035de:	a08d                	j	80003640 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035e0:	ff45849b          	addw	s1,a1,-12
    800035e4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035e8:	0ff00793          	li	a5,255
    800035ec:	08e7e563          	bltu	a5,a4,80003676 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035f0:	08052903          	lw	s2,128(a0)
    800035f4:	00091d63          	bnez	s2,8000360e <bmap+0x72>
      addr = balloc(ip->dev);
    800035f8:	4108                	lw	a0,0(a0)
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	e70080e7          	jalr	-400(ra) # 8000346a <balloc>
    80003602:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003606:	02090d63          	beqz	s2,80003640 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000360a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000360e:	85ca                	mv	a1,s2
    80003610:	0009a503          	lw	a0,0(s3)
    80003614:	00000097          	auipc	ra,0x0
    80003618:	b96080e7          	jalr	-1130(ra) # 800031aa <bread>
    8000361c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000361e:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003622:	02049713          	sll	a4,s1,0x20
    80003626:	01e75593          	srl	a1,a4,0x1e
    8000362a:	00b784b3          	add	s1,a5,a1
    8000362e:	0004a903          	lw	s2,0(s1)
    80003632:	02090063          	beqz	s2,80003652 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003636:	8552                	mv	a0,s4
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	ca2080e7          	jalr	-862(ra) # 800032da <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003640:	854a                	mv	a0,s2
    80003642:	70a2                	ld	ra,40(sp)
    80003644:	7402                	ld	s0,32(sp)
    80003646:	64e2                	ld	s1,24(sp)
    80003648:	6942                	ld	s2,16(sp)
    8000364a:	69a2                	ld	s3,8(sp)
    8000364c:	6a02                	ld	s4,0(sp)
    8000364e:	6145                	add	sp,sp,48
    80003650:	8082                	ret
      addr = balloc(ip->dev);
    80003652:	0009a503          	lw	a0,0(s3)
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	e14080e7          	jalr	-492(ra) # 8000346a <balloc>
    8000365e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003662:	fc090ae3          	beqz	s2,80003636 <bmap+0x9a>
        a[bn] = addr;
    80003666:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000366a:	8552                	mv	a0,s4
    8000366c:	00001097          	auipc	ra,0x1
    80003670:	ec6080e7          	jalr	-314(ra) # 80004532 <log_write>
    80003674:	b7c9                	j	80003636 <bmap+0x9a>
  panic("bmap: out of range");
    80003676:	00005517          	auipc	a0,0x5
    8000367a:	eba50513          	add	a0,a0,-326 # 80008530 <syscalls+0x128>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	ebe080e7          	jalr	-322(ra) # 8000053c <panic>

0000000080003686 <iget>:
{
    80003686:	7179                	add	sp,sp,-48
    80003688:	f406                	sd	ra,40(sp)
    8000368a:	f022                	sd	s0,32(sp)
    8000368c:	ec26                	sd	s1,24(sp)
    8000368e:	e84a                	sd	s2,16(sp)
    80003690:	e44e                	sd	s3,8(sp)
    80003692:	e052                	sd	s4,0(sp)
    80003694:	1800                	add	s0,sp,48
    80003696:	89aa                	mv	s3,a0
    80003698:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000369a:	0001c517          	auipc	a0,0x1c
    8000369e:	f9e50513          	add	a0,a0,-98 # 8001f638 <itable>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	530080e7          	jalr	1328(ra) # 80000bd2 <acquire>
  empty = 0;
    800036aa:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036ac:	0001c497          	auipc	s1,0x1c
    800036b0:	fa448493          	add	s1,s1,-92 # 8001f650 <itable+0x18>
    800036b4:	0001e697          	auipc	a3,0x1e
    800036b8:	a2c68693          	add	a3,a3,-1492 # 800210e0 <log>
    800036bc:	a039                	j	800036ca <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036be:	02090b63          	beqz	s2,800036f4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036c2:	08848493          	add	s1,s1,136
    800036c6:	02d48a63          	beq	s1,a3,800036fa <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036ca:	449c                	lw	a5,8(s1)
    800036cc:	fef059e3          	blez	a5,800036be <iget+0x38>
    800036d0:	4098                	lw	a4,0(s1)
    800036d2:	ff3716e3          	bne	a4,s3,800036be <iget+0x38>
    800036d6:	40d8                	lw	a4,4(s1)
    800036d8:	ff4713e3          	bne	a4,s4,800036be <iget+0x38>
      ip->ref++;
    800036dc:	2785                	addw	a5,a5,1
    800036de:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036e0:	0001c517          	auipc	a0,0x1c
    800036e4:	f5850513          	add	a0,a0,-168 # 8001f638 <itable>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	59e080e7          	jalr	1438(ra) # 80000c86 <release>
      return ip;
    800036f0:	8926                	mv	s2,s1
    800036f2:	a03d                	j	80003720 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036f4:	f7f9                	bnez	a5,800036c2 <iget+0x3c>
    800036f6:	8926                	mv	s2,s1
    800036f8:	b7e9                	j	800036c2 <iget+0x3c>
  if(empty == 0)
    800036fa:	02090c63          	beqz	s2,80003732 <iget+0xac>
  ip->dev = dev;
    800036fe:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003702:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003706:	4785                	li	a5,1
    80003708:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000370c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003710:	0001c517          	auipc	a0,0x1c
    80003714:	f2850513          	add	a0,a0,-216 # 8001f638 <itable>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	56e080e7          	jalr	1390(ra) # 80000c86 <release>
}
    80003720:	854a                	mv	a0,s2
    80003722:	70a2                	ld	ra,40(sp)
    80003724:	7402                	ld	s0,32(sp)
    80003726:	64e2                	ld	s1,24(sp)
    80003728:	6942                	ld	s2,16(sp)
    8000372a:	69a2                	ld	s3,8(sp)
    8000372c:	6a02                	ld	s4,0(sp)
    8000372e:	6145                	add	sp,sp,48
    80003730:	8082                	ret
    panic("iget: no inodes");
    80003732:	00005517          	auipc	a0,0x5
    80003736:	e1650513          	add	a0,a0,-490 # 80008548 <syscalls+0x140>
    8000373a:	ffffd097          	auipc	ra,0xffffd
    8000373e:	e02080e7          	jalr	-510(ra) # 8000053c <panic>

0000000080003742 <fsinit>:
fsinit(int dev) {
    80003742:	7179                	add	sp,sp,-48
    80003744:	f406                	sd	ra,40(sp)
    80003746:	f022                	sd	s0,32(sp)
    80003748:	ec26                	sd	s1,24(sp)
    8000374a:	e84a                	sd	s2,16(sp)
    8000374c:	e44e                	sd	s3,8(sp)
    8000374e:	1800                	add	s0,sp,48
    80003750:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003752:	4585                	li	a1,1
    80003754:	00000097          	auipc	ra,0x0
    80003758:	a56080e7          	jalr	-1450(ra) # 800031aa <bread>
    8000375c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000375e:	0001c997          	auipc	s3,0x1c
    80003762:	eba98993          	add	s3,s3,-326 # 8001f618 <sb>
    80003766:	02000613          	li	a2,32
    8000376a:	05850593          	add	a1,a0,88
    8000376e:	854e                	mv	a0,s3
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	5ba080e7          	jalr	1466(ra) # 80000d2a <memmove>
  brelse(bp);
    80003778:	8526                	mv	a0,s1
    8000377a:	00000097          	auipc	ra,0x0
    8000377e:	b60080e7          	jalr	-1184(ra) # 800032da <brelse>
  if(sb.magic != FSMAGIC)
    80003782:	0009a703          	lw	a4,0(s3)
    80003786:	102037b7          	lui	a5,0x10203
    8000378a:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000378e:	02f71263          	bne	a4,a5,800037b2 <fsinit+0x70>
  initlog(dev, &sb);
    80003792:	0001c597          	auipc	a1,0x1c
    80003796:	e8658593          	add	a1,a1,-378 # 8001f618 <sb>
    8000379a:	854a                	mv	a0,s2
    8000379c:	00001097          	auipc	ra,0x1
    800037a0:	b2c080e7          	jalr	-1236(ra) # 800042c8 <initlog>
}
    800037a4:	70a2                	ld	ra,40(sp)
    800037a6:	7402                	ld	s0,32(sp)
    800037a8:	64e2                	ld	s1,24(sp)
    800037aa:	6942                	ld	s2,16(sp)
    800037ac:	69a2                	ld	s3,8(sp)
    800037ae:	6145                	add	sp,sp,48
    800037b0:	8082                	ret
    panic("invalid file system");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	da650513          	add	a0,a0,-602 # 80008558 <syscalls+0x150>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	d82080e7          	jalr	-638(ra) # 8000053c <panic>

00000000800037c2 <iinit>:
{
    800037c2:	7179                	add	sp,sp,-48
    800037c4:	f406                	sd	ra,40(sp)
    800037c6:	f022                	sd	s0,32(sp)
    800037c8:	ec26                	sd	s1,24(sp)
    800037ca:	e84a                	sd	s2,16(sp)
    800037cc:	e44e                	sd	s3,8(sp)
    800037ce:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800037d0:	00005597          	auipc	a1,0x5
    800037d4:	da058593          	add	a1,a1,-608 # 80008570 <syscalls+0x168>
    800037d8:	0001c517          	auipc	a0,0x1c
    800037dc:	e6050513          	add	a0,a0,-416 # 8001f638 <itable>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	362080e7          	jalr	866(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037e8:	0001c497          	auipc	s1,0x1c
    800037ec:	e7848493          	add	s1,s1,-392 # 8001f660 <itable+0x28>
    800037f0:	0001e997          	auipc	s3,0x1e
    800037f4:	90098993          	add	s3,s3,-1792 # 800210f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037f8:	00005917          	auipc	s2,0x5
    800037fc:	d8090913          	add	s2,s2,-640 # 80008578 <syscalls+0x170>
    80003800:	85ca                	mv	a1,s2
    80003802:	8526                	mv	a0,s1
    80003804:	00001097          	auipc	ra,0x1
    80003808:	e12080e7          	jalr	-494(ra) # 80004616 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000380c:	08848493          	add	s1,s1,136
    80003810:	ff3498e3          	bne	s1,s3,80003800 <iinit+0x3e>
}
    80003814:	70a2                	ld	ra,40(sp)
    80003816:	7402                	ld	s0,32(sp)
    80003818:	64e2                	ld	s1,24(sp)
    8000381a:	6942                	ld	s2,16(sp)
    8000381c:	69a2                	ld	s3,8(sp)
    8000381e:	6145                	add	sp,sp,48
    80003820:	8082                	ret

0000000080003822 <ialloc>:
{
    80003822:	7139                	add	sp,sp,-64
    80003824:	fc06                	sd	ra,56(sp)
    80003826:	f822                	sd	s0,48(sp)
    80003828:	f426                	sd	s1,40(sp)
    8000382a:	f04a                	sd	s2,32(sp)
    8000382c:	ec4e                	sd	s3,24(sp)
    8000382e:	e852                	sd	s4,16(sp)
    80003830:	e456                	sd	s5,8(sp)
    80003832:	e05a                	sd	s6,0(sp)
    80003834:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003836:	0001c717          	auipc	a4,0x1c
    8000383a:	dee72703          	lw	a4,-530(a4) # 8001f624 <sb+0xc>
    8000383e:	4785                	li	a5,1
    80003840:	04e7f863          	bgeu	a5,a4,80003890 <ialloc+0x6e>
    80003844:	8aaa                	mv	s5,a0
    80003846:	8b2e                	mv	s6,a1
    80003848:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000384a:	0001ca17          	auipc	s4,0x1c
    8000384e:	dcea0a13          	add	s4,s4,-562 # 8001f618 <sb>
    80003852:	00495593          	srl	a1,s2,0x4
    80003856:	018a2783          	lw	a5,24(s4)
    8000385a:	9dbd                	addw	a1,a1,a5
    8000385c:	8556                	mv	a0,s5
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	94c080e7          	jalr	-1716(ra) # 800031aa <bread>
    80003866:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003868:	05850993          	add	s3,a0,88
    8000386c:	00f97793          	and	a5,s2,15
    80003870:	079a                	sll	a5,a5,0x6
    80003872:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003874:	00099783          	lh	a5,0(s3)
    80003878:	cf9d                	beqz	a5,800038b6 <ialloc+0x94>
    brelse(bp);
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	a60080e7          	jalr	-1440(ra) # 800032da <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003882:	0905                	add	s2,s2,1
    80003884:	00ca2703          	lw	a4,12(s4)
    80003888:	0009079b          	sext.w	a5,s2
    8000388c:	fce7e3e3          	bltu	a5,a4,80003852 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003890:	00005517          	auipc	a0,0x5
    80003894:	cf050513          	add	a0,a0,-784 # 80008580 <syscalls+0x178>
    80003898:	ffffd097          	auipc	ra,0xffffd
    8000389c:	cee080e7          	jalr	-786(ra) # 80000586 <printf>
  return 0;
    800038a0:	4501                	li	a0,0
}
    800038a2:	70e2                	ld	ra,56(sp)
    800038a4:	7442                	ld	s0,48(sp)
    800038a6:	74a2                	ld	s1,40(sp)
    800038a8:	7902                	ld	s2,32(sp)
    800038aa:	69e2                	ld	s3,24(sp)
    800038ac:	6a42                	ld	s4,16(sp)
    800038ae:	6aa2                	ld	s5,8(sp)
    800038b0:	6b02                	ld	s6,0(sp)
    800038b2:	6121                	add	sp,sp,64
    800038b4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038b6:	04000613          	li	a2,64
    800038ba:	4581                	li	a1,0
    800038bc:	854e                	mv	a0,s3
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	410080e7          	jalr	1040(ra) # 80000cce <memset>
      dip->type = type;
    800038c6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038ca:	8526                	mv	a0,s1
    800038cc:	00001097          	auipc	ra,0x1
    800038d0:	c66080e7          	jalr	-922(ra) # 80004532 <log_write>
      brelse(bp);
    800038d4:	8526                	mv	a0,s1
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	a04080e7          	jalr	-1532(ra) # 800032da <brelse>
      return iget(dev, inum);
    800038de:	0009059b          	sext.w	a1,s2
    800038e2:	8556                	mv	a0,s5
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	da2080e7          	jalr	-606(ra) # 80003686 <iget>
    800038ec:	bf5d                	j	800038a2 <ialloc+0x80>

00000000800038ee <iupdate>:
{
    800038ee:	1101                	add	sp,sp,-32
    800038f0:	ec06                	sd	ra,24(sp)
    800038f2:	e822                	sd	s0,16(sp)
    800038f4:	e426                	sd	s1,8(sp)
    800038f6:	e04a                	sd	s2,0(sp)
    800038f8:	1000                	add	s0,sp,32
    800038fa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038fc:	415c                	lw	a5,4(a0)
    800038fe:	0047d79b          	srlw	a5,a5,0x4
    80003902:	0001c597          	auipc	a1,0x1c
    80003906:	d2e5a583          	lw	a1,-722(a1) # 8001f630 <sb+0x18>
    8000390a:	9dbd                	addw	a1,a1,a5
    8000390c:	4108                	lw	a0,0(a0)
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	89c080e7          	jalr	-1892(ra) # 800031aa <bread>
    80003916:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003918:	05850793          	add	a5,a0,88
    8000391c:	40d8                	lw	a4,4(s1)
    8000391e:	8b3d                	and	a4,a4,15
    80003920:	071a                	sll	a4,a4,0x6
    80003922:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003924:	04449703          	lh	a4,68(s1)
    80003928:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000392c:	04649703          	lh	a4,70(s1)
    80003930:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003934:	04849703          	lh	a4,72(s1)
    80003938:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000393c:	04a49703          	lh	a4,74(s1)
    80003940:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003944:	44f8                	lw	a4,76(s1)
    80003946:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003948:	03400613          	li	a2,52
    8000394c:	05048593          	add	a1,s1,80
    80003950:	00c78513          	add	a0,a5,12
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	3d6080e7          	jalr	982(ra) # 80000d2a <memmove>
  log_write(bp);
    8000395c:	854a                	mv	a0,s2
    8000395e:	00001097          	auipc	ra,0x1
    80003962:	bd4080e7          	jalr	-1068(ra) # 80004532 <log_write>
  brelse(bp);
    80003966:	854a                	mv	a0,s2
    80003968:	00000097          	auipc	ra,0x0
    8000396c:	972080e7          	jalr	-1678(ra) # 800032da <brelse>
}
    80003970:	60e2                	ld	ra,24(sp)
    80003972:	6442                	ld	s0,16(sp)
    80003974:	64a2                	ld	s1,8(sp)
    80003976:	6902                	ld	s2,0(sp)
    80003978:	6105                	add	sp,sp,32
    8000397a:	8082                	ret

000000008000397c <idup>:
{
    8000397c:	1101                	add	sp,sp,-32
    8000397e:	ec06                	sd	ra,24(sp)
    80003980:	e822                	sd	s0,16(sp)
    80003982:	e426                	sd	s1,8(sp)
    80003984:	1000                	add	s0,sp,32
    80003986:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003988:	0001c517          	auipc	a0,0x1c
    8000398c:	cb050513          	add	a0,a0,-848 # 8001f638 <itable>
    80003990:	ffffd097          	auipc	ra,0xffffd
    80003994:	242080e7          	jalr	578(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003998:	449c                	lw	a5,8(s1)
    8000399a:	2785                	addw	a5,a5,1
    8000399c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000399e:	0001c517          	auipc	a0,0x1c
    800039a2:	c9a50513          	add	a0,a0,-870 # 8001f638 <itable>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	2e0080e7          	jalr	736(ra) # 80000c86 <release>
}
    800039ae:	8526                	mv	a0,s1
    800039b0:	60e2                	ld	ra,24(sp)
    800039b2:	6442                	ld	s0,16(sp)
    800039b4:	64a2                	ld	s1,8(sp)
    800039b6:	6105                	add	sp,sp,32
    800039b8:	8082                	ret

00000000800039ba <ilock>:
{
    800039ba:	1101                	add	sp,sp,-32
    800039bc:	ec06                	sd	ra,24(sp)
    800039be:	e822                	sd	s0,16(sp)
    800039c0:	e426                	sd	s1,8(sp)
    800039c2:	e04a                	sd	s2,0(sp)
    800039c4:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039c6:	c115                	beqz	a0,800039ea <ilock+0x30>
    800039c8:	84aa                	mv	s1,a0
    800039ca:	451c                	lw	a5,8(a0)
    800039cc:	00f05f63          	blez	a5,800039ea <ilock+0x30>
  acquiresleep(&ip->lock);
    800039d0:	0541                	add	a0,a0,16
    800039d2:	00001097          	auipc	ra,0x1
    800039d6:	c7e080e7          	jalr	-898(ra) # 80004650 <acquiresleep>
  if(ip->valid == 0){
    800039da:	40bc                	lw	a5,64(s1)
    800039dc:	cf99                	beqz	a5,800039fa <ilock+0x40>
}
    800039de:	60e2                	ld	ra,24(sp)
    800039e0:	6442                	ld	s0,16(sp)
    800039e2:	64a2                	ld	s1,8(sp)
    800039e4:	6902                	ld	s2,0(sp)
    800039e6:	6105                	add	sp,sp,32
    800039e8:	8082                	ret
    panic("ilock");
    800039ea:	00005517          	auipc	a0,0x5
    800039ee:	bae50513          	add	a0,a0,-1106 # 80008598 <syscalls+0x190>
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	b4a080e7          	jalr	-1206(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039fa:	40dc                	lw	a5,4(s1)
    800039fc:	0047d79b          	srlw	a5,a5,0x4
    80003a00:	0001c597          	auipc	a1,0x1c
    80003a04:	c305a583          	lw	a1,-976(a1) # 8001f630 <sb+0x18>
    80003a08:	9dbd                	addw	a1,a1,a5
    80003a0a:	4088                	lw	a0,0(s1)
    80003a0c:	fffff097          	auipc	ra,0xfffff
    80003a10:	79e080e7          	jalr	1950(ra) # 800031aa <bread>
    80003a14:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a16:	05850593          	add	a1,a0,88
    80003a1a:	40dc                	lw	a5,4(s1)
    80003a1c:	8bbd                	and	a5,a5,15
    80003a1e:	079a                	sll	a5,a5,0x6
    80003a20:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a22:	00059783          	lh	a5,0(a1)
    80003a26:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a2a:	00259783          	lh	a5,2(a1)
    80003a2e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a32:	00459783          	lh	a5,4(a1)
    80003a36:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a3a:	00659783          	lh	a5,6(a1)
    80003a3e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a42:	459c                	lw	a5,8(a1)
    80003a44:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a46:	03400613          	li	a2,52
    80003a4a:	05b1                	add	a1,a1,12
    80003a4c:	05048513          	add	a0,s1,80
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	2da080e7          	jalr	730(ra) # 80000d2a <memmove>
    brelse(bp);
    80003a58:	854a                	mv	a0,s2
    80003a5a:	00000097          	auipc	ra,0x0
    80003a5e:	880080e7          	jalr	-1920(ra) # 800032da <brelse>
    ip->valid = 1;
    80003a62:	4785                	li	a5,1
    80003a64:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a66:	04449783          	lh	a5,68(s1)
    80003a6a:	fbb5                	bnez	a5,800039de <ilock+0x24>
      panic("ilock: no type");
    80003a6c:	00005517          	auipc	a0,0x5
    80003a70:	b3450513          	add	a0,a0,-1228 # 800085a0 <syscalls+0x198>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	ac8080e7          	jalr	-1336(ra) # 8000053c <panic>

0000000080003a7c <iunlock>:
{
    80003a7c:	1101                	add	sp,sp,-32
    80003a7e:	ec06                	sd	ra,24(sp)
    80003a80:	e822                	sd	s0,16(sp)
    80003a82:	e426                	sd	s1,8(sp)
    80003a84:	e04a                	sd	s2,0(sp)
    80003a86:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a88:	c905                	beqz	a0,80003ab8 <iunlock+0x3c>
    80003a8a:	84aa                	mv	s1,a0
    80003a8c:	01050913          	add	s2,a0,16
    80003a90:	854a                	mv	a0,s2
    80003a92:	00001097          	auipc	ra,0x1
    80003a96:	c58080e7          	jalr	-936(ra) # 800046ea <holdingsleep>
    80003a9a:	cd19                	beqz	a0,80003ab8 <iunlock+0x3c>
    80003a9c:	449c                	lw	a5,8(s1)
    80003a9e:	00f05d63          	blez	a5,80003ab8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	c02080e7          	jalr	-1022(ra) # 800046a6 <releasesleep>
}
    80003aac:	60e2                	ld	ra,24(sp)
    80003aae:	6442                	ld	s0,16(sp)
    80003ab0:	64a2                	ld	s1,8(sp)
    80003ab2:	6902                	ld	s2,0(sp)
    80003ab4:	6105                	add	sp,sp,32
    80003ab6:	8082                	ret
    panic("iunlock");
    80003ab8:	00005517          	auipc	a0,0x5
    80003abc:	af850513          	add	a0,a0,-1288 # 800085b0 <syscalls+0x1a8>
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	a7c080e7          	jalr	-1412(ra) # 8000053c <panic>

0000000080003ac8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ac8:	7179                	add	sp,sp,-48
    80003aca:	f406                	sd	ra,40(sp)
    80003acc:	f022                	sd	s0,32(sp)
    80003ace:	ec26                	sd	s1,24(sp)
    80003ad0:	e84a                	sd	s2,16(sp)
    80003ad2:	e44e                	sd	s3,8(sp)
    80003ad4:	e052                	sd	s4,0(sp)
    80003ad6:	1800                	add	s0,sp,48
    80003ad8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ada:	05050493          	add	s1,a0,80
    80003ade:	08050913          	add	s2,a0,128
    80003ae2:	a021                	j	80003aea <itrunc+0x22>
    80003ae4:	0491                	add	s1,s1,4
    80003ae6:	01248d63          	beq	s1,s2,80003b00 <itrunc+0x38>
    if(ip->addrs[i]){
    80003aea:	408c                	lw	a1,0(s1)
    80003aec:	dde5                	beqz	a1,80003ae4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003aee:	0009a503          	lw	a0,0(s3)
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	8fc080e7          	jalr	-1796(ra) # 800033ee <bfree>
      ip->addrs[i] = 0;
    80003afa:	0004a023          	sw	zero,0(s1)
    80003afe:	b7dd                	j	80003ae4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b00:	0809a583          	lw	a1,128(s3)
    80003b04:	e185                	bnez	a1,80003b24 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b06:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b0a:	854e                	mv	a0,s3
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	de2080e7          	jalr	-542(ra) # 800038ee <iupdate>
}
    80003b14:	70a2                	ld	ra,40(sp)
    80003b16:	7402                	ld	s0,32(sp)
    80003b18:	64e2                	ld	s1,24(sp)
    80003b1a:	6942                	ld	s2,16(sp)
    80003b1c:	69a2                	ld	s3,8(sp)
    80003b1e:	6a02                	ld	s4,0(sp)
    80003b20:	6145                	add	sp,sp,48
    80003b22:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b24:	0009a503          	lw	a0,0(s3)
    80003b28:	fffff097          	auipc	ra,0xfffff
    80003b2c:	682080e7          	jalr	1666(ra) # 800031aa <bread>
    80003b30:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b32:	05850493          	add	s1,a0,88
    80003b36:	45850913          	add	s2,a0,1112
    80003b3a:	a021                	j	80003b42 <itrunc+0x7a>
    80003b3c:	0491                	add	s1,s1,4
    80003b3e:	01248b63          	beq	s1,s2,80003b54 <itrunc+0x8c>
      if(a[j])
    80003b42:	408c                	lw	a1,0(s1)
    80003b44:	dde5                	beqz	a1,80003b3c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b46:	0009a503          	lw	a0,0(s3)
    80003b4a:	00000097          	auipc	ra,0x0
    80003b4e:	8a4080e7          	jalr	-1884(ra) # 800033ee <bfree>
    80003b52:	b7ed                	j	80003b3c <itrunc+0x74>
    brelse(bp);
    80003b54:	8552                	mv	a0,s4
    80003b56:	fffff097          	auipc	ra,0xfffff
    80003b5a:	784080e7          	jalr	1924(ra) # 800032da <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b5e:	0809a583          	lw	a1,128(s3)
    80003b62:	0009a503          	lw	a0,0(s3)
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	888080e7          	jalr	-1912(ra) # 800033ee <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b6e:	0809a023          	sw	zero,128(s3)
    80003b72:	bf51                	j	80003b06 <itrunc+0x3e>

0000000080003b74 <iput>:
{
    80003b74:	1101                	add	sp,sp,-32
    80003b76:	ec06                	sd	ra,24(sp)
    80003b78:	e822                	sd	s0,16(sp)
    80003b7a:	e426                	sd	s1,8(sp)
    80003b7c:	e04a                	sd	s2,0(sp)
    80003b7e:	1000                	add	s0,sp,32
    80003b80:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b82:	0001c517          	auipc	a0,0x1c
    80003b86:	ab650513          	add	a0,a0,-1354 # 8001f638 <itable>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	048080e7          	jalr	72(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b92:	4498                	lw	a4,8(s1)
    80003b94:	4785                	li	a5,1
    80003b96:	02f70363          	beq	a4,a5,80003bbc <iput+0x48>
  ip->ref--;
    80003b9a:	449c                	lw	a5,8(s1)
    80003b9c:	37fd                	addw	a5,a5,-1
    80003b9e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ba0:	0001c517          	auipc	a0,0x1c
    80003ba4:	a9850513          	add	a0,a0,-1384 # 8001f638 <itable>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	0de080e7          	jalr	222(ra) # 80000c86 <release>
}
    80003bb0:	60e2                	ld	ra,24(sp)
    80003bb2:	6442                	ld	s0,16(sp)
    80003bb4:	64a2                	ld	s1,8(sp)
    80003bb6:	6902                	ld	s2,0(sp)
    80003bb8:	6105                	add	sp,sp,32
    80003bba:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bbc:	40bc                	lw	a5,64(s1)
    80003bbe:	dff1                	beqz	a5,80003b9a <iput+0x26>
    80003bc0:	04a49783          	lh	a5,74(s1)
    80003bc4:	fbf9                	bnez	a5,80003b9a <iput+0x26>
    acquiresleep(&ip->lock);
    80003bc6:	01048913          	add	s2,s1,16
    80003bca:	854a                	mv	a0,s2
    80003bcc:	00001097          	auipc	ra,0x1
    80003bd0:	a84080e7          	jalr	-1404(ra) # 80004650 <acquiresleep>
    release(&itable.lock);
    80003bd4:	0001c517          	auipc	a0,0x1c
    80003bd8:	a6450513          	add	a0,a0,-1436 # 8001f638 <itable>
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	0aa080e7          	jalr	170(ra) # 80000c86 <release>
    itrunc(ip);
    80003be4:	8526                	mv	a0,s1
    80003be6:	00000097          	auipc	ra,0x0
    80003bea:	ee2080e7          	jalr	-286(ra) # 80003ac8 <itrunc>
    ip->type = 0;
    80003bee:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	cfa080e7          	jalr	-774(ra) # 800038ee <iupdate>
    ip->valid = 0;
    80003bfc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c00:	854a                	mv	a0,s2
    80003c02:	00001097          	auipc	ra,0x1
    80003c06:	aa4080e7          	jalr	-1372(ra) # 800046a6 <releasesleep>
    acquire(&itable.lock);
    80003c0a:	0001c517          	auipc	a0,0x1c
    80003c0e:	a2e50513          	add	a0,a0,-1490 # 8001f638 <itable>
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	fc0080e7          	jalr	-64(ra) # 80000bd2 <acquire>
    80003c1a:	b741                	j	80003b9a <iput+0x26>

0000000080003c1c <iunlockput>:
{
    80003c1c:	1101                	add	sp,sp,-32
    80003c1e:	ec06                	sd	ra,24(sp)
    80003c20:	e822                	sd	s0,16(sp)
    80003c22:	e426                	sd	s1,8(sp)
    80003c24:	1000                	add	s0,sp,32
    80003c26:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	e54080e7          	jalr	-428(ra) # 80003a7c <iunlock>
  iput(ip);
    80003c30:	8526                	mv	a0,s1
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	f42080e7          	jalr	-190(ra) # 80003b74 <iput>
}
    80003c3a:	60e2                	ld	ra,24(sp)
    80003c3c:	6442                	ld	s0,16(sp)
    80003c3e:	64a2                	ld	s1,8(sp)
    80003c40:	6105                	add	sp,sp,32
    80003c42:	8082                	ret

0000000080003c44 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c44:	1141                	add	sp,sp,-16
    80003c46:	e422                	sd	s0,8(sp)
    80003c48:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003c4a:	411c                	lw	a5,0(a0)
    80003c4c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c4e:	415c                	lw	a5,4(a0)
    80003c50:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c52:	04451783          	lh	a5,68(a0)
    80003c56:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c5a:	04a51783          	lh	a5,74(a0)
    80003c5e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c62:	04c56783          	lwu	a5,76(a0)
    80003c66:	e99c                	sd	a5,16(a1)
}
    80003c68:	6422                	ld	s0,8(sp)
    80003c6a:	0141                	add	sp,sp,16
    80003c6c:	8082                	ret

0000000080003c6e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c6e:	457c                	lw	a5,76(a0)
    80003c70:	0ed7e963          	bltu	a5,a3,80003d62 <readi+0xf4>
{
    80003c74:	7159                	add	sp,sp,-112
    80003c76:	f486                	sd	ra,104(sp)
    80003c78:	f0a2                	sd	s0,96(sp)
    80003c7a:	eca6                	sd	s1,88(sp)
    80003c7c:	e8ca                	sd	s2,80(sp)
    80003c7e:	e4ce                	sd	s3,72(sp)
    80003c80:	e0d2                	sd	s4,64(sp)
    80003c82:	fc56                	sd	s5,56(sp)
    80003c84:	f85a                	sd	s6,48(sp)
    80003c86:	f45e                	sd	s7,40(sp)
    80003c88:	f062                	sd	s8,32(sp)
    80003c8a:	ec66                	sd	s9,24(sp)
    80003c8c:	e86a                	sd	s10,16(sp)
    80003c8e:	e46e                	sd	s11,8(sp)
    80003c90:	1880                	add	s0,sp,112
    80003c92:	8b2a                	mv	s6,a0
    80003c94:	8bae                	mv	s7,a1
    80003c96:	8a32                	mv	s4,a2
    80003c98:	84b6                	mv	s1,a3
    80003c9a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c9c:	9f35                	addw	a4,a4,a3
    return 0;
    80003c9e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ca0:	0ad76063          	bltu	a4,a3,80003d40 <readi+0xd2>
  if(off + n > ip->size)
    80003ca4:	00e7f463          	bgeu	a5,a4,80003cac <readi+0x3e>
    n = ip->size - off;
    80003ca8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cac:	0a0a8963          	beqz	s5,80003d5e <readi+0xf0>
    80003cb0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cb2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cb6:	5c7d                	li	s8,-1
    80003cb8:	a82d                	j	80003cf2 <readi+0x84>
    80003cba:	020d1d93          	sll	s11,s10,0x20
    80003cbe:	020ddd93          	srl	s11,s11,0x20
    80003cc2:	05890613          	add	a2,s2,88
    80003cc6:	86ee                	mv	a3,s11
    80003cc8:	963a                	add	a2,a2,a4
    80003cca:	85d2                	mv	a1,s4
    80003ccc:	855e                	mv	a0,s7
    80003cce:	fffff097          	auipc	ra,0xfffff
    80003cd2:	844080e7          	jalr	-1980(ra) # 80002512 <either_copyout>
    80003cd6:	05850d63          	beq	a0,s8,80003d30 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cda:	854a                	mv	a0,s2
    80003cdc:	fffff097          	auipc	ra,0xfffff
    80003ce0:	5fe080e7          	jalr	1534(ra) # 800032da <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce4:	013d09bb          	addw	s3,s10,s3
    80003ce8:	009d04bb          	addw	s1,s10,s1
    80003cec:	9a6e                	add	s4,s4,s11
    80003cee:	0559f763          	bgeu	s3,s5,80003d3c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cf2:	00a4d59b          	srlw	a1,s1,0xa
    80003cf6:	855a                	mv	a0,s6
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	8a4080e7          	jalr	-1884(ra) # 8000359c <bmap>
    80003d00:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d04:	cd85                	beqz	a1,80003d3c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d06:	000b2503          	lw	a0,0(s6)
    80003d0a:	fffff097          	auipc	ra,0xfffff
    80003d0e:	4a0080e7          	jalr	1184(ra) # 800031aa <bread>
    80003d12:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d14:	3ff4f713          	and	a4,s1,1023
    80003d18:	40ec87bb          	subw	a5,s9,a4
    80003d1c:	413a86bb          	subw	a3,s5,s3
    80003d20:	8d3e                	mv	s10,a5
    80003d22:	2781                	sext.w	a5,a5
    80003d24:	0006861b          	sext.w	a2,a3
    80003d28:	f8f679e3          	bgeu	a2,a5,80003cba <readi+0x4c>
    80003d2c:	8d36                	mv	s10,a3
    80003d2e:	b771                	j	80003cba <readi+0x4c>
      brelse(bp);
    80003d30:	854a                	mv	a0,s2
    80003d32:	fffff097          	auipc	ra,0xfffff
    80003d36:	5a8080e7          	jalr	1448(ra) # 800032da <brelse>
      tot = -1;
    80003d3a:	59fd                	li	s3,-1
  }
  return tot;
    80003d3c:	0009851b          	sext.w	a0,s3
}
    80003d40:	70a6                	ld	ra,104(sp)
    80003d42:	7406                	ld	s0,96(sp)
    80003d44:	64e6                	ld	s1,88(sp)
    80003d46:	6946                	ld	s2,80(sp)
    80003d48:	69a6                	ld	s3,72(sp)
    80003d4a:	6a06                	ld	s4,64(sp)
    80003d4c:	7ae2                	ld	s5,56(sp)
    80003d4e:	7b42                	ld	s6,48(sp)
    80003d50:	7ba2                	ld	s7,40(sp)
    80003d52:	7c02                	ld	s8,32(sp)
    80003d54:	6ce2                	ld	s9,24(sp)
    80003d56:	6d42                	ld	s10,16(sp)
    80003d58:	6da2                	ld	s11,8(sp)
    80003d5a:	6165                	add	sp,sp,112
    80003d5c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d5e:	89d6                	mv	s3,s5
    80003d60:	bff1                	j	80003d3c <readi+0xce>
    return 0;
    80003d62:	4501                	li	a0,0
}
    80003d64:	8082                	ret

0000000080003d66 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d66:	457c                	lw	a5,76(a0)
    80003d68:	10d7e863          	bltu	a5,a3,80003e78 <writei+0x112>
{
    80003d6c:	7159                	add	sp,sp,-112
    80003d6e:	f486                	sd	ra,104(sp)
    80003d70:	f0a2                	sd	s0,96(sp)
    80003d72:	eca6                	sd	s1,88(sp)
    80003d74:	e8ca                	sd	s2,80(sp)
    80003d76:	e4ce                	sd	s3,72(sp)
    80003d78:	e0d2                	sd	s4,64(sp)
    80003d7a:	fc56                	sd	s5,56(sp)
    80003d7c:	f85a                	sd	s6,48(sp)
    80003d7e:	f45e                	sd	s7,40(sp)
    80003d80:	f062                	sd	s8,32(sp)
    80003d82:	ec66                	sd	s9,24(sp)
    80003d84:	e86a                	sd	s10,16(sp)
    80003d86:	e46e                	sd	s11,8(sp)
    80003d88:	1880                	add	s0,sp,112
    80003d8a:	8aaa                	mv	s5,a0
    80003d8c:	8bae                	mv	s7,a1
    80003d8e:	8a32                	mv	s4,a2
    80003d90:	8936                	mv	s2,a3
    80003d92:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d94:	00e687bb          	addw	a5,a3,a4
    80003d98:	0ed7e263          	bltu	a5,a3,80003e7c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d9c:	00043737          	lui	a4,0x43
    80003da0:	0ef76063          	bltu	a4,a5,80003e80 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da4:	0c0b0863          	beqz	s6,80003e74 <writei+0x10e>
    80003da8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003daa:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dae:	5c7d                	li	s8,-1
    80003db0:	a091                	j	80003df4 <writei+0x8e>
    80003db2:	020d1d93          	sll	s11,s10,0x20
    80003db6:	020ddd93          	srl	s11,s11,0x20
    80003dba:	05848513          	add	a0,s1,88
    80003dbe:	86ee                	mv	a3,s11
    80003dc0:	8652                	mv	a2,s4
    80003dc2:	85de                	mv	a1,s7
    80003dc4:	953a                	add	a0,a0,a4
    80003dc6:	ffffe097          	auipc	ra,0xffffe
    80003dca:	7a2080e7          	jalr	1954(ra) # 80002568 <either_copyin>
    80003dce:	07850263          	beq	a0,s8,80003e32 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	75e080e7          	jalr	1886(ra) # 80004532 <log_write>
    brelse(bp);
    80003ddc:	8526                	mv	a0,s1
    80003dde:	fffff097          	auipc	ra,0xfffff
    80003de2:	4fc080e7          	jalr	1276(ra) # 800032da <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de6:	013d09bb          	addw	s3,s10,s3
    80003dea:	012d093b          	addw	s2,s10,s2
    80003dee:	9a6e                	add	s4,s4,s11
    80003df0:	0569f663          	bgeu	s3,s6,80003e3c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003df4:	00a9559b          	srlw	a1,s2,0xa
    80003df8:	8556                	mv	a0,s5
    80003dfa:	fffff097          	auipc	ra,0xfffff
    80003dfe:	7a2080e7          	jalr	1954(ra) # 8000359c <bmap>
    80003e02:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e06:	c99d                	beqz	a1,80003e3c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e08:	000aa503          	lw	a0,0(s5)
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	39e080e7          	jalr	926(ra) # 800031aa <bread>
    80003e14:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e16:	3ff97713          	and	a4,s2,1023
    80003e1a:	40ec87bb          	subw	a5,s9,a4
    80003e1e:	413b06bb          	subw	a3,s6,s3
    80003e22:	8d3e                	mv	s10,a5
    80003e24:	2781                	sext.w	a5,a5
    80003e26:	0006861b          	sext.w	a2,a3
    80003e2a:	f8f674e3          	bgeu	a2,a5,80003db2 <writei+0x4c>
    80003e2e:	8d36                	mv	s10,a3
    80003e30:	b749                	j	80003db2 <writei+0x4c>
      brelse(bp);
    80003e32:	8526                	mv	a0,s1
    80003e34:	fffff097          	auipc	ra,0xfffff
    80003e38:	4a6080e7          	jalr	1190(ra) # 800032da <brelse>
  }

  if(off > ip->size)
    80003e3c:	04caa783          	lw	a5,76(s5)
    80003e40:	0127f463          	bgeu	a5,s2,80003e48 <writei+0xe2>
    ip->size = off;
    80003e44:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e48:	8556                	mv	a0,s5
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	aa4080e7          	jalr	-1372(ra) # 800038ee <iupdate>

  return tot;
    80003e52:	0009851b          	sext.w	a0,s3
}
    80003e56:	70a6                	ld	ra,104(sp)
    80003e58:	7406                	ld	s0,96(sp)
    80003e5a:	64e6                	ld	s1,88(sp)
    80003e5c:	6946                	ld	s2,80(sp)
    80003e5e:	69a6                	ld	s3,72(sp)
    80003e60:	6a06                	ld	s4,64(sp)
    80003e62:	7ae2                	ld	s5,56(sp)
    80003e64:	7b42                	ld	s6,48(sp)
    80003e66:	7ba2                	ld	s7,40(sp)
    80003e68:	7c02                	ld	s8,32(sp)
    80003e6a:	6ce2                	ld	s9,24(sp)
    80003e6c:	6d42                	ld	s10,16(sp)
    80003e6e:	6da2                	ld	s11,8(sp)
    80003e70:	6165                	add	sp,sp,112
    80003e72:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e74:	89da                	mv	s3,s6
    80003e76:	bfc9                	j	80003e48 <writei+0xe2>
    return -1;
    80003e78:	557d                	li	a0,-1
}
    80003e7a:	8082                	ret
    return -1;
    80003e7c:	557d                	li	a0,-1
    80003e7e:	bfe1                	j	80003e56 <writei+0xf0>
    return -1;
    80003e80:	557d                	li	a0,-1
    80003e82:	bfd1                	j	80003e56 <writei+0xf0>

0000000080003e84 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e84:	1141                	add	sp,sp,-16
    80003e86:	e406                	sd	ra,8(sp)
    80003e88:	e022                	sd	s0,0(sp)
    80003e8a:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e8c:	4639                	li	a2,14
    80003e8e:	ffffd097          	auipc	ra,0xffffd
    80003e92:	f10080e7          	jalr	-240(ra) # 80000d9e <strncmp>
}
    80003e96:	60a2                	ld	ra,8(sp)
    80003e98:	6402                	ld	s0,0(sp)
    80003e9a:	0141                	add	sp,sp,16
    80003e9c:	8082                	ret

0000000080003e9e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e9e:	7139                	add	sp,sp,-64
    80003ea0:	fc06                	sd	ra,56(sp)
    80003ea2:	f822                	sd	s0,48(sp)
    80003ea4:	f426                	sd	s1,40(sp)
    80003ea6:	f04a                	sd	s2,32(sp)
    80003ea8:	ec4e                	sd	s3,24(sp)
    80003eaa:	e852                	sd	s4,16(sp)
    80003eac:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003eae:	04451703          	lh	a4,68(a0)
    80003eb2:	4785                	li	a5,1
    80003eb4:	00f71a63          	bne	a4,a5,80003ec8 <dirlookup+0x2a>
    80003eb8:	892a                	mv	s2,a0
    80003eba:	89ae                	mv	s3,a1
    80003ebc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ebe:	457c                	lw	a5,76(a0)
    80003ec0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ec2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec4:	e79d                	bnez	a5,80003ef2 <dirlookup+0x54>
    80003ec6:	a8a5                	j	80003f3e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ec8:	00004517          	auipc	a0,0x4
    80003ecc:	6f050513          	add	a0,a0,1776 # 800085b8 <syscalls+0x1b0>
    80003ed0:	ffffc097          	auipc	ra,0xffffc
    80003ed4:	66c080e7          	jalr	1644(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003ed8:	00004517          	auipc	a0,0x4
    80003edc:	6f850513          	add	a0,a0,1784 # 800085d0 <syscalls+0x1c8>
    80003ee0:	ffffc097          	auipc	ra,0xffffc
    80003ee4:	65c080e7          	jalr	1628(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee8:	24c1                	addw	s1,s1,16
    80003eea:	04c92783          	lw	a5,76(s2)
    80003eee:	04f4f763          	bgeu	s1,a5,80003f3c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ef2:	4741                	li	a4,16
    80003ef4:	86a6                	mv	a3,s1
    80003ef6:	fc040613          	add	a2,s0,-64
    80003efa:	4581                	li	a1,0
    80003efc:	854a                	mv	a0,s2
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	d70080e7          	jalr	-656(ra) # 80003c6e <readi>
    80003f06:	47c1                	li	a5,16
    80003f08:	fcf518e3          	bne	a0,a5,80003ed8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f0c:	fc045783          	lhu	a5,-64(s0)
    80003f10:	dfe1                	beqz	a5,80003ee8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f12:	fc240593          	add	a1,s0,-62
    80003f16:	854e                	mv	a0,s3
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	f6c080e7          	jalr	-148(ra) # 80003e84 <namecmp>
    80003f20:	f561                	bnez	a0,80003ee8 <dirlookup+0x4a>
      if(poff)
    80003f22:	000a0463          	beqz	s4,80003f2a <dirlookup+0x8c>
        *poff = off;
    80003f26:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f2a:	fc045583          	lhu	a1,-64(s0)
    80003f2e:	00092503          	lw	a0,0(s2)
    80003f32:	fffff097          	auipc	ra,0xfffff
    80003f36:	754080e7          	jalr	1876(ra) # 80003686 <iget>
    80003f3a:	a011                	j	80003f3e <dirlookup+0xa0>
  return 0;
    80003f3c:	4501                	li	a0,0
}
    80003f3e:	70e2                	ld	ra,56(sp)
    80003f40:	7442                	ld	s0,48(sp)
    80003f42:	74a2                	ld	s1,40(sp)
    80003f44:	7902                	ld	s2,32(sp)
    80003f46:	69e2                	ld	s3,24(sp)
    80003f48:	6a42                	ld	s4,16(sp)
    80003f4a:	6121                	add	sp,sp,64
    80003f4c:	8082                	ret

0000000080003f4e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f4e:	711d                	add	sp,sp,-96
    80003f50:	ec86                	sd	ra,88(sp)
    80003f52:	e8a2                	sd	s0,80(sp)
    80003f54:	e4a6                	sd	s1,72(sp)
    80003f56:	e0ca                	sd	s2,64(sp)
    80003f58:	fc4e                	sd	s3,56(sp)
    80003f5a:	f852                	sd	s4,48(sp)
    80003f5c:	f456                	sd	s5,40(sp)
    80003f5e:	f05a                	sd	s6,32(sp)
    80003f60:	ec5e                	sd	s7,24(sp)
    80003f62:	e862                	sd	s8,16(sp)
    80003f64:	e466                	sd	s9,8(sp)
    80003f66:	1080                	add	s0,sp,96
    80003f68:	84aa                	mv	s1,a0
    80003f6a:	8b2e                	mv	s6,a1
    80003f6c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f6e:	00054703          	lbu	a4,0(a0)
    80003f72:	02f00793          	li	a5,47
    80003f76:	02f70263          	beq	a4,a5,80003f9a <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f7a:	ffffe097          	auipc	ra,0xffffe
    80003f7e:	a3c080e7          	jalr	-1476(ra) # 800019b6 <myproc>
    80003f82:	15053503          	ld	a0,336(a0)
    80003f86:	00000097          	auipc	ra,0x0
    80003f8a:	9f6080e7          	jalr	-1546(ra) # 8000397c <idup>
    80003f8e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003f90:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003f94:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f96:	4b85                	li	s7,1
    80003f98:	a875                	j	80004054 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003f9a:	4585                	li	a1,1
    80003f9c:	4505                	li	a0,1
    80003f9e:	fffff097          	auipc	ra,0xfffff
    80003fa2:	6e8080e7          	jalr	1768(ra) # 80003686 <iget>
    80003fa6:	8a2a                	mv	s4,a0
    80003fa8:	b7e5                	j	80003f90 <namex+0x42>
      iunlockput(ip);
    80003faa:	8552                	mv	a0,s4
    80003fac:	00000097          	auipc	ra,0x0
    80003fb0:	c70080e7          	jalr	-912(ra) # 80003c1c <iunlockput>
      return 0;
    80003fb4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fb6:	8552                	mv	a0,s4
    80003fb8:	60e6                	ld	ra,88(sp)
    80003fba:	6446                	ld	s0,80(sp)
    80003fbc:	64a6                	ld	s1,72(sp)
    80003fbe:	6906                	ld	s2,64(sp)
    80003fc0:	79e2                	ld	s3,56(sp)
    80003fc2:	7a42                	ld	s4,48(sp)
    80003fc4:	7aa2                	ld	s5,40(sp)
    80003fc6:	7b02                	ld	s6,32(sp)
    80003fc8:	6be2                	ld	s7,24(sp)
    80003fca:	6c42                	ld	s8,16(sp)
    80003fcc:	6ca2                	ld	s9,8(sp)
    80003fce:	6125                	add	sp,sp,96
    80003fd0:	8082                	ret
      iunlock(ip);
    80003fd2:	8552                	mv	a0,s4
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	aa8080e7          	jalr	-1368(ra) # 80003a7c <iunlock>
      return ip;
    80003fdc:	bfe9                	j	80003fb6 <namex+0x68>
      iunlockput(ip);
    80003fde:	8552                	mv	a0,s4
    80003fe0:	00000097          	auipc	ra,0x0
    80003fe4:	c3c080e7          	jalr	-964(ra) # 80003c1c <iunlockput>
      return 0;
    80003fe8:	8a4e                	mv	s4,s3
    80003fea:	b7f1                	j	80003fb6 <namex+0x68>
  len = path - s;
    80003fec:	40998633          	sub	a2,s3,s1
    80003ff0:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ff4:	099c5863          	bge	s8,s9,80004084 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003ff8:	4639                	li	a2,14
    80003ffa:	85a6                	mv	a1,s1
    80003ffc:	8556                	mv	a0,s5
    80003ffe:	ffffd097          	auipc	ra,0xffffd
    80004002:	d2c080e7          	jalr	-724(ra) # 80000d2a <memmove>
    80004006:	84ce                	mv	s1,s3
  while(*path == '/')
    80004008:	0004c783          	lbu	a5,0(s1)
    8000400c:	01279763          	bne	a5,s2,8000401a <namex+0xcc>
    path++;
    80004010:	0485                	add	s1,s1,1
  while(*path == '/')
    80004012:	0004c783          	lbu	a5,0(s1)
    80004016:	ff278de3          	beq	a5,s2,80004010 <namex+0xc2>
    ilock(ip);
    8000401a:	8552                	mv	a0,s4
    8000401c:	00000097          	auipc	ra,0x0
    80004020:	99e080e7          	jalr	-1634(ra) # 800039ba <ilock>
    if(ip->type != T_DIR){
    80004024:	044a1783          	lh	a5,68(s4)
    80004028:	f97791e3          	bne	a5,s7,80003faa <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000402c:	000b0563          	beqz	s6,80004036 <namex+0xe8>
    80004030:	0004c783          	lbu	a5,0(s1)
    80004034:	dfd9                	beqz	a5,80003fd2 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004036:	4601                	li	a2,0
    80004038:	85d6                	mv	a1,s5
    8000403a:	8552                	mv	a0,s4
    8000403c:	00000097          	auipc	ra,0x0
    80004040:	e62080e7          	jalr	-414(ra) # 80003e9e <dirlookup>
    80004044:	89aa                	mv	s3,a0
    80004046:	dd41                	beqz	a0,80003fde <namex+0x90>
    iunlockput(ip);
    80004048:	8552                	mv	a0,s4
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	bd2080e7          	jalr	-1070(ra) # 80003c1c <iunlockput>
    ip = next;
    80004052:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004054:	0004c783          	lbu	a5,0(s1)
    80004058:	01279763          	bne	a5,s2,80004066 <namex+0x118>
    path++;
    8000405c:	0485                	add	s1,s1,1
  while(*path == '/')
    8000405e:	0004c783          	lbu	a5,0(s1)
    80004062:	ff278de3          	beq	a5,s2,8000405c <namex+0x10e>
  if(*path == 0)
    80004066:	cb9d                	beqz	a5,8000409c <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004068:	0004c783          	lbu	a5,0(s1)
    8000406c:	89a6                	mv	s3,s1
  len = path - s;
    8000406e:	4c81                	li	s9,0
    80004070:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004072:	01278963          	beq	a5,s2,80004084 <namex+0x136>
    80004076:	dbbd                	beqz	a5,80003fec <namex+0x9e>
    path++;
    80004078:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    8000407a:	0009c783          	lbu	a5,0(s3)
    8000407e:	ff279ce3          	bne	a5,s2,80004076 <namex+0x128>
    80004082:	b7ad                	j	80003fec <namex+0x9e>
    memmove(name, s, len);
    80004084:	2601                	sext.w	a2,a2
    80004086:	85a6                	mv	a1,s1
    80004088:	8556                	mv	a0,s5
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	ca0080e7          	jalr	-864(ra) # 80000d2a <memmove>
    name[len] = 0;
    80004092:	9cd6                	add	s9,s9,s5
    80004094:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004098:	84ce                	mv	s1,s3
    8000409a:	b7bd                	j	80004008 <namex+0xba>
  if(nameiparent){
    8000409c:	f00b0de3          	beqz	s6,80003fb6 <namex+0x68>
    iput(ip);
    800040a0:	8552                	mv	a0,s4
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	ad2080e7          	jalr	-1326(ra) # 80003b74 <iput>
    return 0;
    800040aa:	4a01                	li	s4,0
    800040ac:	b729                	j	80003fb6 <namex+0x68>

00000000800040ae <dirlink>:
{
    800040ae:	7139                	add	sp,sp,-64
    800040b0:	fc06                	sd	ra,56(sp)
    800040b2:	f822                	sd	s0,48(sp)
    800040b4:	f426                	sd	s1,40(sp)
    800040b6:	f04a                	sd	s2,32(sp)
    800040b8:	ec4e                	sd	s3,24(sp)
    800040ba:	e852                	sd	s4,16(sp)
    800040bc:	0080                	add	s0,sp,64
    800040be:	892a                	mv	s2,a0
    800040c0:	8a2e                	mv	s4,a1
    800040c2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040c4:	4601                	li	a2,0
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	dd8080e7          	jalr	-552(ra) # 80003e9e <dirlookup>
    800040ce:	e93d                	bnez	a0,80004144 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d0:	04c92483          	lw	s1,76(s2)
    800040d4:	c49d                	beqz	s1,80004102 <dirlink+0x54>
    800040d6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040d8:	4741                	li	a4,16
    800040da:	86a6                	mv	a3,s1
    800040dc:	fc040613          	add	a2,s0,-64
    800040e0:	4581                	li	a1,0
    800040e2:	854a                	mv	a0,s2
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	b8a080e7          	jalr	-1142(ra) # 80003c6e <readi>
    800040ec:	47c1                	li	a5,16
    800040ee:	06f51163          	bne	a0,a5,80004150 <dirlink+0xa2>
    if(de.inum == 0)
    800040f2:	fc045783          	lhu	a5,-64(s0)
    800040f6:	c791                	beqz	a5,80004102 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f8:	24c1                	addw	s1,s1,16
    800040fa:	04c92783          	lw	a5,76(s2)
    800040fe:	fcf4ede3          	bltu	s1,a5,800040d8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004102:	4639                	li	a2,14
    80004104:	85d2                	mv	a1,s4
    80004106:	fc240513          	add	a0,s0,-62
    8000410a:	ffffd097          	auipc	ra,0xffffd
    8000410e:	cd0080e7          	jalr	-816(ra) # 80000dda <strncpy>
  de.inum = inum;
    80004112:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004116:	4741                	li	a4,16
    80004118:	86a6                	mv	a3,s1
    8000411a:	fc040613          	add	a2,s0,-64
    8000411e:	4581                	li	a1,0
    80004120:	854a                	mv	a0,s2
    80004122:	00000097          	auipc	ra,0x0
    80004126:	c44080e7          	jalr	-956(ra) # 80003d66 <writei>
    8000412a:	1541                	add	a0,a0,-16
    8000412c:	00a03533          	snez	a0,a0
    80004130:	40a00533          	neg	a0,a0
}
    80004134:	70e2                	ld	ra,56(sp)
    80004136:	7442                	ld	s0,48(sp)
    80004138:	74a2                	ld	s1,40(sp)
    8000413a:	7902                	ld	s2,32(sp)
    8000413c:	69e2                	ld	s3,24(sp)
    8000413e:	6a42                	ld	s4,16(sp)
    80004140:	6121                	add	sp,sp,64
    80004142:	8082                	ret
    iput(ip);
    80004144:	00000097          	auipc	ra,0x0
    80004148:	a30080e7          	jalr	-1488(ra) # 80003b74 <iput>
    return -1;
    8000414c:	557d                	li	a0,-1
    8000414e:	b7dd                	j	80004134 <dirlink+0x86>
      panic("dirlink read");
    80004150:	00004517          	auipc	a0,0x4
    80004154:	49050513          	add	a0,a0,1168 # 800085e0 <syscalls+0x1d8>
    80004158:	ffffc097          	auipc	ra,0xffffc
    8000415c:	3e4080e7          	jalr	996(ra) # 8000053c <panic>

0000000080004160 <namei>:

struct inode*
namei(char *path)
{
    80004160:	1101                	add	sp,sp,-32
    80004162:	ec06                	sd	ra,24(sp)
    80004164:	e822                	sd	s0,16(sp)
    80004166:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004168:	fe040613          	add	a2,s0,-32
    8000416c:	4581                	li	a1,0
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	de0080e7          	jalr	-544(ra) # 80003f4e <namex>
}
    80004176:	60e2                	ld	ra,24(sp)
    80004178:	6442                	ld	s0,16(sp)
    8000417a:	6105                	add	sp,sp,32
    8000417c:	8082                	ret

000000008000417e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000417e:	1141                	add	sp,sp,-16
    80004180:	e406                	sd	ra,8(sp)
    80004182:	e022                	sd	s0,0(sp)
    80004184:	0800                	add	s0,sp,16
    80004186:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004188:	4585                	li	a1,1
    8000418a:	00000097          	auipc	ra,0x0
    8000418e:	dc4080e7          	jalr	-572(ra) # 80003f4e <namex>
}
    80004192:	60a2                	ld	ra,8(sp)
    80004194:	6402                	ld	s0,0(sp)
    80004196:	0141                	add	sp,sp,16
    80004198:	8082                	ret

000000008000419a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000419a:	1101                	add	sp,sp,-32
    8000419c:	ec06                	sd	ra,24(sp)
    8000419e:	e822                	sd	s0,16(sp)
    800041a0:	e426                	sd	s1,8(sp)
    800041a2:	e04a                	sd	s2,0(sp)
    800041a4:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041a6:	0001d917          	auipc	s2,0x1d
    800041aa:	f3a90913          	add	s2,s2,-198 # 800210e0 <log>
    800041ae:	01892583          	lw	a1,24(s2)
    800041b2:	02892503          	lw	a0,40(s2)
    800041b6:	fffff097          	auipc	ra,0xfffff
    800041ba:	ff4080e7          	jalr	-12(ra) # 800031aa <bread>
    800041be:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041c0:	02c92603          	lw	a2,44(s2)
    800041c4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041c6:	00c05f63          	blez	a2,800041e4 <write_head+0x4a>
    800041ca:	0001d717          	auipc	a4,0x1d
    800041ce:	f4670713          	add	a4,a4,-186 # 80021110 <log+0x30>
    800041d2:	87aa                	mv	a5,a0
    800041d4:	060a                	sll	a2,a2,0x2
    800041d6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800041d8:	4314                	lw	a3,0(a4)
    800041da:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800041dc:	0711                	add	a4,a4,4
    800041de:	0791                	add	a5,a5,4
    800041e0:	fec79ce3          	bne	a5,a2,800041d8 <write_head+0x3e>
  }
  bwrite(buf);
    800041e4:	8526                	mv	a0,s1
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	0b6080e7          	jalr	182(ra) # 8000329c <bwrite>
  brelse(buf);
    800041ee:	8526                	mv	a0,s1
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	0ea080e7          	jalr	234(ra) # 800032da <brelse>
}
    800041f8:	60e2                	ld	ra,24(sp)
    800041fa:	6442                	ld	s0,16(sp)
    800041fc:	64a2                	ld	s1,8(sp)
    800041fe:	6902                	ld	s2,0(sp)
    80004200:	6105                	add	sp,sp,32
    80004202:	8082                	ret

0000000080004204 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004204:	0001d797          	auipc	a5,0x1d
    80004208:	f087a783          	lw	a5,-248(a5) # 8002110c <log+0x2c>
    8000420c:	0af05d63          	blez	a5,800042c6 <install_trans+0xc2>
{
    80004210:	7139                	add	sp,sp,-64
    80004212:	fc06                	sd	ra,56(sp)
    80004214:	f822                	sd	s0,48(sp)
    80004216:	f426                	sd	s1,40(sp)
    80004218:	f04a                	sd	s2,32(sp)
    8000421a:	ec4e                	sd	s3,24(sp)
    8000421c:	e852                	sd	s4,16(sp)
    8000421e:	e456                	sd	s5,8(sp)
    80004220:	e05a                	sd	s6,0(sp)
    80004222:	0080                	add	s0,sp,64
    80004224:	8b2a                	mv	s6,a0
    80004226:	0001da97          	auipc	s5,0x1d
    8000422a:	eeaa8a93          	add	s5,s5,-278 # 80021110 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000422e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004230:	0001d997          	auipc	s3,0x1d
    80004234:	eb098993          	add	s3,s3,-336 # 800210e0 <log>
    80004238:	a00d                	j	8000425a <install_trans+0x56>
    brelse(lbuf);
    8000423a:	854a                	mv	a0,s2
    8000423c:	fffff097          	auipc	ra,0xfffff
    80004240:	09e080e7          	jalr	158(ra) # 800032da <brelse>
    brelse(dbuf);
    80004244:	8526                	mv	a0,s1
    80004246:	fffff097          	auipc	ra,0xfffff
    8000424a:	094080e7          	jalr	148(ra) # 800032da <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000424e:	2a05                	addw	s4,s4,1
    80004250:	0a91                	add	s5,s5,4
    80004252:	02c9a783          	lw	a5,44(s3)
    80004256:	04fa5e63          	bge	s4,a5,800042b2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000425a:	0189a583          	lw	a1,24(s3)
    8000425e:	014585bb          	addw	a1,a1,s4
    80004262:	2585                	addw	a1,a1,1
    80004264:	0289a503          	lw	a0,40(s3)
    80004268:	fffff097          	auipc	ra,0xfffff
    8000426c:	f42080e7          	jalr	-190(ra) # 800031aa <bread>
    80004270:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004272:	000aa583          	lw	a1,0(s5)
    80004276:	0289a503          	lw	a0,40(s3)
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	f30080e7          	jalr	-208(ra) # 800031aa <bread>
    80004282:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004284:	40000613          	li	a2,1024
    80004288:	05890593          	add	a1,s2,88
    8000428c:	05850513          	add	a0,a0,88
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	a9a080e7          	jalr	-1382(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004298:	8526                	mv	a0,s1
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	002080e7          	jalr	2(ra) # 8000329c <bwrite>
    if(recovering == 0)
    800042a2:	f80b1ce3          	bnez	s6,8000423a <install_trans+0x36>
      bunpin(dbuf);
    800042a6:	8526                	mv	a0,s1
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	10a080e7          	jalr	266(ra) # 800033b2 <bunpin>
    800042b0:	b769                	j	8000423a <install_trans+0x36>
}
    800042b2:	70e2                	ld	ra,56(sp)
    800042b4:	7442                	ld	s0,48(sp)
    800042b6:	74a2                	ld	s1,40(sp)
    800042b8:	7902                	ld	s2,32(sp)
    800042ba:	69e2                	ld	s3,24(sp)
    800042bc:	6a42                	ld	s4,16(sp)
    800042be:	6aa2                	ld	s5,8(sp)
    800042c0:	6b02                	ld	s6,0(sp)
    800042c2:	6121                	add	sp,sp,64
    800042c4:	8082                	ret
    800042c6:	8082                	ret

00000000800042c8 <initlog>:
{
    800042c8:	7179                	add	sp,sp,-48
    800042ca:	f406                	sd	ra,40(sp)
    800042cc:	f022                	sd	s0,32(sp)
    800042ce:	ec26                	sd	s1,24(sp)
    800042d0:	e84a                	sd	s2,16(sp)
    800042d2:	e44e                	sd	s3,8(sp)
    800042d4:	1800                	add	s0,sp,48
    800042d6:	892a                	mv	s2,a0
    800042d8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042da:	0001d497          	auipc	s1,0x1d
    800042de:	e0648493          	add	s1,s1,-506 # 800210e0 <log>
    800042e2:	00004597          	auipc	a1,0x4
    800042e6:	30e58593          	add	a1,a1,782 # 800085f0 <syscalls+0x1e8>
    800042ea:	8526                	mv	a0,s1
    800042ec:	ffffd097          	auipc	ra,0xffffd
    800042f0:	856080e7          	jalr	-1962(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800042f4:	0149a583          	lw	a1,20(s3)
    800042f8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042fa:	0109a783          	lw	a5,16(s3)
    800042fe:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004300:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004304:	854a                	mv	a0,s2
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	ea4080e7          	jalr	-348(ra) # 800031aa <bread>
  log.lh.n = lh->n;
    8000430e:	4d30                	lw	a2,88(a0)
    80004310:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004312:	00c05f63          	blez	a2,80004330 <initlog+0x68>
    80004316:	87aa                	mv	a5,a0
    80004318:	0001d717          	auipc	a4,0x1d
    8000431c:	df870713          	add	a4,a4,-520 # 80021110 <log+0x30>
    80004320:	060a                	sll	a2,a2,0x2
    80004322:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004324:	4ff4                	lw	a3,92(a5)
    80004326:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004328:	0791                	add	a5,a5,4
    8000432a:	0711                	add	a4,a4,4
    8000432c:	fec79ce3          	bne	a5,a2,80004324 <initlog+0x5c>
  brelse(buf);
    80004330:	fffff097          	auipc	ra,0xfffff
    80004334:	faa080e7          	jalr	-86(ra) # 800032da <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004338:	4505                	li	a0,1
    8000433a:	00000097          	auipc	ra,0x0
    8000433e:	eca080e7          	jalr	-310(ra) # 80004204 <install_trans>
  log.lh.n = 0;
    80004342:	0001d797          	auipc	a5,0x1d
    80004346:	dc07a523          	sw	zero,-566(a5) # 8002110c <log+0x2c>
  write_head(); // clear the log
    8000434a:	00000097          	auipc	ra,0x0
    8000434e:	e50080e7          	jalr	-432(ra) # 8000419a <write_head>
}
    80004352:	70a2                	ld	ra,40(sp)
    80004354:	7402                	ld	s0,32(sp)
    80004356:	64e2                	ld	s1,24(sp)
    80004358:	6942                	ld	s2,16(sp)
    8000435a:	69a2                	ld	s3,8(sp)
    8000435c:	6145                	add	sp,sp,48
    8000435e:	8082                	ret

0000000080004360 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004360:	1101                	add	sp,sp,-32
    80004362:	ec06                	sd	ra,24(sp)
    80004364:	e822                	sd	s0,16(sp)
    80004366:	e426                	sd	s1,8(sp)
    80004368:	e04a                	sd	s2,0(sp)
    8000436a:	1000                	add	s0,sp,32
  acquire(&log.lock);
    8000436c:	0001d517          	auipc	a0,0x1d
    80004370:	d7450513          	add	a0,a0,-652 # 800210e0 <log>
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	85e080e7          	jalr	-1954(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000437c:	0001d497          	auipc	s1,0x1d
    80004380:	d6448493          	add	s1,s1,-668 # 800210e0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004384:	4979                	li	s2,30
    80004386:	a039                	j	80004394 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004388:	85a6                	mv	a1,s1
    8000438a:	8526                	mv	a0,s1
    8000438c:	ffffe097          	auipc	ra,0xffffe
    80004390:	d72080e7          	jalr	-654(ra) # 800020fe <sleep>
    if(log.committing){
    80004394:	50dc                	lw	a5,36(s1)
    80004396:	fbed                	bnez	a5,80004388 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004398:	5098                	lw	a4,32(s1)
    8000439a:	2705                	addw	a4,a4,1
    8000439c:	0027179b          	sllw	a5,a4,0x2
    800043a0:	9fb9                	addw	a5,a5,a4
    800043a2:	0017979b          	sllw	a5,a5,0x1
    800043a6:	54d4                	lw	a3,44(s1)
    800043a8:	9fb5                	addw	a5,a5,a3
    800043aa:	00f95963          	bge	s2,a5,800043bc <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043ae:	85a6                	mv	a1,s1
    800043b0:	8526                	mv	a0,s1
    800043b2:	ffffe097          	auipc	ra,0xffffe
    800043b6:	d4c080e7          	jalr	-692(ra) # 800020fe <sleep>
    800043ba:	bfe9                	j	80004394 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043bc:	0001d517          	auipc	a0,0x1d
    800043c0:	d2450513          	add	a0,a0,-732 # 800210e0 <log>
    800043c4:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800043c6:	ffffd097          	auipc	ra,0xffffd
    800043ca:	8c0080e7          	jalr	-1856(ra) # 80000c86 <release>
      break;
    }
  }
}
    800043ce:	60e2                	ld	ra,24(sp)
    800043d0:	6442                	ld	s0,16(sp)
    800043d2:	64a2                	ld	s1,8(sp)
    800043d4:	6902                	ld	s2,0(sp)
    800043d6:	6105                	add	sp,sp,32
    800043d8:	8082                	ret

00000000800043da <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043da:	7139                	add	sp,sp,-64
    800043dc:	fc06                	sd	ra,56(sp)
    800043de:	f822                	sd	s0,48(sp)
    800043e0:	f426                	sd	s1,40(sp)
    800043e2:	f04a                	sd	s2,32(sp)
    800043e4:	ec4e                	sd	s3,24(sp)
    800043e6:	e852                	sd	s4,16(sp)
    800043e8:	e456                	sd	s5,8(sp)
    800043ea:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043ec:	0001d497          	auipc	s1,0x1d
    800043f0:	cf448493          	add	s1,s1,-780 # 800210e0 <log>
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffc097          	auipc	ra,0xffffc
    800043fa:	7dc080e7          	jalr	2012(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800043fe:	509c                	lw	a5,32(s1)
    80004400:	37fd                	addw	a5,a5,-1
    80004402:	0007891b          	sext.w	s2,a5
    80004406:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004408:	50dc                	lw	a5,36(s1)
    8000440a:	e7b9                	bnez	a5,80004458 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000440c:	04091e63          	bnez	s2,80004468 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004410:	0001d497          	auipc	s1,0x1d
    80004414:	cd048493          	add	s1,s1,-816 # 800210e0 <log>
    80004418:	4785                	li	a5,1
    8000441a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000441c:	8526                	mv	a0,s1
    8000441e:	ffffd097          	auipc	ra,0xffffd
    80004422:	868080e7          	jalr	-1944(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004426:	54dc                	lw	a5,44(s1)
    80004428:	06f04763          	bgtz	a5,80004496 <end_op+0xbc>
    acquire(&log.lock);
    8000442c:	0001d497          	auipc	s1,0x1d
    80004430:	cb448493          	add	s1,s1,-844 # 800210e0 <log>
    80004434:	8526                	mv	a0,s1
    80004436:	ffffc097          	auipc	ra,0xffffc
    8000443a:	79c080e7          	jalr	1948(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000443e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004442:	8526                	mv	a0,s1
    80004444:	ffffe097          	auipc	ra,0xffffe
    80004448:	d1e080e7          	jalr	-738(ra) # 80002162 <wakeup>
    release(&log.lock);
    8000444c:	8526                	mv	a0,s1
    8000444e:	ffffd097          	auipc	ra,0xffffd
    80004452:	838080e7          	jalr	-1992(ra) # 80000c86 <release>
}
    80004456:	a03d                	j	80004484 <end_op+0xaa>
    panic("log.committing");
    80004458:	00004517          	auipc	a0,0x4
    8000445c:	1a050513          	add	a0,a0,416 # 800085f8 <syscalls+0x1f0>
    80004460:	ffffc097          	auipc	ra,0xffffc
    80004464:	0dc080e7          	jalr	220(ra) # 8000053c <panic>
    wakeup(&log);
    80004468:	0001d497          	auipc	s1,0x1d
    8000446c:	c7848493          	add	s1,s1,-904 # 800210e0 <log>
    80004470:	8526                	mv	a0,s1
    80004472:	ffffe097          	auipc	ra,0xffffe
    80004476:	cf0080e7          	jalr	-784(ra) # 80002162 <wakeup>
  release(&log.lock);
    8000447a:	8526                	mv	a0,s1
    8000447c:	ffffd097          	auipc	ra,0xffffd
    80004480:	80a080e7          	jalr	-2038(ra) # 80000c86 <release>
}
    80004484:	70e2                	ld	ra,56(sp)
    80004486:	7442                	ld	s0,48(sp)
    80004488:	74a2                	ld	s1,40(sp)
    8000448a:	7902                	ld	s2,32(sp)
    8000448c:	69e2                	ld	s3,24(sp)
    8000448e:	6a42                	ld	s4,16(sp)
    80004490:	6aa2                	ld	s5,8(sp)
    80004492:	6121                	add	sp,sp,64
    80004494:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004496:	0001da97          	auipc	s5,0x1d
    8000449a:	c7aa8a93          	add	s5,s5,-902 # 80021110 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000449e:	0001da17          	auipc	s4,0x1d
    800044a2:	c42a0a13          	add	s4,s4,-958 # 800210e0 <log>
    800044a6:	018a2583          	lw	a1,24(s4)
    800044aa:	012585bb          	addw	a1,a1,s2
    800044ae:	2585                	addw	a1,a1,1
    800044b0:	028a2503          	lw	a0,40(s4)
    800044b4:	fffff097          	auipc	ra,0xfffff
    800044b8:	cf6080e7          	jalr	-778(ra) # 800031aa <bread>
    800044bc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044be:	000aa583          	lw	a1,0(s5)
    800044c2:	028a2503          	lw	a0,40(s4)
    800044c6:	fffff097          	auipc	ra,0xfffff
    800044ca:	ce4080e7          	jalr	-796(ra) # 800031aa <bread>
    800044ce:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044d0:	40000613          	li	a2,1024
    800044d4:	05850593          	add	a1,a0,88
    800044d8:	05848513          	add	a0,s1,88
    800044dc:	ffffd097          	auipc	ra,0xffffd
    800044e0:	84e080e7          	jalr	-1970(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800044e4:	8526                	mv	a0,s1
    800044e6:	fffff097          	auipc	ra,0xfffff
    800044ea:	db6080e7          	jalr	-586(ra) # 8000329c <bwrite>
    brelse(from);
    800044ee:	854e                	mv	a0,s3
    800044f0:	fffff097          	auipc	ra,0xfffff
    800044f4:	dea080e7          	jalr	-534(ra) # 800032da <brelse>
    brelse(to);
    800044f8:	8526                	mv	a0,s1
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	de0080e7          	jalr	-544(ra) # 800032da <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004502:	2905                	addw	s2,s2,1
    80004504:	0a91                	add	s5,s5,4
    80004506:	02ca2783          	lw	a5,44(s4)
    8000450a:	f8f94ee3          	blt	s2,a5,800044a6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000450e:	00000097          	auipc	ra,0x0
    80004512:	c8c080e7          	jalr	-884(ra) # 8000419a <write_head>
    install_trans(0); // Now install writes to home locations
    80004516:	4501                	li	a0,0
    80004518:	00000097          	auipc	ra,0x0
    8000451c:	cec080e7          	jalr	-788(ra) # 80004204 <install_trans>
    log.lh.n = 0;
    80004520:	0001d797          	auipc	a5,0x1d
    80004524:	be07a623          	sw	zero,-1044(a5) # 8002110c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	c72080e7          	jalr	-910(ra) # 8000419a <write_head>
    80004530:	bdf5                	j	8000442c <end_op+0x52>

0000000080004532 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004532:	1101                	add	sp,sp,-32
    80004534:	ec06                	sd	ra,24(sp)
    80004536:	e822                	sd	s0,16(sp)
    80004538:	e426                	sd	s1,8(sp)
    8000453a:	e04a                	sd	s2,0(sp)
    8000453c:	1000                	add	s0,sp,32
    8000453e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004540:	0001d917          	auipc	s2,0x1d
    80004544:	ba090913          	add	s2,s2,-1120 # 800210e0 <log>
    80004548:	854a                	mv	a0,s2
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	688080e7          	jalr	1672(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004552:	02c92603          	lw	a2,44(s2)
    80004556:	47f5                	li	a5,29
    80004558:	06c7c563          	blt	a5,a2,800045c2 <log_write+0x90>
    8000455c:	0001d797          	auipc	a5,0x1d
    80004560:	ba07a783          	lw	a5,-1120(a5) # 800210fc <log+0x1c>
    80004564:	37fd                	addw	a5,a5,-1
    80004566:	04f65e63          	bge	a2,a5,800045c2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000456a:	0001d797          	auipc	a5,0x1d
    8000456e:	b967a783          	lw	a5,-1130(a5) # 80021100 <log+0x20>
    80004572:	06f05063          	blez	a5,800045d2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004576:	4781                	li	a5,0
    80004578:	06c05563          	blez	a2,800045e2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000457c:	44cc                	lw	a1,12(s1)
    8000457e:	0001d717          	auipc	a4,0x1d
    80004582:	b9270713          	add	a4,a4,-1134 # 80021110 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004586:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004588:	4314                	lw	a3,0(a4)
    8000458a:	04b68c63          	beq	a3,a1,800045e2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000458e:	2785                	addw	a5,a5,1
    80004590:	0711                	add	a4,a4,4
    80004592:	fef61be3          	bne	a2,a5,80004588 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004596:	0621                	add	a2,a2,8
    80004598:	060a                	sll	a2,a2,0x2
    8000459a:	0001d797          	auipc	a5,0x1d
    8000459e:	b4678793          	add	a5,a5,-1210 # 800210e0 <log>
    800045a2:	97b2                	add	a5,a5,a2
    800045a4:	44d8                	lw	a4,12(s1)
    800045a6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045a8:	8526                	mv	a0,s1
    800045aa:	fffff097          	auipc	ra,0xfffff
    800045ae:	dcc080e7          	jalr	-564(ra) # 80003376 <bpin>
    log.lh.n++;
    800045b2:	0001d717          	auipc	a4,0x1d
    800045b6:	b2e70713          	add	a4,a4,-1234 # 800210e0 <log>
    800045ba:	575c                	lw	a5,44(a4)
    800045bc:	2785                	addw	a5,a5,1
    800045be:	d75c                	sw	a5,44(a4)
    800045c0:	a82d                	j	800045fa <log_write+0xc8>
    panic("too big a transaction");
    800045c2:	00004517          	auipc	a0,0x4
    800045c6:	04650513          	add	a0,a0,70 # 80008608 <syscalls+0x200>
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	f72080e7          	jalr	-142(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800045d2:	00004517          	auipc	a0,0x4
    800045d6:	04e50513          	add	a0,a0,78 # 80008620 <syscalls+0x218>
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	f62080e7          	jalr	-158(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800045e2:	00878693          	add	a3,a5,8
    800045e6:	068a                	sll	a3,a3,0x2
    800045e8:	0001d717          	auipc	a4,0x1d
    800045ec:	af870713          	add	a4,a4,-1288 # 800210e0 <log>
    800045f0:	9736                	add	a4,a4,a3
    800045f2:	44d4                	lw	a3,12(s1)
    800045f4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045f6:	faf609e3          	beq	a2,a5,800045a8 <log_write+0x76>
  }
  release(&log.lock);
    800045fa:	0001d517          	auipc	a0,0x1d
    800045fe:	ae650513          	add	a0,a0,-1306 # 800210e0 <log>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	684080e7          	jalr	1668(ra) # 80000c86 <release>
}
    8000460a:	60e2                	ld	ra,24(sp)
    8000460c:	6442                	ld	s0,16(sp)
    8000460e:	64a2                	ld	s1,8(sp)
    80004610:	6902                	ld	s2,0(sp)
    80004612:	6105                	add	sp,sp,32
    80004614:	8082                	ret

0000000080004616 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004616:	1101                	add	sp,sp,-32
    80004618:	ec06                	sd	ra,24(sp)
    8000461a:	e822                	sd	s0,16(sp)
    8000461c:	e426                	sd	s1,8(sp)
    8000461e:	e04a                	sd	s2,0(sp)
    80004620:	1000                	add	s0,sp,32
    80004622:	84aa                	mv	s1,a0
    80004624:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004626:	00004597          	auipc	a1,0x4
    8000462a:	01a58593          	add	a1,a1,26 # 80008640 <syscalls+0x238>
    8000462e:	0521                	add	a0,a0,8
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	512080e7          	jalr	1298(ra) # 80000b42 <initlock>
  lk->name = name;
    80004638:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000463c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004640:	0204a423          	sw	zero,40(s1)
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	add	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004650:	1101                	add	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	e04a                	sd	s2,0(sp)
    8000465a:	1000                	add	s0,sp,32
    8000465c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000465e:	00850913          	add	s2,a0,8
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	56e080e7          	jalr	1390(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000466c:	409c                	lw	a5,0(s1)
    8000466e:	cb89                	beqz	a5,80004680 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004670:	85ca                	mv	a1,s2
    80004672:	8526                	mv	a0,s1
    80004674:	ffffe097          	auipc	ra,0xffffe
    80004678:	a8a080e7          	jalr	-1398(ra) # 800020fe <sleep>
  while (lk->locked) {
    8000467c:	409c                	lw	a5,0(s1)
    8000467e:	fbed                	bnez	a5,80004670 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004680:	4785                	li	a5,1
    80004682:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004684:	ffffd097          	auipc	ra,0xffffd
    80004688:	332080e7          	jalr	818(ra) # 800019b6 <myproc>
    8000468c:	591c                	lw	a5,48(a0)
    8000468e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004690:	854a                	mv	a0,s2
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	5f4080e7          	jalr	1524(ra) # 80000c86 <release>
}
    8000469a:	60e2                	ld	ra,24(sp)
    8000469c:	6442                	ld	s0,16(sp)
    8000469e:	64a2                	ld	s1,8(sp)
    800046a0:	6902                	ld	s2,0(sp)
    800046a2:	6105                	add	sp,sp,32
    800046a4:	8082                	ret

00000000800046a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046a6:	1101                	add	sp,sp,-32
    800046a8:	ec06                	sd	ra,24(sp)
    800046aa:	e822                	sd	s0,16(sp)
    800046ac:	e426                	sd	s1,8(sp)
    800046ae:	e04a                	sd	s2,0(sp)
    800046b0:	1000                	add	s0,sp,32
    800046b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046b4:	00850913          	add	s2,a0,8
    800046b8:	854a                	mv	a0,s2
    800046ba:	ffffc097          	auipc	ra,0xffffc
    800046be:	518080e7          	jalr	1304(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800046c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046c6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046ca:	8526                	mv	a0,s1
    800046cc:	ffffe097          	auipc	ra,0xffffe
    800046d0:	a96080e7          	jalr	-1386(ra) # 80002162 <wakeup>
  release(&lk->lk);
    800046d4:	854a                	mv	a0,s2
    800046d6:	ffffc097          	auipc	ra,0xffffc
    800046da:	5b0080e7          	jalr	1456(ra) # 80000c86 <release>
}
    800046de:	60e2                	ld	ra,24(sp)
    800046e0:	6442                	ld	s0,16(sp)
    800046e2:	64a2                	ld	s1,8(sp)
    800046e4:	6902                	ld	s2,0(sp)
    800046e6:	6105                	add	sp,sp,32
    800046e8:	8082                	ret

00000000800046ea <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046ea:	7179                	add	sp,sp,-48
    800046ec:	f406                	sd	ra,40(sp)
    800046ee:	f022                	sd	s0,32(sp)
    800046f0:	ec26                	sd	s1,24(sp)
    800046f2:	e84a                	sd	s2,16(sp)
    800046f4:	e44e                	sd	s3,8(sp)
    800046f6:	1800                	add	s0,sp,48
    800046f8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046fa:	00850913          	add	s2,a0,8
    800046fe:	854a                	mv	a0,s2
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	4d2080e7          	jalr	1234(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004708:	409c                	lw	a5,0(s1)
    8000470a:	ef99                	bnez	a5,80004728 <holdingsleep+0x3e>
    8000470c:	4481                	li	s1,0
  release(&lk->lk);
    8000470e:	854a                	mv	a0,s2
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	576080e7          	jalr	1398(ra) # 80000c86 <release>
  return r;
}
    80004718:	8526                	mv	a0,s1
    8000471a:	70a2                	ld	ra,40(sp)
    8000471c:	7402                	ld	s0,32(sp)
    8000471e:	64e2                	ld	s1,24(sp)
    80004720:	6942                	ld	s2,16(sp)
    80004722:	69a2                	ld	s3,8(sp)
    80004724:	6145                	add	sp,sp,48
    80004726:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004728:	0284a983          	lw	s3,40(s1)
    8000472c:	ffffd097          	auipc	ra,0xffffd
    80004730:	28a080e7          	jalr	650(ra) # 800019b6 <myproc>
    80004734:	5904                	lw	s1,48(a0)
    80004736:	413484b3          	sub	s1,s1,s3
    8000473a:	0014b493          	seqz	s1,s1
    8000473e:	bfc1                	j	8000470e <holdingsleep+0x24>

0000000080004740 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004740:	1141                	add	sp,sp,-16
    80004742:	e406                	sd	ra,8(sp)
    80004744:	e022                	sd	s0,0(sp)
    80004746:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004748:	00004597          	auipc	a1,0x4
    8000474c:	f0858593          	add	a1,a1,-248 # 80008650 <syscalls+0x248>
    80004750:	0001d517          	auipc	a0,0x1d
    80004754:	ad850513          	add	a0,a0,-1320 # 80021228 <ftable>
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	3ea080e7          	jalr	1002(ra) # 80000b42 <initlock>
}
    80004760:	60a2                	ld	ra,8(sp)
    80004762:	6402                	ld	s0,0(sp)
    80004764:	0141                	add	sp,sp,16
    80004766:	8082                	ret

0000000080004768 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004768:	1101                	add	sp,sp,-32
    8000476a:	ec06                	sd	ra,24(sp)
    8000476c:	e822                	sd	s0,16(sp)
    8000476e:	e426                	sd	s1,8(sp)
    80004770:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004772:	0001d517          	auipc	a0,0x1d
    80004776:	ab650513          	add	a0,a0,-1354 # 80021228 <ftable>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	458080e7          	jalr	1112(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004782:	0001d497          	auipc	s1,0x1d
    80004786:	abe48493          	add	s1,s1,-1346 # 80021240 <ftable+0x18>
    8000478a:	0001e717          	auipc	a4,0x1e
    8000478e:	a5670713          	add	a4,a4,-1450 # 800221e0 <readlock>
    if(f->ref == 0){
    80004792:	40dc                	lw	a5,4(s1)
    80004794:	cf99                	beqz	a5,800047b2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004796:	02848493          	add	s1,s1,40
    8000479a:	fee49ce3          	bne	s1,a4,80004792 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000479e:	0001d517          	auipc	a0,0x1d
    800047a2:	a8a50513          	add	a0,a0,-1398 # 80021228 <ftable>
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	4e0080e7          	jalr	1248(ra) # 80000c86 <release>
  return 0;
    800047ae:	4481                	li	s1,0
    800047b0:	a819                	j	800047c6 <filealloc+0x5e>
      f->ref = 1;
    800047b2:	4785                	li	a5,1
    800047b4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047b6:	0001d517          	auipc	a0,0x1d
    800047ba:	a7250513          	add	a0,a0,-1422 # 80021228 <ftable>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	4c8080e7          	jalr	1224(ra) # 80000c86 <release>
}
    800047c6:	8526                	mv	a0,s1
    800047c8:	60e2                	ld	ra,24(sp)
    800047ca:	6442                	ld	s0,16(sp)
    800047cc:	64a2                	ld	s1,8(sp)
    800047ce:	6105                	add	sp,sp,32
    800047d0:	8082                	ret

00000000800047d2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047d2:	1101                	add	sp,sp,-32
    800047d4:	ec06                	sd	ra,24(sp)
    800047d6:	e822                	sd	s0,16(sp)
    800047d8:	e426                	sd	s1,8(sp)
    800047da:	1000                	add	s0,sp,32
    800047dc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047de:	0001d517          	auipc	a0,0x1d
    800047e2:	a4a50513          	add	a0,a0,-1462 # 80021228 <ftable>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	3ec080e7          	jalr	1004(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800047ee:	40dc                	lw	a5,4(s1)
    800047f0:	02f05263          	blez	a5,80004814 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047f4:	2785                	addw	a5,a5,1
    800047f6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047f8:	0001d517          	auipc	a0,0x1d
    800047fc:	a3050513          	add	a0,a0,-1488 # 80021228 <ftable>
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	486080e7          	jalr	1158(ra) # 80000c86 <release>
  return f;
}
    80004808:	8526                	mv	a0,s1
    8000480a:	60e2                	ld	ra,24(sp)
    8000480c:	6442                	ld	s0,16(sp)
    8000480e:	64a2                	ld	s1,8(sp)
    80004810:	6105                	add	sp,sp,32
    80004812:	8082                	ret
    panic("filedup");
    80004814:	00004517          	auipc	a0,0x4
    80004818:	e4450513          	add	a0,a0,-444 # 80008658 <syscalls+0x250>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	d20080e7          	jalr	-736(ra) # 8000053c <panic>

0000000080004824 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004824:	7139                	add	sp,sp,-64
    80004826:	fc06                	sd	ra,56(sp)
    80004828:	f822                	sd	s0,48(sp)
    8000482a:	f426                	sd	s1,40(sp)
    8000482c:	f04a                	sd	s2,32(sp)
    8000482e:	ec4e                	sd	s3,24(sp)
    80004830:	e852                	sd	s4,16(sp)
    80004832:	e456                	sd	s5,8(sp)
    80004834:	0080                	add	s0,sp,64
    80004836:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004838:	0001d517          	auipc	a0,0x1d
    8000483c:	9f050513          	add	a0,a0,-1552 # 80021228 <ftable>
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	392080e7          	jalr	914(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004848:	40dc                	lw	a5,4(s1)
    8000484a:	06f05163          	blez	a5,800048ac <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000484e:	37fd                	addw	a5,a5,-1
    80004850:	0007871b          	sext.w	a4,a5
    80004854:	c0dc                	sw	a5,4(s1)
    80004856:	06e04363          	bgtz	a4,800048bc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000485a:	0004a903          	lw	s2,0(s1)
    8000485e:	0094ca83          	lbu	s5,9(s1)
    80004862:	0104ba03          	ld	s4,16(s1)
    80004866:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000486a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000486e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004872:	0001d517          	auipc	a0,0x1d
    80004876:	9b650513          	add	a0,a0,-1610 # 80021228 <ftable>
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	40c080e7          	jalr	1036(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004882:	4785                	li	a5,1
    80004884:	04f90d63          	beq	s2,a5,800048de <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004888:	3979                	addw	s2,s2,-2
    8000488a:	4785                	li	a5,1
    8000488c:	0527e063          	bltu	a5,s2,800048cc <fileclose+0xa8>
    begin_op();
    80004890:	00000097          	auipc	ra,0x0
    80004894:	ad0080e7          	jalr	-1328(ra) # 80004360 <begin_op>
    iput(ff.ip);
    80004898:	854e                	mv	a0,s3
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	2da080e7          	jalr	730(ra) # 80003b74 <iput>
    end_op();
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	b38080e7          	jalr	-1224(ra) # 800043da <end_op>
    800048aa:	a00d                	j	800048cc <fileclose+0xa8>
    panic("fileclose");
    800048ac:	00004517          	auipc	a0,0x4
    800048b0:	db450513          	add	a0,a0,-588 # 80008660 <syscalls+0x258>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	c88080e7          	jalr	-888(ra) # 8000053c <panic>
    release(&ftable.lock);
    800048bc:	0001d517          	auipc	a0,0x1d
    800048c0:	96c50513          	add	a0,a0,-1684 # 80021228 <ftable>
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	3c2080e7          	jalr	962(ra) # 80000c86 <release>
  }
}
    800048cc:	70e2                	ld	ra,56(sp)
    800048ce:	7442                	ld	s0,48(sp)
    800048d0:	74a2                	ld	s1,40(sp)
    800048d2:	7902                	ld	s2,32(sp)
    800048d4:	69e2                	ld	s3,24(sp)
    800048d6:	6a42                	ld	s4,16(sp)
    800048d8:	6aa2                	ld	s5,8(sp)
    800048da:	6121                	add	sp,sp,64
    800048dc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048de:	85d6                	mv	a1,s5
    800048e0:	8552                	mv	a0,s4
    800048e2:	00000097          	auipc	ra,0x0
    800048e6:	348080e7          	jalr	840(ra) # 80004c2a <pipeclose>
    800048ea:	b7cd                	j	800048cc <fileclose+0xa8>

00000000800048ec <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048ec:	715d                	add	sp,sp,-80
    800048ee:	e486                	sd	ra,72(sp)
    800048f0:	e0a2                	sd	s0,64(sp)
    800048f2:	fc26                	sd	s1,56(sp)
    800048f4:	f84a                	sd	s2,48(sp)
    800048f6:	f44e                	sd	s3,40(sp)
    800048f8:	0880                	add	s0,sp,80
    800048fa:	84aa                	mv	s1,a0
    800048fc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048fe:	ffffd097          	auipc	ra,0xffffd
    80004902:	0b8080e7          	jalr	184(ra) # 800019b6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004906:	409c                	lw	a5,0(s1)
    80004908:	37f9                	addw	a5,a5,-2
    8000490a:	4705                	li	a4,1
    8000490c:	04f76763          	bltu	a4,a5,8000495a <filestat+0x6e>
    80004910:	892a                	mv	s2,a0
    ilock(f->ip);
    80004912:	6c88                	ld	a0,24(s1)
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	0a6080e7          	jalr	166(ra) # 800039ba <ilock>
    stati(f->ip, &st);
    8000491c:	fb840593          	add	a1,s0,-72
    80004920:	6c88                	ld	a0,24(s1)
    80004922:	fffff097          	auipc	ra,0xfffff
    80004926:	322080e7          	jalr	802(ra) # 80003c44 <stati>
    iunlock(f->ip);
    8000492a:	6c88                	ld	a0,24(s1)
    8000492c:	fffff097          	auipc	ra,0xfffff
    80004930:	150080e7          	jalr	336(ra) # 80003a7c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004934:	46e1                	li	a3,24
    80004936:	fb840613          	add	a2,s0,-72
    8000493a:	85ce                	mv	a1,s3
    8000493c:	05093503          	ld	a0,80(s2)
    80004940:	ffffd097          	auipc	ra,0xffffd
    80004944:	d36080e7          	jalr	-714(ra) # 80001676 <copyout>
    80004948:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000494c:	60a6                	ld	ra,72(sp)
    8000494e:	6406                	ld	s0,64(sp)
    80004950:	74e2                	ld	s1,56(sp)
    80004952:	7942                	ld	s2,48(sp)
    80004954:	79a2                	ld	s3,40(sp)
    80004956:	6161                	add	sp,sp,80
    80004958:	8082                	ret
  return -1;
    8000495a:	557d                	li	a0,-1
    8000495c:	bfc5                	j	8000494c <filestat+0x60>

000000008000495e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000495e:	7179                	add	sp,sp,-48
    80004960:	f406                	sd	ra,40(sp)
    80004962:	f022                	sd	s0,32(sp)
    80004964:	ec26                	sd	s1,24(sp)
    80004966:	e84a                	sd	s2,16(sp)
    80004968:	e44e                	sd	s3,8(sp)
    8000496a:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000496c:	00854783          	lbu	a5,8(a0)
    80004970:	c3d5                	beqz	a5,80004a14 <fileread+0xb6>
    80004972:	84aa                	mv	s1,a0
    80004974:	89ae                	mv	s3,a1
    80004976:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004978:	411c                	lw	a5,0(a0)
    8000497a:	4705                	li	a4,1
    8000497c:	04e78963          	beq	a5,a4,800049ce <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004980:	470d                	li	a4,3
    80004982:	04e78d63          	beq	a5,a4,800049dc <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004986:	4709                	li	a4,2
    80004988:	06e79e63          	bne	a5,a4,80004a04 <fileread+0xa6>
    ilock(f->ip);
    8000498c:	6d08                	ld	a0,24(a0)
    8000498e:	fffff097          	auipc	ra,0xfffff
    80004992:	02c080e7          	jalr	44(ra) # 800039ba <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004996:	874a                	mv	a4,s2
    80004998:	5094                	lw	a3,32(s1)
    8000499a:	864e                	mv	a2,s3
    8000499c:	4585                	li	a1,1
    8000499e:	6c88                	ld	a0,24(s1)
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	2ce080e7          	jalr	718(ra) # 80003c6e <readi>
    800049a8:	892a                	mv	s2,a0
    800049aa:	00a05563          	blez	a0,800049b4 <fileread+0x56>
      f->off += r;
    800049ae:	509c                	lw	a5,32(s1)
    800049b0:	9fa9                	addw	a5,a5,a0
    800049b2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049b4:	6c88                	ld	a0,24(s1)
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	0c6080e7          	jalr	198(ra) # 80003a7c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049be:	854a                	mv	a0,s2
    800049c0:	70a2                	ld	ra,40(sp)
    800049c2:	7402                	ld	s0,32(sp)
    800049c4:	64e2                	ld	s1,24(sp)
    800049c6:	6942                	ld	s2,16(sp)
    800049c8:	69a2                	ld	s3,8(sp)
    800049ca:	6145                	add	sp,sp,48
    800049cc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049ce:	6908                	ld	a0,16(a0)
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	3c2080e7          	jalr	962(ra) # 80004d92 <piperead>
    800049d8:	892a                	mv	s2,a0
    800049da:	b7d5                	j	800049be <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049dc:	02451783          	lh	a5,36(a0)
    800049e0:	03079693          	sll	a3,a5,0x30
    800049e4:	92c1                	srl	a3,a3,0x30
    800049e6:	4725                	li	a4,9
    800049e8:	02d76863          	bltu	a4,a3,80004a18 <fileread+0xba>
    800049ec:	0792                	sll	a5,a5,0x4
    800049ee:	0001c717          	auipc	a4,0x1c
    800049f2:	79a70713          	add	a4,a4,1946 # 80021188 <devsw>
    800049f6:	97ba                	add	a5,a5,a4
    800049f8:	639c                	ld	a5,0(a5)
    800049fa:	c38d                	beqz	a5,80004a1c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049fc:	4505                	li	a0,1
    800049fe:	9782                	jalr	a5
    80004a00:	892a                	mv	s2,a0
    80004a02:	bf75                	j	800049be <fileread+0x60>
    panic("fileread");
    80004a04:	00004517          	auipc	a0,0x4
    80004a08:	c6c50513          	add	a0,a0,-916 # 80008670 <syscalls+0x268>
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	b30080e7          	jalr	-1232(ra) # 8000053c <panic>
    return -1;
    80004a14:	597d                	li	s2,-1
    80004a16:	b765                	j	800049be <fileread+0x60>
      return -1;
    80004a18:	597d                	li	s2,-1
    80004a1a:	b755                	j	800049be <fileread+0x60>
    80004a1c:	597d                	li	s2,-1
    80004a1e:	b745                	j	800049be <fileread+0x60>

0000000080004a20 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a20:	00954783          	lbu	a5,9(a0)
    80004a24:	10078e63          	beqz	a5,80004b40 <filewrite+0x120>
{
    80004a28:	715d                	add	sp,sp,-80
    80004a2a:	e486                	sd	ra,72(sp)
    80004a2c:	e0a2                	sd	s0,64(sp)
    80004a2e:	fc26                	sd	s1,56(sp)
    80004a30:	f84a                	sd	s2,48(sp)
    80004a32:	f44e                	sd	s3,40(sp)
    80004a34:	f052                	sd	s4,32(sp)
    80004a36:	ec56                	sd	s5,24(sp)
    80004a38:	e85a                	sd	s6,16(sp)
    80004a3a:	e45e                	sd	s7,8(sp)
    80004a3c:	e062                	sd	s8,0(sp)
    80004a3e:	0880                	add	s0,sp,80
    80004a40:	892a                	mv	s2,a0
    80004a42:	8b2e                	mv	s6,a1
    80004a44:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a46:	411c                	lw	a5,0(a0)
    80004a48:	4705                	li	a4,1
    80004a4a:	02e78263          	beq	a5,a4,80004a6e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a4e:	470d                	li	a4,3
    80004a50:	02e78563          	beq	a5,a4,80004a7a <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a54:	4709                	li	a4,2
    80004a56:	0ce79d63          	bne	a5,a4,80004b30 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a5a:	0ac05b63          	blez	a2,80004b10 <filewrite+0xf0>
    int i = 0;
    80004a5e:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004a60:	6b85                	lui	s7,0x1
    80004a62:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a66:	6c05                	lui	s8,0x1
    80004a68:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004a6c:	a851                	j	80004b00 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a6e:	6908                	ld	a0,16(a0)
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	22a080e7          	jalr	554(ra) # 80004c9a <pipewrite>
    80004a78:	a045                	j	80004b18 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a7a:	02451783          	lh	a5,36(a0)
    80004a7e:	03079693          	sll	a3,a5,0x30
    80004a82:	92c1                	srl	a3,a3,0x30
    80004a84:	4725                	li	a4,9
    80004a86:	0ad76f63          	bltu	a4,a3,80004b44 <filewrite+0x124>
    80004a8a:	0792                	sll	a5,a5,0x4
    80004a8c:	0001c717          	auipc	a4,0x1c
    80004a90:	6fc70713          	add	a4,a4,1788 # 80021188 <devsw>
    80004a94:	97ba                	add	a5,a5,a4
    80004a96:	679c                	ld	a5,8(a5)
    80004a98:	cbc5                	beqz	a5,80004b48 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004a9a:	4505                	li	a0,1
    80004a9c:	9782                	jalr	a5
    80004a9e:	a8ad                	j	80004b18 <filewrite+0xf8>
      if(n1 > max)
    80004aa0:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004aa4:	00000097          	auipc	ra,0x0
    80004aa8:	8bc080e7          	jalr	-1860(ra) # 80004360 <begin_op>
      ilock(f->ip);
    80004aac:	01893503          	ld	a0,24(s2)
    80004ab0:	fffff097          	auipc	ra,0xfffff
    80004ab4:	f0a080e7          	jalr	-246(ra) # 800039ba <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ab8:	8756                	mv	a4,s5
    80004aba:	02092683          	lw	a3,32(s2)
    80004abe:	01698633          	add	a2,s3,s6
    80004ac2:	4585                	li	a1,1
    80004ac4:	01893503          	ld	a0,24(s2)
    80004ac8:	fffff097          	auipc	ra,0xfffff
    80004acc:	29e080e7          	jalr	670(ra) # 80003d66 <writei>
    80004ad0:	84aa                	mv	s1,a0
    80004ad2:	00a05763          	blez	a0,80004ae0 <filewrite+0xc0>
        f->off += r;
    80004ad6:	02092783          	lw	a5,32(s2)
    80004ada:	9fa9                	addw	a5,a5,a0
    80004adc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ae0:	01893503          	ld	a0,24(s2)
    80004ae4:	fffff097          	auipc	ra,0xfffff
    80004ae8:	f98080e7          	jalr	-104(ra) # 80003a7c <iunlock>
      end_op();
    80004aec:	00000097          	auipc	ra,0x0
    80004af0:	8ee080e7          	jalr	-1810(ra) # 800043da <end_op>

      if(r != n1){
    80004af4:	009a9f63          	bne	s5,s1,80004b12 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004af8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004afc:	0149db63          	bge	s3,s4,80004b12 <filewrite+0xf2>
      int n1 = n - i;
    80004b00:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004b04:	0004879b          	sext.w	a5,s1
    80004b08:	f8fbdce3          	bge	s7,a5,80004aa0 <filewrite+0x80>
    80004b0c:	84e2                	mv	s1,s8
    80004b0e:	bf49                	j	80004aa0 <filewrite+0x80>
    int i = 0;
    80004b10:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b12:	033a1d63          	bne	s4,s3,80004b4c <filewrite+0x12c>
    80004b16:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b18:	60a6                	ld	ra,72(sp)
    80004b1a:	6406                	ld	s0,64(sp)
    80004b1c:	74e2                	ld	s1,56(sp)
    80004b1e:	7942                	ld	s2,48(sp)
    80004b20:	79a2                	ld	s3,40(sp)
    80004b22:	7a02                	ld	s4,32(sp)
    80004b24:	6ae2                	ld	s5,24(sp)
    80004b26:	6b42                	ld	s6,16(sp)
    80004b28:	6ba2                	ld	s7,8(sp)
    80004b2a:	6c02                	ld	s8,0(sp)
    80004b2c:	6161                	add	sp,sp,80
    80004b2e:	8082                	ret
    panic("filewrite");
    80004b30:	00004517          	auipc	a0,0x4
    80004b34:	b5050513          	add	a0,a0,-1200 # 80008680 <syscalls+0x278>
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	a04080e7          	jalr	-1532(ra) # 8000053c <panic>
    return -1;
    80004b40:	557d                	li	a0,-1
}
    80004b42:	8082                	ret
      return -1;
    80004b44:	557d                	li	a0,-1
    80004b46:	bfc9                	j	80004b18 <filewrite+0xf8>
    80004b48:	557d                	li	a0,-1
    80004b4a:	b7f9                	j	80004b18 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004b4c:	557d                	li	a0,-1
    80004b4e:	b7e9                	j	80004b18 <filewrite+0xf8>

0000000080004b50 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b50:	7179                	add	sp,sp,-48
    80004b52:	f406                	sd	ra,40(sp)
    80004b54:	f022                	sd	s0,32(sp)
    80004b56:	ec26                	sd	s1,24(sp)
    80004b58:	e84a                	sd	s2,16(sp)
    80004b5a:	e44e                	sd	s3,8(sp)
    80004b5c:	e052                	sd	s4,0(sp)
    80004b5e:	1800                	add	s0,sp,48
    80004b60:	84aa                	mv	s1,a0
    80004b62:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b64:	0005b023          	sd	zero,0(a1)
    80004b68:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b6c:	00000097          	auipc	ra,0x0
    80004b70:	bfc080e7          	jalr	-1028(ra) # 80004768 <filealloc>
    80004b74:	e088                	sd	a0,0(s1)
    80004b76:	c551                	beqz	a0,80004c02 <pipealloc+0xb2>
    80004b78:	00000097          	auipc	ra,0x0
    80004b7c:	bf0080e7          	jalr	-1040(ra) # 80004768 <filealloc>
    80004b80:	00aa3023          	sd	a0,0(s4)
    80004b84:	c92d                	beqz	a0,80004bf6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	f5c080e7          	jalr	-164(ra) # 80000ae2 <kalloc>
    80004b8e:	892a                	mv	s2,a0
    80004b90:	c125                	beqz	a0,80004bf0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b92:	4985                	li	s3,1
    80004b94:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b98:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b9c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ba0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ba4:	00004597          	auipc	a1,0x4
    80004ba8:	aec58593          	add	a1,a1,-1300 # 80008690 <syscalls+0x288>
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	f96080e7          	jalr	-106(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004bb4:	609c                	ld	a5,0(s1)
    80004bb6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bba:	609c                	ld	a5,0(s1)
    80004bbc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bc0:	609c                	ld	a5,0(s1)
    80004bc2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bc6:	609c                	ld	a5,0(s1)
    80004bc8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bcc:	000a3783          	ld	a5,0(s4)
    80004bd0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bd4:	000a3783          	ld	a5,0(s4)
    80004bd8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bdc:	000a3783          	ld	a5,0(s4)
    80004be0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004be4:	000a3783          	ld	a5,0(s4)
    80004be8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bec:	4501                	li	a0,0
    80004bee:	a025                	j	80004c16 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bf0:	6088                	ld	a0,0(s1)
    80004bf2:	e501                	bnez	a0,80004bfa <pipealloc+0xaa>
    80004bf4:	a039                	j	80004c02 <pipealloc+0xb2>
    80004bf6:	6088                	ld	a0,0(s1)
    80004bf8:	c51d                	beqz	a0,80004c26 <pipealloc+0xd6>
    fileclose(*f0);
    80004bfa:	00000097          	auipc	ra,0x0
    80004bfe:	c2a080e7          	jalr	-982(ra) # 80004824 <fileclose>
  if(*f1)
    80004c02:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c06:	557d                	li	a0,-1
  if(*f1)
    80004c08:	c799                	beqz	a5,80004c16 <pipealloc+0xc6>
    fileclose(*f1);
    80004c0a:	853e                	mv	a0,a5
    80004c0c:	00000097          	auipc	ra,0x0
    80004c10:	c18080e7          	jalr	-1000(ra) # 80004824 <fileclose>
  return -1;
    80004c14:	557d                	li	a0,-1
}
    80004c16:	70a2                	ld	ra,40(sp)
    80004c18:	7402                	ld	s0,32(sp)
    80004c1a:	64e2                	ld	s1,24(sp)
    80004c1c:	6942                	ld	s2,16(sp)
    80004c1e:	69a2                	ld	s3,8(sp)
    80004c20:	6a02                	ld	s4,0(sp)
    80004c22:	6145                	add	sp,sp,48
    80004c24:	8082                	ret
  return -1;
    80004c26:	557d                	li	a0,-1
    80004c28:	b7fd                	j	80004c16 <pipealloc+0xc6>

0000000080004c2a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c2a:	1101                	add	sp,sp,-32
    80004c2c:	ec06                	sd	ra,24(sp)
    80004c2e:	e822                	sd	s0,16(sp)
    80004c30:	e426                	sd	s1,8(sp)
    80004c32:	e04a                	sd	s2,0(sp)
    80004c34:	1000                	add	s0,sp,32
    80004c36:	84aa                	mv	s1,a0
    80004c38:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	f98080e7          	jalr	-104(ra) # 80000bd2 <acquire>
  if(writable){
    80004c42:	02090d63          	beqz	s2,80004c7c <pipeclose+0x52>
    pi->writeopen = 0;
    80004c46:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c4a:	21848513          	add	a0,s1,536
    80004c4e:	ffffd097          	auipc	ra,0xffffd
    80004c52:	514080e7          	jalr	1300(ra) # 80002162 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c56:	2204b783          	ld	a5,544(s1)
    80004c5a:	eb95                	bnez	a5,80004c8e <pipeclose+0x64>
    release(&pi->lock);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	028080e7          	jalr	40(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	d7c080e7          	jalr	-644(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004c70:	60e2                	ld	ra,24(sp)
    80004c72:	6442                	ld	s0,16(sp)
    80004c74:	64a2                	ld	s1,8(sp)
    80004c76:	6902                	ld	s2,0(sp)
    80004c78:	6105                	add	sp,sp,32
    80004c7a:	8082                	ret
    pi->readopen = 0;
    80004c7c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c80:	21c48513          	add	a0,s1,540
    80004c84:	ffffd097          	auipc	ra,0xffffd
    80004c88:	4de080e7          	jalr	1246(ra) # 80002162 <wakeup>
    80004c8c:	b7e9                	j	80004c56 <pipeclose+0x2c>
    release(&pi->lock);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	ffffc097          	auipc	ra,0xffffc
    80004c94:	ff6080e7          	jalr	-10(ra) # 80000c86 <release>
}
    80004c98:	bfe1                	j	80004c70 <pipeclose+0x46>

0000000080004c9a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c9a:	711d                	add	sp,sp,-96
    80004c9c:	ec86                	sd	ra,88(sp)
    80004c9e:	e8a2                	sd	s0,80(sp)
    80004ca0:	e4a6                	sd	s1,72(sp)
    80004ca2:	e0ca                	sd	s2,64(sp)
    80004ca4:	fc4e                	sd	s3,56(sp)
    80004ca6:	f852                	sd	s4,48(sp)
    80004ca8:	f456                	sd	s5,40(sp)
    80004caa:	f05a                	sd	s6,32(sp)
    80004cac:	ec5e                	sd	s7,24(sp)
    80004cae:	e862                	sd	s8,16(sp)
    80004cb0:	1080                	add	s0,sp,96
    80004cb2:	84aa                	mv	s1,a0
    80004cb4:	8aae                	mv	s5,a1
    80004cb6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cb8:	ffffd097          	auipc	ra,0xffffd
    80004cbc:	cfe080e7          	jalr	-770(ra) # 800019b6 <myproc>
    80004cc0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cc2:	8526                	mv	a0,s1
    80004cc4:	ffffc097          	auipc	ra,0xffffc
    80004cc8:	f0e080e7          	jalr	-242(ra) # 80000bd2 <acquire>
  while(i < n){
    80004ccc:	0b405663          	blez	s4,80004d78 <pipewrite+0xde>
  int i = 0;
    80004cd0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cd2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cd4:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cd8:	21c48b93          	add	s7,s1,540
    80004cdc:	a089                	j	80004d1e <pipewrite+0x84>
      release(&pi->lock);
    80004cde:	8526                	mv	a0,s1
    80004ce0:	ffffc097          	auipc	ra,0xffffc
    80004ce4:	fa6080e7          	jalr	-90(ra) # 80000c86 <release>
      return -1;
    80004ce8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cea:	854a                	mv	a0,s2
    80004cec:	60e6                	ld	ra,88(sp)
    80004cee:	6446                	ld	s0,80(sp)
    80004cf0:	64a6                	ld	s1,72(sp)
    80004cf2:	6906                	ld	s2,64(sp)
    80004cf4:	79e2                	ld	s3,56(sp)
    80004cf6:	7a42                	ld	s4,48(sp)
    80004cf8:	7aa2                	ld	s5,40(sp)
    80004cfa:	7b02                	ld	s6,32(sp)
    80004cfc:	6be2                	ld	s7,24(sp)
    80004cfe:	6c42                	ld	s8,16(sp)
    80004d00:	6125                	add	sp,sp,96
    80004d02:	8082                	ret
      wakeup(&pi->nread);
    80004d04:	8562                	mv	a0,s8
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	45c080e7          	jalr	1116(ra) # 80002162 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d0e:	85a6                	mv	a1,s1
    80004d10:	855e                	mv	a0,s7
    80004d12:	ffffd097          	auipc	ra,0xffffd
    80004d16:	3ec080e7          	jalr	1004(ra) # 800020fe <sleep>
  while(i < n){
    80004d1a:	07495063          	bge	s2,s4,80004d7a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d1e:	2204a783          	lw	a5,544(s1)
    80004d22:	dfd5                	beqz	a5,80004cde <pipewrite+0x44>
    80004d24:	854e                	mv	a0,s3
    80004d26:	ffffd097          	auipc	ra,0xffffd
    80004d2a:	68c080e7          	jalr	1676(ra) # 800023b2 <killed>
    80004d2e:	f945                	bnez	a0,80004cde <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d30:	2184a783          	lw	a5,536(s1)
    80004d34:	21c4a703          	lw	a4,540(s1)
    80004d38:	2007879b          	addw	a5,a5,512
    80004d3c:	fcf704e3          	beq	a4,a5,80004d04 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d40:	4685                	li	a3,1
    80004d42:	01590633          	add	a2,s2,s5
    80004d46:	faf40593          	add	a1,s0,-81
    80004d4a:	0509b503          	ld	a0,80(s3)
    80004d4e:	ffffd097          	auipc	ra,0xffffd
    80004d52:	9b4080e7          	jalr	-1612(ra) # 80001702 <copyin>
    80004d56:	03650263          	beq	a0,s6,80004d7a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d5a:	21c4a783          	lw	a5,540(s1)
    80004d5e:	0017871b          	addw	a4,a5,1
    80004d62:	20e4ae23          	sw	a4,540(s1)
    80004d66:	1ff7f793          	and	a5,a5,511
    80004d6a:	97a6                	add	a5,a5,s1
    80004d6c:	faf44703          	lbu	a4,-81(s0)
    80004d70:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d74:	2905                	addw	s2,s2,1
    80004d76:	b755                	j	80004d1a <pipewrite+0x80>
  int i = 0;
    80004d78:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d7a:	21848513          	add	a0,s1,536
    80004d7e:	ffffd097          	auipc	ra,0xffffd
    80004d82:	3e4080e7          	jalr	996(ra) # 80002162 <wakeup>
  release(&pi->lock);
    80004d86:	8526                	mv	a0,s1
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	efe080e7          	jalr	-258(ra) # 80000c86 <release>
  return i;
    80004d90:	bfa9                	j	80004cea <pipewrite+0x50>

0000000080004d92 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d92:	715d                	add	sp,sp,-80
    80004d94:	e486                	sd	ra,72(sp)
    80004d96:	e0a2                	sd	s0,64(sp)
    80004d98:	fc26                	sd	s1,56(sp)
    80004d9a:	f84a                	sd	s2,48(sp)
    80004d9c:	f44e                	sd	s3,40(sp)
    80004d9e:	f052                	sd	s4,32(sp)
    80004da0:	ec56                	sd	s5,24(sp)
    80004da2:	e85a                	sd	s6,16(sp)
    80004da4:	0880                	add	s0,sp,80
    80004da6:	84aa                	mv	s1,a0
    80004da8:	892e                	mv	s2,a1
    80004daa:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dac:	ffffd097          	auipc	ra,0xffffd
    80004db0:	c0a080e7          	jalr	-1014(ra) # 800019b6 <myproc>
    80004db4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004db6:	8526                	mv	a0,s1
    80004db8:	ffffc097          	auipc	ra,0xffffc
    80004dbc:	e1a080e7          	jalr	-486(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc0:	2184a703          	lw	a4,536(s1)
    80004dc4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dc8:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dcc:	02f71763          	bne	a4,a5,80004dfa <piperead+0x68>
    80004dd0:	2244a783          	lw	a5,548(s1)
    80004dd4:	c39d                	beqz	a5,80004dfa <piperead+0x68>
    if(killed(pr)){
    80004dd6:	8552                	mv	a0,s4
    80004dd8:	ffffd097          	auipc	ra,0xffffd
    80004ddc:	5da080e7          	jalr	1498(ra) # 800023b2 <killed>
    80004de0:	e949                	bnez	a0,80004e72 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004de2:	85a6                	mv	a1,s1
    80004de4:	854e                	mv	a0,s3
    80004de6:	ffffd097          	auipc	ra,0xffffd
    80004dea:	318080e7          	jalr	792(ra) # 800020fe <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dee:	2184a703          	lw	a4,536(s1)
    80004df2:	21c4a783          	lw	a5,540(s1)
    80004df6:	fcf70de3          	beq	a4,a5,80004dd0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dfa:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dfc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dfe:	05505463          	blez	s5,80004e46 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004e02:	2184a783          	lw	a5,536(s1)
    80004e06:	21c4a703          	lw	a4,540(s1)
    80004e0a:	02f70e63          	beq	a4,a5,80004e46 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e0e:	0017871b          	addw	a4,a5,1
    80004e12:	20e4ac23          	sw	a4,536(s1)
    80004e16:	1ff7f793          	and	a5,a5,511
    80004e1a:	97a6                	add	a5,a5,s1
    80004e1c:	0187c783          	lbu	a5,24(a5)
    80004e20:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e24:	4685                	li	a3,1
    80004e26:	fbf40613          	add	a2,s0,-65
    80004e2a:	85ca                	mv	a1,s2
    80004e2c:	050a3503          	ld	a0,80(s4)
    80004e30:	ffffd097          	auipc	ra,0xffffd
    80004e34:	846080e7          	jalr	-1978(ra) # 80001676 <copyout>
    80004e38:	01650763          	beq	a0,s6,80004e46 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e3c:	2985                	addw	s3,s3,1
    80004e3e:	0905                	add	s2,s2,1
    80004e40:	fd3a91e3          	bne	s5,s3,80004e02 <piperead+0x70>
    80004e44:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e46:	21c48513          	add	a0,s1,540
    80004e4a:	ffffd097          	auipc	ra,0xffffd
    80004e4e:	318080e7          	jalr	792(ra) # 80002162 <wakeup>
  release(&pi->lock);
    80004e52:	8526                	mv	a0,s1
    80004e54:	ffffc097          	auipc	ra,0xffffc
    80004e58:	e32080e7          	jalr	-462(ra) # 80000c86 <release>
  return i;
}
    80004e5c:	854e                	mv	a0,s3
    80004e5e:	60a6                	ld	ra,72(sp)
    80004e60:	6406                	ld	s0,64(sp)
    80004e62:	74e2                	ld	s1,56(sp)
    80004e64:	7942                	ld	s2,48(sp)
    80004e66:	79a2                	ld	s3,40(sp)
    80004e68:	7a02                	ld	s4,32(sp)
    80004e6a:	6ae2                	ld	s5,24(sp)
    80004e6c:	6b42                	ld	s6,16(sp)
    80004e6e:	6161                	add	sp,sp,80
    80004e70:	8082                	ret
      release(&pi->lock);
    80004e72:	8526                	mv	a0,s1
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	e12080e7          	jalr	-494(ra) # 80000c86 <release>
      return -1;
    80004e7c:	59fd                	li	s3,-1
    80004e7e:	bff9                	j	80004e5c <piperead+0xca>

0000000080004e80 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e80:	1141                	add	sp,sp,-16
    80004e82:	e422                	sd	s0,8(sp)
    80004e84:	0800                	add	s0,sp,16
    80004e86:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e88:	8905                	and	a0,a0,1
    80004e8a:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e8c:	8b89                	and	a5,a5,2
    80004e8e:	c399                	beqz	a5,80004e94 <flags2perm+0x14>
      perm |= PTE_W;
    80004e90:	00456513          	or	a0,a0,4
    return perm;
}
    80004e94:	6422                	ld	s0,8(sp)
    80004e96:	0141                	add	sp,sp,16
    80004e98:	8082                	ret

0000000080004e9a <exec>:

int
exec(char *path, char **argv)
{
    80004e9a:	df010113          	add	sp,sp,-528
    80004e9e:	20113423          	sd	ra,520(sp)
    80004ea2:	20813023          	sd	s0,512(sp)
    80004ea6:	ffa6                	sd	s1,504(sp)
    80004ea8:	fbca                	sd	s2,496(sp)
    80004eaa:	f7ce                	sd	s3,488(sp)
    80004eac:	f3d2                	sd	s4,480(sp)
    80004eae:	efd6                	sd	s5,472(sp)
    80004eb0:	ebda                	sd	s6,464(sp)
    80004eb2:	e7de                	sd	s7,456(sp)
    80004eb4:	e3e2                	sd	s8,448(sp)
    80004eb6:	ff66                	sd	s9,440(sp)
    80004eb8:	fb6a                	sd	s10,432(sp)
    80004eba:	f76e                	sd	s11,424(sp)
    80004ebc:	0c00                	add	s0,sp,528
    80004ebe:	892a                	mv	s2,a0
    80004ec0:	dea43c23          	sd	a0,-520(s0)
    80004ec4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ec8:	ffffd097          	auipc	ra,0xffffd
    80004ecc:	aee080e7          	jalr	-1298(ra) # 800019b6 <myproc>
    80004ed0:	84aa                	mv	s1,a0

  begin_op();
    80004ed2:	fffff097          	auipc	ra,0xfffff
    80004ed6:	48e080e7          	jalr	1166(ra) # 80004360 <begin_op>

  if((ip = namei(path)) == 0){
    80004eda:	854a                	mv	a0,s2
    80004edc:	fffff097          	auipc	ra,0xfffff
    80004ee0:	284080e7          	jalr	644(ra) # 80004160 <namei>
    80004ee4:	c92d                	beqz	a0,80004f56 <exec+0xbc>
    80004ee6:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	ad2080e7          	jalr	-1326(ra) # 800039ba <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ef0:	04000713          	li	a4,64
    80004ef4:	4681                	li	a3,0
    80004ef6:	e5040613          	add	a2,s0,-432
    80004efa:	4581                	li	a1,0
    80004efc:	8552                	mv	a0,s4
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	d70080e7          	jalr	-656(ra) # 80003c6e <readi>
    80004f06:	04000793          	li	a5,64
    80004f0a:	00f51a63          	bne	a0,a5,80004f1e <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f0e:	e5042703          	lw	a4,-432(s0)
    80004f12:	464c47b7          	lui	a5,0x464c4
    80004f16:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f1a:	04f70463          	beq	a4,a5,80004f62 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f1e:	8552                	mv	a0,s4
    80004f20:	fffff097          	auipc	ra,0xfffff
    80004f24:	cfc080e7          	jalr	-772(ra) # 80003c1c <iunlockput>
    end_op();
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	4b2080e7          	jalr	1202(ra) # 800043da <end_op>
  }
  return -1;
    80004f30:	557d                	li	a0,-1
}
    80004f32:	20813083          	ld	ra,520(sp)
    80004f36:	20013403          	ld	s0,512(sp)
    80004f3a:	74fe                	ld	s1,504(sp)
    80004f3c:	795e                	ld	s2,496(sp)
    80004f3e:	79be                	ld	s3,488(sp)
    80004f40:	7a1e                	ld	s4,480(sp)
    80004f42:	6afe                	ld	s5,472(sp)
    80004f44:	6b5e                	ld	s6,464(sp)
    80004f46:	6bbe                	ld	s7,456(sp)
    80004f48:	6c1e                	ld	s8,448(sp)
    80004f4a:	7cfa                	ld	s9,440(sp)
    80004f4c:	7d5a                	ld	s10,432(sp)
    80004f4e:	7dba                	ld	s11,424(sp)
    80004f50:	21010113          	add	sp,sp,528
    80004f54:	8082                	ret
    end_op();
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	484080e7          	jalr	1156(ra) # 800043da <end_op>
    return -1;
    80004f5e:	557d                	li	a0,-1
    80004f60:	bfc9                	j	80004f32 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f62:	8526                	mv	a0,s1
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	b16080e7          	jalr	-1258(ra) # 80001a7a <proc_pagetable>
    80004f6c:	8b2a                	mv	s6,a0
    80004f6e:	d945                	beqz	a0,80004f1e <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f70:	e7042d03          	lw	s10,-400(s0)
    80004f74:	e8845783          	lhu	a5,-376(s0)
    80004f78:	10078463          	beqz	a5,80005080 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f7c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f7e:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004f80:	6c85                	lui	s9,0x1
    80004f82:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f86:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f8a:	6a85                	lui	s5,0x1
    80004f8c:	a0b5                	j	80004ff8 <exec+0x15e>
      panic("loadseg: address should exist");
    80004f8e:	00003517          	auipc	a0,0x3
    80004f92:	70a50513          	add	a0,a0,1802 # 80008698 <syscalls+0x290>
    80004f96:	ffffb097          	auipc	ra,0xffffb
    80004f9a:	5a6080e7          	jalr	1446(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004f9e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fa0:	8726                	mv	a4,s1
    80004fa2:	012c06bb          	addw	a3,s8,s2
    80004fa6:	4581                	li	a1,0
    80004fa8:	8552                	mv	a0,s4
    80004faa:	fffff097          	auipc	ra,0xfffff
    80004fae:	cc4080e7          	jalr	-828(ra) # 80003c6e <readi>
    80004fb2:	2501                	sext.w	a0,a0
    80004fb4:	24a49863          	bne	s1,a0,80005204 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004fb8:	012a893b          	addw	s2,s5,s2
    80004fbc:	03397563          	bgeu	s2,s3,80004fe6 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004fc0:	02091593          	sll	a1,s2,0x20
    80004fc4:	9181                	srl	a1,a1,0x20
    80004fc6:	95de                	add	a1,a1,s7
    80004fc8:	855a                	mv	a0,s6
    80004fca:	ffffc097          	auipc	ra,0xffffc
    80004fce:	09c080e7          	jalr	156(ra) # 80001066 <walkaddr>
    80004fd2:	862a                	mv	a2,a0
    if(pa == 0)
    80004fd4:	dd4d                	beqz	a0,80004f8e <exec+0xf4>
    if(sz - i < PGSIZE)
    80004fd6:	412984bb          	subw	s1,s3,s2
    80004fda:	0004879b          	sext.w	a5,s1
    80004fde:	fcfcf0e3          	bgeu	s9,a5,80004f9e <exec+0x104>
    80004fe2:	84d6                	mv	s1,s5
    80004fe4:	bf6d                	j	80004f9e <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fe6:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fea:	2d85                	addw	s11,s11,1
    80004fec:	038d0d1b          	addw	s10,s10,56
    80004ff0:	e8845783          	lhu	a5,-376(s0)
    80004ff4:	08fdd763          	bge	s11,a5,80005082 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ff8:	2d01                	sext.w	s10,s10
    80004ffa:	03800713          	li	a4,56
    80004ffe:	86ea                	mv	a3,s10
    80005000:	e1840613          	add	a2,s0,-488
    80005004:	4581                	li	a1,0
    80005006:	8552                	mv	a0,s4
    80005008:	fffff097          	auipc	ra,0xfffff
    8000500c:	c66080e7          	jalr	-922(ra) # 80003c6e <readi>
    80005010:	03800793          	li	a5,56
    80005014:	1ef51663          	bne	a0,a5,80005200 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80005018:	e1842783          	lw	a5,-488(s0)
    8000501c:	4705                	li	a4,1
    8000501e:	fce796e3          	bne	a5,a4,80004fea <exec+0x150>
    if(ph.memsz < ph.filesz)
    80005022:	e4043483          	ld	s1,-448(s0)
    80005026:	e3843783          	ld	a5,-456(s0)
    8000502a:	1ef4e863          	bltu	s1,a5,8000521a <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000502e:	e2843783          	ld	a5,-472(s0)
    80005032:	94be                	add	s1,s1,a5
    80005034:	1ef4e663          	bltu	s1,a5,80005220 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80005038:	df043703          	ld	a4,-528(s0)
    8000503c:	8ff9                	and	a5,a5,a4
    8000503e:	1e079463          	bnez	a5,80005226 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005042:	e1c42503          	lw	a0,-484(s0)
    80005046:	00000097          	auipc	ra,0x0
    8000504a:	e3a080e7          	jalr	-454(ra) # 80004e80 <flags2perm>
    8000504e:	86aa                	mv	a3,a0
    80005050:	8626                	mv	a2,s1
    80005052:	85ca                	mv	a1,s2
    80005054:	855a                	mv	a0,s6
    80005056:	ffffc097          	auipc	ra,0xffffc
    8000505a:	3c4080e7          	jalr	964(ra) # 8000141a <uvmalloc>
    8000505e:	e0a43423          	sd	a0,-504(s0)
    80005062:	1c050563          	beqz	a0,8000522c <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005066:	e2843b83          	ld	s7,-472(s0)
    8000506a:	e2042c03          	lw	s8,-480(s0)
    8000506e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005072:	00098463          	beqz	s3,8000507a <exec+0x1e0>
    80005076:	4901                	li	s2,0
    80005078:	b7a1                	j	80004fc0 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000507a:	e0843903          	ld	s2,-504(s0)
    8000507e:	b7b5                	j	80004fea <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005080:	4901                	li	s2,0
  iunlockput(ip);
    80005082:	8552                	mv	a0,s4
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	b98080e7          	jalr	-1128(ra) # 80003c1c <iunlockput>
  end_op();
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	34e080e7          	jalr	846(ra) # 800043da <end_op>
  p = myproc();
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	922080e7          	jalr	-1758(ra) # 800019b6 <myproc>
    8000509c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000509e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800050a2:	6985                	lui	s3,0x1
    800050a4:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    800050a6:	99ca                	add	s3,s3,s2
    800050a8:	77fd                	lui	a5,0xfffff
    800050aa:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050ae:	4691                	li	a3,4
    800050b0:	6609                	lui	a2,0x2
    800050b2:	964e                	add	a2,a2,s3
    800050b4:	85ce                	mv	a1,s3
    800050b6:	855a                	mv	a0,s6
    800050b8:	ffffc097          	auipc	ra,0xffffc
    800050bc:	362080e7          	jalr	866(ra) # 8000141a <uvmalloc>
    800050c0:	892a                	mv	s2,a0
    800050c2:	e0a43423          	sd	a0,-504(s0)
    800050c6:	e509                	bnez	a0,800050d0 <exec+0x236>
  if(pagetable)
    800050c8:	e1343423          	sd	s3,-504(s0)
    800050cc:	4a01                	li	s4,0
    800050ce:	aa1d                	j	80005204 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050d0:	75f9                	lui	a1,0xffffe
    800050d2:	95aa                	add	a1,a1,a0
    800050d4:	855a                	mv	a0,s6
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	56e080e7          	jalr	1390(ra) # 80001644 <uvmclear>
  stackbase = sp - PGSIZE;
    800050de:	7bfd                	lui	s7,0xfffff
    800050e0:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800050e2:	e0043783          	ld	a5,-512(s0)
    800050e6:	6388                	ld	a0,0(a5)
    800050e8:	c52d                	beqz	a0,80005152 <exec+0x2b8>
    800050ea:	e9040993          	add	s3,s0,-368
    800050ee:	f9040c13          	add	s8,s0,-112
    800050f2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	d54080e7          	jalr	-684(ra) # 80000e48 <strlen>
    800050fc:	0015079b          	addw	a5,a0,1
    80005100:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005104:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80005108:	13796563          	bltu	s2,s7,80005232 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000510c:	e0043d03          	ld	s10,-512(s0)
    80005110:	000d3a03          	ld	s4,0(s10)
    80005114:	8552                	mv	a0,s4
    80005116:	ffffc097          	auipc	ra,0xffffc
    8000511a:	d32080e7          	jalr	-718(ra) # 80000e48 <strlen>
    8000511e:	0015069b          	addw	a3,a0,1
    80005122:	8652                	mv	a2,s4
    80005124:	85ca                	mv	a1,s2
    80005126:	855a                	mv	a0,s6
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	54e080e7          	jalr	1358(ra) # 80001676 <copyout>
    80005130:	10054363          	bltz	a0,80005236 <exec+0x39c>
    ustack[argc] = sp;
    80005134:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005138:	0485                	add	s1,s1,1
    8000513a:	008d0793          	add	a5,s10,8
    8000513e:	e0f43023          	sd	a5,-512(s0)
    80005142:	008d3503          	ld	a0,8(s10)
    80005146:	c909                	beqz	a0,80005158 <exec+0x2be>
    if(argc >= MAXARG)
    80005148:	09a1                	add	s3,s3,8
    8000514a:	fb8995e3          	bne	s3,s8,800050f4 <exec+0x25a>
  ip = 0;
    8000514e:	4a01                	li	s4,0
    80005150:	a855                	j	80005204 <exec+0x36a>
  sp = sz;
    80005152:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005156:	4481                	li	s1,0
  ustack[argc] = 0;
    80005158:	00349793          	sll	a5,s1,0x3
    8000515c:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdcc58>
    80005160:	97a2                	add	a5,a5,s0
    80005162:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005166:	00148693          	add	a3,s1,1
    8000516a:	068e                	sll	a3,a3,0x3
    8000516c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005170:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005174:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005178:	f57968e3          	bltu	s2,s7,800050c8 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000517c:	e9040613          	add	a2,s0,-368
    80005180:	85ca                	mv	a1,s2
    80005182:	855a                	mv	a0,s6
    80005184:	ffffc097          	auipc	ra,0xffffc
    80005188:	4f2080e7          	jalr	1266(ra) # 80001676 <copyout>
    8000518c:	0a054763          	bltz	a0,8000523a <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005190:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005194:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005198:	df843783          	ld	a5,-520(s0)
    8000519c:	0007c703          	lbu	a4,0(a5)
    800051a0:	cf11                	beqz	a4,800051bc <exec+0x322>
    800051a2:	0785                	add	a5,a5,1
    if(*s == '/')
    800051a4:	02f00693          	li	a3,47
    800051a8:	a039                	j	800051b6 <exec+0x31c>
      last = s+1;
    800051aa:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051ae:	0785                	add	a5,a5,1
    800051b0:	fff7c703          	lbu	a4,-1(a5)
    800051b4:	c701                	beqz	a4,800051bc <exec+0x322>
    if(*s == '/')
    800051b6:	fed71ce3          	bne	a4,a3,800051ae <exec+0x314>
    800051ba:	bfc5                	j	800051aa <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    800051bc:	4641                	li	a2,16
    800051be:	df843583          	ld	a1,-520(s0)
    800051c2:	158a8513          	add	a0,s5,344
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	c50080e7          	jalr	-944(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    800051ce:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051d2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800051d6:	e0843783          	ld	a5,-504(s0)
    800051da:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051de:	058ab783          	ld	a5,88(s5)
    800051e2:	e6843703          	ld	a4,-408(s0)
    800051e6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051e8:	058ab783          	ld	a5,88(s5)
    800051ec:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051f0:	85e6                	mv	a1,s9
    800051f2:	ffffd097          	auipc	ra,0xffffd
    800051f6:	924080e7          	jalr	-1756(ra) # 80001b16 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051fa:	0004851b          	sext.w	a0,s1
    800051fe:	bb15                	j	80004f32 <exec+0x98>
    80005200:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005204:	e0843583          	ld	a1,-504(s0)
    80005208:	855a                	mv	a0,s6
    8000520a:	ffffd097          	auipc	ra,0xffffd
    8000520e:	90c080e7          	jalr	-1780(ra) # 80001b16 <proc_freepagetable>
  return -1;
    80005212:	557d                	li	a0,-1
  if(ip){
    80005214:	d00a0fe3          	beqz	s4,80004f32 <exec+0x98>
    80005218:	b319                	j	80004f1e <exec+0x84>
    8000521a:	e1243423          	sd	s2,-504(s0)
    8000521e:	b7dd                	j	80005204 <exec+0x36a>
    80005220:	e1243423          	sd	s2,-504(s0)
    80005224:	b7c5                	j	80005204 <exec+0x36a>
    80005226:	e1243423          	sd	s2,-504(s0)
    8000522a:	bfe9                	j	80005204 <exec+0x36a>
    8000522c:	e1243423          	sd	s2,-504(s0)
    80005230:	bfd1                	j	80005204 <exec+0x36a>
  ip = 0;
    80005232:	4a01                	li	s4,0
    80005234:	bfc1                	j	80005204 <exec+0x36a>
    80005236:	4a01                	li	s4,0
  if(pagetable)
    80005238:	b7f1                	j	80005204 <exec+0x36a>
  sz = sz1;
    8000523a:	e0843983          	ld	s3,-504(s0)
    8000523e:	b569                	j	800050c8 <exec+0x22e>

0000000080005240 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005240:	7179                	add	sp,sp,-48
    80005242:	f406                	sd	ra,40(sp)
    80005244:	f022                	sd	s0,32(sp)
    80005246:	ec26                	sd	s1,24(sp)
    80005248:	e84a                	sd	s2,16(sp)
    8000524a:	1800                	add	s0,sp,48
    8000524c:	892e                	mv	s2,a1
    8000524e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005250:	fdc40593          	add	a1,s0,-36
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	b68080e7          	jalr	-1176(ra) # 80002dbc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000525c:	fdc42703          	lw	a4,-36(s0)
    80005260:	47bd                	li	a5,15
    80005262:	02e7eb63          	bltu	a5,a4,80005298 <argfd+0x58>
    80005266:	ffffc097          	auipc	ra,0xffffc
    8000526a:	750080e7          	jalr	1872(ra) # 800019b6 <myproc>
    8000526e:	fdc42703          	lw	a4,-36(s0)
    80005272:	01a70793          	add	a5,a4,26
    80005276:	078e                	sll	a5,a5,0x3
    80005278:	953e                	add	a0,a0,a5
    8000527a:	611c                	ld	a5,0(a0)
    8000527c:	c385                	beqz	a5,8000529c <argfd+0x5c>
    return -1;
  if(pfd)
    8000527e:	00090463          	beqz	s2,80005286 <argfd+0x46>
    *pfd = fd;
    80005282:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005286:	4501                	li	a0,0
  if(pf)
    80005288:	c091                	beqz	s1,8000528c <argfd+0x4c>
    *pf = f;
    8000528a:	e09c                	sd	a5,0(s1)
}
    8000528c:	70a2                	ld	ra,40(sp)
    8000528e:	7402                	ld	s0,32(sp)
    80005290:	64e2                	ld	s1,24(sp)
    80005292:	6942                	ld	s2,16(sp)
    80005294:	6145                	add	sp,sp,48
    80005296:	8082                	ret
    return -1;
    80005298:	557d                	li	a0,-1
    8000529a:	bfcd                	j	8000528c <argfd+0x4c>
    8000529c:	557d                	li	a0,-1
    8000529e:	b7fd                	j	8000528c <argfd+0x4c>

00000000800052a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052a0:	1101                	add	sp,sp,-32
    800052a2:	ec06                	sd	ra,24(sp)
    800052a4:	e822                	sd	s0,16(sp)
    800052a6:	e426                	sd	s1,8(sp)
    800052a8:	1000                	add	s0,sp,32
    800052aa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	70a080e7          	jalr	1802(ra) # 800019b6 <myproc>
    800052b4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052b6:	0d050793          	add	a5,a0,208
    800052ba:	4501                	li	a0,0
    800052bc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052be:	6398                	ld	a4,0(a5)
    800052c0:	cb19                	beqz	a4,800052d6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052c2:	2505                	addw	a0,a0,1
    800052c4:	07a1                	add	a5,a5,8
    800052c6:	fed51ce3          	bne	a0,a3,800052be <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052ca:	557d                	li	a0,-1
}
    800052cc:	60e2                	ld	ra,24(sp)
    800052ce:	6442                	ld	s0,16(sp)
    800052d0:	64a2                	ld	s1,8(sp)
    800052d2:	6105                	add	sp,sp,32
    800052d4:	8082                	ret
      p->ofile[fd] = f;
    800052d6:	01a50793          	add	a5,a0,26
    800052da:	078e                	sll	a5,a5,0x3
    800052dc:	963e                	add	a2,a2,a5
    800052de:	e204                	sd	s1,0(a2)
      return fd;
    800052e0:	b7f5                	j	800052cc <fdalloc+0x2c>

00000000800052e2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052e2:	715d                	add	sp,sp,-80
    800052e4:	e486                	sd	ra,72(sp)
    800052e6:	e0a2                	sd	s0,64(sp)
    800052e8:	fc26                	sd	s1,56(sp)
    800052ea:	f84a                	sd	s2,48(sp)
    800052ec:	f44e                	sd	s3,40(sp)
    800052ee:	f052                	sd	s4,32(sp)
    800052f0:	ec56                	sd	s5,24(sp)
    800052f2:	e85a                	sd	s6,16(sp)
    800052f4:	0880                	add	s0,sp,80
    800052f6:	8b2e                	mv	s6,a1
    800052f8:	89b2                	mv	s3,a2
    800052fa:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052fc:	fb040593          	add	a1,s0,-80
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	e7e080e7          	jalr	-386(ra) # 8000417e <nameiparent>
    80005308:	84aa                	mv	s1,a0
    8000530a:	14050b63          	beqz	a0,80005460 <create+0x17e>
    return 0;

  ilock(dp);
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	6ac080e7          	jalr	1708(ra) # 800039ba <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005316:	4601                	li	a2,0
    80005318:	fb040593          	add	a1,s0,-80
    8000531c:	8526                	mv	a0,s1
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	b80080e7          	jalr	-1152(ra) # 80003e9e <dirlookup>
    80005326:	8aaa                	mv	s5,a0
    80005328:	c921                	beqz	a0,80005378 <create+0x96>
    iunlockput(dp);
    8000532a:	8526                	mv	a0,s1
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	8f0080e7          	jalr	-1808(ra) # 80003c1c <iunlockput>
    ilock(ip);
    80005334:	8556                	mv	a0,s5
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	684080e7          	jalr	1668(ra) # 800039ba <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000533e:	4789                	li	a5,2
    80005340:	02fb1563          	bne	s6,a5,8000536a <create+0x88>
    80005344:	044ad783          	lhu	a5,68(s5)
    80005348:	37f9                	addw	a5,a5,-2
    8000534a:	17c2                	sll	a5,a5,0x30
    8000534c:	93c1                	srl	a5,a5,0x30
    8000534e:	4705                	li	a4,1
    80005350:	00f76d63          	bltu	a4,a5,8000536a <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005354:	8556                	mv	a0,s5
    80005356:	60a6                	ld	ra,72(sp)
    80005358:	6406                	ld	s0,64(sp)
    8000535a:	74e2                	ld	s1,56(sp)
    8000535c:	7942                	ld	s2,48(sp)
    8000535e:	79a2                	ld	s3,40(sp)
    80005360:	7a02                	ld	s4,32(sp)
    80005362:	6ae2                	ld	s5,24(sp)
    80005364:	6b42                	ld	s6,16(sp)
    80005366:	6161                	add	sp,sp,80
    80005368:	8082                	ret
    iunlockput(ip);
    8000536a:	8556                	mv	a0,s5
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	8b0080e7          	jalr	-1872(ra) # 80003c1c <iunlockput>
    return 0;
    80005374:	4a81                	li	s5,0
    80005376:	bff9                	j	80005354 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005378:	85da                	mv	a1,s6
    8000537a:	4088                	lw	a0,0(s1)
    8000537c:	ffffe097          	auipc	ra,0xffffe
    80005380:	4a6080e7          	jalr	1190(ra) # 80003822 <ialloc>
    80005384:	8a2a                	mv	s4,a0
    80005386:	c529                	beqz	a0,800053d0 <create+0xee>
  ilock(ip);
    80005388:	ffffe097          	auipc	ra,0xffffe
    8000538c:	632080e7          	jalr	1586(ra) # 800039ba <ilock>
  ip->major = major;
    80005390:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005394:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005398:	4905                	li	s2,1
    8000539a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000539e:	8552                	mv	a0,s4
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	54e080e7          	jalr	1358(ra) # 800038ee <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053a8:	032b0b63          	beq	s6,s2,800053de <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053ac:	004a2603          	lw	a2,4(s4)
    800053b0:	fb040593          	add	a1,s0,-80
    800053b4:	8526                	mv	a0,s1
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	cf8080e7          	jalr	-776(ra) # 800040ae <dirlink>
    800053be:	06054f63          	bltz	a0,8000543c <create+0x15a>
  iunlockput(dp);
    800053c2:	8526                	mv	a0,s1
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	858080e7          	jalr	-1960(ra) # 80003c1c <iunlockput>
  return ip;
    800053cc:	8ad2                	mv	s5,s4
    800053ce:	b759                	j	80005354 <create+0x72>
    iunlockput(dp);
    800053d0:	8526                	mv	a0,s1
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	84a080e7          	jalr	-1974(ra) # 80003c1c <iunlockput>
    return 0;
    800053da:	8ad2                	mv	s5,s4
    800053dc:	bfa5                	j	80005354 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053de:	004a2603          	lw	a2,4(s4)
    800053e2:	00003597          	auipc	a1,0x3
    800053e6:	2d658593          	add	a1,a1,726 # 800086b8 <syscalls+0x2b0>
    800053ea:	8552                	mv	a0,s4
    800053ec:	fffff097          	auipc	ra,0xfffff
    800053f0:	cc2080e7          	jalr	-830(ra) # 800040ae <dirlink>
    800053f4:	04054463          	bltz	a0,8000543c <create+0x15a>
    800053f8:	40d0                	lw	a2,4(s1)
    800053fa:	00003597          	auipc	a1,0x3
    800053fe:	2c658593          	add	a1,a1,710 # 800086c0 <syscalls+0x2b8>
    80005402:	8552                	mv	a0,s4
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	caa080e7          	jalr	-854(ra) # 800040ae <dirlink>
    8000540c:	02054863          	bltz	a0,8000543c <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    80005410:	004a2603          	lw	a2,4(s4)
    80005414:	fb040593          	add	a1,s0,-80
    80005418:	8526                	mv	a0,s1
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	c94080e7          	jalr	-876(ra) # 800040ae <dirlink>
    80005422:	00054d63          	bltz	a0,8000543c <create+0x15a>
    dp->nlink++;  // for ".."
    80005426:	04a4d783          	lhu	a5,74(s1)
    8000542a:	2785                	addw	a5,a5,1
    8000542c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005430:	8526                	mv	a0,s1
    80005432:	ffffe097          	auipc	ra,0xffffe
    80005436:	4bc080e7          	jalr	1212(ra) # 800038ee <iupdate>
    8000543a:	b761                	j	800053c2 <create+0xe0>
  ip->nlink = 0;
    8000543c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005440:	8552                	mv	a0,s4
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	4ac080e7          	jalr	1196(ra) # 800038ee <iupdate>
  iunlockput(ip);
    8000544a:	8552                	mv	a0,s4
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	7d0080e7          	jalr	2000(ra) # 80003c1c <iunlockput>
  iunlockput(dp);
    80005454:	8526                	mv	a0,s1
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	7c6080e7          	jalr	1990(ra) # 80003c1c <iunlockput>
  return 0;
    8000545e:	bddd                	j	80005354 <create+0x72>
    return 0;
    80005460:	8aaa                	mv	s5,a0
    80005462:	bdcd                	j	80005354 <create+0x72>

0000000080005464 <sys_dup>:
{
    80005464:	7179                	add	sp,sp,-48
    80005466:	f406                	sd	ra,40(sp)
    80005468:	f022                	sd	s0,32(sp)
    8000546a:	ec26                	sd	s1,24(sp)
    8000546c:	e84a                	sd	s2,16(sp)
    8000546e:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005470:	fd840613          	add	a2,s0,-40
    80005474:	4581                	li	a1,0
    80005476:	4501                	li	a0,0
    80005478:	00000097          	auipc	ra,0x0
    8000547c:	dc8080e7          	jalr	-568(ra) # 80005240 <argfd>
    return -1;
    80005480:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005482:	02054363          	bltz	a0,800054a8 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005486:	fd843903          	ld	s2,-40(s0)
    8000548a:	854a                	mv	a0,s2
    8000548c:	00000097          	auipc	ra,0x0
    80005490:	e14080e7          	jalr	-492(ra) # 800052a0 <fdalloc>
    80005494:	84aa                	mv	s1,a0
    return -1;
    80005496:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005498:	00054863          	bltz	a0,800054a8 <sys_dup+0x44>
  filedup(f);
    8000549c:	854a                	mv	a0,s2
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	334080e7          	jalr	820(ra) # 800047d2 <filedup>
  return fd;
    800054a6:	87a6                	mv	a5,s1
}
    800054a8:	853e                	mv	a0,a5
    800054aa:	70a2                	ld	ra,40(sp)
    800054ac:	7402                	ld	s0,32(sp)
    800054ae:	64e2                	ld	s1,24(sp)
    800054b0:	6942                	ld	s2,16(sp)
    800054b2:	6145                	add	sp,sp,48
    800054b4:	8082                	ret

00000000800054b6 <sys_read>:
{
    800054b6:	7139                	add	sp,sp,-64
    800054b8:	fc06                	sd	ra,56(sp)
    800054ba:	f822                	sd	s0,48(sp)
    800054bc:	f426                	sd	s1,40(sp)
    800054be:	0080                	add	s0,sp,64
  acquire(&readlock);
    800054c0:	0001d497          	auipc	s1,0x1d
    800054c4:	d2048493          	add	s1,s1,-736 # 800221e0 <readlock>
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffb097          	auipc	ra,0xffffb
    800054ce:	708080e7          	jalr	1800(ra) # 80000bd2 <acquire>
  read++;
    800054d2:	00003717          	auipc	a4,0x3
    800054d6:	3d270713          	add	a4,a4,978 # 800088a4 <read>
    800054da:	431c                	lw	a5,0(a4)
    800054dc:	2785                	addw	a5,a5,1
    800054de:	c31c                	sw	a5,0(a4)
  release(&readlock);
    800054e0:	8526                	mv	a0,s1
    800054e2:	ffffb097          	auipc	ra,0xffffb
    800054e6:	7a4080e7          	jalr	1956(ra) # 80000c86 <release>
  argaddr(1, &p);
    800054ea:	fc840593          	add	a1,s0,-56
    800054ee:	4505                	li	a0,1
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	8ec080e7          	jalr	-1812(ra) # 80002ddc <argaddr>
  argint(2, &n);
    800054f8:	fd440593          	add	a1,s0,-44
    800054fc:	4509                	li	a0,2
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	8be080e7          	jalr	-1858(ra) # 80002dbc <argint>
  if(argfd(0, 0, &f) < 0)
    80005506:	fd840613          	add	a2,s0,-40
    8000550a:	4581                	li	a1,0
    8000550c:	4501                	li	a0,0
    8000550e:	00000097          	auipc	ra,0x0
    80005512:	d32080e7          	jalr	-718(ra) # 80005240 <argfd>
    80005516:	87aa                	mv	a5,a0
    return -1;
    80005518:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000551a:	0007cc63          	bltz	a5,80005532 <sys_read+0x7c>
  return fileread(f, p, n);
    8000551e:	fd442603          	lw	a2,-44(s0)
    80005522:	fc843583          	ld	a1,-56(s0)
    80005526:	fd843503          	ld	a0,-40(s0)
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	434080e7          	jalr	1076(ra) # 8000495e <fileread>
}
    80005532:	70e2                	ld	ra,56(sp)
    80005534:	7442                	ld	s0,48(sp)
    80005536:	74a2                	ld	s1,40(sp)
    80005538:	6121                	add	sp,sp,64
    8000553a:	8082                	ret

000000008000553c <sys_getreadcount>:
{
    8000553c:	1141                	add	sp,sp,-16
    8000553e:	e422                	sd	s0,8(sp)
    80005540:	0800                	add	s0,sp,16
}
    80005542:	00003517          	auipc	a0,0x3
    80005546:	36252503          	lw	a0,866(a0) # 800088a4 <read>
    8000554a:	6422                	ld	s0,8(sp)
    8000554c:	0141                	add	sp,sp,16
    8000554e:	8082                	ret

0000000080005550 <sys_write>:
{
    80005550:	7179                	add	sp,sp,-48
    80005552:	f406                	sd	ra,40(sp)
    80005554:	f022                	sd	s0,32(sp)
    80005556:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005558:	fd840593          	add	a1,s0,-40
    8000555c:	4505                	li	a0,1
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	87e080e7          	jalr	-1922(ra) # 80002ddc <argaddr>
  argint(2, &n);
    80005566:	fe440593          	add	a1,s0,-28
    8000556a:	4509                	li	a0,2
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	850080e7          	jalr	-1968(ra) # 80002dbc <argint>
  if(argfd(0, 0, &f) < 0)
    80005574:	fe840613          	add	a2,s0,-24
    80005578:	4581                	li	a1,0
    8000557a:	4501                	li	a0,0
    8000557c:	00000097          	auipc	ra,0x0
    80005580:	cc4080e7          	jalr	-828(ra) # 80005240 <argfd>
    80005584:	87aa                	mv	a5,a0
    return -1;
    80005586:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005588:	0007cc63          	bltz	a5,800055a0 <sys_write+0x50>
  return filewrite(f, p, n);
    8000558c:	fe442603          	lw	a2,-28(s0)
    80005590:	fd843583          	ld	a1,-40(s0)
    80005594:	fe843503          	ld	a0,-24(s0)
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	488080e7          	jalr	1160(ra) # 80004a20 <filewrite>
}
    800055a0:	70a2                	ld	ra,40(sp)
    800055a2:	7402                	ld	s0,32(sp)
    800055a4:	6145                	add	sp,sp,48
    800055a6:	8082                	ret

00000000800055a8 <sys_close>:
{
    800055a8:	1101                	add	sp,sp,-32
    800055aa:	ec06                	sd	ra,24(sp)
    800055ac:	e822                	sd	s0,16(sp)
    800055ae:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055b0:	fe040613          	add	a2,s0,-32
    800055b4:	fec40593          	add	a1,s0,-20
    800055b8:	4501                	li	a0,0
    800055ba:	00000097          	auipc	ra,0x0
    800055be:	c86080e7          	jalr	-890(ra) # 80005240 <argfd>
    return -1;
    800055c2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055c4:	02054463          	bltz	a0,800055ec <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055c8:	ffffc097          	auipc	ra,0xffffc
    800055cc:	3ee080e7          	jalr	1006(ra) # 800019b6 <myproc>
    800055d0:	fec42783          	lw	a5,-20(s0)
    800055d4:	07e9                	add	a5,a5,26
    800055d6:	078e                	sll	a5,a5,0x3
    800055d8:	953e                	add	a0,a0,a5
    800055da:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055de:	fe043503          	ld	a0,-32(s0)
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	242080e7          	jalr	578(ra) # 80004824 <fileclose>
  return 0;
    800055ea:	4781                	li	a5,0
}
    800055ec:	853e                	mv	a0,a5
    800055ee:	60e2                	ld	ra,24(sp)
    800055f0:	6442                	ld	s0,16(sp)
    800055f2:	6105                	add	sp,sp,32
    800055f4:	8082                	ret

00000000800055f6 <sys_fstat>:
{
    800055f6:	1101                	add	sp,sp,-32
    800055f8:	ec06                	sd	ra,24(sp)
    800055fa:	e822                	sd	s0,16(sp)
    800055fc:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800055fe:	fe040593          	add	a1,s0,-32
    80005602:	4505                	li	a0,1
    80005604:	ffffd097          	auipc	ra,0xffffd
    80005608:	7d8080e7          	jalr	2008(ra) # 80002ddc <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000560c:	fe840613          	add	a2,s0,-24
    80005610:	4581                	li	a1,0
    80005612:	4501                	li	a0,0
    80005614:	00000097          	auipc	ra,0x0
    80005618:	c2c080e7          	jalr	-980(ra) # 80005240 <argfd>
    8000561c:	87aa                	mv	a5,a0
    return -1;
    8000561e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005620:	0007ca63          	bltz	a5,80005634 <sys_fstat+0x3e>
  return filestat(f, st);
    80005624:	fe043583          	ld	a1,-32(s0)
    80005628:	fe843503          	ld	a0,-24(s0)
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	2c0080e7          	jalr	704(ra) # 800048ec <filestat>
}
    80005634:	60e2                	ld	ra,24(sp)
    80005636:	6442                	ld	s0,16(sp)
    80005638:	6105                	add	sp,sp,32
    8000563a:	8082                	ret

000000008000563c <sys_link>:
{
    8000563c:	7169                	add	sp,sp,-304
    8000563e:	f606                	sd	ra,296(sp)
    80005640:	f222                	sd	s0,288(sp)
    80005642:	ee26                	sd	s1,280(sp)
    80005644:	ea4a                	sd	s2,272(sp)
    80005646:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005648:	08000613          	li	a2,128
    8000564c:	ed040593          	add	a1,s0,-304
    80005650:	4501                	li	a0,0
    80005652:	ffffd097          	auipc	ra,0xffffd
    80005656:	7aa080e7          	jalr	1962(ra) # 80002dfc <argstr>
    return -1;
    8000565a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000565c:	10054e63          	bltz	a0,80005778 <sys_link+0x13c>
    80005660:	08000613          	li	a2,128
    80005664:	f5040593          	add	a1,s0,-176
    80005668:	4505                	li	a0,1
    8000566a:	ffffd097          	auipc	ra,0xffffd
    8000566e:	792080e7          	jalr	1938(ra) # 80002dfc <argstr>
    return -1;
    80005672:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005674:	10054263          	bltz	a0,80005778 <sys_link+0x13c>
  begin_op();
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	ce8080e7          	jalr	-792(ra) # 80004360 <begin_op>
  if((ip = namei(old)) == 0){
    80005680:	ed040513          	add	a0,s0,-304
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	adc080e7          	jalr	-1316(ra) # 80004160 <namei>
    8000568c:	84aa                	mv	s1,a0
    8000568e:	c551                	beqz	a0,8000571a <sys_link+0xde>
  ilock(ip);
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	32a080e7          	jalr	810(ra) # 800039ba <ilock>
  if(ip->type == T_DIR){
    80005698:	04449703          	lh	a4,68(s1)
    8000569c:	4785                	li	a5,1
    8000569e:	08f70463          	beq	a4,a5,80005726 <sys_link+0xea>
  ip->nlink++;
    800056a2:	04a4d783          	lhu	a5,74(s1)
    800056a6:	2785                	addw	a5,a5,1
    800056a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ac:	8526                	mv	a0,s1
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	240080e7          	jalr	576(ra) # 800038ee <iupdate>
  iunlock(ip);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	3c4080e7          	jalr	964(ra) # 80003a7c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056c0:	fd040593          	add	a1,s0,-48
    800056c4:	f5040513          	add	a0,s0,-176
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	ab6080e7          	jalr	-1354(ra) # 8000417e <nameiparent>
    800056d0:	892a                	mv	s2,a0
    800056d2:	c935                	beqz	a0,80005746 <sys_link+0x10a>
  ilock(dp);
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	2e6080e7          	jalr	742(ra) # 800039ba <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056dc:	00092703          	lw	a4,0(s2)
    800056e0:	409c                	lw	a5,0(s1)
    800056e2:	04f71d63          	bne	a4,a5,8000573c <sys_link+0x100>
    800056e6:	40d0                	lw	a2,4(s1)
    800056e8:	fd040593          	add	a1,s0,-48
    800056ec:	854a                	mv	a0,s2
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	9c0080e7          	jalr	-1600(ra) # 800040ae <dirlink>
    800056f6:	04054363          	bltz	a0,8000573c <sys_link+0x100>
  iunlockput(dp);
    800056fa:	854a                	mv	a0,s2
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	520080e7          	jalr	1312(ra) # 80003c1c <iunlockput>
  iput(ip);
    80005704:	8526                	mv	a0,s1
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	46e080e7          	jalr	1134(ra) # 80003b74 <iput>
  end_op();
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	ccc080e7          	jalr	-820(ra) # 800043da <end_op>
  return 0;
    80005716:	4781                	li	a5,0
    80005718:	a085                	j	80005778 <sys_link+0x13c>
    end_op();
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	cc0080e7          	jalr	-832(ra) # 800043da <end_op>
    return -1;
    80005722:	57fd                	li	a5,-1
    80005724:	a891                	j	80005778 <sys_link+0x13c>
    iunlockput(ip);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	4f4080e7          	jalr	1268(ra) # 80003c1c <iunlockput>
    end_op();
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	caa080e7          	jalr	-854(ra) # 800043da <end_op>
    return -1;
    80005738:	57fd                	li	a5,-1
    8000573a:	a83d                	j	80005778 <sys_link+0x13c>
    iunlockput(dp);
    8000573c:	854a                	mv	a0,s2
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	4de080e7          	jalr	1246(ra) # 80003c1c <iunlockput>
  ilock(ip);
    80005746:	8526                	mv	a0,s1
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	272080e7          	jalr	626(ra) # 800039ba <ilock>
  ip->nlink--;
    80005750:	04a4d783          	lhu	a5,74(s1)
    80005754:	37fd                	addw	a5,a5,-1
    80005756:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000575a:	8526                	mv	a0,s1
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	192080e7          	jalr	402(ra) # 800038ee <iupdate>
  iunlockput(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	4b6080e7          	jalr	1206(ra) # 80003c1c <iunlockput>
  end_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	c6c080e7          	jalr	-916(ra) # 800043da <end_op>
  return -1;
    80005776:	57fd                	li	a5,-1
}
    80005778:	853e                	mv	a0,a5
    8000577a:	70b2                	ld	ra,296(sp)
    8000577c:	7412                	ld	s0,288(sp)
    8000577e:	64f2                	ld	s1,280(sp)
    80005780:	6952                	ld	s2,272(sp)
    80005782:	6155                	add	sp,sp,304
    80005784:	8082                	ret

0000000080005786 <sys_unlink>:
{
    80005786:	7151                	add	sp,sp,-240
    80005788:	f586                	sd	ra,232(sp)
    8000578a:	f1a2                	sd	s0,224(sp)
    8000578c:	eda6                	sd	s1,216(sp)
    8000578e:	e9ca                	sd	s2,208(sp)
    80005790:	e5ce                	sd	s3,200(sp)
    80005792:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005794:	08000613          	li	a2,128
    80005798:	f3040593          	add	a1,s0,-208
    8000579c:	4501                	li	a0,0
    8000579e:	ffffd097          	auipc	ra,0xffffd
    800057a2:	65e080e7          	jalr	1630(ra) # 80002dfc <argstr>
    800057a6:	18054163          	bltz	a0,80005928 <sys_unlink+0x1a2>
  begin_op();
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	bb6080e7          	jalr	-1098(ra) # 80004360 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057b2:	fb040593          	add	a1,s0,-80
    800057b6:	f3040513          	add	a0,s0,-208
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	9c4080e7          	jalr	-1596(ra) # 8000417e <nameiparent>
    800057c2:	84aa                	mv	s1,a0
    800057c4:	c979                	beqz	a0,8000589a <sys_unlink+0x114>
  ilock(dp);
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	1f4080e7          	jalr	500(ra) # 800039ba <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057ce:	00003597          	auipc	a1,0x3
    800057d2:	eea58593          	add	a1,a1,-278 # 800086b8 <syscalls+0x2b0>
    800057d6:	fb040513          	add	a0,s0,-80
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	6aa080e7          	jalr	1706(ra) # 80003e84 <namecmp>
    800057e2:	14050a63          	beqz	a0,80005936 <sys_unlink+0x1b0>
    800057e6:	00003597          	auipc	a1,0x3
    800057ea:	eda58593          	add	a1,a1,-294 # 800086c0 <syscalls+0x2b8>
    800057ee:	fb040513          	add	a0,s0,-80
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	692080e7          	jalr	1682(ra) # 80003e84 <namecmp>
    800057fa:	12050e63          	beqz	a0,80005936 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057fe:	f2c40613          	add	a2,s0,-212
    80005802:	fb040593          	add	a1,s0,-80
    80005806:	8526                	mv	a0,s1
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	696080e7          	jalr	1686(ra) # 80003e9e <dirlookup>
    80005810:	892a                	mv	s2,a0
    80005812:	12050263          	beqz	a0,80005936 <sys_unlink+0x1b0>
  ilock(ip);
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	1a4080e7          	jalr	420(ra) # 800039ba <ilock>
  if(ip->nlink < 1)
    8000581e:	04a91783          	lh	a5,74(s2)
    80005822:	08f05263          	blez	a5,800058a6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005826:	04491703          	lh	a4,68(s2)
    8000582a:	4785                	li	a5,1
    8000582c:	08f70563          	beq	a4,a5,800058b6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005830:	4641                	li	a2,16
    80005832:	4581                	li	a1,0
    80005834:	fc040513          	add	a0,s0,-64
    80005838:	ffffb097          	auipc	ra,0xffffb
    8000583c:	496080e7          	jalr	1174(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005840:	4741                	li	a4,16
    80005842:	f2c42683          	lw	a3,-212(s0)
    80005846:	fc040613          	add	a2,s0,-64
    8000584a:	4581                	li	a1,0
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	518080e7          	jalr	1304(ra) # 80003d66 <writei>
    80005856:	47c1                	li	a5,16
    80005858:	0af51563          	bne	a0,a5,80005902 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000585c:	04491703          	lh	a4,68(s2)
    80005860:	4785                	li	a5,1
    80005862:	0af70863          	beq	a4,a5,80005912 <sys_unlink+0x18c>
  iunlockput(dp);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	3b4080e7          	jalr	948(ra) # 80003c1c <iunlockput>
  ip->nlink--;
    80005870:	04a95783          	lhu	a5,74(s2)
    80005874:	37fd                	addw	a5,a5,-1
    80005876:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000587a:	854a                	mv	a0,s2
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	072080e7          	jalr	114(ra) # 800038ee <iupdate>
  iunlockput(ip);
    80005884:	854a                	mv	a0,s2
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	396080e7          	jalr	918(ra) # 80003c1c <iunlockput>
  end_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	b4c080e7          	jalr	-1204(ra) # 800043da <end_op>
  return 0;
    80005896:	4501                	li	a0,0
    80005898:	a84d                	j	8000594a <sys_unlink+0x1c4>
    end_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	b40080e7          	jalr	-1216(ra) # 800043da <end_op>
    return -1;
    800058a2:	557d                	li	a0,-1
    800058a4:	a05d                	j	8000594a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058a6:	00003517          	auipc	a0,0x3
    800058aa:	e2250513          	add	a0,a0,-478 # 800086c8 <syscalls+0x2c0>
    800058ae:	ffffb097          	auipc	ra,0xffffb
    800058b2:	c8e080e7          	jalr	-882(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058b6:	04c92703          	lw	a4,76(s2)
    800058ba:	02000793          	li	a5,32
    800058be:	f6e7f9e3          	bgeu	a5,a4,80005830 <sys_unlink+0xaa>
    800058c2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058c6:	4741                	li	a4,16
    800058c8:	86ce                	mv	a3,s3
    800058ca:	f1840613          	add	a2,s0,-232
    800058ce:	4581                	li	a1,0
    800058d0:	854a                	mv	a0,s2
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	39c080e7          	jalr	924(ra) # 80003c6e <readi>
    800058da:	47c1                	li	a5,16
    800058dc:	00f51b63          	bne	a0,a5,800058f2 <sys_unlink+0x16c>
    if(de.inum != 0)
    800058e0:	f1845783          	lhu	a5,-232(s0)
    800058e4:	e7a1                	bnez	a5,8000592c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058e6:	29c1                	addw	s3,s3,16
    800058e8:	04c92783          	lw	a5,76(s2)
    800058ec:	fcf9ede3          	bltu	s3,a5,800058c6 <sys_unlink+0x140>
    800058f0:	b781                	j	80005830 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058f2:	00003517          	auipc	a0,0x3
    800058f6:	dee50513          	add	a0,a0,-530 # 800086e0 <syscalls+0x2d8>
    800058fa:	ffffb097          	auipc	ra,0xffffb
    800058fe:	c42080e7          	jalr	-958(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005902:	00003517          	auipc	a0,0x3
    80005906:	df650513          	add	a0,a0,-522 # 800086f8 <syscalls+0x2f0>
    8000590a:	ffffb097          	auipc	ra,0xffffb
    8000590e:	c32080e7          	jalr	-974(ra) # 8000053c <panic>
    dp->nlink--;
    80005912:	04a4d783          	lhu	a5,74(s1)
    80005916:	37fd                	addw	a5,a5,-1
    80005918:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000591c:	8526                	mv	a0,s1
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	fd0080e7          	jalr	-48(ra) # 800038ee <iupdate>
    80005926:	b781                	j	80005866 <sys_unlink+0xe0>
    return -1;
    80005928:	557d                	li	a0,-1
    8000592a:	a005                	j	8000594a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000592c:	854a                	mv	a0,s2
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	2ee080e7          	jalr	750(ra) # 80003c1c <iunlockput>
  iunlockput(dp);
    80005936:	8526                	mv	a0,s1
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	2e4080e7          	jalr	740(ra) # 80003c1c <iunlockput>
  end_op();
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	a9a080e7          	jalr	-1382(ra) # 800043da <end_op>
  return -1;
    80005948:	557d                	li	a0,-1
}
    8000594a:	70ae                	ld	ra,232(sp)
    8000594c:	740e                	ld	s0,224(sp)
    8000594e:	64ee                	ld	s1,216(sp)
    80005950:	694e                	ld	s2,208(sp)
    80005952:	69ae                	ld	s3,200(sp)
    80005954:	616d                	add	sp,sp,240
    80005956:	8082                	ret

0000000080005958 <sys_open>:

uint64
sys_open(void)
{
    80005958:	7131                	add	sp,sp,-192
    8000595a:	fd06                	sd	ra,184(sp)
    8000595c:	f922                	sd	s0,176(sp)
    8000595e:	f526                	sd	s1,168(sp)
    80005960:	f14a                	sd	s2,160(sp)
    80005962:	ed4e                	sd	s3,152(sp)
    80005964:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005966:	f4c40593          	add	a1,s0,-180
    8000596a:	4505                	li	a0,1
    8000596c:	ffffd097          	auipc	ra,0xffffd
    80005970:	450080e7          	jalr	1104(ra) # 80002dbc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005974:	08000613          	li	a2,128
    80005978:	f5040593          	add	a1,s0,-176
    8000597c:	4501                	li	a0,0
    8000597e:	ffffd097          	auipc	ra,0xffffd
    80005982:	47e080e7          	jalr	1150(ra) # 80002dfc <argstr>
    80005986:	87aa                	mv	a5,a0
    return -1;
    80005988:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000598a:	0a07c863          	bltz	a5,80005a3a <sys_open+0xe2>

  begin_op();
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	9d2080e7          	jalr	-1582(ra) # 80004360 <begin_op>

  if(omode & O_CREATE){
    80005996:	f4c42783          	lw	a5,-180(s0)
    8000599a:	2007f793          	and	a5,a5,512
    8000599e:	cbdd                	beqz	a5,80005a54 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    800059a0:	4681                	li	a3,0
    800059a2:	4601                	li	a2,0
    800059a4:	4589                	li	a1,2
    800059a6:	f5040513          	add	a0,s0,-176
    800059aa:	00000097          	auipc	ra,0x0
    800059ae:	938080e7          	jalr	-1736(ra) # 800052e2 <create>
    800059b2:	84aa                	mv	s1,a0
    if(ip == 0){
    800059b4:	c951                	beqz	a0,80005a48 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059b6:	04449703          	lh	a4,68(s1)
    800059ba:	478d                	li	a5,3
    800059bc:	00f71763          	bne	a4,a5,800059ca <sys_open+0x72>
    800059c0:	0464d703          	lhu	a4,70(s1)
    800059c4:	47a5                	li	a5,9
    800059c6:	0ce7ec63          	bltu	a5,a4,80005a9e <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059ca:	fffff097          	auipc	ra,0xfffff
    800059ce:	d9e080e7          	jalr	-610(ra) # 80004768 <filealloc>
    800059d2:	892a                	mv	s2,a0
    800059d4:	c56d                	beqz	a0,80005abe <sys_open+0x166>
    800059d6:	00000097          	auipc	ra,0x0
    800059da:	8ca080e7          	jalr	-1846(ra) # 800052a0 <fdalloc>
    800059de:	89aa                	mv	s3,a0
    800059e0:	0c054a63          	bltz	a0,80005ab4 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059e4:	04449703          	lh	a4,68(s1)
    800059e8:	478d                	li	a5,3
    800059ea:	0ef70563          	beq	a4,a5,80005ad4 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059ee:	4789                	li	a5,2
    800059f0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059f4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059f8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059fc:	f4c42783          	lw	a5,-180(s0)
    80005a00:	0017c713          	xor	a4,a5,1
    80005a04:	8b05                	and	a4,a4,1
    80005a06:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a0a:	0037f713          	and	a4,a5,3
    80005a0e:	00e03733          	snez	a4,a4
    80005a12:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a16:	4007f793          	and	a5,a5,1024
    80005a1a:	c791                	beqz	a5,80005a26 <sys_open+0xce>
    80005a1c:	04449703          	lh	a4,68(s1)
    80005a20:	4789                	li	a5,2
    80005a22:	0cf70063          	beq	a4,a5,80005ae2 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005a26:	8526                	mv	a0,s1
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	054080e7          	jalr	84(ra) # 80003a7c <iunlock>
  end_op();
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	9aa080e7          	jalr	-1622(ra) # 800043da <end_op>

  return fd;
    80005a38:	854e                	mv	a0,s3
}
    80005a3a:	70ea                	ld	ra,184(sp)
    80005a3c:	744a                	ld	s0,176(sp)
    80005a3e:	74aa                	ld	s1,168(sp)
    80005a40:	790a                	ld	s2,160(sp)
    80005a42:	69ea                	ld	s3,152(sp)
    80005a44:	6129                	add	sp,sp,192
    80005a46:	8082                	ret
      end_op();
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	992080e7          	jalr	-1646(ra) # 800043da <end_op>
      return -1;
    80005a50:	557d                	li	a0,-1
    80005a52:	b7e5                	j	80005a3a <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005a54:	f5040513          	add	a0,s0,-176
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	708080e7          	jalr	1800(ra) # 80004160 <namei>
    80005a60:	84aa                	mv	s1,a0
    80005a62:	c905                	beqz	a0,80005a92 <sys_open+0x13a>
    ilock(ip);
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	f56080e7          	jalr	-170(ra) # 800039ba <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a6c:	04449703          	lh	a4,68(s1)
    80005a70:	4785                	li	a5,1
    80005a72:	f4f712e3          	bne	a4,a5,800059b6 <sys_open+0x5e>
    80005a76:	f4c42783          	lw	a5,-180(s0)
    80005a7a:	dba1                	beqz	a5,800059ca <sys_open+0x72>
      iunlockput(ip);
    80005a7c:	8526                	mv	a0,s1
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	19e080e7          	jalr	414(ra) # 80003c1c <iunlockput>
      end_op();
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	954080e7          	jalr	-1708(ra) # 800043da <end_op>
      return -1;
    80005a8e:	557d                	li	a0,-1
    80005a90:	b76d                	j	80005a3a <sys_open+0xe2>
      end_op();
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	948080e7          	jalr	-1720(ra) # 800043da <end_op>
      return -1;
    80005a9a:	557d                	li	a0,-1
    80005a9c:	bf79                	j	80005a3a <sys_open+0xe2>
    iunlockput(ip);
    80005a9e:	8526                	mv	a0,s1
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	17c080e7          	jalr	380(ra) # 80003c1c <iunlockput>
    end_op();
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	932080e7          	jalr	-1742(ra) # 800043da <end_op>
    return -1;
    80005ab0:	557d                	li	a0,-1
    80005ab2:	b761                	j	80005a3a <sys_open+0xe2>
      fileclose(f);
    80005ab4:	854a                	mv	a0,s2
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	d6e080e7          	jalr	-658(ra) # 80004824 <fileclose>
    iunlockput(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	15c080e7          	jalr	348(ra) # 80003c1c <iunlockput>
    end_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	912080e7          	jalr	-1774(ra) # 800043da <end_op>
    return -1;
    80005ad0:	557d                	li	a0,-1
    80005ad2:	b7a5                	j	80005a3a <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005ad4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005ad8:	04649783          	lh	a5,70(s1)
    80005adc:	02f91223          	sh	a5,36(s2)
    80005ae0:	bf21                	j	800059f8 <sys_open+0xa0>
    itrunc(ip);
    80005ae2:	8526                	mv	a0,s1
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	fe4080e7          	jalr	-28(ra) # 80003ac8 <itrunc>
    80005aec:	bf2d                	j	80005a26 <sys_open+0xce>

0000000080005aee <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005aee:	7175                	add	sp,sp,-144
    80005af0:	e506                	sd	ra,136(sp)
    80005af2:	e122                	sd	s0,128(sp)
    80005af4:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	86a080e7          	jalr	-1942(ra) # 80004360 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005afe:	08000613          	li	a2,128
    80005b02:	f7040593          	add	a1,s0,-144
    80005b06:	4501                	li	a0,0
    80005b08:	ffffd097          	auipc	ra,0xffffd
    80005b0c:	2f4080e7          	jalr	756(ra) # 80002dfc <argstr>
    80005b10:	02054963          	bltz	a0,80005b42 <sys_mkdir+0x54>
    80005b14:	4681                	li	a3,0
    80005b16:	4601                	li	a2,0
    80005b18:	4585                	li	a1,1
    80005b1a:	f7040513          	add	a0,s0,-144
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	7c4080e7          	jalr	1988(ra) # 800052e2 <create>
    80005b26:	cd11                	beqz	a0,80005b42 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	0f4080e7          	jalr	244(ra) # 80003c1c <iunlockput>
  end_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	8aa080e7          	jalr	-1878(ra) # 800043da <end_op>
  return 0;
    80005b38:	4501                	li	a0,0
}
    80005b3a:	60aa                	ld	ra,136(sp)
    80005b3c:	640a                	ld	s0,128(sp)
    80005b3e:	6149                	add	sp,sp,144
    80005b40:	8082                	ret
    end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	898080e7          	jalr	-1896(ra) # 800043da <end_op>
    return -1;
    80005b4a:	557d                	li	a0,-1
    80005b4c:	b7fd                	j	80005b3a <sys_mkdir+0x4c>

0000000080005b4e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b4e:	7135                	add	sp,sp,-160
    80005b50:	ed06                	sd	ra,152(sp)
    80005b52:	e922                	sd	s0,144(sp)
    80005b54:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	80a080e7          	jalr	-2038(ra) # 80004360 <begin_op>
  argint(1, &major);
    80005b5e:	f6c40593          	add	a1,s0,-148
    80005b62:	4505                	li	a0,1
    80005b64:	ffffd097          	auipc	ra,0xffffd
    80005b68:	258080e7          	jalr	600(ra) # 80002dbc <argint>
  argint(2, &minor);
    80005b6c:	f6840593          	add	a1,s0,-152
    80005b70:	4509                	li	a0,2
    80005b72:	ffffd097          	auipc	ra,0xffffd
    80005b76:	24a080e7          	jalr	586(ra) # 80002dbc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b7a:	08000613          	li	a2,128
    80005b7e:	f7040593          	add	a1,s0,-144
    80005b82:	4501                	li	a0,0
    80005b84:	ffffd097          	auipc	ra,0xffffd
    80005b88:	278080e7          	jalr	632(ra) # 80002dfc <argstr>
    80005b8c:	02054b63          	bltz	a0,80005bc2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b90:	f6841683          	lh	a3,-152(s0)
    80005b94:	f6c41603          	lh	a2,-148(s0)
    80005b98:	458d                	li	a1,3
    80005b9a:	f7040513          	add	a0,s0,-144
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	744080e7          	jalr	1860(ra) # 800052e2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ba6:	cd11                	beqz	a0,80005bc2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ba8:	ffffe097          	auipc	ra,0xffffe
    80005bac:	074080e7          	jalr	116(ra) # 80003c1c <iunlockput>
  end_op();
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	82a080e7          	jalr	-2006(ra) # 800043da <end_op>
  return 0;
    80005bb8:	4501                	li	a0,0
}
    80005bba:	60ea                	ld	ra,152(sp)
    80005bbc:	644a                	ld	s0,144(sp)
    80005bbe:	610d                	add	sp,sp,160
    80005bc0:	8082                	ret
    end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	818080e7          	jalr	-2024(ra) # 800043da <end_op>
    return -1;
    80005bca:	557d                	li	a0,-1
    80005bcc:	b7fd                	j	80005bba <sys_mknod+0x6c>

0000000080005bce <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bce:	7135                	add	sp,sp,-160
    80005bd0:	ed06                	sd	ra,152(sp)
    80005bd2:	e922                	sd	s0,144(sp)
    80005bd4:	e526                	sd	s1,136(sp)
    80005bd6:	e14a                	sd	s2,128(sp)
    80005bd8:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bda:	ffffc097          	auipc	ra,0xffffc
    80005bde:	ddc080e7          	jalr	-548(ra) # 800019b6 <myproc>
    80005be2:	892a                	mv	s2,a0
  
  begin_op();
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	77c080e7          	jalr	1916(ra) # 80004360 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bec:	08000613          	li	a2,128
    80005bf0:	f6040593          	add	a1,s0,-160
    80005bf4:	4501                	li	a0,0
    80005bf6:	ffffd097          	auipc	ra,0xffffd
    80005bfa:	206080e7          	jalr	518(ra) # 80002dfc <argstr>
    80005bfe:	04054b63          	bltz	a0,80005c54 <sys_chdir+0x86>
    80005c02:	f6040513          	add	a0,s0,-160
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	55a080e7          	jalr	1370(ra) # 80004160 <namei>
    80005c0e:	84aa                	mv	s1,a0
    80005c10:	c131                	beqz	a0,80005c54 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c12:	ffffe097          	auipc	ra,0xffffe
    80005c16:	da8080e7          	jalr	-600(ra) # 800039ba <ilock>
  if(ip->type != T_DIR){
    80005c1a:	04449703          	lh	a4,68(s1)
    80005c1e:	4785                	li	a5,1
    80005c20:	04f71063          	bne	a4,a5,80005c60 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c24:	8526                	mv	a0,s1
    80005c26:	ffffe097          	auipc	ra,0xffffe
    80005c2a:	e56080e7          	jalr	-426(ra) # 80003a7c <iunlock>
  iput(p->cwd);
    80005c2e:	15093503          	ld	a0,336(s2)
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	f42080e7          	jalr	-190(ra) # 80003b74 <iput>
  end_op();
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	7a0080e7          	jalr	1952(ra) # 800043da <end_op>
  p->cwd = ip;
    80005c42:	14993823          	sd	s1,336(s2)
  return 0;
    80005c46:	4501                	li	a0,0
}
    80005c48:	60ea                	ld	ra,152(sp)
    80005c4a:	644a                	ld	s0,144(sp)
    80005c4c:	64aa                	ld	s1,136(sp)
    80005c4e:	690a                	ld	s2,128(sp)
    80005c50:	610d                	add	sp,sp,160
    80005c52:	8082                	ret
    end_op();
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	786080e7          	jalr	1926(ra) # 800043da <end_op>
    return -1;
    80005c5c:	557d                	li	a0,-1
    80005c5e:	b7ed                	j	80005c48 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c60:	8526                	mv	a0,s1
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	fba080e7          	jalr	-70(ra) # 80003c1c <iunlockput>
    end_op();
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	770080e7          	jalr	1904(ra) # 800043da <end_op>
    return -1;
    80005c72:	557d                	li	a0,-1
    80005c74:	bfd1                	j	80005c48 <sys_chdir+0x7a>

0000000080005c76 <sys_exec>:

uint64
sys_exec(void)
{
    80005c76:	7121                	add	sp,sp,-448
    80005c78:	ff06                	sd	ra,440(sp)
    80005c7a:	fb22                	sd	s0,432(sp)
    80005c7c:	f726                	sd	s1,424(sp)
    80005c7e:	f34a                	sd	s2,416(sp)
    80005c80:	ef4e                	sd	s3,408(sp)
    80005c82:	eb52                	sd	s4,400(sp)
    80005c84:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c86:	e4840593          	add	a1,s0,-440
    80005c8a:	4505                	li	a0,1
    80005c8c:	ffffd097          	auipc	ra,0xffffd
    80005c90:	150080e7          	jalr	336(ra) # 80002ddc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c94:	08000613          	li	a2,128
    80005c98:	f5040593          	add	a1,s0,-176
    80005c9c:	4501                	li	a0,0
    80005c9e:	ffffd097          	auipc	ra,0xffffd
    80005ca2:	15e080e7          	jalr	350(ra) # 80002dfc <argstr>
    80005ca6:	87aa                	mv	a5,a0
    return -1;
    80005ca8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005caa:	0c07c263          	bltz	a5,80005d6e <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005cae:	10000613          	li	a2,256
    80005cb2:	4581                	li	a1,0
    80005cb4:	e5040513          	add	a0,s0,-432
    80005cb8:	ffffb097          	auipc	ra,0xffffb
    80005cbc:	016080e7          	jalr	22(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cc0:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005cc4:	89a6                	mv	s3,s1
    80005cc6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cc8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ccc:	00391513          	sll	a0,s2,0x3
    80005cd0:	e4040593          	add	a1,s0,-448
    80005cd4:	e4843783          	ld	a5,-440(s0)
    80005cd8:	953e                	add	a0,a0,a5
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	044080e7          	jalr	68(ra) # 80002d1e <fetchaddr>
    80005ce2:	02054a63          	bltz	a0,80005d16 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005ce6:	e4043783          	ld	a5,-448(s0)
    80005cea:	c3b9                	beqz	a5,80005d30 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cec:	ffffb097          	auipc	ra,0xffffb
    80005cf0:	df6080e7          	jalr	-522(ra) # 80000ae2 <kalloc>
    80005cf4:	85aa                	mv	a1,a0
    80005cf6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cfa:	cd11                	beqz	a0,80005d16 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cfc:	6605                	lui	a2,0x1
    80005cfe:	e4043503          	ld	a0,-448(s0)
    80005d02:	ffffd097          	auipc	ra,0xffffd
    80005d06:	06e080e7          	jalr	110(ra) # 80002d70 <fetchstr>
    80005d0a:	00054663          	bltz	a0,80005d16 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005d0e:	0905                	add	s2,s2,1
    80005d10:	09a1                	add	s3,s3,8
    80005d12:	fb491de3          	bne	s2,s4,80005ccc <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d16:	f5040913          	add	s2,s0,-176
    80005d1a:	6088                	ld	a0,0(s1)
    80005d1c:	c921                	beqz	a0,80005d6c <sys_exec+0xf6>
    kfree(argv[i]);
    80005d1e:	ffffb097          	auipc	ra,0xffffb
    80005d22:	cc6080e7          	jalr	-826(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d26:	04a1                	add	s1,s1,8
    80005d28:	ff2499e3          	bne	s1,s2,80005d1a <sys_exec+0xa4>
  return -1;
    80005d2c:	557d                	li	a0,-1
    80005d2e:	a081                	j	80005d6e <sys_exec+0xf8>
      argv[i] = 0;
    80005d30:	0009079b          	sext.w	a5,s2
    80005d34:	078e                	sll	a5,a5,0x3
    80005d36:	fd078793          	add	a5,a5,-48
    80005d3a:	97a2                	add	a5,a5,s0
    80005d3c:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005d40:	e5040593          	add	a1,s0,-432
    80005d44:	f5040513          	add	a0,s0,-176
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	152080e7          	jalr	338(ra) # 80004e9a <exec>
    80005d50:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d52:	f5040993          	add	s3,s0,-176
    80005d56:	6088                	ld	a0,0(s1)
    80005d58:	c901                	beqz	a0,80005d68 <sys_exec+0xf2>
    kfree(argv[i]);
    80005d5a:	ffffb097          	auipc	ra,0xffffb
    80005d5e:	c8a080e7          	jalr	-886(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d62:	04a1                	add	s1,s1,8
    80005d64:	ff3499e3          	bne	s1,s3,80005d56 <sys_exec+0xe0>
  return ret;
    80005d68:	854a                	mv	a0,s2
    80005d6a:	a011                	j	80005d6e <sys_exec+0xf8>
  return -1;
    80005d6c:	557d                	li	a0,-1
}
    80005d6e:	70fa                	ld	ra,440(sp)
    80005d70:	745a                	ld	s0,432(sp)
    80005d72:	74ba                	ld	s1,424(sp)
    80005d74:	791a                	ld	s2,416(sp)
    80005d76:	69fa                	ld	s3,408(sp)
    80005d78:	6a5a                	ld	s4,400(sp)
    80005d7a:	6139                	add	sp,sp,448
    80005d7c:	8082                	ret

0000000080005d7e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d7e:	7139                	add	sp,sp,-64
    80005d80:	fc06                	sd	ra,56(sp)
    80005d82:	f822                	sd	s0,48(sp)
    80005d84:	f426                	sd	s1,40(sp)
    80005d86:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d88:	ffffc097          	auipc	ra,0xffffc
    80005d8c:	c2e080e7          	jalr	-978(ra) # 800019b6 <myproc>
    80005d90:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d92:	fd840593          	add	a1,s0,-40
    80005d96:	4501                	li	a0,0
    80005d98:	ffffd097          	auipc	ra,0xffffd
    80005d9c:	044080e7          	jalr	68(ra) # 80002ddc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005da0:	fc840593          	add	a1,s0,-56
    80005da4:	fd040513          	add	a0,s0,-48
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	da8080e7          	jalr	-600(ra) # 80004b50 <pipealloc>
    return -1;
    80005db0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005db2:	0c054463          	bltz	a0,80005e7a <sys_pipe+0xfc>
  fd0 = -1;
    80005db6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dba:	fd043503          	ld	a0,-48(s0)
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	4e2080e7          	jalr	1250(ra) # 800052a0 <fdalloc>
    80005dc6:	fca42223          	sw	a0,-60(s0)
    80005dca:	08054b63          	bltz	a0,80005e60 <sys_pipe+0xe2>
    80005dce:	fc843503          	ld	a0,-56(s0)
    80005dd2:	fffff097          	auipc	ra,0xfffff
    80005dd6:	4ce080e7          	jalr	1230(ra) # 800052a0 <fdalloc>
    80005dda:	fca42023          	sw	a0,-64(s0)
    80005dde:	06054863          	bltz	a0,80005e4e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005de2:	4691                	li	a3,4
    80005de4:	fc440613          	add	a2,s0,-60
    80005de8:	fd843583          	ld	a1,-40(s0)
    80005dec:	68a8                	ld	a0,80(s1)
    80005dee:	ffffc097          	auipc	ra,0xffffc
    80005df2:	888080e7          	jalr	-1912(ra) # 80001676 <copyout>
    80005df6:	02054063          	bltz	a0,80005e16 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dfa:	4691                	li	a3,4
    80005dfc:	fc040613          	add	a2,s0,-64
    80005e00:	fd843583          	ld	a1,-40(s0)
    80005e04:	0591                	add	a1,a1,4
    80005e06:	68a8                	ld	a0,80(s1)
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	86e080e7          	jalr	-1938(ra) # 80001676 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e10:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e12:	06055463          	bgez	a0,80005e7a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e16:	fc442783          	lw	a5,-60(s0)
    80005e1a:	07e9                	add	a5,a5,26
    80005e1c:	078e                	sll	a5,a5,0x3
    80005e1e:	97a6                	add	a5,a5,s1
    80005e20:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e24:	fc042783          	lw	a5,-64(s0)
    80005e28:	07e9                	add	a5,a5,26
    80005e2a:	078e                	sll	a5,a5,0x3
    80005e2c:	94be                	add	s1,s1,a5
    80005e2e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e32:	fd043503          	ld	a0,-48(s0)
    80005e36:	fffff097          	auipc	ra,0xfffff
    80005e3a:	9ee080e7          	jalr	-1554(ra) # 80004824 <fileclose>
    fileclose(wf);
    80005e3e:	fc843503          	ld	a0,-56(s0)
    80005e42:	fffff097          	auipc	ra,0xfffff
    80005e46:	9e2080e7          	jalr	-1566(ra) # 80004824 <fileclose>
    return -1;
    80005e4a:	57fd                	li	a5,-1
    80005e4c:	a03d                	j	80005e7a <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e4e:	fc442783          	lw	a5,-60(s0)
    80005e52:	0007c763          	bltz	a5,80005e60 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e56:	07e9                	add	a5,a5,26
    80005e58:	078e                	sll	a5,a5,0x3
    80005e5a:	97a6                	add	a5,a5,s1
    80005e5c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e60:	fd043503          	ld	a0,-48(s0)
    80005e64:	fffff097          	auipc	ra,0xfffff
    80005e68:	9c0080e7          	jalr	-1600(ra) # 80004824 <fileclose>
    fileclose(wf);
    80005e6c:	fc843503          	ld	a0,-56(s0)
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	9b4080e7          	jalr	-1612(ra) # 80004824 <fileclose>
    return -1;
    80005e78:	57fd                	li	a5,-1
}
    80005e7a:	853e                	mv	a0,a5
    80005e7c:	70e2                	ld	ra,56(sp)
    80005e7e:	7442                	ld	s0,48(sp)
    80005e80:	74a2                	ld	s1,40(sp)
    80005e82:	6121                	add	sp,sp,64
    80005e84:	8082                	ret
	...

0000000080005e90 <kernelvec>:
    80005e90:	7111                	add	sp,sp,-256
    80005e92:	e006                	sd	ra,0(sp)
    80005e94:	e40a                	sd	sp,8(sp)
    80005e96:	e80e                	sd	gp,16(sp)
    80005e98:	ec12                	sd	tp,24(sp)
    80005e9a:	f016                	sd	t0,32(sp)
    80005e9c:	f41a                	sd	t1,40(sp)
    80005e9e:	f81e                	sd	t2,48(sp)
    80005ea0:	fc22                	sd	s0,56(sp)
    80005ea2:	e0a6                	sd	s1,64(sp)
    80005ea4:	e4aa                	sd	a0,72(sp)
    80005ea6:	e8ae                	sd	a1,80(sp)
    80005ea8:	ecb2                	sd	a2,88(sp)
    80005eaa:	f0b6                	sd	a3,96(sp)
    80005eac:	f4ba                	sd	a4,104(sp)
    80005eae:	f8be                	sd	a5,112(sp)
    80005eb0:	fcc2                	sd	a6,120(sp)
    80005eb2:	e146                	sd	a7,128(sp)
    80005eb4:	e54a                	sd	s2,136(sp)
    80005eb6:	e94e                	sd	s3,144(sp)
    80005eb8:	ed52                	sd	s4,152(sp)
    80005eba:	f156                	sd	s5,160(sp)
    80005ebc:	f55a                	sd	s6,168(sp)
    80005ebe:	f95e                	sd	s7,176(sp)
    80005ec0:	fd62                	sd	s8,184(sp)
    80005ec2:	e1e6                	sd	s9,192(sp)
    80005ec4:	e5ea                	sd	s10,200(sp)
    80005ec6:	e9ee                	sd	s11,208(sp)
    80005ec8:	edf2                	sd	t3,216(sp)
    80005eca:	f1f6                	sd	t4,224(sp)
    80005ecc:	f5fa                	sd	t5,232(sp)
    80005ece:	f9fe                	sd	t6,240(sp)
    80005ed0:	cd7fc0ef          	jal	80002ba6 <kerneltrap>
    80005ed4:	6082                	ld	ra,0(sp)
    80005ed6:	6122                	ld	sp,8(sp)
    80005ed8:	61c2                	ld	gp,16(sp)
    80005eda:	7282                	ld	t0,32(sp)
    80005edc:	7322                	ld	t1,40(sp)
    80005ede:	73c2                	ld	t2,48(sp)
    80005ee0:	7462                	ld	s0,56(sp)
    80005ee2:	6486                	ld	s1,64(sp)
    80005ee4:	6526                	ld	a0,72(sp)
    80005ee6:	65c6                	ld	a1,80(sp)
    80005ee8:	6666                	ld	a2,88(sp)
    80005eea:	7686                	ld	a3,96(sp)
    80005eec:	7726                	ld	a4,104(sp)
    80005eee:	77c6                	ld	a5,112(sp)
    80005ef0:	7866                	ld	a6,120(sp)
    80005ef2:	688a                	ld	a7,128(sp)
    80005ef4:	692a                	ld	s2,136(sp)
    80005ef6:	69ca                	ld	s3,144(sp)
    80005ef8:	6a6a                	ld	s4,152(sp)
    80005efa:	7a8a                	ld	s5,160(sp)
    80005efc:	7b2a                	ld	s6,168(sp)
    80005efe:	7bca                	ld	s7,176(sp)
    80005f00:	7c6a                	ld	s8,184(sp)
    80005f02:	6c8e                	ld	s9,192(sp)
    80005f04:	6d2e                	ld	s10,200(sp)
    80005f06:	6dce                	ld	s11,208(sp)
    80005f08:	6e6e                	ld	t3,216(sp)
    80005f0a:	7e8e                	ld	t4,224(sp)
    80005f0c:	7f2e                	ld	t5,232(sp)
    80005f0e:	7fce                	ld	t6,240(sp)
    80005f10:	6111                	add	sp,sp,256
    80005f12:	10200073          	sret
    80005f16:	00000013          	nop
    80005f1a:	00000013          	nop
    80005f1e:	0001                	nop

0000000080005f20 <timervec>:
    80005f20:	34051573          	csrrw	a0,mscratch,a0
    80005f24:	e10c                	sd	a1,0(a0)
    80005f26:	e510                	sd	a2,8(a0)
    80005f28:	e914                	sd	a3,16(a0)
    80005f2a:	6d0c                	ld	a1,24(a0)
    80005f2c:	7110                	ld	a2,32(a0)
    80005f2e:	6194                	ld	a3,0(a1)
    80005f30:	96b2                	add	a3,a3,a2
    80005f32:	e194                	sd	a3,0(a1)
    80005f34:	4589                	li	a1,2
    80005f36:	14459073          	csrw	sip,a1
    80005f3a:	6914                	ld	a3,16(a0)
    80005f3c:	6510                	ld	a2,8(a0)
    80005f3e:	610c                	ld	a1,0(a0)
    80005f40:	34051573          	csrrw	a0,mscratch,a0
    80005f44:	30200073          	mret
	...

0000000080005f4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f4a:	1141                	add	sp,sp,-16
    80005f4c:	e422                	sd	s0,8(sp)
    80005f4e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f50:	0c0007b7          	lui	a5,0xc000
    80005f54:	4705                	li	a4,1
    80005f56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f58:	c3d8                	sw	a4,4(a5)
}
    80005f5a:	6422                	ld	s0,8(sp)
    80005f5c:	0141                	add	sp,sp,16
    80005f5e:	8082                	ret

0000000080005f60 <plicinithart>:

void
plicinithart(void)
{
    80005f60:	1141                	add	sp,sp,-16
    80005f62:	e406                	sd	ra,8(sp)
    80005f64:	e022                	sd	s0,0(sp)
    80005f66:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005f68:	ffffc097          	auipc	ra,0xffffc
    80005f6c:	a22080e7          	jalr	-1502(ra) # 8000198a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f70:	0085171b          	sllw	a4,a0,0x8
    80005f74:	0c0027b7          	lui	a5,0xc002
    80005f78:	97ba                	add	a5,a5,a4
    80005f7a:	40200713          	li	a4,1026
    80005f7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f82:	00d5151b          	sllw	a0,a0,0xd
    80005f86:	0c2017b7          	lui	a5,0xc201
    80005f8a:	97aa                	add	a5,a5,a0
    80005f8c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f90:	60a2                	ld	ra,8(sp)
    80005f92:	6402                	ld	s0,0(sp)
    80005f94:	0141                	add	sp,sp,16
    80005f96:	8082                	ret

0000000080005f98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f98:	1141                	add	sp,sp,-16
    80005f9a:	e406                	sd	ra,8(sp)
    80005f9c:	e022                	sd	s0,0(sp)
    80005f9e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005fa0:	ffffc097          	auipc	ra,0xffffc
    80005fa4:	9ea080e7          	jalr	-1558(ra) # 8000198a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fa8:	00d5151b          	sllw	a0,a0,0xd
    80005fac:	0c2017b7          	lui	a5,0xc201
    80005fb0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fb2:	43c8                	lw	a0,4(a5)
    80005fb4:	60a2                	ld	ra,8(sp)
    80005fb6:	6402                	ld	s0,0(sp)
    80005fb8:	0141                	add	sp,sp,16
    80005fba:	8082                	ret

0000000080005fbc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fbc:	1101                	add	sp,sp,-32
    80005fbe:	ec06                	sd	ra,24(sp)
    80005fc0:	e822                	sd	s0,16(sp)
    80005fc2:	e426                	sd	s1,8(sp)
    80005fc4:	1000                	add	s0,sp,32
    80005fc6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fc8:	ffffc097          	auipc	ra,0xffffc
    80005fcc:	9c2080e7          	jalr	-1598(ra) # 8000198a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fd0:	00d5151b          	sllw	a0,a0,0xd
    80005fd4:	0c2017b7          	lui	a5,0xc201
    80005fd8:	97aa                	add	a5,a5,a0
    80005fda:	c3c4                	sw	s1,4(a5)
}
    80005fdc:	60e2                	ld	ra,24(sp)
    80005fde:	6442                	ld	s0,16(sp)
    80005fe0:	64a2                	ld	s1,8(sp)
    80005fe2:	6105                	add	sp,sp,32
    80005fe4:	8082                	ret

0000000080005fe6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fe6:	1141                	add	sp,sp,-16
    80005fe8:	e406                	sd	ra,8(sp)
    80005fea:	e022                	sd	s0,0(sp)
    80005fec:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005fee:	479d                	li	a5,7
    80005ff0:	04a7cc63          	blt	a5,a0,80006048 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ff4:	0001c797          	auipc	a5,0x1c
    80005ff8:	20478793          	add	a5,a5,516 # 800221f8 <disk>
    80005ffc:	97aa                	add	a5,a5,a0
    80005ffe:	0187c783          	lbu	a5,24(a5)
    80006002:	ebb9                	bnez	a5,80006058 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006004:	00451693          	sll	a3,a0,0x4
    80006008:	0001c797          	auipc	a5,0x1c
    8000600c:	1f078793          	add	a5,a5,496 # 800221f8 <disk>
    80006010:	6398                	ld	a4,0(a5)
    80006012:	9736                	add	a4,a4,a3
    80006014:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006018:	6398                	ld	a4,0(a5)
    8000601a:	9736                	add	a4,a4,a3
    8000601c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006020:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006024:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006028:	97aa                	add	a5,a5,a0
    8000602a:	4705                	li	a4,1
    8000602c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006030:	0001c517          	auipc	a0,0x1c
    80006034:	1e050513          	add	a0,a0,480 # 80022210 <disk+0x18>
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	12a080e7          	jalr	298(ra) # 80002162 <wakeup>
}
    80006040:	60a2                	ld	ra,8(sp)
    80006042:	6402                	ld	s0,0(sp)
    80006044:	0141                	add	sp,sp,16
    80006046:	8082                	ret
    panic("free_desc 1");
    80006048:	00002517          	auipc	a0,0x2
    8000604c:	6c050513          	add	a0,a0,1728 # 80008708 <syscalls+0x300>
    80006050:	ffffa097          	auipc	ra,0xffffa
    80006054:	4ec080e7          	jalr	1260(ra) # 8000053c <panic>
    panic("free_desc 2");
    80006058:	00002517          	auipc	a0,0x2
    8000605c:	6c050513          	add	a0,a0,1728 # 80008718 <syscalls+0x310>
    80006060:	ffffa097          	auipc	ra,0xffffa
    80006064:	4dc080e7          	jalr	1244(ra) # 8000053c <panic>

0000000080006068 <virtio_disk_init>:
{
    80006068:	1101                	add	sp,sp,-32
    8000606a:	ec06                	sd	ra,24(sp)
    8000606c:	e822                	sd	s0,16(sp)
    8000606e:	e426                	sd	s1,8(sp)
    80006070:	e04a                	sd	s2,0(sp)
    80006072:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006074:	00002597          	auipc	a1,0x2
    80006078:	6b458593          	add	a1,a1,1716 # 80008728 <syscalls+0x320>
    8000607c:	0001c517          	auipc	a0,0x1c
    80006080:	2a450513          	add	a0,a0,676 # 80022320 <disk+0x128>
    80006084:	ffffb097          	auipc	ra,0xffffb
    80006088:	abe080e7          	jalr	-1346(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000608c:	100017b7          	lui	a5,0x10001
    80006090:	4398                	lw	a4,0(a5)
    80006092:	2701                	sext.w	a4,a4
    80006094:	747277b7          	lui	a5,0x74727
    80006098:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000609c:	14f71b63          	bne	a4,a5,800061f2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060a0:	100017b7          	lui	a5,0x10001
    800060a4:	43dc                	lw	a5,4(a5)
    800060a6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060a8:	4709                	li	a4,2
    800060aa:	14e79463          	bne	a5,a4,800061f2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	479c                	lw	a5,8(a5)
    800060b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060b6:	12e79e63          	bne	a5,a4,800061f2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060ba:	100017b7          	lui	a5,0x10001
    800060be:	47d8                	lw	a4,12(a5)
    800060c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060c2:	554d47b7          	lui	a5,0x554d4
    800060c6:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060ca:	12f71463          	bne	a4,a5,800061f2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ce:	100017b7          	lui	a5,0x10001
    800060d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060d6:	4705                	li	a4,1
    800060d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060da:	470d                	li	a4,3
    800060dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060de:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060e0:	c7ffe6b7          	lui	a3,0xc7ffe
    800060e4:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc427>
    800060e8:	8f75                	and	a4,a4,a3
    800060ea:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ec:	472d                	li	a4,11
    800060ee:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060f0:	5bbc                	lw	a5,112(a5)
    800060f2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060f6:	8ba1                	and	a5,a5,8
    800060f8:	10078563          	beqz	a5,80006202 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060fc:	100017b7          	lui	a5,0x10001
    80006100:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006104:	43fc                	lw	a5,68(a5)
    80006106:	2781                	sext.w	a5,a5
    80006108:	10079563          	bnez	a5,80006212 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000610c:	100017b7          	lui	a5,0x10001
    80006110:	5bdc                	lw	a5,52(a5)
    80006112:	2781                	sext.w	a5,a5
  if(max == 0)
    80006114:	10078763          	beqz	a5,80006222 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006118:	471d                	li	a4,7
    8000611a:	10f77c63          	bgeu	a4,a5,80006232 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000611e:	ffffb097          	auipc	ra,0xffffb
    80006122:	9c4080e7          	jalr	-1596(ra) # 80000ae2 <kalloc>
    80006126:	0001c497          	auipc	s1,0x1c
    8000612a:	0d248493          	add	s1,s1,210 # 800221f8 <disk>
    8000612e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006130:	ffffb097          	auipc	ra,0xffffb
    80006134:	9b2080e7          	jalr	-1614(ra) # 80000ae2 <kalloc>
    80006138:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000613a:	ffffb097          	auipc	ra,0xffffb
    8000613e:	9a8080e7          	jalr	-1624(ra) # 80000ae2 <kalloc>
    80006142:	87aa                	mv	a5,a0
    80006144:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006146:	6088                	ld	a0,0(s1)
    80006148:	cd6d                	beqz	a0,80006242 <virtio_disk_init+0x1da>
    8000614a:	0001c717          	auipc	a4,0x1c
    8000614e:	0b673703          	ld	a4,182(a4) # 80022200 <disk+0x8>
    80006152:	cb65                	beqz	a4,80006242 <virtio_disk_init+0x1da>
    80006154:	c7fd                	beqz	a5,80006242 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006156:	6605                	lui	a2,0x1
    80006158:	4581                	li	a1,0
    8000615a:	ffffb097          	auipc	ra,0xffffb
    8000615e:	b74080e7          	jalr	-1164(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80006162:	0001c497          	auipc	s1,0x1c
    80006166:	09648493          	add	s1,s1,150 # 800221f8 <disk>
    8000616a:	6605                	lui	a2,0x1
    8000616c:	4581                	li	a1,0
    8000616e:	6488                	ld	a0,8(s1)
    80006170:	ffffb097          	auipc	ra,0xffffb
    80006174:	b5e080e7          	jalr	-1186(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80006178:	6605                	lui	a2,0x1
    8000617a:	4581                	li	a1,0
    8000617c:	6888                	ld	a0,16(s1)
    8000617e:	ffffb097          	auipc	ra,0xffffb
    80006182:	b50080e7          	jalr	-1200(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006186:	100017b7          	lui	a5,0x10001
    8000618a:	4721                	li	a4,8
    8000618c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000618e:	4098                	lw	a4,0(s1)
    80006190:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006194:	40d8                	lw	a4,4(s1)
    80006196:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000619a:	6498                	ld	a4,8(s1)
    8000619c:	0007069b          	sext.w	a3,a4
    800061a0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061a4:	9701                	sra	a4,a4,0x20
    800061a6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061aa:	6898                	ld	a4,16(s1)
    800061ac:	0007069b          	sext.w	a3,a4
    800061b0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061b4:	9701                	sra	a4,a4,0x20
    800061b6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061ba:	4705                	li	a4,1
    800061bc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800061be:	00e48c23          	sb	a4,24(s1)
    800061c2:	00e48ca3          	sb	a4,25(s1)
    800061c6:	00e48d23          	sb	a4,26(s1)
    800061ca:	00e48da3          	sb	a4,27(s1)
    800061ce:	00e48e23          	sb	a4,28(s1)
    800061d2:	00e48ea3          	sb	a4,29(s1)
    800061d6:	00e48f23          	sb	a4,30(s1)
    800061da:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061de:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e2:	0727a823          	sw	s2,112(a5)
}
    800061e6:	60e2                	ld	ra,24(sp)
    800061e8:	6442                	ld	s0,16(sp)
    800061ea:	64a2                	ld	s1,8(sp)
    800061ec:	6902                	ld	s2,0(sp)
    800061ee:	6105                	add	sp,sp,32
    800061f0:	8082                	ret
    panic("could not find virtio disk");
    800061f2:	00002517          	auipc	a0,0x2
    800061f6:	54650513          	add	a0,a0,1350 # 80008738 <syscalls+0x330>
    800061fa:	ffffa097          	auipc	ra,0xffffa
    800061fe:	342080e7          	jalr	834(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006202:	00002517          	auipc	a0,0x2
    80006206:	55650513          	add	a0,a0,1366 # 80008758 <syscalls+0x350>
    8000620a:	ffffa097          	auipc	ra,0xffffa
    8000620e:	332080e7          	jalr	818(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006212:	00002517          	auipc	a0,0x2
    80006216:	56650513          	add	a0,a0,1382 # 80008778 <syscalls+0x370>
    8000621a:	ffffa097          	auipc	ra,0xffffa
    8000621e:	322080e7          	jalr	802(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006222:	00002517          	auipc	a0,0x2
    80006226:	57650513          	add	a0,a0,1398 # 80008798 <syscalls+0x390>
    8000622a:	ffffa097          	auipc	ra,0xffffa
    8000622e:	312080e7          	jalr	786(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006232:	00002517          	auipc	a0,0x2
    80006236:	58650513          	add	a0,a0,1414 # 800087b8 <syscalls+0x3b0>
    8000623a:	ffffa097          	auipc	ra,0xffffa
    8000623e:	302080e7          	jalr	770(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006242:	00002517          	auipc	a0,0x2
    80006246:	59650513          	add	a0,a0,1430 # 800087d8 <syscalls+0x3d0>
    8000624a:	ffffa097          	auipc	ra,0xffffa
    8000624e:	2f2080e7          	jalr	754(ra) # 8000053c <panic>

0000000080006252 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006252:	7159                	add	sp,sp,-112
    80006254:	f486                	sd	ra,104(sp)
    80006256:	f0a2                	sd	s0,96(sp)
    80006258:	eca6                	sd	s1,88(sp)
    8000625a:	e8ca                	sd	s2,80(sp)
    8000625c:	e4ce                	sd	s3,72(sp)
    8000625e:	e0d2                	sd	s4,64(sp)
    80006260:	fc56                	sd	s5,56(sp)
    80006262:	f85a                	sd	s6,48(sp)
    80006264:	f45e                	sd	s7,40(sp)
    80006266:	f062                	sd	s8,32(sp)
    80006268:	ec66                	sd	s9,24(sp)
    8000626a:	e86a                	sd	s10,16(sp)
    8000626c:	1880                	add	s0,sp,112
    8000626e:	8a2a                	mv	s4,a0
    80006270:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006272:	00c52c83          	lw	s9,12(a0)
    80006276:	001c9c9b          	sllw	s9,s9,0x1
    8000627a:	1c82                	sll	s9,s9,0x20
    8000627c:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006280:	0001c517          	auipc	a0,0x1c
    80006284:	0a050513          	add	a0,a0,160 # 80022320 <disk+0x128>
    80006288:	ffffb097          	auipc	ra,0xffffb
    8000628c:	94a080e7          	jalr	-1718(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006290:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006292:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006294:	0001cb17          	auipc	s6,0x1c
    80006298:	f64b0b13          	add	s6,s6,-156 # 800221f8 <disk>
  for(int i = 0; i < 3; i++){
    8000629c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000629e:	0001cc17          	auipc	s8,0x1c
    800062a2:	082c0c13          	add	s8,s8,130 # 80022320 <disk+0x128>
    800062a6:	a095                	j	8000630a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062a8:	00fb0733          	add	a4,s6,a5
    800062ac:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062b0:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    800062b2:	0207c563          	bltz	a5,800062dc <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    800062b6:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    800062b8:	0591                	add	a1,a1,4
    800062ba:	05560d63          	beq	a2,s5,80006314 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800062be:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    800062c0:	0001c717          	auipc	a4,0x1c
    800062c4:	f3870713          	add	a4,a4,-200 # 800221f8 <disk>
    800062c8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    800062ca:	01874683          	lbu	a3,24(a4)
    800062ce:	fee9                	bnez	a3,800062a8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    800062d0:	2785                	addw	a5,a5,1
    800062d2:	0705                	add	a4,a4,1
    800062d4:	fe979be3          	bne	a5,s1,800062ca <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    800062d8:	57fd                	li	a5,-1
    800062da:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    800062dc:	00c05e63          	blez	a2,800062f8 <virtio_disk_rw+0xa6>
    800062e0:	060a                	sll	a2,a2,0x2
    800062e2:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    800062e6:	0009a503          	lw	a0,0(s3)
    800062ea:	00000097          	auipc	ra,0x0
    800062ee:	cfc080e7          	jalr	-772(ra) # 80005fe6 <free_desc>
      for(int j = 0; j < i; j++)
    800062f2:	0991                	add	s3,s3,4
    800062f4:	ffa999e3          	bne	s3,s10,800062e6 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062f8:	85e2                	mv	a1,s8
    800062fa:	0001c517          	auipc	a0,0x1c
    800062fe:	f1650513          	add	a0,a0,-234 # 80022210 <disk+0x18>
    80006302:	ffffc097          	auipc	ra,0xffffc
    80006306:	dfc080e7          	jalr	-516(ra) # 800020fe <sleep>
  for(int i = 0; i < 3; i++){
    8000630a:	f9040993          	add	s3,s0,-112
{
    8000630e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006310:	864a                	mv	a2,s2
    80006312:	b775                	j	800062be <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006314:	f9042503          	lw	a0,-112(s0)
    80006318:	00a50713          	add	a4,a0,10
    8000631c:	0712                	sll	a4,a4,0x4

  if(write)
    8000631e:	0001c797          	auipc	a5,0x1c
    80006322:	eda78793          	add	a5,a5,-294 # 800221f8 <disk>
    80006326:	00e786b3          	add	a3,a5,a4
    8000632a:	01703633          	snez	a2,s7
    8000632e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006330:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006334:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006338:	f6070613          	add	a2,a4,-160
    8000633c:	6394                	ld	a3,0(a5)
    8000633e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006340:	00870593          	add	a1,a4,8
    80006344:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006346:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006348:	0007b803          	ld	a6,0(a5)
    8000634c:	9642                	add	a2,a2,a6
    8000634e:	46c1                	li	a3,16
    80006350:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006352:	4585                	li	a1,1
    80006354:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006358:	f9442683          	lw	a3,-108(s0)
    8000635c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006360:	0692                	sll	a3,a3,0x4
    80006362:	9836                	add	a6,a6,a3
    80006364:	058a0613          	add	a2,s4,88
    80006368:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000636c:	0007b803          	ld	a6,0(a5)
    80006370:	96c2                	add	a3,a3,a6
    80006372:	40000613          	li	a2,1024
    80006376:	c690                	sw	a2,8(a3)
  if(write)
    80006378:	001bb613          	seqz	a2,s7
    8000637c:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006380:	00166613          	or	a2,a2,1
    80006384:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006388:	f9842603          	lw	a2,-104(s0)
    8000638c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006390:	00250693          	add	a3,a0,2
    80006394:	0692                	sll	a3,a3,0x4
    80006396:	96be                	add	a3,a3,a5
    80006398:	58fd                	li	a7,-1
    8000639a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000639e:	0612                	sll	a2,a2,0x4
    800063a0:	9832                	add	a6,a6,a2
    800063a2:	f9070713          	add	a4,a4,-112
    800063a6:	973e                	add	a4,a4,a5
    800063a8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800063ac:	6398                	ld	a4,0(a5)
    800063ae:	9732                	add	a4,a4,a2
    800063b0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063b2:	4609                	li	a2,2
    800063b4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800063b8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063bc:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    800063c0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063c4:	6794                	ld	a3,8(a5)
    800063c6:	0026d703          	lhu	a4,2(a3)
    800063ca:	8b1d                	and	a4,a4,7
    800063cc:	0706                	sll	a4,a4,0x1
    800063ce:	96ba                	add	a3,a3,a4
    800063d0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800063d4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063d8:	6798                	ld	a4,8(a5)
    800063da:	00275783          	lhu	a5,2(a4)
    800063de:	2785                	addw	a5,a5,1
    800063e0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063e4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063e8:	100017b7          	lui	a5,0x10001
    800063ec:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063f0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800063f4:	0001c917          	auipc	s2,0x1c
    800063f8:	f2c90913          	add	s2,s2,-212 # 80022320 <disk+0x128>
  while(b->disk == 1) {
    800063fc:	4485                	li	s1,1
    800063fe:	00b79c63          	bne	a5,a1,80006416 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006402:	85ca                	mv	a1,s2
    80006404:	8552                	mv	a0,s4
    80006406:	ffffc097          	auipc	ra,0xffffc
    8000640a:	cf8080e7          	jalr	-776(ra) # 800020fe <sleep>
  while(b->disk == 1) {
    8000640e:	004a2783          	lw	a5,4(s4)
    80006412:	fe9788e3          	beq	a5,s1,80006402 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006416:	f9042903          	lw	s2,-112(s0)
    8000641a:	00290713          	add	a4,s2,2
    8000641e:	0712                	sll	a4,a4,0x4
    80006420:	0001c797          	auipc	a5,0x1c
    80006424:	dd878793          	add	a5,a5,-552 # 800221f8 <disk>
    80006428:	97ba                	add	a5,a5,a4
    8000642a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000642e:	0001c997          	auipc	s3,0x1c
    80006432:	dca98993          	add	s3,s3,-566 # 800221f8 <disk>
    80006436:	00491713          	sll	a4,s2,0x4
    8000643a:	0009b783          	ld	a5,0(s3)
    8000643e:	97ba                	add	a5,a5,a4
    80006440:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006444:	854a                	mv	a0,s2
    80006446:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000644a:	00000097          	auipc	ra,0x0
    8000644e:	b9c080e7          	jalr	-1124(ra) # 80005fe6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006452:	8885                	and	s1,s1,1
    80006454:	f0ed                	bnez	s1,80006436 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006456:	0001c517          	auipc	a0,0x1c
    8000645a:	eca50513          	add	a0,a0,-310 # 80022320 <disk+0x128>
    8000645e:	ffffb097          	auipc	ra,0xffffb
    80006462:	828080e7          	jalr	-2008(ra) # 80000c86 <release>
}
    80006466:	70a6                	ld	ra,104(sp)
    80006468:	7406                	ld	s0,96(sp)
    8000646a:	64e6                	ld	s1,88(sp)
    8000646c:	6946                	ld	s2,80(sp)
    8000646e:	69a6                	ld	s3,72(sp)
    80006470:	6a06                	ld	s4,64(sp)
    80006472:	7ae2                	ld	s5,56(sp)
    80006474:	7b42                	ld	s6,48(sp)
    80006476:	7ba2                	ld	s7,40(sp)
    80006478:	7c02                	ld	s8,32(sp)
    8000647a:	6ce2                	ld	s9,24(sp)
    8000647c:	6d42                	ld	s10,16(sp)
    8000647e:	6165                	add	sp,sp,112
    80006480:	8082                	ret

0000000080006482 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006482:	1101                	add	sp,sp,-32
    80006484:	ec06                	sd	ra,24(sp)
    80006486:	e822                	sd	s0,16(sp)
    80006488:	e426                	sd	s1,8(sp)
    8000648a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000648c:	0001c497          	auipc	s1,0x1c
    80006490:	d6c48493          	add	s1,s1,-660 # 800221f8 <disk>
    80006494:	0001c517          	auipc	a0,0x1c
    80006498:	e8c50513          	add	a0,a0,-372 # 80022320 <disk+0x128>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	736080e7          	jalr	1846(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064a4:	10001737          	lui	a4,0x10001
    800064a8:	533c                	lw	a5,96(a4)
    800064aa:	8b8d                	and	a5,a5,3
    800064ac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064b2:	689c                	ld	a5,16(s1)
    800064b4:	0204d703          	lhu	a4,32(s1)
    800064b8:	0027d783          	lhu	a5,2(a5)
    800064bc:	04f70863          	beq	a4,a5,8000650c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800064c0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064c4:	6898                	ld	a4,16(s1)
    800064c6:	0204d783          	lhu	a5,32(s1)
    800064ca:	8b9d                	and	a5,a5,7
    800064cc:	078e                	sll	a5,a5,0x3
    800064ce:	97ba                	add	a5,a5,a4
    800064d0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064d2:	00278713          	add	a4,a5,2
    800064d6:	0712                	sll	a4,a4,0x4
    800064d8:	9726                	add	a4,a4,s1
    800064da:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800064de:	e721                	bnez	a4,80006526 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064e0:	0789                	add	a5,a5,2
    800064e2:	0792                	sll	a5,a5,0x4
    800064e4:	97a6                	add	a5,a5,s1
    800064e6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064ec:	ffffc097          	auipc	ra,0xffffc
    800064f0:	c76080e7          	jalr	-906(ra) # 80002162 <wakeup>

    disk.used_idx += 1;
    800064f4:	0204d783          	lhu	a5,32(s1)
    800064f8:	2785                	addw	a5,a5,1
    800064fa:	17c2                	sll	a5,a5,0x30
    800064fc:	93c1                	srl	a5,a5,0x30
    800064fe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006502:	6898                	ld	a4,16(s1)
    80006504:	00275703          	lhu	a4,2(a4)
    80006508:	faf71ce3          	bne	a4,a5,800064c0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000650c:	0001c517          	auipc	a0,0x1c
    80006510:	e1450513          	add	a0,a0,-492 # 80022320 <disk+0x128>
    80006514:	ffffa097          	auipc	ra,0xffffa
    80006518:	772080e7          	jalr	1906(ra) # 80000c86 <release>
}
    8000651c:	60e2                	ld	ra,24(sp)
    8000651e:	6442                	ld	s0,16(sp)
    80006520:	64a2                	ld	s1,8(sp)
    80006522:	6105                	add	sp,sp,32
    80006524:	8082                	ret
      panic("virtio_disk_intr status");
    80006526:	00002517          	auipc	a0,0x2
    8000652a:	2ca50513          	add	a0,a0,714 # 800087f0 <syscalls+0x3e8>
    8000652e:	ffffa097          	auipc	ra,0xffffa
    80006532:	00e080e7          	jalr	14(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
