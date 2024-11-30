
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	92010113          	addi	sp,sp,-1760 # 80007920 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
// Machine Environment Configuration Register
static inline uint64
r_menvcfg()
{
  uint64 x;
  asm volatile("csrr %0, menvcfg" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4
}

static inline void 
w_menvcfg(uint64 x)
{
  asm volatile("csrw menvcfg, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddbaf>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	15a020ef          	jal	80002254 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	0000f517          	auipc	a0,0xf
    80000158:	7cc50513          	addi	a0,a0,1996 # 8000f920 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	0000f497          	auipc	s1,0xf
    80000164:	7c048493          	addi	s1,s1,1984 # 8000f920 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	85090913          	addi	s2,s2,-1968 # 8000f9b8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	763010ef          	jal	800020e6 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	521010ef          	jal	80001eae <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	78070713          	addi	a4,a4,1920 # 8000f920 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	038020ef          	jal	8000220a <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	73650513          	addi	a0,a0,1846 # 8000f920 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	0000f717          	auipc	a4,0xf
    80000218:	7af72223          	sw	a5,1956(a4) # 8000f9b8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	6f650513          	addi	a0,a0,1782 # 8000f920 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	6a250513          	addi	a0,a0,1698 # 8000f920 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	7ff010ef          	jal	8000229e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	67c50513          	addi	a0,a0,1660 # 8000f920 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	65e70713          	addi	a4,a4,1630 # 8000f920 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	63878793          	addi	a5,a5,1592 # 8000f920 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	6a27a783          	lw	a5,1698(a5) # 8000f9b8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	5f470713          	addi	a4,a4,1524 # 8000f920 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	5e448493          	addi	s1,s1,1508 # 8000f920 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	5a270713          	addi	a4,a4,1442 # 8000f920 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	62f72623          	sw	a5,1580(a4) # 8000f9c0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	56e78793          	addi	a5,a5,1390 # 8000f920 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	5ec7a323          	sw	a2,1510(a5) # 8000f9bc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	5da50513          	addi	a0,a0,1498 # 8000f9b8 <cons+0x98>
    800003e6:	315010ef          	jal	80001efa <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	52450513          	addi	a0,a0,1316 # 8000f920 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	6ac78793          	addi	a5,a5,1708 # 8001fab8 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	5007a783          	lw	a5,1280(a5) # 8000f9e0 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	49c50513          	addi	a0,a0,1180 # 8000f9c8 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	24250513          	addi	a0,a0,578 # 8000f9c8 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2407a023          	sw	zero,576(a5) # 8000f9e0 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	10f72e23          	sw	a5,284(a4) # 800078e0 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	1f048493          	addi	s1,s1,496 # 8000f9c8 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	1a850513          	addi	a0,a0,424 # 8000f9e8 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	07c7a783          	lw	a5,124(a5) # 800078e0 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	04e7b783          	ld	a5,78(a5) # 800078e8 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	04e73703          	ld	a4,78(a4) # 800078f0 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	120a8a93          	addi	s5,s5,288 # 8000f9e8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	01848493          	addi	s1,s1,24 # 800078e8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	01498993          	addi	s3,s3,20 # 800078f0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	5fc010ef          	jal	80001efa <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	09c50513          	addi	a0,a0,156 # 8000f9e8 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	f887a783          	lw	a5,-120(a5) # 800078e0 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	f8e73703          	ld	a4,-114(a4) # 800078f0 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f7e7b783          	ld	a5,-130(a5) # 800078e8 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	07298993          	addi	s3,s3,114 # 8000f9e8 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	f6a48493          	addi	s1,s1,-150 # 800078e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	f6a90913          	addi	s2,s2,-150 # 800078f0 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	518010ef          	jal	80001eae <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	04048493          	addi	s1,s1,64 # 8000f9e8 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f2e7ba23          	sd	a4,-204(a5) # 800078f0 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	fc848493          	addi	s1,s1,-56 # 8000f9e8 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	1fa78793          	addi	a5,a5,506 # 80020c50 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	fae90913          	addi	s2,s2,-82 # 8000fa20 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f2050513          	addi	a0,a0,-224 # 8000fa20 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	14050513          	addi	a0,a0,320 # 80020c50 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	ef248493          	addi	s1,s1,-270 # 8000fa20 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	ede50513          	addi	a0,a0,-290 # 8000fa20 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	eba50513          	addi	a0,a0,-326 # 8000fa20 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde3b1>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	a8a70713          	addi	a4,a4,-1398 # 800078f8 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	538010ef          	jal	800023d0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	47c040ef          	jal	80005318 <plicinithart>
  }

  scheduler();        
    80000ea0:	675000ef          	jal	80001d14 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	4cc010ef          	jal	800023ac <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	4ec010ef          	jal	800023d0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	416040ef          	jal	800052fe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	42c040ef          	jal	80005318 <plicinithart>
    binit();         // buffer cache
    80000ef0:	313010ef          	jal	80002a02 <binit>
    iinit();         // inode table
    80000ef4:	10a020ef          	jal	80002ffe <iinit>
    fileinit();      // file table
    80000ef8:	6f9020ef          	jal	80003df0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	50c040ef          	jal	80005408 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	449000ef          	jal	80001b48 <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	9ef72723          	sw	a5,-1554(a4) # 800078f8 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	9e27b783          	ld	a5,-1566(a5) # 80007900 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde3a7>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00006797          	auipc	a5,0x6
    800011ae:	74a7bb23          	sd	a0,1878(a5) # 80007900 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	0000e497          	auipc	s1,0xe
    80001780:	6f448493          	addi	s1,s1,1780 # 8000fe70 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	04fa5937          	lui	s2,0x4fa5
    8000178a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	fa590913          	addi	s2,s2,-91
    80001794:	0932                	slli	s2,s2,0xc
    80001796:	fa590913          	addi	s2,s2,-91
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	fa590913          	addi	s2,s2,-91
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00014a97          	auipc	s5,0x14
    800017ac:	0c8a8a93          	addi	s5,s5,200 # 80015870 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	858d                	srai	a1,a1,0x3
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	16848493          	addi	s1,s1,360
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	0000e517          	auipc	a0,0xe
    8000181e:	22650513          	addi	a0,a0,550 # 8000fa40 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	0000e517          	auipc	a0,0xe
    80001832:	22a50513          	addi	a0,a0,554 # 8000fa58 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	0000e497          	auipc	s1,0xe
    8000183e:	63648493          	addi	s1,s1,1590 # 8000fe70 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	04fa5937          	lui	s2,0x4fa5
    80001850:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	fa590913          	addi	s2,s2,-91
    8000185a:	0932                	slli	s2,s2,0xc
    8000185c:	fa590913          	addi	s2,s2,-91
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	fa590913          	addi	s2,s2,-91
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00014a17          	auipc	s4,0x14
    80001872:	002a0a13          	addi	s4,s4,2 # 80015870 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	878d                	srai	a5,a5,0x3
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	16848493          	addi	s1,s1,360
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	0000e517          	auipc	a0,0xe
    800018d4:	1a050513          	addi	a0,a0,416 # 8000fa70 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	0000e717          	auipc	a4,0xe
    800018f8:	14c70713          	addi	a4,a4,332 # 8000fa40 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00006797          	auipc	a5,0x6
    80001924:	f707a783          	lw	a5,-144(a5) # 80007890 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	2bf000ef          	jal	800023e8 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	65a010ef          	jal	80002f92 <fsinit>
    first = 0;
    8000193c:	00006797          	auipc	a5,0x6
    80001940:	f407aa23          	sw	zero,-172(a5) # 80007890 <first.1>
    __sync_synchronize();
    80001944:	0ff0000f          	fence
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	0000e917          	auipc	s2,0xe
    8000195a:	0ea90913          	addi	s2,s2,234 # 8000fa40 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00006797          	auipc	a5,0x6
    80001968:	f3078793          	addi	a5,a5,-208 # 80007894 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	0000e497          	auipc	s1,0xe
    80001ab2:	3c248493          	addi	s1,s1,962 # 8000fe70 <proc>
    80001ab6:	00014917          	auipc	s2,0x14
    80001aba:	dba90913          	addi	s2,s2,-582 # 80015870 <tickslock>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	16848493          	addi	s1,s1,360
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a089                	j	80001b1a <allocproc+0x78>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae4:	840ff0ef          	jal	80000b24 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	cd15                	beqz	a0,80001b28 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aee:	8526                	mv	a0,s1
    80001af0:	e99ff0ef          	jal	80001988 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af8:	c121                	beqz	a0,80001b38 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9c4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	e0878793          	addi	a5,a5,-504 # 80001910 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
}
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    freeproc(p);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f29ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	95cff0ef          	jal	80000c8c <release>
    return 0;
    80001b34:	84ca                	mv	s1,s2
    80001b36:	b7d5                	j	80001b1a <allocproc+0x78>
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f19ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	94cff0ef          	jal	80000c8c <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	bfd1                	j	80001b1a <allocproc+0x78>

0000000080001b48 <userinit>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b52:	f51ff0ef          	jal	80001aa2 <allocproc>
    80001b56:	84aa                	mv	s1,a0
  initproc = p;
    80001b58:	00006797          	auipc	a5,0x6
    80001b5c:	daa7b823          	sd	a0,-592(a5) # 80007908 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b60:	03400613          	li	a2,52
    80001b64:	00006597          	auipc	a1,0x6
    80001b68:	d3c58593          	addi	a1,a1,-708 # 800078a0 <initcode>
    80001b6c:	6928                	ld	a0,80(a0)
    80001b6e:	f2eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b72:	6785                	lui	a5,0x1
    80001b74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b7c:	6cb8                	ld	a4,88(s1)
    80001b7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b80:	4641                	li	a2,16
    80001b82:	00005597          	auipc	a1,0x5
    80001b86:	69e58593          	addi	a1,a1,1694 # 80007220 <etext+0x220>
    80001b8a:	15848513          	addi	a0,s1,344
    80001b8e:	a78ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	69e50513          	addi	a0,a0,1694 # 80007230 <etext+0x230>
    80001b9a:	549010ef          	jal	800038e2 <namei>
    80001b9e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ba2:	478d                	li	a5,3
    80001ba4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	8e4ff0ef          	jal	80000c8c <release>
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <growproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc4:	d1dff0ef          	jal	800018e0 <myproc>
    80001bc8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bca:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bcc:	01204c63          	bgtz	s2,80001be4 <growproc+0x2e>
  } else if(n < 0){
    80001bd0:	02094463          	bltz	s2,80001bf8 <growproc+0x42>
  p->sz = sz;
    80001bd4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd6:	4501                	li	a0,0
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be4:	4691                	li	a3,4
    80001be6:	00b90633          	add	a2,s2,a1
    80001bea:	6928                	ld	a0,80(a0)
    80001bec:	f52ff0ef          	jal	8000133e <uvmalloc>
    80001bf0:	85aa                	mv	a1,a0
    80001bf2:	f16d                	bnez	a0,80001bd4 <growproc+0x1e>
      return -1;
    80001bf4:	557d                	li	a0,-1
    80001bf6:	b7cd                	j	80001bd8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	efcff0ef          	jal	800012fa <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bfc1                	j	80001bd4 <growproc+0x1e>

0000000080001c06 <fork>:
{
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f04a                	sd	s2,32(sp)
    80001c0e:	e456                	sd	s5,8(sp)
    80001c10:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c12:	ccfff0ef          	jal	800018e0 <myproc>
    80001c16:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c18:	e8bff0ef          	jal	80001aa2 <allocproc>
    80001c1c:	0e050a63          	beqz	a0,80001d10 <fork+0x10a>
    80001c20:	e852                	sd	s4,16(sp)
    80001c22:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c24:	048ab603          	ld	a2,72(s5)
    80001c28:	692c                	ld	a1,80(a0)
    80001c2a:	050ab503          	ld	a0,80(s5)
    80001c2e:	849ff0ef          	jal	80001476 <uvmcopy>
    80001c32:	04054a63          	bltz	a0,80001c86 <fork+0x80>
    80001c36:	f426                	sd	s1,40(sp)
    80001c38:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c42:	058ab683          	ld	a3,88(s5)
    80001c46:	87b6                	mv	a5,a3
    80001c48:	058a3703          	ld	a4,88(s4)
    80001c4c:	12068693          	addi	a3,a3,288
    80001c50:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c54:	6788                	ld	a0,8(a5)
    80001c56:	6b8c                	ld	a1,16(a5)
    80001c58:	6f90                	ld	a2,24(a5)
    80001c5a:	01073023          	sd	a6,0(a4)
    80001c5e:	e708                	sd	a0,8(a4)
    80001c60:	eb0c                	sd	a1,16(a4)
    80001c62:	ef10                	sd	a2,24(a4)
    80001c64:	02078793          	addi	a5,a5,32
    80001c68:	02070713          	addi	a4,a4,32
    80001c6c:	fed792e3          	bne	a5,a3,80001c50 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c70:	058a3783          	ld	a5,88(s4)
    80001c74:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c78:	0d0a8493          	addi	s1,s5,208
    80001c7c:	0d0a0913          	addi	s2,s4,208
    80001c80:	150a8993          	addi	s3,s5,336
    80001c84:	a831                	j	80001ca0 <fork+0x9a>
    freeproc(np);
    80001c86:	8552                	mv	a0,s4
    80001c88:	dcbff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	ffffe0ef          	jal	80000c8c <release>
    return -1;
    80001c92:	597d                	li	s2,-1
    80001c94:	6a42                	ld	s4,16(sp)
    80001c96:	a0b5                	j	80001d02 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c98:	04a1                	addi	s1,s1,8
    80001c9a:	0921                	addi	s2,s2,8
    80001c9c:	01348963          	beq	s1,s3,80001cae <fork+0xa8>
    if(p->ofile[i])
    80001ca0:	6088                	ld	a0,0(s1)
    80001ca2:	d97d                	beqz	a0,80001c98 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca4:	1ce020ef          	jal	80003e72 <filedup>
    80001ca8:	00a93023          	sd	a0,0(s2)
    80001cac:	b7f5                	j	80001c98 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cae:	150ab503          	ld	a0,336(s5)
    80001cb2:	4de010ef          	jal	80003190 <idup>
    80001cb6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cba:	4641                	li	a2,16
    80001cbc:	158a8593          	addi	a1,s5,344
    80001cc0:	158a0513          	addi	a0,s4,344
    80001cc4:	942ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cc8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ccc:	8552                	mv	a0,s4
    80001cce:	fbffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cd2:	0000e497          	auipc	s1,0xe
    80001cd6:	d8648493          	addi	s1,s1,-634 # 8000fa58 <wait_lock>
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f19fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ce0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fa7fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cea:	8552                	mv	a0,s4
    80001cec:	f09fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf6:	8552                	mv	a0,s4
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
  return pid;
    80001cfc:	74a2                	ld	s1,40(sp)
    80001cfe:	69e2                	ld	s3,24(sp)
    80001d00:	6a42                	ld	s4,16(sp)
}
    80001d02:	854a                	mv	a0,s2
    80001d04:	70e2                	ld	ra,56(sp)
    80001d06:	7442                	ld	s0,48(sp)
    80001d08:	7902                	ld	s2,32(sp)
    80001d0a:	6aa2                	ld	s5,8(sp)
    80001d0c:	6121                	addi	sp,sp,64
    80001d0e:	8082                	ret
    return -1;
    80001d10:	597d                	li	s2,-1
    80001d12:	bfc5                	j	80001d02 <fork+0xfc>

0000000080001d14 <scheduler>:
{
    80001d14:	715d                	addi	sp,sp,-80
    80001d16:	e486                	sd	ra,72(sp)
    80001d18:	e0a2                	sd	s0,64(sp)
    80001d1a:	fc26                	sd	s1,56(sp)
    80001d1c:	f84a                	sd	s2,48(sp)
    80001d1e:	f44e                	sd	s3,40(sp)
    80001d20:	f052                	sd	s4,32(sp)
    80001d22:	ec56                	sd	s5,24(sp)
    80001d24:	e85a                	sd	s6,16(sp)
    80001d26:	e45e                	sd	s7,8(sp)
    80001d28:	e062                	sd	s8,0(sp)
    80001d2a:	0880                	addi	s0,sp,80
    80001d2c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d30:	00779b13          	slli	s6,a5,0x7
    80001d34:	0000e717          	auipc	a4,0xe
    80001d38:	d0c70713          	addi	a4,a4,-756 # 8000fa40 <pid_lock>
    80001d3c:	975a                	add	a4,a4,s6
    80001d3e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d42:	0000e717          	auipc	a4,0xe
    80001d46:	d3670713          	addi	a4,a4,-714 # 8000fa78 <cpus+0x8>
    80001d4a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4c:	4c11                	li	s8,4
        c->proc = p;
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	0000ea17          	auipc	s4,0xe
    80001d54:	cf0a0a13          	addi	s4,s4,-784 # 8000fa40 <pid_lock>
    80001d58:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00014997          	auipc	s3,0x14
    80001d60:	b1498993          	addi	s3,s3,-1260 # 80015870 <tickslock>
    80001d64:	a0a9                	j	80001dae <scheduler+0x9a>
      release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6c:	16848493          	addi	s1,s1,360
    80001d70:	03348563          	beq	s1,s3,80001d9a <scheduler+0x86>
      acquire(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	e7ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d7a:	4c9c                	lw	a5,24(s1)
    80001d7c:	ff2795e3          	bne	a5,s2,80001d66 <scheduler+0x52>
        p->state = RUNNING;
    80001d80:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d84:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d88:	06048593          	addi	a1,s1,96
    80001d8c:	855a                	mv	a0,s6
    80001d8e:	5b4000ef          	jal	80002342 <swtch>
        c->proc = 0;
    80001d92:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d96:	8ade                	mv	s5,s7
    80001d98:	b7f9                	j	80001d66 <scheduler+0x52>
    if(found == 0) {
    80001d9a:	000a9a63          	bnez	s5,80001dae <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001da6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001daa:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dba:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	0000e497          	auipc	s1,0xe
    80001dc0:	0b448493          	addi	s1,s1,180 # 8000fe70 <proc>
      if(p->state == RUNNABLE) {
    80001dc4:	490d                	li	s2,3
    80001dc6:	b77d                	j	80001d74 <scheduler+0x60>

0000000080001dc8 <sched>:
{
    80001dc8:	7179                	addi	sp,sp,-48
    80001dca:	f406                	sd	ra,40(sp)
    80001dcc:	f022                	sd	s0,32(sp)
    80001dce:	ec26                	sd	s1,24(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	e44e                	sd	s3,8(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	b0bff0ef          	jal	800018e0 <myproc>
    80001dda:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ddc:	daffe0ef          	jal	80000b8a <holding>
    80001de0:	c92d                	beqz	a0,80001e52 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001de2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de4:	2781                	sext.w	a5,a5
    80001de6:	079e                	slli	a5,a5,0x7
    80001de8:	0000e717          	auipc	a4,0xe
    80001dec:	c5870713          	addi	a4,a4,-936 # 8000fa40 <pid_lock>
    80001df0:	97ba                	add	a5,a5,a4
    80001df2:	0a87a703          	lw	a4,168(a5)
    80001df6:	4785                	li	a5,1
    80001df8:	06f71363          	bne	a4,a5,80001e5e <sched+0x96>
  if(p->state == RUNNING)
    80001dfc:	4c98                	lw	a4,24(s1)
    80001dfe:	4791                	li	a5,4
    80001e00:	06f70563          	beq	a4,a5,80001e6a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e04:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e08:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e0a:	e7b5                	bnez	a5,80001e76 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0e:	0000e917          	auipc	s2,0xe
    80001e12:	c3290913          	addi	s2,s2,-974 # 8000fa40 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	0000e597          	auipc	a1,0xe
    80001e2a:	c5258593          	addi	a1,a1,-942 # 8000fa78 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	50e000ef          	jal	80002342 <swtch>
    80001e38:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	993e                	add	s2,s2,a5
    80001e40:	0b392623          	sw	s3,172(s2)
}
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    panic("sched p->lock");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	3e650513          	addi	a0,a0,998 # 80007238 <etext+0x238>
    80001e5a:	93bfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	3ea50513          	addi	a0,a0,1002 # 80007248 <etext+0x248>
    80001e66:	92ffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	3ee50513          	addi	a0,a0,1006 # 80007258 <etext+0x258>
    80001e72:	923fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	3f250513          	addi	a0,a0,1010 # 80007268 <etext+0x268>
    80001e7e:	917fe0ef          	jal	80000794 <panic>

0000000080001e82 <yield>:
{
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e8c:	a55ff0ef          	jal	800018e0 <myproc>
    80001e90:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e92:	d63fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001e96:	478d                	li	a5,3
    80001e98:	cc9c                	sw	a5,24(s1)
  sched();
    80001e9a:	f2fff0ef          	jal	80001dc8 <sched>
  release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	dedfe0ef          	jal	80000c8c <release>
}
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	64a2                	ld	s1,8(sp)
    80001eaa:	6105                	addi	sp,sp,32
    80001eac:	8082                	ret

0000000080001eae <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	1800                	addi	s0,sp,48
    80001ebc:	89aa                	mv	s3,a0
    80001ebe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec0:	a21ff0ef          	jal	800018e0 <myproc>
    80001ec4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec6:	d2ffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001eca:	854a                	mv	a0,s2
    80001ecc:	dc1fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001ed0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed4:	4789                	li	a5,2
    80001ed6:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed8:	ef1ff0ef          	jal	80001dc8 <sched>

  // Tidy up.
  p->chan = 0;
    80001edc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	dabfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	d0dfe0ef          	jal	80000bf4 <acquire>
}
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001efa:	7139                	addi	sp,sp,-64
    80001efc:	fc06                	sd	ra,56(sp)
    80001efe:	f822                	sd	s0,48(sp)
    80001f00:	f426                	sd	s1,40(sp)
    80001f02:	f04a                	sd	s2,32(sp)
    80001f04:	ec4e                	sd	s3,24(sp)
    80001f06:	e852                	sd	s4,16(sp)
    80001f08:	e456                	sd	s5,8(sp)
    80001f0a:	0080                	addi	s0,sp,64
    80001f0c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	0000e497          	auipc	s1,0xe
    80001f12:	f6248493          	addi	s1,s1,-158 # 8000fe70 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f16:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f18:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00014917          	auipc	s2,0x14
    80001f1e:	95690913          	addi	s2,s2,-1706 # 80015870 <tickslock>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
      }
      release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	d67fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	16848493          	addi	s1,s1,360
    80001f2e:	03248263          	beq	s1,s2,80001f52 <wakeup+0x58>
    if(p != myproc()){
    80001f32:	9afff0ef          	jal	800018e0 <myproc>
    80001f36:	fea48ae3          	beq	s1,a0,80001f2a <wakeup+0x30>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	cb9fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <wakeup+0x2a>
    80001f46:	709c                	ld	a5,32(s1)
    80001f48:	fd479ee3          	bne	a5,s4,80001f24 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f4c:	0154ac23          	sw	s5,24(s1)
    80001f50:	bfd1                	j	80001f24 <wakeup+0x2a>
    }
  }
}
    80001f52:	70e2                	ld	ra,56(sp)
    80001f54:	7442                	ld	s0,48(sp)
    80001f56:	74a2                	ld	s1,40(sp)
    80001f58:	7902                	ld	s2,32(sp)
    80001f5a:	69e2                	ld	s3,24(sp)
    80001f5c:	6a42                	ld	s4,16(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret

0000000080001f64 <reparent>:
{
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	e052                	sd	s4,0(sp)
    80001f72:	1800                	addi	s0,sp,48
    80001f74:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f76:	0000e497          	auipc	s1,0xe
    80001f7a:	efa48493          	addi	s1,s1,-262 # 8000fe70 <proc>
      pp->parent = initproc;
    80001f7e:	00006a17          	auipc	s4,0x6
    80001f82:	98aa0a13          	addi	s4,s4,-1654 # 80007908 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f86:	00014997          	auipc	s3,0x14
    80001f8a:	8ea98993          	addi	s3,s3,-1814 # 80015870 <tickslock>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	16848493          	addi	s1,s1,360
    80001f94:	01348b63          	beq	s1,s3,80001faa <reparent+0x46>
    if(pp->parent == p){
    80001f98:	7c9c                	ld	a5,56(s1)
    80001f9a:	ff279be3          	bne	a5,s2,80001f90 <reparent+0x2c>
      pp->parent = initproc;
    80001f9e:	000a3503          	ld	a0,0(s4)
    80001fa2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa4:	f57ff0ef          	jal	80001efa <wakeup>
    80001fa8:	b7e5                	j	80001f90 <reparent+0x2c>
}
    80001faa:	70a2                	ld	ra,40(sp)
    80001fac:	7402                	ld	s0,32(sp)
    80001fae:	64e2                	ld	s1,24(sp)
    80001fb0:	6942                	ld	s2,16(sp)
    80001fb2:	69a2                	ld	s3,8(sp)
    80001fb4:	6a02                	ld	s4,0(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret

0000000080001fba <exit>:
{
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	e052                	sd	s4,0(sp)
    80001fc8:	1800                	addi	s0,sp,48
    80001fca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fcc:	915ff0ef          	jal	800018e0 <myproc>
    80001fd0:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fd2:	00006797          	auipc	a5,0x6
    80001fd6:	9367b783          	ld	a5,-1738(a5) # 80007908 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <exit+0x46>
    panic("init exiting");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	29a50513          	addi	a0,a0,666 # 80007280 <etext+0x280>
    80001fee:	fa6fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001ff2:	6c7010ef          	jal	80003eb8 <fileclose>
      p->ofile[fd] = 0;
    80001ff6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248563          	beq	s1,s2,80002006 <exit+0x4c>
    if(p->ofile[fd]){
    80002000:	6088                	ld	a0,0(s1)
    80002002:	f965                	bnez	a0,80001ff2 <exit+0x38>
    80002004:	bfdd                	j	80001ffa <exit+0x40>
  begin_op();
    80002006:	299010ef          	jal	80003a9e <begin_op>
  iput(p->cwd);
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	33a010ef          	jal	80003348 <iput>
  end_op();
    80002012:	2f7010ef          	jal	80003b08 <end_op>
  p->cwd = 0;
    80002016:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000201a:	0000e497          	auipc	s1,0xe
    8000201e:	a3e48493          	addi	s1,s1,-1474 # 8000fa58 <wait_lock>
    80002022:	8526                	mv	a0,s1
    80002024:	bd1fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002028:	854e                	mv	a0,s3
    8000202a:	f3bff0ef          	jal	80001f64 <reparent>
  wakeup(p->parent);
    8000202e:	0389b503          	ld	a0,56(s3)
    80002032:	ec9ff0ef          	jal	80001efa <wakeup>
  acquire(&p->lock);
    80002036:	854e                	mv	a0,s3
    80002038:	bbdfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000203c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002040:	4795                	li	a5,5
    80002042:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002046:	8526                	mv	a0,s1
    80002048:	c45fe0ef          	jal	80000c8c <release>
  sched();
    8000204c:	d7dff0ef          	jal	80001dc8 <sched>
  panic("zombie exit");
    80002050:	00005517          	auipc	a0,0x5
    80002054:	24050513          	addi	a0,a0,576 # 80007290 <etext+0x290>
    80002058:	f3cfe0ef          	jal	80000794 <panic>

000000008000205c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000206c:	0000e497          	auipc	s1,0xe
    80002070:	e0448493          	addi	s1,s1,-508 # 8000fe70 <proc>
    80002074:	00013997          	auipc	s3,0x13
    80002078:	7fc98993          	addi	s3,s3,2044 # 80015870 <tickslock>
    acquire(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	b77fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002082:	589c                	lw	a5,48(s1)
    80002084:	01278b63          	beq	a5,s2,8000209a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	c03fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208e:	16848493          	addi	s1,s1,360
    80002092:	ff3495e3          	bne	s1,s3,8000207c <kill+0x20>
  }
  return -1;
    80002096:	557d                	li	a0,-1
    80002098:	a819                	j	800020ae <kill+0x52>
      p->killed = 1;
    8000209a:	4785                	li	a5,1
    8000209c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209e:	4c98                	lw	a4,24(s1)
    800020a0:	4789                	li	a5,2
    800020a2:	00f70d63          	beq	a4,a5,800020bc <kill+0x60>
      release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	be5fe0ef          	jal	80000c8c <release>
      return 0;
    800020ac:	4501                	li	a0,0
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
        p->state = RUNNABLE;
    800020bc:	478d                	li	a5,3
    800020be:	cc9c                	sw	a5,24(s1)
    800020c0:	b7dd                	j	800020a6 <kill+0x4a>

00000000800020c2 <setkilled>:

void
setkilled(struct proc *p)
{
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ce:	b27fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020d2:	4785                	li	a5,1
    800020d4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	bb5fe0ef          	jal	80000c8c <release>
}
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <killed>:

int
killed(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f4:	b01fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    800020f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b8ffe0ef          	jal	80000c8c <release>
  return k;
}
    80002102:	854a                	mv	a0,s2
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <wait>:
{
    80002110:	715d                	addi	sp,sp,-80
    80002112:	e486                	sd	ra,72(sp)
    80002114:	e0a2                	sd	s0,64(sp)
    80002116:	fc26                	sd	s1,56(sp)
    80002118:	f84a                	sd	s2,48(sp)
    8000211a:	f44e                	sd	s3,40(sp)
    8000211c:	f052                	sd	s4,32(sp)
    8000211e:	ec56                	sd	s5,24(sp)
    80002120:	e85a                	sd	s6,16(sp)
    80002122:	e45e                	sd	s7,8(sp)
    80002124:	e062                	sd	s8,0(sp)
    80002126:	0880                	addi	s0,sp,80
    80002128:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000212a:	fb6ff0ef          	jal	800018e0 <myproc>
    8000212e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002130:	0000e517          	auipc	a0,0xe
    80002134:	92850513          	addi	a0,a0,-1752 # 8000fa58 <wait_lock>
    80002138:	abdfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000213c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000213e:	4a15                	li	s4,5
        havekids = 1;
    80002140:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002142:	00013997          	auipc	s3,0x13
    80002146:	72e98993          	addi	s3,s3,1838 # 80015870 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214a:	0000ec17          	auipc	s8,0xe
    8000214e:	90ec0c13          	addi	s8,s8,-1778 # 8000fa58 <wait_lock>
    80002152:	a871                	j	800021ee <wait+0xde>
          pid = pp->pid;
    80002154:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002158:	000b0c63          	beqz	s6,80002170 <wait+0x60>
    8000215c:	4691                	li	a3,4
    8000215e:	02c48613          	addi	a2,s1,44
    80002162:	85da                	mv	a1,s6
    80002164:	05093503          	ld	a0,80(s2)
    80002168:	beaff0ef          	jal	80001552 <copyout>
    8000216c:	02054b63          	bltz	a0,800021a2 <wait+0x92>
          freeproc(pp);
    80002170:	8526                	mv	a0,s1
    80002172:	8e1ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	b15fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000217c:	0000e517          	auipc	a0,0xe
    80002180:	8dc50513          	addi	a0,a0,-1828 # 8000fa58 <wait_lock>
    80002184:	b09fe0ef          	jal	80000c8c <release>
}
    80002188:	854e                	mv	a0,s3
    8000218a:	60a6                	ld	ra,72(sp)
    8000218c:	6406                	ld	s0,64(sp)
    8000218e:	74e2                	ld	s1,56(sp)
    80002190:	7942                	ld	s2,48(sp)
    80002192:	79a2                	ld	s3,40(sp)
    80002194:	7a02                	ld	s4,32(sp)
    80002196:	6ae2                	ld	s5,24(sp)
    80002198:	6b42                	ld	s6,16(sp)
    8000219a:	6ba2                	ld	s7,8(sp)
    8000219c:	6c02                	ld	s8,0(sp)
    8000219e:	6161                	addi	sp,sp,80
    800021a0:	8082                	ret
            release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021a8:	0000e517          	auipc	a0,0xe
    800021ac:	8b050513          	addi	a0,a0,-1872 # 8000fa58 <wait_lock>
    800021b0:	addfe0ef          	jal	80000c8c <release>
            return -1;
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	16848493          	addi	s1,s1,360
    800021bc:	03348063          	beq	s1,s3,800021dc <wait+0xcc>
      if(pp->parent == p){
    800021c0:	7c9c                	ld	a5,56(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <wait+0xa8>
        acquire(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	a2dfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021cc:	4c9c                	lw	a5,24(s1)
    800021ce:	f94783e3          	beq	a5,s4,80002154 <wait+0x44>
        release(&pp->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	ab9fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800021d8:	8756                	mv	a4,s5
    800021da:	bff9                	j	800021b8 <wait+0xa8>
    if(!havekids || killed(p)){
    800021dc:	cf19                	beqz	a4,800021fa <wait+0xea>
    800021de:	854a                	mv	a0,s2
    800021e0:	f07ff0ef          	jal	800020e6 <killed>
    800021e4:	e919                	bnez	a0,800021fa <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e6:	85e2                	mv	a1,s8
    800021e8:	854a                	mv	a0,s2
    800021ea:	cc5ff0ef          	jal	80001eae <sleep>
    havekids = 0;
    800021ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f0:	0000e497          	auipc	s1,0xe
    800021f4:	c8048493          	addi	s1,s1,-896 # 8000fe70 <proc>
    800021f8:	b7e1                	j	800021c0 <wait+0xb0>
      release(&wait_lock);
    800021fa:	0000e517          	auipc	a0,0xe
    800021fe:	85e50513          	addi	a0,a0,-1954 # 8000fa58 <wait_lock>
    80002202:	a8bfe0ef          	jal	80000c8c <release>
      return -1;
    80002206:	59fd                	li	s3,-1
    80002208:	b741                	j	80002188 <wait+0x78>

000000008000220a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	84aa                	mv	s1,a0
    8000221c:	892e                	mv	s2,a1
    8000221e:	89b2                	mv	s3,a2
    80002220:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002222:	ebeff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    80002226:	cc99                	beqz	s1,80002244 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002228:	86d2                	mv	a3,s4
    8000222a:	864e                	mv	a2,s3
    8000222c:	85ca                	mv	a1,s2
    8000222e:	6928                	ld	a0,80(a0)
    80002230:	b22ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6a02                	ld	s4,0(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
    memmove((char *)dst, src, len);
    80002244:	000a061b          	sext.w	a2,s4
    80002248:	85ce                	mv	a1,s3
    8000224a:	854a                	mv	a0,s2
    8000224c:	ad9fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002250:	8526                	mv	a0,s1
    80002252:	b7cd                	j	80002234 <either_copyout+0x2a>

0000000080002254 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	892a                	mv	s2,a0
    80002266:	84ae                	mv	s1,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e74ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    80002270:	cc99                	beqz	s1,8000228e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	baeff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a8ffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyin+0x2a>

000000008000229e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000229e:	715d                	addi	sp,sp,-80
    800022a0:	e486                	sd	ra,72(sp)
    800022a2:	e0a2                	sd	s0,64(sp)
    800022a4:	fc26                	sd	s1,56(sp)
    800022a6:	f84a                	sd	s2,48(sp)
    800022a8:	f44e                	sd	s3,40(sp)
    800022aa:	f052                	sd	s4,32(sp)
    800022ac:	ec56                	sd	s5,24(sp)
    800022ae:	e85a                	sd	s6,16(sp)
    800022b0:	e45e                	sd	s7,8(sp)
    800022b2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	dc450513          	addi	a0,a0,-572 # 80007078 <etext+0x78>
    800022bc:	a06fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022c0:	0000e497          	auipc	s1,0xe
    800022c4:	d0848493          	addi	s1,s1,-760 # 8000ffc8 <proc+0x158>
    800022c8:	00013917          	auipc	s2,0x13
    800022cc:	70090913          	addi	s2,s2,1792 # 800159c8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d2:	00005997          	auipc	s3,0x5
    800022d6:	fce98993          	addi	s3,s3,-50 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022da:	00005a97          	auipc	s5,0x5
    800022de:	fcea8a93          	addi	s5,s5,-50 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022e2:	00005a17          	auipc	s4,0x5
    800022e6:	d96a0a13          	addi	s4,s4,-618 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ea:	00005b97          	auipc	s7,0x5
    800022ee:	49eb8b93          	addi	s7,s7,1182 # 80007788 <states.0>
    800022f2:	a829                	j	8000230c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f4:	ed86a583          	lw	a1,-296(a3)
    800022f8:	8556                	mv	a0,s5
    800022fa:	9c8fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800022fe:	8552                	mv	a0,s4
    80002300:	9c2fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002304:	16848493          	addi	s1,s1,360
    80002308:	03248263          	beq	s1,s2,8000232c <procdump+0x8e>
    if(p->state == UNUSED)
    8000230c:	86a6                	mv	a3,s1
    8000230e:	ec04a783          	lw	a5,-320(s1)
    80002312:	dbed                	beqz	a5,80002304 <procdump+0x66>
      state = "???";
    80002314:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002316:	fcfb6fe3          	bltu	s6,a5,800022f4 <procdump+0x56>
    8000231a:	02079713          	slli	a4,a5,0x20
    8000231e:	01d75793          	srli	a5,a4,0x1d
    80002322:	97de                	add	a5,a5,s7
    80002324:	6390                	ld	a2,0(a5)
    80002326:	f679                	bnez	a2,800022f4 <procdump+0x56>
      state = "???";
    80002328:	864e                	mv	a2,s3
    8000232a:	b7e9                	j	800022f4 <procdump+0x56>
  }
}
    8000232c:	60a6                	ld	ra,72(sp)
    8000232e:	6406                	ld	s0,64(sp)
    80002330:	74e2                	ld	s1,56(sp)
    80002332:	7942                	ld	s2,48(sp)
    80002334:	79a2                	ld	s3,40(sp)
    80002336:	7a02                	ld	s4,32(sp)
    80002338:	6ae2                	ld	s5,24(sp)
    8000233a:	6b42                	ld	s6,16(sp)
    8000233c:	6ba2                	ld	s7,8(sp)
    8000233e:	6161                	addi	sp,sp,80
    80002340:	8082                	ret

0000000080002342 <swtch>:
    80002342:	00153023          	sd	ra,0(a0)
    80002346:	00253423          	sd	sp,8(a0)
    8000234a:	e900                	sd	s0,16(a0)
    8000234c:	ed04                	sd	s1,24(a0)
    8000234e:	03253023          	sd	s2,32(a0)
    80002352:	03353423          	sd	s3,40(a0)
    80002356:	03453823          	sd	s4,48(a0)
    8000235a:	03553c23          	sd	s5,56(a0)
    8000235e:	05653023          	sd	s6,64(a0)
    80002362:	05753423          	sd	s7,72(a0)
    80002366:	05853823          	sd	s8,80(a0)
    8000236a:	05953c23          	sd	s9,88(a0)
    8000236e:	07a53023          	sd	s10,96(a0)
    80002372:	07b53423          	sd	s11,104(a0)
    80002376:	0005b083          	ld	ra,0(a1)
    8000237a:	0085b103          	ld	sp,8(a1)
    8000237e:	6980                	ld	s0,16(a1)
    80002380:	6d84                	ld	s1,24(a1)
    80002382:	0205b903          	ld	s2,32(a1)
    80002386:	0285b983          	ld	s3,40(a1)
    8000238a:	0305ba03          	ld	s4,48(a1)
    8000238e:	0385ba83          	ld	s5,56(a1)
    80002392:	0405bb03          	ld	s6,64(a1)
    80002396:	0485bb83          	ld	s7,72(a1)
    8000239a:	0505bc03          	ld	s8,80(a1)
    8000239e:	0585bc83          	ld	s9,88(a1)
    800023a2:	0605bd03          	ld	s10,96(a1)
    800023a6:	0685bd83          	ld	s11,104(a1)
    800023aa:	8082                	ret

00000000800023ac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ac:	1141                	addi	sp,sp,-16
    800023ae:	e406                	sd	ra,8(sp)
    800023b0:	e022                	sd	s0,0(sp)
    800023b2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023b4:	00005597          	auipc	a1,0x5
    800023b8:	f3458593          	addi	a1,a1,-204 # 800072e8 <etext+0x2e8>
    800023bc:	00013517          	auipc	a0,0x13
    800023c0:	4b450513          	addi	a0,a0,1204 # 80015870 <tickslock>
    800023c4:	fb0fe0ef          	jal	80000b74 <initlock>
}
    800023c8:	60a2                	ld	ra,8(sp)
    800023ca:	6402                	ld	s0,0(sp)
    800023cc:	0141                	addi	sp,sp,16
    800023ce:	8082                	ret

00000000800023d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023d0:	1141                	addi	sp,sp,-16
    800023d2:	e422                	sd	s0,8(sp)
    800023d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023d6:	00003797          	auipc	a5,0x3
    800023da:	eca78793          	addi	a5,a5,-310 # 800052a0 <kernelvec>
    800023de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023e2:	6422                	ld	s0,8(sp)
    800023e4:	0141                	addi	sp,sp,16
    800023e6:	8082                	ret

00000000800023e8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023e8:	1141                	addi	sp,sp,-16
    800023ea:	e406                	sd	ra,8(sp)
    800023ec:	e022                	sd	s0,0(sp)
    800023ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023f0:	cf0ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023fa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023fe:	00004697          	auipc	a3,0x4
    80002402:	c0268693          	addi	a3,a3,-1022 # 80006000 <_trampoline>
    80002406:	00004717          	auipc	a4,0x4
    8000240a:	bfa70713          	addi	a4,a4,-1030 # 80006000 <_trampoline>
    8000240e:	8f15                	sub	a4,a4,a3
    80002410:	040007b7          	lui	a5,0x4000
    80002414:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002416:	07b2                	slli	a5,a5,0xc
    80002418:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000241a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000241e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002420:	18002673          	csrr	a2,satp
    80002424:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002426:	6d30                	ld	a2,88(a0)
    80002428:	6138                	ld	a4,64(a0)
    8000242a:	6585                	lui	a1,0x1
    8000242c:	972e                	add	a4,a4,a1
    8000242e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002430:	6d38                	ld	a4,88(a0)
    80002432:	00000617          	auipc	a2,0x0
    80002436:	11060613          	addi	a2,a2,272 # 80002542 <usertrap>
    8000243a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000243c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000243e:	8612                	mv	a2,tp
    80002440:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002442:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002446:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000244a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000244e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002452:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002454:	6f18                	ld	a4,24(a4)
    80002456:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000245a:	6928                	ld	a0,80(a0)
    8000245c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000245e:	00004717          	auipc	a4,0x4
    80002462:	c3e70713          	addi	a4,a4,-962 # 8000609c <userret>
    80002466:	8f15                	sub	a4,a4,a3
    80002468:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000246a:	577d                	li	a4,-1
    8000246c:	177e                	slli	a4,a4,0x3f
    8000246e:	8d59                	or	a0,a0,a4
    80002470:	9782                	jalr	a5
}
    80002472:	60a2                	ld	ra,8(sp)
    80002474:	6402                	ld	s0,0(sp)
    80002476:	0141                	addi	sp,sp,16
    80002478:	8082                	ret

000000008000247a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000247a:	1101                	addi	sp,sp,-32
    8000247c:	ec06                	sd	ra,24(sp)
    8000247e:	e822                	sd	s0,16(sp)
    80002480:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002482:	c32ff0ef          	jal	800018b4 <cpuid>
    80002486:	cd11                	beqz	a0,800024a2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002488:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000248c:	000f4737          	lui	a4,0xf4
    80002490:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002494:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    80002496:	14d79073          	csrw	stimecmp,a5
}
    8000249a:	60e2                	ld	ra,24(sp)
    8000249c:	6442                	ld	s0,16(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret
    800024a2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024a4:	00013497          	auipc	s1,0x13
    800024a8:	3cc48493          	addi	s1,s1,972 # 80015870 <tickslock>
    800024ac:	8526                	mv	a0,s1
    800024ae:	f46fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800024b2:	00005517          	auipc	a0,0x5
    800024b6:	45e50513          	addi	a0,a0,1118 # 80007910 <ticks>
    800024ba:	411c                	lw	a5,0(a0)
    800024bc:	2785                	addiw	a5,a5,1
    800024be:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024c0:	a3bff0ef          	jal	80001efa <wakeup>
    release(&tickslock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fc6fe0ef          	jal	80000c8c <release>
    800024ca:	64a2                	ld	s1,8(sp)
    800024cc:	bf75                	j	80002488 <clockintr+0xe>

00000000800024ce <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024d6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024da:	57fd                	li	a5,-1
    800024dc:	17fe                	slli	a5,a5,0x3f
    800024de:	07a5                	addi	a5,a5,9
    800024e0:	00f70c63          	beq	a4,a5,800024f8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024e4:	57fd                	li	a5,-1
    800024e6:	17fe                	slli	a5,a5,0x3f
    800024e8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024ea:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024ec:	04f70763          	beq	a4,a5,8000253a <devintr+0x6c>
  }
}
    800024f0:	60e2                	ld	ra,24(sp)
    800024f2:	6442                	ld	s0,16(sp)
    800024f4:	6105                	addi	sp,sp,32
    800024f6:	8082                	ret
    800024f8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024fa:	653020ef          	jal	8000534c <plic_claim>
    800024fe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002500:	47a9                	li	a5,10
    80002502:	00f50963          	beq	a0,a5,80002514 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002506:	4785                	li	a5,1
    80002508:	00f50963          	beq	a0,a5,8000251a <devintr+0x4c>
    return 1;
    8000250c:	4505                	li	a0,1
    } else if(irq){
    8000250e:	e889                	bnez	s1,80002520 <devintr+0x52>
    80002510:	64a2                	ld	s1,8(sp)
    80002512:	bff9                	j	800024f0 <devintr+0x22>
      uartintr();
    80002514:	cf2fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002518:	a819                	j	8000252e <devintr+0x60>
      virtio_disk_intr();
    8000251a:	2f8030ef          	jal	80005812 <virtio_disk_intr>
    if(irq)
    8000251e:	a801                	j	8000252e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002520:	85a6                	mv	a1,s1
    80002522:	00005517          	auipc	a0,0x5
    80002526:	dce50513          	addi	a0,a0,-562 # 800072f0 <etext+0x2f0>
    8000252a:	f99fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    8000252e:	8526                	mv	a0,s1
    80002530:	63d020ef          	jal	8000536c <plic_complete>
    return 1;
    80002534:	4505                	li	a0,1
    80002536:	64a2                	ld	s1,8(sp)
    80002538:	bf65                	j	800024f0 <devintr+0x22>
    clockintr();
    8000253a:	f41ff0ef          	jal	8000247a <clockintr>
    return 2;
    8000253e:	4509                	li	a0,2
    80002540:	bf45                	j	800024f0 <devintr+0x22>

0000000080002542 <usertrap>:
{
    80002542:	1101                	addi	sp,sp,-32
    80002544:	ec06                	sd	ra,24(sp)
    80002546:	e822                	sd	s0,16(sp)
    80002548:	e426                	sd	s1,8(sp)
    8000254a:	e04a                	sd	s2,0(sp)
    8000254c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000254e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002552:	1007f793          	andi	a5,a5,256
    80002556:	ef85                	bnez	a5,8000258e <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002558:	00003797          	auipc	a5,0x3
    8000255c:	d4878793          	addi	a5,a5,-696 # 800052a0 <kernelvec>
    80002560:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002564:	b7cff0ef          	jal	800018e0 <myproc>
    80002568:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000256a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000256c:	14102773          	csrr	a4,sepc
    80002570:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002572:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002576:	47a1                	li	a5,8
    80002578:	02f70163          	beq	a4,a5,8000259a <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    8000257c:	f53ff0ef          	jal	800024ce <devintr>
    80002580:	892a                	mv	s2,a0
    80002582:	c135                	beqz	a0,800025e6 <usertrap+0xa4>
  if(killed(p))
    80002584:	8526                	mv	a0,s1
    80002586:	b61ff0ef          	jal	800020e6 <killed>
    8000258a:	cd1d                	beqz	a0,800025c8 <usertrap+0x86>
    8000258c:	a81d                	j	800025c2 <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000258e:	00005517          	auipc	a0,0x5
    80002592:	d8250513          	addi	a0,a0,-638 # 80007310 <etext+0x310>
    80002596:	9fefe0ef          	jal	80000794 <panic>
    if(killed(p))
    8000259a:	b4dff0ef          	jal	800020e6 <killed>
    8000259e:	e121                	bnez	a0,800025de <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025a0:	6cb8                	ld	a4,88(s1)
    800025a2:	6f1c                	ld	a5,24(a4)
    800025a4:	0791                	addi	a5,a5,4
    800025a6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025ac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025b0:	10079073          	csrw	sstatus,a5
    syscall();
    800025b4:	248000ef          	jal	800027fc <syscall>
  if(killed(p))
    800025b8:	8526                	mv	a0,s1
    800025ba:	b2dff0ef          	jal	800020e6 <killed>
    800025be:	c901                	beqz	a0,800025ce <usertrap+0x8c>
    800025c0:	4901                	li	s2,0
    exit(-1);
    800025c2:	557d                	li	a0,-1
    800025c4:	9f7ff0ef          	jal	80001fba <exit>
  if(which_dev == 2)
    800025c8:	4789                	li	a5,2
    800025ca:	04f90563          	beq	s2,a5,80002614 <usertrap+0xd2>
  usertrapret();
    800025ce:	e1bff0ef          	jal	800023e8 <usertrapret>
}
    800025d2:	60e2                	ld	ra,24(sp)
    800025d4:	6442                	ld	s0,16(sp)
    800025d6:	64a2                	ld	s1,8(sp)
    800025d8:	6902                	ld	s2,0(sp)
    800025da:	6105                	addi	sp,sp,32
    800025dc:	8082                	ret
      exit(-1);
    800025de:	557d                	li	a0,-1
    800025e0:	9dbff0ef          	jal	80001fba <exit>
    800025e4:	bf75                	j	800025a0 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ea:	5890                	lw	a2,48(s1)
    800025ec:	00005517          	auipc	a0,0x5
    800025f0:	d4450513          	addi	a0,a0,-700 # 80007330 <etext+0x330>
    800025f4:	ecffd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025fc:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002600:	00005517          	auipc	a0,0x5
    80002604:	d6050513          	addi	a0,a0,-672 # 80007360 <etext+0x360>
    80002608:	ebbfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    8000260c:	8526                	mv	a0,s1
    8000260e:	ab5ff0ef          	jal	800020c2 <setkilled>
    80002612:	b75d                	j	800025b8 <usertrap+0x76>
    yield();
    80002614:	86fff0ef          	jal	80001e82 <yield>
    80002618:	bf5d                	j	800025ce <usertrap+0x8c>

000000008000261a <kerneltrap>:
{
    8000261a:	7179                	addi	sp,sp,-48
    8000261c:	f406                	sd	ra,40(sp)
    8000261e:	f022                	sd	s0,32(sp)
    80002620:	ec26                	sd	s1,24(sp)
    80002622:	e84a                	sd	s2,16(sp)
    80002624:	e44e                	sd	s3,8(sp)
    80002626:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002628:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000262c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002634:	1004f793          	andi	a5,s1,256
    80002638:	c795                	beqz	a5,80002664 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000263a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000263e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002640:	eb85                	bnez	a5,80002670 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002642:	e8dff0ef          	jal	800024ce <devintr>
    80002646:	c91d                	beqz	a0,8000267c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002648:	4789                	li	a5,2
    8000264a:	04f50a63          	beq	a0,a5,8000269e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000264e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002652:	10049073          	csrw	sstatus,s1
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6145                	addi	sp,sp,48
    80002662:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002664:	00005517          	auipc	a0,0x5
    80002668:	d2450513          	addi	a0,a0,-732 # 80007388 <etext+0x388>
    8000266c:	928fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002670:	00005517          	auipc	a0,0x5
    80002674:	d4050513          	addi	a0,a0,-704 # 800073b0 <etext+0x3b0>
    80002678:	91cfe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000267c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002680:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002684:	85ce                	mv	a1,s3
    80002686:	00005517          	auipc	a0,0x5
    8000268a:	d4a50513          	addi	a0,a0,-694 # 800073d0 <etext+0x3d0>
    8000268e:	e35fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002692:	00005517          	auipc	a0,0x5
    80002696:	d6650513          	addi	a0,a0,-666 # 800073f8 <etext+0x3f8>
    8000269a:	8fafe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000269e:	a42ff0ef          	jal	800018e0 <myproc>
    800026a2:	d555                	beqz	a0,8000264e <kerneltrap+0x34>
    yield();
    800026a4:	fdeff0ef          	jal	80001e82 <yield>
    800026a8:	b75d                	j	8000264e <kerneltrap+0x34>

00000000800026aa <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	e426                	sd	s1,8(sp)
    800026b2:	1000                	addi	s0,sp,32
    800026b4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026b6:	a2aff0ef          	jal	800018e0 <myproc>
  switch (n) {
    800026ba:	4795                	li	a5,5
    800026bc:	0497e163          	bltu	a5,s1,800026fe <argraw+0x54>
    800026c0:	048a                	slli	s1,s1,0x2
    800026c2:	00005717          	auipc	a4,0x5
    800026c6:	0f670713          	addi	a4,a4,246 # 800077b8 <states.0+0x30>
    800026ca:	94ba                	add	s1,s1,a4
    800026cc:	409c                	lw	a5,0(s1)
    800026ce:	97ba                	add	a5,a5,a4
    800026d0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026d2:	6d3c                	ld	a5,88(a0)
    800026d4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026d6:	60e2                	ld	ra,24(sp)
    800026d8:	6442                	ld	s0,16(sp)
    800026da:	64a2                	ld	s1,8(sp)
    800026dc:	6105                	addi	sp,sp,32
    800026de:	8082                	ret
    return p->trapframe->a1;
    800026e0:	6d3c                	ld	a5,88(a0)
    800026e2:	7fa8                	ld	a0,120(a5)
    800026e4:	bfcd                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a2;
    800026e6:	6d3c                	ld	a5,88(a0)
    800026e8:	63c8                	ld	a0,128(a5)
    800026ea:	b7f5                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a3;
    800026ec:	6d3c                	ld	a5,88(a0)
    800026ee:	67c8                	ld	a0,136(a5)
    800026f0:	b7dd                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a4;
    800026f2:	6d3c                	ld	a5,88(a0)
    800026f4:	6bc8                	ld	a0,144(a5)
    800026f6:	b7c5                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a5;
    800026f8:	6d3c                	ld	a5,88(a0)
    800026fa:	6fc8                	ld	a0,152(a5)
    800026fc:	bfe9                	j	800026d6 <argraw+0x2c>
  panic("argraw");
    800026fe:	00005517          	auipc	a0,0x5
    80002702:	d0a50513          	addi	a0,a0,-758 # 80007408 <etext+0x408>
    80002706:	88efe0ef          	jal	80000794 <panic>

000000008000270a <fetchaddr>:
{
    8000270a:	1101                	addi	sp,sp,-32
    8000270c:	ec06                	sd	ra,24(sp)
    8000270e:	e822                	sd	s0,16(sp)
    80002710:	e426                	sd	s1,8(sp)
    80002712:	e04a                	sd	s2,0(sp)
    80002714:	1000                	addi	s0,sp,32
    80002716:	84aa                	mv	s1,a0
    80002718:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000271a:	9c6ff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000271e:	653c                	ld	a5,72(a0)
    80002720:	02f4f663          	bgeu	s1,a5,8000274c <fetchaddr+0x42>
    80002724:	00848713          	addi	a4,s1,8
    80002728:	02e7e463          	bltu	a5,a4,80002750 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000272c:	46a1                	li	a3,8
    8000272e:	8626                	mv	a2,s1
    80002730:	85ca                	mv	a1,s2
    80002732:	6928                	ld	a0,80(a0)
    80002734:	ef5fe0ef          	jal	80001628 <copyin>
    80002738:	00a03533          	snez	a0,a0
    8000273c:	40a00533          	neg	a0,a0
}
    80002740:	60e2                	ld	ra,24(sp)
    80002742:	6442                	ld	s0,16(sp)
    80002744:	64a2                	ld	s1,8(sp)
    80002746:	6902                	ld	s2,0(sp)
    80002748:	6105                	addi	sp,sp,32
    8000274a:	8082                	ret
    return -1;
    8000274c:	557d                	li	a0,-1
    8000274e:	bfcd                	j	80002740 <fetchaddr+0x36>
    80002750:	557d                	li	a0,-1
    80002752:	b7fd                	j	80002740 <fetchaddr+0x36>

0000000080002754 <fetchstr>:
{
    80002754:	7179                	addi	sp,sp,-48
    80002756:	f406                	sd	ra,40(sp)
    80002758:	f022                	sd	s0,32(sp)
    8000275a:	ec26                	sd	s1,24(sp)
    8000275c:	e84a                	sd	s2,16(sp)
    8000275e:	e44e                	sd	s3,8(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	892a                	mv	s2,a0
    80002764:	84ae                	mv	s1,a1
    80002766:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002768:	978ff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000276c:	86ce                	mv	a3,s3
    8000276e:	864a                	mv	a2,s2
    80002770:	85a6                	mv	a1,s1
    80002772:	6928                	ld	a0,80(a0)
    80002774:	f3bfe0ef          	jal	800016ae <copyinstr>
    80002778:	00054c63          	bltz	a0,80002790 <fetchstr+0x3c>
  return strlen(buf);
    8000277c:	8526                	mv	a0,s1
    8000277e:	ebafe0ef          	jal	80000e38 <strlen>
}
    80002782:	70a2                	ld	ra,40(sp)
    80002784:	7402                	ld	s0,32(sp)
    80002786:	64e2                	ld	s1,24(sp)
    80002788:	6942                	ld	s2,16(sp)
    8000278a:	69a2                	ld	s3,8(sp)
    8000278c:	6145                	addi	sp,sp,48
    8000278e:	8082                	ret
    return -1;
    80002790:	557d                	li	a0,-1
    80002792:	bfc5                	j	80002782 <fetchstr+0x2e>

0000000080002794 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002794:	1101                	addi	sp,sp,-32
    80002796:	ec06                	sd	ra,24(sp)
    80002798:	e822                	sd	s0,16(sp)
    8000279a:	e426                	sd	s1,8(sp)
    8000279c:	1000                	addi	s0,sp,32
    8000279e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027a0:	f0bff0ef          	jal	800026aa <argraw>
    800027a4:	c088                	sw	a0,0(s1)
}
    800027a6:	60e2                	ld	ra,24(sp)
    800027a8:	6442                	ld	s0,16(sp)
    800027aa:	64a2                	ld	s1,8(sp)
    800027ac:	6105                	addi	sp,sp,32
    800027ae:	8082                	ret

00000000800027b0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027b0:	1101                	addi	sp,sp,-32
    800027b2:	ec06                	sd	ra,24(sp)
    800027b4:	e822                	sd	s0,16(sp)
    800027b6:	e426                	sd	s1,8(sp)
    800027b8:	1000                	addi	s0,sp,32
    800027ba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027bc:	eefff0ef          	jal	800026aa <argraw>
    800027c0:	e088                	sd	a0,0(s1)
}
    800027c2:	60e2                	ld	ra,24(sp)
    800027c4:	6442                	ld	s0,16(sp)
    800027c6:	64a2                	ld	s1,8(sp)
    800027c8:	6105                	addi	sp,sp,32
    800027ca:	8082                	ret

00000000800027cc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027cc:	7179                	addi	sp,sp,-48
    800027ce:	f406                	sd	ra,40(sp)
    800027d0:	f022                	sd	s0,32(sp)
    800027d2:	ec26                	sd	s1,24(sp)
    800027d4:	e84a                	sd	s2,16(sp)
    800027d6:	1800                	addi	s0,sp,48
    800027d8:	84ae                	mv	s1,a1
    800027da:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800027dc:	fd840593          	addi	a1,s0,-40
    800027e0:	fd1ff0ef          	jal	800027b0 <argaddr>
  return fetchstr(addr, buf, max);
    800027e4:	864a                	mv	a2,s2
    800027e6:	85a6                	mv	a1,s1
    800027e8:	fd843503          	ld	a0,-40(s0)
    800027ec:	f69ff0ef          	jal	80002754 <fetchstr>
}
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	6145                	addi	sp,sp,48
    800027fa:	8082                	ret

00000000800027fc <syscall>:

};

void
syscall(void)
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	e04a                	sd	s2,0(sp)
    80002806:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002808:	8d8ff0ef          	jal	800018e0 <myproc>
    8000280c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000280e:	05853903          	ld	s2,88(a0)
    80002812:	0a893783          	ld	a5,168(s2)
    80002816:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000281a:	37fd                	addiw	a5,a5,-1
    8000281c:	4755                	li	a4,21
    8000281e:	00f76f63          	bltu	a4,a5,8000283c <syscall+0x40>
    80002822:	00369713          	slli	a4,a3,0x3
    80002826:	00005797          	auipc	a5,0x5
    8000282a:	faa78793          	addi	a5,a5,-86 # 800077d0 <syscalls>
    8000282e:	97ba                	add	a5,a5,a4
    80002830:	639c                	ld	a5,0(a5)
    80002832:	c789                	beqz	a5,8000283c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002834:	9782                	jalr	a5
    80002836:	06a93823          	sd	a0,112(s2)
    8000283a:	a829                	j	80002854 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000283c:	15848613          	addi	a2,s1,344
    80002840:	588c                	lw	a1,48(s1)
    80002842:	00005517          	auipc	a0,0x5
    80002846:	bce50513          	addi	a0,a0,-1074 # 80007410 <etext+0x410>
    8000284a:	c79fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000284e:	6cbc                	ld	a5,88(s1)
    80002850:	577d                	li	a4,-1
    80002852:	fbb8                	sd	a4,112(a5)
  }
}
    80002854:	60e2                	ld	ra,24(sp)
    80002856:	6442                	ld	s0,16(sp)
    80002858:	64a2                	ld	s1,8(sp)
    8000285a:	6902                	ld	s2,0(sp)
    8000285c:	6105                	addi	sp,sp,32
    8000285e:	8082                	ret

0000000080002860 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002860:	1101                	addi	sp,sp,-32
    80002862:	ec06                	sd	ra,24(sp)
    80002864:	e822                	sd	s0,16(sp)
    80002866:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002868:	fec40593          	addi	a1,s0,-20
    8000286c:	4501                	li	a0,0
    8000286e:	f27ff0ef          	jal	80002794 <argint>
  exit(n);
    80002872:	fec42503          	lw	a0,-20(s0)
    80002876:	f44ff0ef          	jal	80001fba <exit>
  return 0;  // not reached
}
    8000287a:	4501                	li	a0,0
    8000287c:	60e2                	ld	ra,24(sp)
    8000287e:	6442                	ld	s0,16(sp)
    80002880:	6105                	addi	sp,sp,32
    80002882:	8082                	ret

0000000080002884 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002884:	1141                	addi	sp,sp,-16
    80002886:	e406                	sd	ra,8(sp)
    80002888:	e022                	sd	s0,0(sp)
    8000288a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000288c:	854ff0ef          	jal	800018e0 <myproc>
}
    80002890:	5908                	lw	a0,48(a0)
    80002892:	60a2                	ld	ra,8(sp)
    80002894:	6402                	ld	s0,0(sp)
    80002896:	0141                	addi	sp,sp,16
    80002898:	8082                	ret

000000008000289a <sys_fork>:

uint64
sys_fork(void)
{
    8000289a:	1141                	addi	sp,sp,-16
    8000289c:	e406                	sd	ra,8(sp)
    8000289e:	e022                	sd	s0,0(sp)
    800028a0:	0800                	addi	s0,sp,16
  return fork();
    800028a2:	b64ff0ef          	jal	80001c06 <fork>
}
    800028a6:	60a2                	ld	ra,8(sp)
    800028a8:	6402                	ld	s0,0(sp)
    800028aa:	0141                	addi	sp,sp,16
    800028ac:	8082                	ret

00000000800028ae <sys_wait>:

uint64
sys_wait(void)
{
    800028ae:	1101                	addi	sp,sp,-32
    800028b0:	ec06                	sd	ra,24(sp)
    800028b2:	e822                	sd	s0,16(sp)
    800028b4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028b6:	fe840593          	addi	a1,s0,-24
    800028ba:	4501                	li	a0,0
    800028bc:	ef5ff0ef          	jal	800027b0 <argaddr>
  return wait(p);
    800028c0:	fe843503          	ld	a0,-24(s0)
    800028c4:	84dff0ef          	jal	80002110 <wait>
}
    800028c8:	60e2                	ld	ra,24(sp)
    800028ca:	6442                	ld	s0,16(sp)
    800028cc:	6105                	addi	sp,sp,32
    800028ce:	8082                	ret

00000000800028d0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028d0:	7179                	addi	sp,sp,-48
    800028d2:	f406                	sd	ra,40(sp)
    800028d4:	f022                	sd	s0,32(sp)
    800028d6:	ec26                	sd	s1,24(sp)
    800028d8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800028da:	fdc40593          	addi	a1,s0,-36
    800028de:	4501                	li	a0,0
    800028e0:	eb5ff0ef          	jal	80002794 <argint>
  addr = myproc()->sz;
    800028e4:	ffdfe0ef          	jal	800018e0 <myproc>
    800028e8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800028ea:	fdc42503          	lw	a0,-36(s0)
    800028ee:	ac8ff0ef          	jal	80001bb6 <growproc>
    800028f2:	00054863          	bltz	a0,80002902 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800028f6:	8526                	mv	a0,s1
    800028f8:	70a2                	ld	ra,40(sp)
    800028fa:	7402                	ld	s0,32(sp)
    800028fc:	64e2                	ld	s1,24(sp)
    800028fe:	6145                	addi	sp,sp,48
    80002900:	8082                	ret
    return -1;
    80002902:	54fd                	li	s1,-1
    80002904:	bfcd                	j	800028f6 <sys_sbrk+0x26>

0000000080002906 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002906:	7139                	addi	sp,sp,-64
    80002908:	fc06                	sd	ra,56(sp)
    8000290a:	f822                	sd	s0,48(sp)
    8000290c:	f04a                	sd	s2,32(sp)
    8000290e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002910:	fcc40593          	addi	a1,s0,-52
    80002914:	4501                	li	a0,0
    80002916:	e7fff0ef          	jal	80002794 <argint>
  if(n < 0)
    8000291a:	fcc42783          	lw	a5,-52(s0)
    8000291e:	0607c763          	bltz	a5,8000298c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002922:	00013517          	auipc	a0,0x13
    80002926:	f4e50513          	addi	a0,a0,-178 # 80015870 <tickslock>
    8000292a:	acafe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    8000292e:	00005917          	auipc	s2,0x5
    80002932:	fe292903          	lw	s2,-30(s2) # 80007910 <ticks>
  while(ticks - ticks0 < n){
    80002936:	fcc42783          	lw	a5,-52(s0)
    8000293a:	cf8d                	beqz	a5,80002974 <sys_sleep+0x6e>
    8000293c:	f426                	sd	s1,40(sp)
    8000293e:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002940:	00013997          	auipc	s3,0x13
    80002944:	f3098993          	addi	s3,s3,-208 # 80015870 <tickslock>
    80002948:	00005497          	auipc	s1,0x5
    8000294c:	fc848493          	addi	s1,s1,-56 # 80007910 <ticks>
    if(killed(myproc())){
    80002950:	f91fe0ef          	jal	800018e0 <myproc>
    80002954:	f92ff0ef          	jal	800020e6 <killed>
    80002958:	ed0d                	bnez	a0,80002992 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000295a:	85ce                	mv	a1,s3
    8000295c:	8526                	mv	a0,s1
    8000295e:	d50ff0ef          	jal	80001eae <sleep>
  while(ticks - ticks0 < n){
    80002962:	409c                	lw	a5,0(s1)
    80002964:	412787bb          	subw	a5,a5,s2
    80002968:	fcc42703          	lw	a4,-52(s0)
    8000296c:	fee7e2e3          	bltu	a5,a4,80002950 <sys_sleep+0x4a>
    80002970:	74a2                	ld	s1,40(sp)
    80002972:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002974:	00013517          	auipc	a0,0x13
    80002978:	efc50513          	addi	a0,a0,-260 # 80015870 <tickslock>
    8000297c:	b10fe0ef          	jal	80000c8c <release>
  return 0;
    80002980:	4501                	li	a0,0
}
    80002982:	70e2                	ld	ra,56(sp)
    80002984:	7442                	ld	s0,48(sp)
    80002986:	7902                	ld	s2,32(sp)
    80002988:	6121                	addi	sp,sp,64
    8000298a:	8082                	ret
    n = 0;
    8000298c:	fc042623          	sw	zero,-52(s0)
    80002990:	bf49                	j	80002922 <sys_sleep+0x1c>
      release(&tickslock);
    80002992:	00013517          	auipc	a0,0x13
    80002996:	ede50513          	addi	a0,a0,-290 # 80015870 <tickslock>
    8000299a:	af2fe0ef          	jal	80000c8c <release>
      return -1;
    8000299e:	557d                	li	a0,-1
    800029a0:	74a2                	ld	s1,40(sp)
    800029a2:	69e2                	ld	s3,24(sp)
    800029a4:	bff9                	j	80002982 <sys_sleep+0x7c>

00000000800029a6 <sys_kill>:

uint64
sys_kill(void)
{
    800029a6:	1101                	addi	sp,sp,-32
    800029a8:	ec06                	sd	ra,24(sp)
    800029aa:	e822                	sd	s0,16(sp)
    800029ac:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029ae:	fec40593          	addi	a1,s0,-20
    800029b2:	4501                	li	a0,0
    800029b4:	de1ff0ef          	jal	80002794 <argint>
  return kill(pid);
    800029b8:	fec42503          	lw	a0,-20(s0)
    800029bc:	ea0ff0ef          	jal	8000205c <kill>
}
    800029c0:	60e2                	ld	ra,24(sp)
    800029c2:	6442                	ld	s0,16(sp)
    800029c4:	6105                	addi	sp,sp,32
    800029c6:	8082                	ret

00000000800029c8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800029c8:	1101                	addi	sp,sp,-32
    800029ca:	ec06                	sd	ra,24(sp)
    800029cc:	e822                	sd	s0,16(sp)
    800029ce:	e426                	sd	s1,8(sp)
    800029d0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800029d2:	00013517          	auipc	a0,0x13
    800029d6:	e9e50513          	addi	a0,a0,-354 # 80015870 <tickslock>
    800029da:	a1afe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    800029de:	00005497          	auipc	s1,0x5
    800029e2:	f324a483          	lw	s1,-206(s1) # 80007910 <ticks>
  release(&tickslock);
    800029e6:	00013517          	auipc	a0,0x13
    800029ea:	e8a50513          	addi	a0,a0,-374 # 80015870 <tickslock>
    800029ee:	a9efe0ef          	jal	80000c8c <release>
  return xticks;
}
    800029f2:	02049513          	slli	a0,s1,0x20
    800029f6:	9101                	srli	a0,a0,0x20
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret

0000000080002a02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a02:	7179                	addi	sp,sp,-48
    80002a04:	f406                	sd	ra,40(sp)
    80002a06:	f022                	sd	s0,32(sp)
    80002a08:	ec26                	sd	s1,24(sp)
    80002a0a:	e84a                	sd	s2,16(sp)
    80002a0c:	e44e                	sd	s3,8(sp)
    80002a0e:	e052                	sd	s4,0(sp)
    80002a10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a12:	00005597          	auipc	a1,0x5
    80002a16:	a1e58593          	addi	a1,a1,-1506 # 80007430 <etext+0x430>
    80002a1a:	00013517          	auipc	a0,0x13
    80002a1e:	e6e50513          	addi	a0,a0,-402 # 80015888 <bcache>
    80002a22:	952fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a26:	0001b797          	auipc	a5,0x1b
    80002a2a:	e6278793          	addi	a5,a5,-414 # 8001d888 <bcache+0x8000>
    80002a2e:	0001b717          	auipc	a4,0x1b
    80002a32:	0c270713          	addi	a4,a4,194 # 8001daf0 <bcache+0x8268>
    80002a36:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002a3a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a3e:	00013497          	auipc	s1,0x13
    80002a42:	e6248493          	addi	s1,s1,-414 # 800158a0 <bcache+0x18>
    b->next = bcache.head.next;
    80002a46:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002a48:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002a4a:	00005a17          	auipc	s4,0x5
    80002a4e:	9eea0a13          	addi	s4,s4,-1554 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002a52:	2b893783          	ld	a5,696(s2)
    80002a56:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002a58:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002a5c:	85d2                	mv	a1,s4
    80002a5e:	01048513          	addi	a0,s1,16
    80002a62:	290010ef          	jal	80003cf2 <initsleeplock>
    bcache.head.next->prev = b;
    80002a66:	2b893783          	ld	a5,696(s2)
    80002a6a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002a6c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a70:	45848493          	addi	s1,s1,1112
    80002a74:	fd349fe3          	bne	s1,s3,80002a52 <binit+0x50>
  }
}
    80002a78:	70a2                	ld	ra,40(sp)
    80002a7a:	7402                	ld	s0,32(sp)
    80002a7c:	64e2                	ld	s1,24(sp)
    80002a7e:	6942                	ld	s2,16(sp)
    80002a80:	69a2                	ld	s3,8(sp)
    80002a82:	6a02                	ld	s4,0(sp)
    80002a84:	6145                	addi	sp,sp,48
    80002a86:	8082                	ret

0000000080002a88 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002a88:	7179                	addi	sp,sp,-48
    80002a8a:	f406                	sd	ra,40(sp)
    80002a8c:	f022                	sd	s0,32(sp)
    80002a8e:	ec26                	sd	s1,24(sp)
    80002a90:	e84a                	sd	s2,16(sp)
    80002a92:	e44e                	sd	s3,8(sp)
    80002a94:	1800                	addi	s0,sp,48
    80002a96:	892a                	mv	s2,a0
    80002a98:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002a9a:	00013517          	auipc	a0,0x13
    80002a9e:	dee50513          	addi	a0,a0,-530 # 80015888 <bcache>
    80002aa2:	952fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002aa6:	0001b497          	auipc	s1,0x1b
    80002aaa:	09a4b483          	ld	s1,154(s1) # 8001db40 <bcache+0x82b8>
    80002aae:	0001b797          	auipc	a5,0x1b
    80002ab2:	04278793          	addi	a5,a5,66 # 8001daf0 <bcache+0x8268>
    80002ab6:	02f48b63          	beq	s1,a5,80002aec <bread+0x64>
    80002aba:	873e                	mv	a4,a5
    80002abc:	a021                	j	80002ac4 <bread+0x3c>
    80002abe:	68a4                	ld	s1,80(s1)
    80002ac0:	02e48663          	beq	s1,a4,80002aec <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ac4:	449c                	lw	a5,8(s1)
    80002ac6:	ff279ce3          	bne	a5,s2,80002abe <bread+0x36>
    80002aca:	44dc                	lw	a5,12(s1)
    80002acc:	ff3799e3          	bne	a5,s3,80002abe <bread+0x36>
      b->refcnt++;
    80002ad0:	40bc                	lw	a5,64(s1)
    80002ad2:	2785                	addiw	a5,a5,1
    80002ad4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ad6:	00013517          	auipc	a0,0x13
    80002ada:	db250513          	addi	a0,a0,-590 # 80015888 <bcache>
    80002ade:	9aefe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002ae2:	01048513          	addi	a0,s1,16
    80002ae6:	242010ef          	jal	80003d28 <acquiresleep>
      return b;
    80002aea:	a889                	j	80002b3c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002aec:	0001b497          	auipc	s1,0x1b
    80002af0:	04c4b483          	ld	s1,76(s1) # 8001db38 <bcache+0x82b0>
    80002af4:	0001b797          	auipc	a5,0x1b
    80002af8:	ffc78793          	addi	a5,a5,-4 # 8001daf0 <bcache+0x8268>
    80002afc:	00f48863          	beq	s1,a5,80002b0c <bread+0x84>
    80002b00:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b02:	40bc                	lw	a5,64(s1)
    80002b04:	cb91                	beqz	a5,80002b18 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b06:	64a4                	ld	s1,72(s1)
    80002b08:	fee49de3          	bne	s1,a4,80002b02 <bread+0x7a>
  panic("bget: no buffers");
    80002b0c:	00005517          	auipc	a0,0x5
    80002b10:	93450513          	addi	a0,a0,-1740 # 80007440 <etext+0x440>
    80002b14:	c81fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002b18:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b1c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b20:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b24:	4785                	li	a5,1
    80002b26:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b28:	00013517          	auipc	a0,0x13
    80002b2c:	d6050513          	addi	a0,a0,-672 # 80015888 <bcache>
    80002b30:	95cfe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b34:	01048513          	addi	a0,s1,16
    80002b38:	1f0010ef          	jal	80003d28 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002b3c:	409c                	lw	a5,0(s1)
    80002b3e:	cb89                	beqz	a5,80002b50 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002b40:	8526                	mv	a0,s1
    80002b42:	70a2                	ld	ra,40(sp)
    80002b44:	7402                	ld	s0,32(sp)
    80002b46:	64e2                	ld	s1,24(sp)
    80002b48:	6942                	ld	s2,16(sp)
    80002b4a:	69a2                	ld	s3,8(sp)
    80002b4c:	6145                	addi	sp,sp,48
    80002b4e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002b50:	4581                	li	a1,0
    80002b52:	8526                	mv	a0,s1
    80002b54:	2ad020ef          	jal	80005600 <virtio_disk_rw>
    b->valid = 1;
    80002b58:	4785                	li	a5,1
    80002b5a:	c09c                	sw	a5,0(s1)
  return b;
    80002b5c:	b7d5                	j	80002b40 <bread+0xb8>

0000000080002b5e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002b5e:	1101                	addi	sp,sp,-32
    80002b60:	ec06                	sd	ra,24(sp)
    80002b62:	e822                	sd	s0,16(sp)
    80002b64:	e426                	sd	s1,8(sp)
    80002b66:	1000                	addi	s0,sp,32
    80002b68:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b6a:	0541                	addi	a0,a0,16
    80002b6c:	23a010ef          	jal	80003da6 <holdingsleep>
    80002b70:	c911                	beqz	a0,80002b84 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002b72:	4585                	li	a1,1
    80002b74:	8526                	mv	a0,s1
    80002b76:	28b020ef          	jal	80005600 <virtio_disk_rw>
}
    80002b7a:	60e2                	ld	ra,24(sp)
    80002b7c:	6442                	ld	s0,16(sp)
    80002b7e:	64a2                	ld	s1,8(sp)
    80002b80:	6105                	addi	sp,sp,32
    80002b82:	8082                	ret
    panic("bwrite");
    80002b84:	00005517          	auipc	a0,0x5
    80002b88:	8d450513          	addi	a0,a0,-1836 # 80007458 <etext+0x458>
    80002b8c:	c09fd0ef          	jal	80000794 <panic>

0000000080002b90 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002b90:	1101                	addi	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	e04a                	sd	s2,0(sp)
    80002b9a:	1000                	addi	s0,sp,32
    80002b9c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b9e:	01050913          	addi	s2,a0,16
    80002ba2:	854a                	mv	a0,s2
    80002ba4:	202010ef          	jal	80003da6 <holdingsleep>
    80002ba8:	c135                	beqz	a0,80002c0c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002baa:	854a                	mv	a0,s2
    80002bac:	1c2010ef          	jal	80003d6e <releasesleep>

  acquire(&bcache.lock);
    80002bb0:	00013517          	auipc	a0,0x13
    80002bb4:	cd850513          	addi	a0,a0,-808 # 80015888 <bcache>
    80002bb8:	83cfe0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002bbc:	40bc                	lw	a5,64(s1)
    80002bbe:	37fd                	addiw	a5,a5,-1
    80002bc0:	0007871b          	sext.w	a4,a5
    80002bc4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002bc6:	e71d                	bnez	a4,80002bf4 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002bc8:	68b8                	ld	a4,80(s1)
    80002bca:	64bc                	ld	a5,72(s1)
    80002bcc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002bce:	68b8                	ld	a4,80(s1)
    80002bd0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002bd2:	0001b797          	auipc	a5,0x1b
    80002bd6:	cb678793          	addi	a5,a5,-842 # 8001d888 <bcache+0x8000>
    80002bda:	2b87b703          	ld	a4,696(a5)
    80002bde:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002be0:	0001b717          	auipc	a4,0x1b
    80002be4:	f1070713          	addi	a4,a4,-240 # 8001daf0 <bcache+0x8268>
    80002be8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002bea:	2b87b703          	ld	a4,696(a5)
    80002bee:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002bf0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002bf4:	00013517          	auipc	a0,0x13
    80002bf8:	c9450513          	addi	a0,a0,-876 # 80015888 <bcache>
    80002bfc:	890fe0ef          	jal	80000c8c <release>
}
    80002c00:	60e2                	ld	ra,24(sp)
    80002c02:	6442                	ld	s0,16(sp)
    80002c04:	64a2                	ld	s1,8(sp)
    80002c06:	6902                	ld	s2,0(sp)
    80002c08:	6105                	addi	sp,sp,32
    80002c0a:	8082                	ret
    panic("brelse");
    80002c0c:	00005517          	auipc	a0,0x5
    80002c10:	85450513          	addi	a0,a0,-1964 # 80007460 <etext+0x460>
    80002c14:	b81fd0ef          	jal	80000794 <panic>

0000000080002c18 <bpin>:

void
bpin(struct buf *b) {
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	e426                	sd	s1,8(sp)
    80002c20:	1000                	addi	s0,sp,32
    80002c22:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c24:	00013517          	auipc	a0,0x13
    80002c28:	c6450513          	addi	a0,a0,-924 # 80015888 <bcache>
    80002c2c:	fc9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002c30:	40bc                	lw	a5,64(s1)
    80002c32:	2785                	addiw	a5,a5,1
    80002c34:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c36:	00013517          	auipc	a0,0x13
    80002c3a:	c5250513          	addi	a0,a0,-942 # 80015888 <bcache>
    80002c3e:	84efe0ef          	jal	80000c8c <release>
}
    80002c42:	60e2                	ld	ra,24(sp)
    80002c44:	6442                	ld	s0,16(sp)
    80002c46:	64a2                	ld	s1,8(sp)
    80002c48:	6105                	addi	sp,sp,32
    80002c4a:	8082                	ret

0000000080002c4c <bunpin>:

void
bunpin(struct buf *b) {
    80002c4c:	1101                	addi	sp,sp,-32
    80002c4e:	ec06                	sd	ra,24(sp)
    80002c50:	e822                	sd	s0,16(sp)
    80002c52:	e426                	sd	s1,8(sp)
    80002c54:	1000                	addi	s0,sp,32
    80002c56:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c58:	00013517          	auipc	a0,0x13
    80002c5c:	c3050513          	addi	a0,a0,-976 # 80015888 <bcache>
    80002c60:	f95fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c64:	40bc                	lw	a5,64(s1)
    80002c66:	37fd                	addiw	a5,a5,-1
    80002c68:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c6a:	00013517          	auipc	a0,0x13
    80002c6e:	c1e50513          	addi	a0,a0,-994 # 80015888 <bcache>
    80002c72:	81afe0ef          	jal	80000c8c <release>
}
    80002c76:	60e2                	ld	ra,24(sp)
    80002c78:	6442                	ld	s0,16(sp)
    80002c7a:	64a2                	ld	s1,8(sp)
    80002c7c:	6105                	addi	sp,sp,32
    80002c7e:	8082                	ret

0000000080002c80 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002c80:	1101                	addi	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	e426                	sd	s1,8(sp)
    80002c88:	e04a                	sd	s2,0(sp)
    80002c8a:	1000                	addi	s0,sp,32
    80002c8c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002c8e:	00d5d59b          	srliw	a1,a1,0xd
    80002c92:	0001b797          	auipc	a5,0x1b
    80002c96:	2d27a783          	lw	a5,722(a5) # 8001df64 <sb+0x1c>
    80002c9a:	9dbd                	addw	a1,a1,a5
    80002c9c:	dedff0ef          	jal	80002a88 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ca0:	0074f713          	andi	a4,s1,7
    80002ca4:	4785                	li	a5,1
    80002ca6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002caa:	14ce                	slli	s1,s1,0x33
    80002cac:	90d9                	srli	s1,s1,0x36
    80002cae:	00950733          	add	a4,a0,s1
    80002cb2:	05874703          	lbu	a4,88(a4)
    80002cb6:	00e7f6b3          	and	a3,a5,a4
    80002cba:	c29d                	beqz	a3,80002ce0 <bfree+0x60>
    80002cbc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002cbe:	94aa                	add	s1,s1,a0
    80002cc0:	fff7c793          	not	a5,a5
    80002cc4:	8f7d                	and	a4,a4,a5
    80002cc6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002cca:	759000ef          	jal	80003c22 <log_write>
  brelse(bp);
    80002cce:	854a                	mv	a0,s2
    80002cd0:	ec1ff0ef          	jal	80002b90 <brelse>
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6902                	ld	s2,0(sp)
    80002cdc:	6105                	addi	sp,sp,32
    80002cde:	8082                	ret
    panic("freeing free block");
    80002ce0:	00004517          	auipc	a0,0x4
    80002ce4:	78850513          	addi	a0,a0,1928 # 80007468 <etext+0x468>
    80002ce8:	aadfd0ef          	jal	80000794 <panic>

0000000080002cec <balloc>:
{
    80002cec:	711d                	addi	sp,sp,-96
    80002cee:	ec86                	sd	ra,88(sp)
    80002cf0:	e8a2                	sd	s0,80(sp)
    80002cf2:	e4a6                	sd	s1,72(sp)
    80002cf4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002cf6:	0001b797          	auipc	a5,0x1b
    80002cfa:	2567a783          	lw	a5,598(a5) # 8001df4c <sb+0x4>
    80002cfe:	0e078f63          	beqz	a5,80002dfc <balloc+0x110>
    80002d02:	e0ca                	sd	s2,64(sp)
    80002d04:	fc4e                	sd	s3,56(sp)
    80002d06:	f852                	sd	s4,48(sp)
    80002d08:	f456                	sd	s5,40(sp)
    80002d0a:	f05a                	sd	s6,32(sp)
    80002d0c:	ec5e                	sd	s7,24(sp)
    80002d0e:	e862                	sd	s8,16(sp)
    80002d10:	e466                	sd	s9,8(sp)
    80002d12:	8baa                	mv	s7,a0
    80002d14:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d16:	0001bb17          	auipc	s6,0x1b
    80002d1a:	232b0b13          	addi	s6,s6,562 # 8001df48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d1e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002d20:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d22:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002d24:	6c89                	lui	s9,0x2
    80002d26:	a0b5                	j	80002d92 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002d28:	97ca                	add	a5,a5,s2
    80002d2a:	8e55                	or	a2,a2,a3
    80002d2c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d30:	854a                	mv	a0,s2
    80002d32:	6f1000ef          	jal	80003c22 <log_write>
        brelse(bp);
    80002d36:	854a                	mv	a0,s2
    80002d38:	e59ff0ef          	jal	80002b90 <brelse>
  bp = bread(dev, bno);
    80002d3c:	85a6                	mv	a1,s1
    80002d3e:	855e                	mv	a0,s7
    80002d40:	d49ff0ef          	jal	80002a88 <bread>
    80002d44:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002d46:	40000613          	li	a2,1024
    80002d4a:	4581                	li	a1,0
    80002d4c:	05850513          	addi	a0,a0,88
    80002d50:	f79fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002d54:	854a                	mv	a0,s2
    80002d56:	6cd000ef          	jal	80003c22 <log_write>
  brelse(bp);
    80002d5a:	854a                	mv	a0,s2
    80002d5c:	e35ff0ef          	jal	80002b90 <brelse>
}
    80002d60:	6906                	ld	s2,64(sp)
    80002d62:	79e2                	ld	s3,56(sp)
    80002d64:	7a42                	ld	s4,48(sp)
    80002d66:	7aa2                	ld	s5,40(sp)
    80002d68:	7b02                	ld	s6,32(sp)
    80002d6a:	6be2                	ld	s7,24(sp)
    80002d6c:	6c42                	ld	s8,16(sp)
    80002d6e:	6ca2                	ld	s9,8(sp)
}
    80002d70:	8526                	mv	a0,s1
    80002d72:	60e6                	ld	ra,88(sp)
    80002d74:	6446                	ld	s0,80(sp)
    80002d76:	64a6                	ld	s1,72(sp)
    80002d78:	6125                	addi	sp,sp,96
    80002d7a:	8082                	ret
    brelse(bp);
    80002d7c:	854a                	mv	a0,s2
    80002d7e:	e13ff0ef          	jal	80002b90 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002d82:	015c87bb          	addw	a5,s9,s5
    80002d86:	00078a9b          	sext.w	s5,a5
    80002d8a:	004b2703          	lw	a4,4(s6)
    80002d8e:	04eaff63          	bgeu	s5,a4,80002dec <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002d92:	41fad79b          	sraiw	a5,s5,0x1f
    80002d96:	0137d79b          	srliw	a5,a5,0x13
    80002d9a:	015787bb          	addw	a5,a5,s5
    80002d9e:	40d7d79b          	sraiw	a5,a5,0xd
    80002da2:	01cb2583          	lw	a1,28(s6)
    80002da6:	9dbd                	addw	a1,a1,a5
    80002da8:	855e                	mv	a0,s7
    80002daa:	cdfff0ef          	jal	80002a88 <bread>
    80002dae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002db0:	004b2503          	lw	a0,4(s6)
    80002db4:	000a849b          	sext.w	s1,s5
    80002db8:	8762                	mv	a4,s8
    80002dba:	fca4f1e3          	bgeu	s1,a0,80002d7c <balloc+0x90>
      m = 1 << (bi % 8);
    80002dbe:	00777693          	andi	a3,a4,7
    80002dc2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002dc6:	41f7579b          	sraiw	a5,a4,0x1f
    80002dca:	01d7d79b          	srliw	a5,a5,0x1d
    80002dce:	9fb9                	addw	a5,a5,a4
    80002dd0:	4037d79b          	sraiw	a5,a5,0x3
    80002dd4:	00f90633          	add	a2,s2,a5
    80002dd8:	05864603          	lbu	a2,88(a2)
    80002ddc:	00c6f5b3          	and	a1,a3,a2
    80002de0:	d5a1                	beqz	a1,80002d28 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002de2:	2705                	addiw	a4,a4,1
    80002de4:	2485                	addiw	s1,s1,1
    80002de6:	fd471ae3          	bne	a4,s4,80002dba <balloc+0xce>
    80002dea:	bf49                	j	80002d7c <balloc+0x90>
    80002dec:	6906                	ld	s2,64(sp)
    80002dee:	79e2                	ld	s3,56(sp)
    80002df0:	7a42                	ld	s4,48(sp)
    80002df2:	7aa2                	ld	s5,40(sp)
    80002df4:	7b02                	ld	s6,32(sp)
    80002df6:	6be2                	ld	s7,24(sp)
    80002df8:	6c42                	ld	s8,16(sp)
    80002dfa:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002dfc:	00004517          	auipc	a0,0x4
    80002e00:	68450513          	addi	a0,a0,1668 # 80007480 <etext+0x480>
    80002e04:	ebefd0ef          	jal	800004c2 <printf>
  return 0;
    80002e08:	4481                	li	s1,0
    80002e0a:	b79d                	j	80002d70 <balloc+0x84>

0000000080002e0c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e0c:	7179                	addi	sp,sp,-48
    80002e0e:	f406                	sd	ra,40(sp)
    80002e10:	f022                	sd	s0,32(sp)
    80002e12:	ec26                	sd	s1,24(sp)
    80002e14:	e84a                	sd	s2,16(sp)
    80002e16:	e44e                	sd	s3,8(sp)
    80002e18:	1800                	addi	s0,sp,48
    80002e1a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002e1c:	47ad                	li	a5,11
    80002e1e:	02b7e663          	bltu	a5,a1,80002e4a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002e22:	02059793          	slli	a5,a1,0x20
    80002e26:	01e7d593          	srli	a1,a5,0x1e
    80002e2a:	00b504b3          	add	s1,a0,a1
    80002e2e:	0504a903          	lw	s2,80(s1)
    80002e32:	06091a63          	bnez	s2,80002ea6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002e36:	4108                	lw	a0,0(a0)
    80002e38:	eb5ff0ef          	jal	80002cec <balloc>
    80002e3c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e40:	06090363          	beqz	s2,80002ea6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002e44:	0524a823          	sw	s2,80(s1)
    80002e48:	a8b9                	j	80002ea6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002e4a:	ff45849b          	addiw	s1,a1,-12
    80002e4e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002e52:	0ff00793          	li	a5,255
    80002e56:	06e7ee63          	bltu	a5,a4,80002ed2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002e5a:	08052903          	lw	s2,128(a0)
    80002e5e:	00091d63          	bnez	s2,80002e78 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002e62:	4108                	lw	a0,0(a0)
    80002e64:	e89ff0ef          	jal	80002cec <balloc>
    80002e68:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e6c:	02090d63          	beqz	s2,80002ea6 <bmap+0x9a>
    80002e70:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002e72:	0929a023          	sw	s2,128(s3)
    80002e76:	a011                	j	80002e7a <bmap+0x6e>
    80002e78:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002e7a:	85ca                	mv	a1,s2
    80002e7c:	0009a503          	lw	a0,0(s3)
    80002e80:	c09ff0ef          	jal	80002a88 <bread>
    80002e84:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002e86:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002e8a:	02049713          	slli	a4,s1,0x20
    80002e8e:	01e75593          	srli	a1,a4,0x1e
    80002e92:	00b784b3          	add	s1,a5,a1
    80002e96:	0004a903          	lw	s2,0(s1)
    80002e9a:	00090e63          	beqz	s2,80002eb6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002e9e:	8552                	mv	a0,s4
    80002ea0:	cf1ff0ef          	jal	80002b90 <brelse>
    return addr;
    80002ea4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002ea6:	854a                	mv	a0,s2
    80002ea8:	70a2                	ld	ra,40(sp)
    80002eaa:	7402                	ld	s0,32(sp)
    80002eac:	64e2                	ld	s1,24(sp)
    80002eae:	6942                	ld	s2,16(sp)
    80002eb0:	69a2                	ld	s3,8(sp)
    80002eb2:	6145                	addi	sp,sp,48
    80002eb4:	8082                	ret
      addr = balloc(ip->dev);
    80002eb6:	0009a503          	lw	a0,0(s3)
    80002eba:	e33ff0ef          	jal	80002cec <balloc>
    80002ebe:	0005091b          	sext.w	s2,a0
      if(addr){
    80002ec2:	fc090ee3          	beqz	s2,80002e9e <bmap+0x92>
        a[bn] = addr;
    80002ec6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002eca:	8552                	mv	a0,s4
    80002ecc:	557000ef          	jal	80003c22 <log_write>
    80002ed0:	b7f9                	j	80002e9e <bmap+0x92>
    80002ed2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002ed4:	00004517          	auipc	a0,0x4
    80002ed8:	5c450513          	addi	a0,a0,1476 # 80007498 <etext+0x498>
    80002edc:	8b9fd0ef          	jal	80000794 <panic>

0000000080002ee0 <iget>:
{
    80002ee0:	7179                	addi	sp,sp,-48
    80002ee2:	f406                	sd	ra,40(sp)
    80002ee4:	f022                	sd	s0,32(sp)
    80002ee6:	ec26                	sd	s1,24(sp)
    80002ee8:	e84a                	sd	s2,16(sp)
    80002eea:	e44e                	sd	s3,8(sp)
    80002eec:	e052                	sd	s4,0(sp)
    80002eee:	1800                	addi	s0,sp,48
    80002ef0:	89aa                	mv	s3,a0
    80002ef2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002ef4:	0001b517          	auipc	a0,0x1b
    80002ef8:	07450513          	addi	a0,a0,116 # 8001df68 <itable>
    80002efc:	cf9fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002f00:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f02:	0001b497          	auipc	s1,0x1b
    80002f06:	07e48493          	addi	s1,s1,126 # 8001df80 <itable+0x18>
    80002f0a:	0001d697          	auipc	a3,0x1d
    80002f0e:	b0668693          	addi	a3,a3,-1274 # 8001fa10 <log>
    80002f12:	a039                	j	80002f20 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Recordar un slot vacío
    80002f14:	02090963          	beqz	s2,80002f46 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f18:	08848493          	addi	s1,s1,136
    80002f1c:	02d48863          	beq	s1,a3,80002f4c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002f20:	449c                	lw	a5,8(s1)
    80002f22:	fef059e3          	blez	a5,80002f14 <iget+0x34>
    80002f26:	4098                	lw	a4,0(s1)
    80002f28:	ff3716e3          	bne	a4,s3,80002f14 <iget+0x34>
    80002f2c:	40d8                	lw	a4,4(s1)
    80002f2e:	ff4713e3          	bne	a4,s4,80002f14 <iget+0x34>
      ip->ref++;
    80002f32:	2785                	addiw	a5,a5,1
    80002f34:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f36:	0001b517          	auipc	a0,0x1b
    80002f3a:	03250513          	addi	a0,a0,50 # 8001df68 <itable>
    80002f3e:	d4ffd0ef          	jal	80000c8c <release>
      return ip;
    80002f42:	8926                	mv	s2,s1
    80002f44:	a805                	j	80002f74 <iget+0x94>
    if(empty == 0 && ip->ref == 0)    // Recordar un slot vacío
    80002f46:	fbe9                	bnez	a5,80002f18 <iget+0x38>
      empty = ip;
    80002f48:	8926                	mv	s2,s1
    80002f4a:	b7f9                	j	80002f18 <iget+0x38>
  if(empty == 0)
    80002f4c:	02090d63          	beqz	s2,80002f86 <iget+0xa6>
  ip->dev = dev;
    80002f50:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002f54:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002f58:	4785                	li	a5,1
    80002f5a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002f5e:	04092023          	sw	zero,64(s2)
  ip->perm = 3;
    80002f62:	478d                	li	a5,3
    80002f64:	08f90223          	sb	a5,132(s2)
  release(&itable.lock);
    80002f68:	0001b517          	auipc	a0,0x1b
    80002f6c:	00050513          	mv	a0,a0
    80002f70:	d1dfd0ef          	jal	80000c8c <release>
}
    80002f74:	854a                	mv	a0,s2
    80002f76:	70a2                	ld	ra,40(sp)
    80002f78:	7402                	ld	s0,32(sp)
    80002f7a:	64e2                	ld	s1,24(sp)
    80002f7c:	6942                	ld	s2,16(sp)
    80002f7e:	69a2                	ld	s3,8(sp)
    80002f80:	6a02                	ld	s4,0(sp)
    80002f82:	6145                	addi	sp,sp,48
    80002f84:	8082                	ret
    panic("iget: no inodes");
    80002f86:	00004517          	auipc	a0,0x4
    80002f8a:	52a50513          	addi	a0,a0,1322 # 800074b0 <etext+0x4b0>
    80002f8e:	807fd0ef          	jal	80000794 <panic>

0000000080002f92 <fsinit>:
fsinit(int dev) {
    80002f92:	7179                	addi	sp,sp,-48
    80002f94:	f406                	sd	ra,40(sp)
    80002f96:	f022                	sd	s0,32(sp)
    80002f98:	ec26                	sd	s1,24(sp)
    80002f9a:	e84a                	sd	s2,16(sp)
    80002f9c:	e44e                	sd	s3,8(sp)
    80002f9e:	1800                	addi	s0,sp,48
    80002fa0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002fa2:	4585                	li	a1,1
    80002fa4:	ae5ff0ef          	jal	80002a88 <bread>
    80002fa8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002faa:	0001b997          	auipc	s3,0x1b
    80002fae:	f9e98993          	addi	s3,s3,-98 # 8001df48 <sb>
    80002fb2:	02000613          	li	a2,32
    80002fb6:	05850593          	addi	a1,a0,88
    80002fba:	854e                	mv	a0,s3
    80002fbc:	d69fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	bcfff0ef          	jal	80002b90 <brelse>
  if(sb.magic != FSMAGIC)
    80002fc6:	0009a703          	lw	a4,0(s3)
    80002fca:	102037b7          	lui	a5,0x10203
    80002fce:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002fd2:	02f71063          	bne	a4,a5,80002ff2 <fsinit+0x60>
  initlog(dev, &sb);
    80002fd6:	0001b597          	auipc	a1,0x1b
    80002fda:	f7258593          	addi	a1,a1,-142 # 8001df48 <sb>
    80002fde:	854a                	mv	a0,s2
    80002fe0:	23b000ef          	jal	80003a1a <initlog>
}
    80002fe4:	70a2                	ld	ra,40(sp)
    80002fe6:	7402                	ld	s0,32(sp)
    80002fe8:	64e2                	ld	s1,24(sp)
    80002fea:	6942                	ld	s2,16(sp)
    80002fec:	69a2                	ld	s3,8(sp)
    80002fee:	6145                	addi	sp,sp,48
    80002ff0:	8082                	ret
    panic("invalid file system");
    80002ff2:	00004517          	auipc	a0,0x4
    80002ff6:	4ce50513          	addi	a0,a0,1230 # 800074c0 <etext+0x4c0>
    80002ffa:	f9afd0ef          	jal	80000794 <panic>

0000000080002ffe <iinit>:
{
    80002ffe:	7179                	addi	sp,sp,-48
    80003000:	f406                	sd	ra,40(sp)
    80003002:	f022                	sd	s0,32(sp)
    80003004:	ec26                	sd	s1,24(sp)
    80003006:	e84a                	sd	s2,16(sp)
    80003008:	e44e                	sd	s3,8(sp)
    8000300a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000300c:	00004597          	auipc	a1,0x4
    80003010:	4cc58593          	addi	a1,a1,1228 # 800074d8 <etext+0x4d8>
    80003014:	0001b517          	auipc	a0,0x1b
    80003018:	f5450513          	addi	a0,a0,-172 # 8001df68 <itable>
    8000301c:	b59fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003020:	0001b497          	auipc	s1,0x1b
    80003024:	f7048493          	addi	s1,s1,-144 # 8001df90 <itable+0x28>
    80003028:	0001d997          	auipc	s3,0x1d
    8000302c:	9f898993          	addi	s3,s3,-1544 # 8001fa20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003030:	00004917          	auipc	s2,0x4
    80003034:	4b090913          	addi	s2,s2,1200 # 800074e0 <etext+0x4e0>
    80003038:	85ca                	mv	a1,s2
    8000303a:	8526                	mv	a0,s1
    8000303c:	4b7000ef          	jal	80003cf2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003040:	08848493          	addi	s1,s1,136
    80003044:	ff349ae3          	bne	s1,s3,80003038 <iinit+0x3a>
}
    80003048:	70a2                	ld	ra,40(sp)
    8000304a:	7402                	ld	s0,32(sp)
    8000304c:	64e2                	ld	s1,24(sp)
    8000304e:	6942                	ld	s2,16(sp)
    80003050:	69a2                	ld	s3,8(sp)
    80003052:	6145                	addi	sp,sp,48
    80003054:	8082                	ret

0000000080003056 <ialloc>:
{
    80003056:	7139                	addi	sp,sp,-64
    80003058:	fc06                	sd	ra,56(sp)
    8000305a:	f822                	sd	s0,48(sp)
    8000305c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000305e:	0001b717          	auipc	a4,0x1b
    80003062:	ef672703          	lw	a4,-266(a4) # 8001df54 <sb+0xc>
    80003066:	4785                	li	a5,1
    80003068:	06e7f063          	bgeu	a5,a4,800030c8 <ialloc+0x72>
    8000306c:	f426                	sd	s1,40(sp)
    8000306e:	f04a                	sd	s2,32(sp)
    80003070:	ec4e                	sd	s3,24(sp)
    80003072:	e852                	sd	s4,16(sp)
    80003074:	e456                	sd	s5,8(sp)
    80003076:	e05a                	sd	s6,0(sp)
    80003078:	8aaa                	mv	s5,a0
    8000307a:	8b2e                	mv	s6,a1
    8000307c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000307e:	0001ba17          	auipc	s4,0x1b
    80003082:	ecaa0a13          	addi	s4,s4,-310 # 8001df48 <sb>
    80003086:	00495593          	srli	a1,s2,0x4
    8000308a:	018a2783          	lw	a5,24(s4)
    8000308e:	9dbd                	addw	a1,a1,a5
    80003090:	8556                	mv	a0,s5
    80003092:	9f7ff0ef          	jal	80002a88 <bread>
    80003096:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003098:	05850993          	addi	s3,a0,88
    8000309c:	00f97793          	andi	a5,s2,15
    800030a0:	079a                	slli	a5,a5,0x6
    800030a2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030a4:	00099783          	lh	a5,0(s3)
    800030a8:	cb9d                	beqz	a5,800030de <ialloc+0x88>
    brelse(bp);
    800030aa:	ae7ff0ef          	jal	80002b90 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030ae:	0905                	addi	s2,s2,1
    800030b0:	00ca2703          	lw	a4,12(s4)
    800030b4:	0009079b          	sext.w	a5,s2
    800030b8:	fce7e7e3          	bltu	a5,a4,80003086 <ialloc+0x30>
    800030bc:	74a2                	ld	s1,40(sp)
    800030be:	7902                	ld	s2,32(sp)
    800030c0:	69e2                	ld	s3,24(sp)
    800030c2:	6a42                	ld	s4,16(sp)
    800030c4:	6aa2                	ld	s5,8(sp)
    800030c6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800030c8:	00004517          	auipc	a0,0x4
    800030cc:	42050513          	addi	a0,a0,1056 # 800074e8 <etext+0x4e8>
    800030d0:	bf2fd0ef          	jal	800004c2 <printf>
  return 0;
    800030d4:	4501                	li	a0,0
}
    800030d6:	70e2                	ld	ra,56(sp)
    800030d8:	7442                	ld	s0,48(sp)
    800030da:	6121                	addi	sp,sp,64
    800030dc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030de:	04000613          	li	a2,64
    800030e2:	4581                	li	a1,0
    800030e4:	854e                	mv	a0,s3
    800030e6:	be3fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800030ea:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800030ee:	8526                	mv	a0,s1
    800030f0:	333000ef          	jal	80003c22 <log_write>
      brelse(bp);
    800030f4:	8526                	mv	a0,s1
    800030f6:	a9bff0ef          	jal	80002b90 <brelse>
      return iget(dev, inum);
    800030fa:	0009059b          	sext.w	a1,s2
    800030fe:	8556                	mv	a0,s5
    80003100:	de1ff0ef          	jal	80002ee0 <iget>
    80003104:	74a2                	ld	s1,40(sp)
    80003106:	7902                	ld	s2,32(sp)
    80003108:	69e2                	ld	s3,24(sp)
    8000310a:	6a42                	ld	s4,16(sp)
    8000310c:	6aa2                	ld	s5,8(sp)
    8000310e:	6b02                	ld	s6,0(sp)
    80003110:	b7d9                	j	800030d6 <ialloc+0x80>

0000000080003112 <iupdate>:
{
    80003112:	1101                	addi	sp,sp,-32
    80003114:	ec06                	sd	ra,24(sp)
    80003116:	e822                	sd	s0,16(sp)
    80003118:	e426                	sd	s1,8(sp)
    8000311a:	e04a                	sd	s2,0(sp)
    8000311c:	1000                	addi	s0,sp,32
    8000311e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003120:	415c                	lw	a5,4(a0)
    80003122:	0047d79b          	srliw	a5,a5,0x4
    80003126:	0001b597          	auipc	a1,0x1b
    8000312a:	e3a5a583          	lw	a1,-454(a1) # 8001df60 <sb+0x18>
    8000312e:	9dbd                	addw	a1,a1,a5
    80003130:	4108                	lw	a0,0(a0)
    80003132:	957ff0ef          	jal	80002a88 <bread>
    80003136:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003138:	05850793          	addi	a5,a0,88
    8000313c:	40d8                	lw	a4,4(s1)
    8000313e:	8b3d                	andi	a4,a4,15
    80003140:	071a                	slli	a4,a4,0x6
    80003142:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003144:	04449703          	lh	a4,68(s1)
    80003148:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000314c:	04649703          	lh	a4,70(s1)
    80003150:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003154:	04849703          	lh	a4,72(s1)
    80003158:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000315c:	04a49703          	lh	a4,74(s1)
    80003160:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003164:	44f8                	lw	a4,76(s1)
    80003166:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003168:	03400613          	li	a2,52
    8000316c:	05048593          	addi	a1,s1,80
    80003170:	00c78513          	addi	a0,a5,12
    80003174:	bb1fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003178:	854a                	mv	a0,s2
    8000317a:	2a9000ef          	jal	80003c22 <log_write>
  brelse(bp);
    8000317e:	854a                	mv	a0,s2
    80003180:	a11ff0ef          	jal	80002b90 <brelse>
}
    80003184:	60e2                	ld	ra,24(sp)
    80003186:	6442                	ld	s0,16(sp)
    80003188:	64a2                	ld	s1,8(sp)
    8000318a:	6902                	ld	s2,0(sp)
    8000318c:	6105                	addi	sp,sp,32
    8000318e:	8082                	ret

0000000080003190 <idup>:
{
    80003190:	1101                	addi	sp,sp,-32
    80003192:	ec06                	sd	ra,24(sp)
    80003194:	e822                	sd	s0,16(sp)
    80003196:	e426                	sd	s1,8(sp)
    80003198:	1000                	addi	s0,sp,32
    8000319a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000319c:	0001b517          	auipc	a0,0x1b
    800031a0:	dcc50513          	addi	a0,a0,-564 # 8001df68 <itable>
    800031a4:	a51fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800031a8:	449c                	lw	a5,8(s1)
    800031aa:	2785                	addiw	a5,a5,1
    800031ac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031ae:	0001b517          	auipc	a0,0x1b
    800031b2:	dba50513          	addi	a0,a0,-582 # 8001df68 <itable>
    800031b6:	ad7fd0ef          	jal	80000c8c <release>
}
    800031ba:	8526                	mv	a0,s1
    800031bc:	60e2                	ld	ra,24(sp)
    800031be:	6442                	ld	s0,16(sp)
    800031c0:	64a2                	ld	s1,8(sp)
    800031c2:	6105                	addi	sp,sp,32
    800031c4:	8082                	ret

00000000800031c6 <ilock>:
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	e426                	sd	s1,8(sp)
    800031ce:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800031d0:	cd19                	beqz	a0,800031ee <ilock+0x28>
    800031d2:	84aa                	mv	s1,a0
    800031d4:	451c                	lw	a5,8(a0)
    800031d6:	00f05c63          	blez	a5,800031ee <ilock+0x28>
  acquiresleep(&ip->lock);
    800031da:	0541                	addi	a0,a0,16
    800031dc:	34d000ef          	jal	80003d28 <acquiresleep>
  if(ip->valid == 0){
    800031e0:	40bc                	lw	a5,64(s1)
    800031e2:	cf89                	beqz	a5,800031fc <ilock+0x36>
}
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6105                	addi	sp,sp,32
    800031ec:	8082                	ret
    800031ee:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800031f0:	00004517          	auipc	a0,0x4
    800031f4:	31050513          	addi	a0,a0,784 # 80007500 <etext+0x500>
    800031f8:	d9cfd0ef          	jal	80000794 <panic>
    800031fc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031fe:	40dc                	lw	a5,4(s1)
    80003200:	0047d79b          	srliw	a5,a5,0x4
    80003204:	0001b597          	auipc	a1,0x1b
    80003208:	d5c5a583          	lw	a1,-676(a1) # 8001df60 <sb+0x18>
    8000320c:	9dbd                	addw	a1,a1,a5
    8000320e:	4088                	lw	a0,0(s1)
    80003210:	879ff0ef          	jal	80002a88 <bread>
    80003214:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003216:	05850593          	addi	a1,a0,88
    8000321a:	40dc                	lw	a5,4(s1)
    8000321c:	8bbd                	andi	a5,a5,15
    8000321e:	079a                	slli	a5,a5,0x6
    80003220:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003222:	00059783          	lh	a5,0(a1)
    80003226:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000322a:	00259783          	lh	a5,2(a1)
    8000322e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003232:	00459783          	lh	a5,4(a1)
    80003236:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000323a:	00659783          	lh	a5,6(a1)
    8000323e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003242:	459c                	lw	a5,8(a1)
    80003244:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003246:	03400613          	li	a2,52
    8000324a:	05b1                	addi	a1,a1,12
    8000324c:	05048513          	addi	a0,s1,80
    80003250:	ad5fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003254:	854a                	mv	a0,s2
    80003256:	93bff0ef          	jal	80002b90 <brelse>
    ip->valid = 1;
    8000325a:	4785                	li	a5,1
    8000325c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000325e:	04449783          	lh	a5,68(s1)
    80003262:	c399                	beqz	a5,80003268 <ilock+0xa2>
    80003264:	6902                	ld	s2,0(sp)
    80003266:	bfbd                	j	800031e4 <ilock+0x1e>
      panic("ilock: no type");
    80003268:	00004517          	auipc	a0,0x4
    8000326c:	2a050513          	addi	a0,a0,672 # 80007508 <etext+0x508>
    80003270:	d24fd0ef          	jal	80000794 <panic>

0000000080003274 <iunlock>:
{
    80003274:	1101                	addi	sp,sp,-32
    80003276:	ec06                	sd	ra,24(sp)
    80003278:	e822                	sd	s0,16(sp)
    8000327a:	e426                	sd	s1,8(sp)
    8000327c:	e04a                	sd	s2,0(sp)
    8000327e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003280:	c505                	beqz	a0,800032a8 <iunlock+0x34>
    80003282:	84aa                	mv	s1,a0
    80003284:	01050913          	addi	s2,a0,16
    80003288:	854a                	mv	a0,s2
    8000328a:	31d000ef          	jal	80003da6 <holdingsleep>
    8000328e:	cd09                	beqz	a0,800032a8 <iunlock+0x34>
    80003290:	449c                	lw	a5,8(s1)
    80003292:	00f05b63          	blez	a5,800032a8 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003296:	854a                	mv	a0,s2
    80003298:	2d7000ef          	jal	80003d6e <releasesleep>
}
    8000329c:	60e2                	ld	ra,24(sp)
    8000329e:	6442                	ld	s0,16(sp)
    800032a0:	64a2                	ld	s1,8(sp)
    800032a2:	6902                	ld	s2,0(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret
    panic("iunlock");
    800032a8:	00004517          	auipc	a0,0x4
    800032ac:	27050513          	addi	a0,a0,624 # 80007518 <etext+0x518>
    800032b0:	ce4fd0ef          	jal	80000794 <panic>

00000000800032b4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032b4:	7179                	addi	sp,sp,-48
    800032b6:	f406                	sd	ra,40(sp)
    800032b8:	f022                	sd	s0,32(sp)
    800032ba:	ec26                	sd	s1,24(sp)
    800032bc:	e84a                	sd	s2,16(sp)
    800032be:	e44e                	sd	s3,8(sp)
    800032c0:	1800                	addi	s0,sp,48
    800032c2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800032c4:	05050493          	addi	s1,a0,80
    800032c8:	08050913          	addi	s2,a0,128
    800032cc:	a021                	j	800032d4 <itrunc+0x20>
    800032ce:	0491                	addi	s1,s1,4
    800032d0:	01248b63          	beq	s1,s2,800032e6 <itrunc+0x32>
    if(ip->addrs[i]){
    800032d4:	408c                	lw	a1,0(s1)
    800032d6:	dde5                	beqz	a1,800032ce <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032d8:	0009a503          	lw	a0,0(s3)
    800032dc:	9a5ff0ef          	jal	80002c80 <bfree>
      ip->addrs[i] = 0;
    800032e0:	0004a023          	sw	zero,0(s1)
    800032e4:	b7ed                	j	800032ce <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800032e6:	0809a583          	lw	a1,128(s3)
    800032ea:	ed89                	bnez	a1,80003304 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800032ec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800032f0:	854e                	mv	a0,s3
    800032f2:	e21ff0ef          	jal	80003112 <iupdate>
}
    800032f6:	70a2                	ld	ra,40(sp)
    800032f8:	7402                	ld	s0,32(sp)
    800032fa:	64e2                	ld	s1,24(sp)
    800032fc:	6942                	ld	s2,16(sp)
    800032fe:	69a2                	ld	s3,8(sp)
    80003300:	6145                	addi	sp,sp,48
    80003302:	8082                	ret
    80003304:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003306:	0009a503          	lw	a0,0(s3)
    8000330a:	f7eff0ef          	jal	80002a88 <bread>
    8000330e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003310:	05850493          	addi	s1,a0,88
    80003314:	45850913          	addi	s2,a0,1112
    80003318:	a021                	j	80003320 <itrunc+0x6c>
    8000331a:	0491                	addi	s1,s1,4
    8000331c:	01248963          	beq	s1,s2,8000332e <itrunc+0x7a>
      if(a[j])
    80003320:	408c                	lw	a1,0(s1)
    80003322:	dde5                	beqz	a1,8000331a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003324:	0009a503          	lw	a0,0(s3)
    80003328:	959ff0ef          	jal	80002c80 <bfree>
    8000332c:	b7fd                	j	8000331a <itrunc+0x66>
    brelse(bp);
    8000332e:	8552                	mv	a0,s4
    80003330:	861ff0ef          	jal	80002b90 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003334:	0809a583          	lw	a1,128(s3)
    80003338:	0009a503          	lw	a0,0(s3)
    8000333c:	945ff0ef          	jal	80002c80 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003340:	0809a023          	sw	zero,128(s3)
    80003344:	6a02                	ld	s4,0(sp)
    80003346:	b75d                	j	800032ec <itrunc+0x38>

0000000080003348 <iput>:
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	1000                	addi	s0,sp,32
    80003352:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003354:	0001b517          	auipc	a0,0x1b
    80003358:	c1450513          	addi	a0,a0,-1004 # 8001df68 <itable>
    8000335c:	899fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003360:	4498                	lw	a4,8(s1)
    80003362:	4785                	li	a5,1
    80003364:	02f70063          	beq	a4,a5,80003384 <iput+0x3c>
  ip->ref--;
    80003368:	449c                	lw	a5,8(s1)
    8000336a:	37fd                	addiw	a5,a5,-1
    8000336c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000336e:	0001b517          	auipc	a0,0x1b
    80003372:	bfa50513          	addi	a0,a0,-1030 # 8001df68 <itable>
    80003376:	917fd0ef          	jal	80000c8c <release>
}
    8000337a:	60e2                	ld	ra,24(sp)
    8000337c:	6442                	ld	s0,16(sp)
    8000337e:	64a2                	ld	s1,8(sp)
    80003380:	6105                	addi	sp,sp,32
    80003382:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003384:	40bc                	lw	a5,64(s1)
    80003386:	d3ed                	beqz	a5,80003368 <iput+0x20>
    80003388:	04a49783          	lh	a5,74(s1)
    8000338c:	fff1                	bnez	a5,80003368 <iput+0x20>
    8000338e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003390:	01048913          	addi	s2,s1,16
    80003394:	854a                	mv	a0,s2
    80003396:	193000ef          	jal	80003d28 <acquiresleep>
    release(&itable.lock);
    8000339a:	0001b517          	auipc	a0,0x1b
    8000339e:	bce50513          	addi	a0,a0,-1074 # 8001df68 <itable>
    800033a2:	8ebfd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800033a6:	8526                	mv	a0,s1
    800033a8:	f0dff0ef          	jal	800032b4 <itrunc>
    ip->type = 0;
    800033ac:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033b0:	8526                	mv	a0,s1
    800033b2:	d61ff0ef          	jal	80003112 <iupdate>
    ip->valid = 0;
    800033b6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033ba:	854a                	mv	a0,s2
    800033bc:	1b3000ef          	jal	80003d6e <releasesleep>
    acquire(&itable.lock);
    800033c0:	0001b517          	auipc	a0,0x1b
    800033c4:	ba850513          	addi	a0,a0,-1112 # 8001df68 <itable>
    800033c8:	82dfd0ef          	jal	80000bf4 <acquire>
    800033cc:	6902                	ld	s2,0(sp)
    800033ce:	bf69                	j	80003368 <iput+0x20>

00000000800033d0 <iunlockput>:
{
    800033d0:	1101                	addi	sp,sp,-32
    800033d2:	ec06                	sd	ra,24(sp)
    800033d4:	e822                	sd	s0,16(sp)
    800033d6:	e426                	sd	s1,8(sp)
    800033d8:	1000                	addi	s0,sp,32
    800033da:	84aa                	mv	s1,a0
  iunlock(ip);
    800033dc:	e99ff0ef          	jal	80003274 <iunlock>
  iput(ip);
    800033e0:	8526                	mv	a0,s1
    800033e2:	f67ff0ef          	jal	80003348 <iput>
}
    800033e6:	60e2                	ld	ra,24(sp)
    800033e8:	6442                	ld	s0,16(sp)
    800033ea:	64a2                	ld	s1,8(sp)
    800033ec:	6105                	addi	sp,sp,32
    800033ee:	8082                	ret

00000000800033f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800033f0:	1141                	addi	sp,sp,-16
    800033f2:	e422                	sd	s0,8(sp)
    800033f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800033f6:	411c                	lw	a5,0(a0)
    800033f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800033fa:	415c                	lw	a5,4(a0)
    800033fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800033fe:	04451783          	lh	a5,68(a0)
    80003402:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003406:	04a51783          	lh	a5,74(a0)
    8000340a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000340e:	04c56783          	lwu	a5,76(a0)
    80003412:	e99c                	sd	a5,16(a1)
}
    80003414:	6422                	ld	s0,8(sp)
    80003416:	0141                	addi	sp,sp,16
    80003418:	8082                	ret

000000008000341a <readi>:
{
  uint tot, m;
  struct buf *bp;

  // Verificar permisos: Sin permiso de lectura
  if((ip->perm & 1) == 0) {
    8000341a:	08454783          	lbu	a5,132(a0)
    8000341e:	8b85                	andi	a5,a5,1
    80003420:	0e078e63          	beqz	a5,8000351c <readi+0x102>
{
    80003424:	7159                	addi	sp,sp,-112
    80003426:	f486                	sd	ra,104(sp)
    80003428:	f0a2                	sd	s0,96(sp)
    8000342a:	eca6                	sd	s1,88(sp)
    8000342c:	e0d2                	sd	s4,64(sp)
    8000342e:	fc56                	sd	s5,56(sp)
    80003430:	f85a                	sd	s6,48(sp)
    80003432:	f45e                	sd	s7,40(sp)
    80003434:	1880                	addi	s0,sp,112
    80003436:	8aaa                	mv	s5,a0
    80003438:	8bae                	mv	s7,a1
    8000343a:	8a32                	mv	s4,a2
    8000343c:	84b6                	mv	s1,a3
    8000343e:	8b3a                	mv	s6,a4
    return -1; // Error por falta de permisos
  }

  if(off > ip->size || off + n < off)
    80003440:	457c                	lw	a5,76(a0)
    return 0;
    80003442:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003444:	0cd7e363          	bltu	a5,a3,8000350a <readi+0xf0>
    80003448:	9f35                	addw	a4,a4,a3
    8000344a:	0cd76063          	bltu	a4,a3,8000350a <readi+0xf0>
    8000344e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003450:	00e7f463          	bgeu	a5,a4,80003458 <readi+0x3e>
    n = ip->size - off;
    80003454:	40d78b3b          	subw	s6,a5,a3

  for(tot = 0; tot < n; tot += m, off += m, dst += m){
    80003458:	080b0f63          	beqz	s6,800034f6 <readi+0xdc>
    8000345c:	e8ca                	sd	s2,80(sp)
    8000345e:	f062                	sd	s8,32(sp)
    80003460:	ec66                	sd	s9,24(sp)
    80003462:	e86a                	sd	s10,16(sp)
    80003464:	e46e                	sd	s11,8(sp)
    80003466:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003468:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000346c:	5c7d                	li	s8,-1
    8000346e:	a80d                	j	800034a0 <readi+0x86>
    80003470:	020d1d93          	slli	s11,s10,0x20
    80003474:	020ddd93          	srli	s11,s11,0x20
    80003478:	05890613          	addi	a2,s2,88
    8000347c:	86ee                	mv	a3,s11
    8000347e:	963a                	add	a2,a2,a4
    80003480:	85d2                	mv	a1,s4
    80003482:	855e                	mv	a0,s7
    80003484:	d87fe0ef          	jal	8000220a <either_copyout>
    80003488:	05850763          	beq	a0,s8,800034d6 <readi+0xbc>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000348c:	854a                	mv	a0,s2
    8000348e:	f02ff0ef          	jal	80002b90 <brelse>
  for(tot = 0; tot < n; tot += m, off += m, dst += m){
    80003492:	013d09bb          	addw	s3,s10,s3
    80003496:	009d04bb          	addw	s1,s10,s1
    8000349a:	9a6e                	add	s4,s4,s11
    8000349c:	0569f763          	bgeu	s3,s6,800034ea <readi+0xd0>
    uint addr = bmap(ip, off / BSIZE);
    800034a0:	00a4d59b          	srliw	a1,s1,0xa
    800034a4:	8556                	mv	a0,s5
    800034a6:	967ff0ef          	jal	80002e0c <bmap>
    800034aa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034ae:	c5b1                	beqz	a1,800034fa <readi+0xe0>
    bp = bread(ip->dev, addr);
    800034b0:	000aa503          	lw	a0,0(s5)
    800034b4:	dd4ff0ef          	jal	80002a88 <bread>
    800034b8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800034ba:	3ff4f713          	andi	a4,s1,1023
    800034be:	40ec87bb          	subw	a5,s9,a4
    800034c2:	413b06bb          	subw	a3,s6,s3
    800034c6:	8d3e                	mv	s10,a5
    800034c8:	2781                	sext.w	a5,a5
    800034ca:	0006861b          	sext.w	a2,a3
    800034ce:	faf671e3          	bgeu	a2,a5,80003470 <readi+0x56>
    800034d2:	8d36                	mv	s10,a3
    800034d4:	bf71                	j	80003470 <readi+0x56>
      brelse(bp);
    800034d6:	854a                	mv	a0,s2
    800034d8:	eb8ff0ef          	jal	80002b90 <brelse>
      tot = -1;
    800034dc:	59fd                	li	s3,-1
      break;
    800034de:	6946                	ld	s2,80(sp)
    800034e0:	7c02                	ld	s8,32(sp)
    800034e2:	6ce2                	ld	s9,24(sp)
    800034e4:	6d42                	ld	s10,16(sp)
    800034e6:	6da2                	ld	s11,8(sp)
    800034e8:	a831                	j	80003504 <readi+0xea>
    800034ea:	6946                	ld	s2,80(sp)
    800034ec:	7c02                	ld	s8,32(sp)
    800034ee:	6ce2                	ld	s9,24(sp)
    800034f0:	6d42                	ld	s10,16(sp)
    800034f2:	6da2                	ld	s11,8(sp)
    800034f4:	a801                	j	80003504 <readi+0xea>
  for(tot = 0; tot < n; tot += m, off += m, dst += m){
    800034f6:	89da                	mv	s3,s6
    800034f8:	a031                	j	80003504 <readi+0xea>
    800034fa:	6946                	ld	s2,80(sp)
    800034fc:	7c02                	ld	s8,32(sp)
    800034fe:	6ce2                	ld	s9,24(sp)
    80003500:	6d42                	ld	s10,16(sp)
    80003502:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003504:	0009851b          	sext.w	a0,s3
    80003508:	69a6                	ld	s3,72(sp)
}
    8000350a:	70a6                	ld	ra,104(sp)
    8000350c:	7406                	ld	s0,96(sp)
    8000350e:	64e6                	ld	s1,88(sp)
    80003510:	6a06                	ld	s4,64(sp)
    80003512:	7ae2                	ld	s5,56(sp)
    80003514:	7b42                	ld	s6,48(sp)
    80003516:	7ba2                	ld	s7,40(sp)
    80003518:	6165                	addi	sp,sp,112
    8000351a:	8082                	ret
    return -1; // Error por falta de permisos
    8000351c:	557d                	li	a0,-1
}
    8000351e:	8082                	ret

0000000080003520 <writei>:
// Returns the number of bytes successfully written.
// If the return value is less than the requested n,
// there was an error of some kind.
int
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
    80003520:	7159                	addi	sp,sp,-112
    80003522:	f486                	sd	ra,104(sp)
    80003524:	f0a2                	sd	s0,96(sp)
    80003526:	f85a                	sd	s6,48(sp)
    80003528:	1880                	addi	s0,sp,112
    8000352a:	8b3a                	mv	s6,a4
    uint tot, m;
    struct buf *bp;

    // Verificar si el archivo es inmutable o no tiene permiso de escritura
    if(ip->perm == 5 || (ip->perm & 2) == 0) {
    8000352c:	08454783          	lbu	a5,132(a0)
    80003530:	4715                	li	a4,5
    80003532:	10e78063          	beq	a5,a4,80003632 <writei+0x112>
    80003536:	e8ca                	sd	s2,80(sp)
    80003538:	e0d2                	sd	s4,64(sp)
    8000353a:	fc56                	sd	s5,56(sp)
    8000353c:	f45e                	sd	s7,40(sp)
    8000353e:	8aaa                	mv	s5,a0
    80003540:	8bae                	mv	s7,a1
    80003542:	8a32                	mv	s4,a2
    80003544:	8936                	mv	s2,a3
    80003546:	8b89                	andi	a5,a5,2
    80003548:	0e078763          	beqz	a5,80003636 <writei+0x116>
        return -1; // Error: archivo inmutable o sin permiso de escritura
    }

    if(off > ip->size || off + n < off)
    8000354c:	457c                	lw	a5,76(a0)
    8000354e:	0ed7ea63          	bltu	a5,a3,80003642 <writei+0x122>
    80003552:	016687bb          	addw	a5,a3,s6
    80003556:	0ed7ec63          	bltu	a5,a3,8000364e <writei+0x12e>
        return -1;
    if(off + n > MAXFILE * BSIZE)
    8000355a:	00043737          	lui	a4,0x43
    8000355e:	0ef76e63          	bltu	a4,a5,8000365a <writei+0x13a>
    80003562:	e4ce                	sd	s3,72(sp)
        return -1;

    for(tot = 0; tot < n; tot += m, off += m, src += m){
    80003564:	0a0b0f63          	beqz	s6,80003622 <writei+0x102>
    80003568:	eca6                	sd	s1,88(sp)
    8000356a:	f062                	sd	s8,32(sp)
    8000356c:	ec66                	sd	s9,24(sp)
    8000356e:	e86a                	sd	s10,16(sp)
    80003570:	e46e                	sd	s11,8(sp)
    80003572:	4981                	li	s3,0
        uint addr = bmap(ip, off / BSIZE);
        if(addr == 0)
            break;
        bp = bread(ip->dev, addr);
        m = min(n - tot, BSIZE - off % BSIZE);
    80003574:	40000c93          	li	s9,1024
        if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003578:	5c7d                	li	s8,-1
    8000357a:	a825                	j	800035b2 <writei+0x92>
    8000357c:	020d1d93          	slli	s11,s10,0x20
    80003580:	020ddd93          	srli	s11,s11,0x20
    80003584:	05848513          	addi	a0,s1,88
    80003588:	86ee                	mv	a3,s11
    8000358a:	8652                	mv	a2,s4
    8000358c:	85de                	mv	a1,s7
    8000358e:	953a                	add	a0,a0,a4
    80003590:	cc5fe0ef          	jal	80002254 <either_copyin>
    80003594:	05850a63          	beq	a0,s8,800035e8 <writei+0xc8>
            brelse(bp);
            break;
        }
        log_write(bp);
    80003598:	8526                	mv	a0,s1
    8000359a:	688000ef          	jal	80003c22 <log_write>
        brelse(bp);
    8000359e:	8526                	mv	a0,s1
    800035a0:	df0ff0ef          	jal	80002b90 <brelse>
    for(tot = 0; tot < n; tot += m, off += m, src += m){
    800035a4:	013d09bb          	addw	s3,s10,s3
    800035a8:	012d093b          	addw	s2,s10,s2
    800035ac:	9a6e                	add	s4,s4,s11
    800035ae:	0569f063          	bgeu	s3,s6,800035ee <writei+0xce>
        uint addr = bmap(ip, off / BSIZE);
    800035b2:	00a9559b          	srliw	a1,s2,0xa
    800035b6:	8556                	mv	a0,s5
    800035b8:	855ff0ef          	jal	80002e0c <bmap>
    800035bc:	0005059b          	sext.w	a1,a0
        if(addr == 0)
    800035c0:	c59d                	beqz	a1,800035ee <writei+0xce>
        bp = bread(ip->dev, addr);
    800035c2:	000aa503          	lw	a0,0(s5)
    800035c6:	cc2ff0ef          	jal	80002a88 <bread>
    800035ca:	84aa                	mv	s1,a0
        m = min(n - tot, BSIZE - off % BSIZE);
    800035cc:	3ff97713          	andi	a4,s2,1023
    800035d0:	40ec87bb          	subw	a5,s9,a4
    800035d4:	413b06bb          	subw	a3,s6,s3
    800035d8:	8d3e                	mv	s10,a5
    800035da:	2781                	sext.w	a5,a5
    800035dc:	0006861b          	sext.w	a2,a3
    800035e0:	f8f67ee3          	bgeu	a2,a5,8000357c <writei+0x5c>
    800035e4:	8d36                	mv	s10,a3
    800035e6:	bf59                	j	8000357c <writei+0x5c>
            brelse(bp);
    800035e8:	8526                	mv	a0,s1
    800035ea:	da6ff0ef          	jal	80002b90 <brelse>
    }

    if(off > ip->size)
    800035ee:	04caa783          	lw	a5,76(s5)
    800035f2:	0327fa63          	bgeu	a5,s2,80003626 <writei+0x106>
        ip->size = off;
    800035f6:	052aa623          	sw	s2,76(s5)
    800035fa:	64e6                	ld	s1,88(sp)
    800035fc:	7c02                	ld	s8,32(sp)
    800035fe:	6ce2                	ld	s9,24(sp)
    80003600:	6d42                	ld	s10,16(sp)
    80003602:	6da2                	ld	s11,8(sp)

    iupdate(ip);
    80003604:	8556                	mv	a0,s5
    80003606:	b0dff0ef          	jal	80003112 <iupdate>
    return tot;
    8000360a:	0009851b          	sext.w	a0,s3
    8000360e:	6946                	ld	s2,80(sp)
    80003610:	69a6                	ld	s3,72(sp)
    80003612:	6a06                	ld	s4,64(sp)
    80003614:	7ae2                	ld	s5,56(sp)
    80003616:	7ba2                	ld	s7,40(sp)
}
    80003618:	70a6                	ld	ra,104(sp)
    8000361a:	7406                	ld	s0,96(sp)
    8000361c:	7b42                	ld	s6,48(sp)
    8000361e:	6165                	addi	sp,sp,112
    80003620:	8082                	ret
    for(tot = 0; tot < n; tot += m, off += m, src += m){
    80003622:	89da                	mv	s3,s6
    80003624:	b7c5                	j	80003604 <writei+0xe4>
    80003626:	64e6                	ld	s1,88(sp)
    80003628:	7c02                	ld	s8,32(sp)
    8000362a:	6ce2                	ld	s9,24(sp)
    8000362c:	6d42                	ld	s10,16(sp)
    8000362e:	6da2                	ld	s11,8(sp)
    80003630:	bfd1                	j	80003604 <writei+0xe4>
        return -1; // Error: archivo inmutable o sin permiso de escritura
    80003632:	557d                	li	a0,-1
    80003634:	b7d5                	j	80003618 <writei+0xf8>
    80003636:	557d                	li	a0,-1
    80003638:	6946                	ld	s2,80(sp)
    8000363a:	6a06                	ld	s4,64(sp)
    8000363c:	7ae2                	ld	s5,56(sp)
    8000363e:	7ba2                	ld	s7,40(sp)
    80003640:	bfe1                	j	80003618 <writei+0xf8>
        return -1;
    80003642:	557d                	li	a0,-1
    80003644:	6946                	ld	s2,80(sp)
    80003646:	6a06                	ld	s4,64(sp)
    80003648:	7ae2                	ld	s5,56(sp)
    8000364a:	7ba2                	ld	s7,40(sp)
    8000364c:	b7f1                	j	80003618 <writei+0xf8>
    8000364e:	557d                	li	a0,-1
    80003650:	6946                	ld	s2,80(sp)
    80003652:	6a06                	ld	s4,64(sp)
    80003654:	7ae2                	ld	s5,56(sp)
    80003656:	7ba2                	ld	s7,40(sp)
    80003658:	b7c1                	j	80003618 <writei+0xf8>
        return -1;
    8000365a:	557d                	li	a0,-1
    8000365c:	6946                	ld	s2,80(sp)
    8000365e:	6a06                	ld	s4,64(sp)
    80003660:	7ae2                	ld	s5,56(sp)
    80003662:	7ba2                	ld	s7,40(sp)
    80003664:	bf55                	j	80003618 <writei+0xf8>

0000000080003666 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003666:	1141                	addi	sp,sp,-16
    80003668:	e406                	sd	ra,8(sp)
    8000366a:	e022                	sd	s0,0(sp)
    8000366c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000366e:	4639                	li	a2,14
    80003670:	f24fd0ef          	jal	80000d94 <strncmp>
}
    80003674:	60a2                	ld	ra,8(sp)
    80003676:	6402                	ld	s0,0(sp)
    80003678:	0141                	addi	sp,sp,16
    8000367a:	8082                	ret

000000008000367c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000367c:	7139                	addi	sp,sp,-64
    8000367e:	fc06                	sd	ra,56(sp)
    80003680:	f822                	sd	s0,48(sp)
    80003682:	f426                	sd	s1,40(sp)
    80003684:	f04a                	sd	s2,32(sp)
    80003686:	ec4e                	sd	s3,24(sp)
    80003688:	e852                	sd	s4,16(sp)
    8000368a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000368c:	04451703          	lh	a4,68(a0)
    80003690:	4785                	li	a5,1
    80003692:	00f71a63          	bne	a4,a5,800036a6 <dirlookup+0x2a>
    80003696:	892a                	mv	s2,a0
    80003698:	89ae                	mv	s3,a1
    8000369a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000369c:	457c                	lw	a5,76(a0)
    8000369e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800036a0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036a2:	e39d                	bnez	a5,800036c8 <dirlookup+0x4c>
    800036a4:	a095                	j	80003708 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800036a6:	00004517          	auipc	a0,0x4
    800036aa:	e7a50513          	addi	a0,a0,-390 # 80007520 <etext+0x520>
    800036ae:	8e6fd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800036b2:	00004517          	auipc	a0,0x4
    800036b6:	e8650513          	addi	a0,a0,-378 # 80007538 <etext+0x538>
    800036ba:	8dafd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036be:	24c1                	addiw	s1,s1,16
    800036c0:	04c92783          	lw	a5,76(s2)
    800036c4:	04f4f163          	bgeu	s1,a5,80003706 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036c8:	4741                	li	a4,16
    800036ca:	86a6                	mv	a3,s1
    800036cc:	fc040613          	addi	a2,s0,-64
    800036d0:	4581                	li	a1,0
    800036d2:	854a                	mv	a0,s2
    800036d4:	d47ff0ef          	jal	8000341a <readi>
    800036d8:	47c1                	li	a5,16
    800036da:	fcf51ce3          	bne	a0,a5,800036b2 <dirlookup+0x36>
    if(de.inum == 0)
    800036de:	fc045783          	lhu	a5,-64(s0)
    800036e2:	dff1                	beqz	a5,800036be <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800036e4:	fc240593          	addi	a1,s0,-62
    800036e8:	854e                	mv	a0,s3
    800036ea:	f7dff0ef          	jal	80003666 <namecmp>
    800036ee:	f961                	bnez	a0,800036be <dirlookup+0x42>
      if(poff)
    800036f0:	000a0463          	beqz	s4,800036f8 <dirlookup+0x7c>
        *poff = off;
    800036f4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800036f8:	fc045583          	lhu	a1,-64(s0)
    800036fc:	00092503          	lw	a0,0(s2)
    80003700:	fe0ff0ef          	jal	80002ee0 <iget>
    80003704:	a011                	j	80003708 <dirlookup+0x8c>
  return 0;
    80003706:	4501                	li	a0,0
}
    80003708:	70e2                	ld	ra,56(sp)
    8000370a:	7442                	ld	s0,48(sp)
    8000370c:	74a2                	ld	s1,40(sp)
    8000370e:	7902                	ld	s2,32(sp)
    80003710:	69e2                	ld	s3,24(sp)
    80003712:	6a42                	ld	s4,16(sp)
    80003714:	6121                	addi	sp,sp,64
    80003716:	8082                	ret

0000000080003718 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003718:	711d                	addi	sp,sp,-96
    8000371a:	ec86                	sd	ra,88(sp)
    8000371c:	e8a2                	sd	s0,80(sp)
    8000371e:	e4a6                	sd	s1,72(sp)
    80003720:	e0ca                	sd	s2,64(sp)
    80003722:	fc4e                	sd	s3,56(sp)
    80003724:	f852                	sd	s4,48(sp)
    80003726:	f456                	sd	s5,40(sp)
    80003728:	f05a                	sd	s6,32(sp)
    8000372a:	ec5e                	sd	s7,24(sp)
    8000372c:	e862                	sd	s8,16(sp)
    8000372e:	e466                	sd	s9,8(sp)
    80003730:	1080                	addi	s0,sp,96
    80003732:	84aa                	mv	s1,a0
    80003734:	8b2e                	mv	s6,a1
    80003736:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003738:	00054703          	lbu	a4,0(a0)
    8000373c:	02f00793          	li	a5,47
    80003740:	00f70e63          	beq	a4,a5,8000375c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003744:	99cfe0ef          	jal	800018e0 <myproc>
    80003748:	15053503          	ld	a0,336(a0)
    8000374c:	a45ff0ef          	jal	80003190 <idup>
    80003750:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003752:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003756:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003758:	4b85                	li	s7,1
    8000375a:	a871                	j	800037f6 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    8000375c:	4585                	li	a1,1
    8000375e:	4505                	li	a0,1
    80003760:	f80ff0ef          	jal	80002ee0 <iget>
    80003764:	8a2a                	mv	s4,a0
    80003766:	b7f5                	j	80003752 <namex+0x3a>
      iunlockput(ip);
    80003768:	8552                	mv	a0,s4
    8000376a:	c67ff0ef          	jal	800033d0 <iunlockput>
      return 0;
    8000376e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003770:	8552                	mv	a0,s4
    80003772:	60e6                	ld	ra,88(sp)
    80003774:	6446                	ld	s0,80(sp)
    80003776:	64a6                	ld	s1,72(sp)
    80003778:	6906                	ld	s2,64(sp)
    8000377a:	79e2                	ld	s3,56(sp)
    8000377c:	7a42                	ld	s4,48(sp)
    8000377e:	7aa2                	ld	s5,40(sp)
    80003780:	7b02                	ld	s6,32(sp)
    80003782:	6be2                	ld	s7,24(sp)
    80003784:	6c42                	ld	s8,16(sp)
    80003786:	6ca2                	ld	s9,8(sp)
    80003788:	6125                	addi	sp,sp,96
    8000378a:	8082                	ret
      iunlock(ip);
    8000378c:	8552                	mv	a0,s4
    8000378e:	ae7ff0ef          	jal	80003274 <iunlock>
      return ip;
    80003792:	bff9                	j	80003770 <namex+0x58>
      iunlockput(ip);
    80003794:	8552                	mv	a0,s4
    80003796:	c3bff0ef          	jal	800033d0 <iunlockput>
      return 0;
    8000379a:	8a4e                	mv	s4,s3
    8000379c:	bfd1                	j	80003770 <namex+0x58>
  len = path - s;
    8000379e:	40998633          	sub	a2,s3,s1
    800037a2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800037a6:	099c5063          	bge	s8,s9,80003826 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800037aa:	4639                	li	a2,14
    800037ac:	85a6                	mv	a1,s1
    800037ae:	8556                	mv	a0,s5
    800037b0:	d74fd0ef          	jal	80000d24 <memmove>
    800037b4:	84ce                	mv	s1,s3
  while(*path == '/')
    800037b6:	0004c783          	lbu	a5,0(s1)
    800037ba:	01279763          	bne	a5,s2,800037c8 <namex+0xb0>
    path++;
    800037be:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037c0:	0004c783          	lbu	a5,0(s1)
    800037c4:	ff278de3          	beq	a5,s2,800037be <namex+0xa6>
    ilock(ip);
    800037c8:	8552                	mv	a0,s4
    800037ca:	9fdff0ef          	jal	800031c6 <ilock>
    if(ip->type != T_DIR){
    800037ce:	044a1783          	lh	a5,68(s4)
    800037d2:	f9779be3          	bne	a5,s7,80003768 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800037d6:	000b0563          	beqz	s6,800037e0 <namex+0xc8>
    800037da:	0004c783          	lbu	a5,0(s1)
    800037de:	d7dd                	beqz	a5,8000378c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800037e0:	4601                	li	a2,0
    800037e2:	85d6                	mv	a1,s5
    800037e4:	8552                	mv	a0,s4
    800037e6:	e97ff0ef          	jal	8000367c <dirlookup>
    800037ea:	89aa                	mv	s3,a0
    800037ec:	d545                	beqz	a0,80003794 <namex+0x7c>
    iunlockput(ip);
    800037ee:	8552                	mv	a0,s4
    800037f0:	be1ff0ef          	jal	800033d0 <iunlockput>
    ip = next;
    800037f4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800037f6:	0004c783          	lbu	a5,0(s1)
    800037fa:	01279763          	bne	a5,s2,80003808 <namex+0xf0>
    path++;
    800037fe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003800:	0004c783          	lbu	a5,0(s1)
    80003804:	ff278de3          	beq	a5,s2,800037fe <namex+0xe6>
  if(*path == 0)
    80003808:	cb8d                	beqz	a5,8000383a <namex+0x122>
  while(*path != '/' && *path != 0)
    8000380a:	0004c783          	lbu	a5,0(s1)
    8000380e:	89a6                	mv	s3,s1
  len = path - s;
    80003810:	4c81                	li	s9,0
    80003812:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003814:	01278963          	beq	a5,s2,80003826 <namex+0x10e>
    80003818:	d3d9                	beqz	a5,8000379e <namex+0x86>
    path++;
    8000381a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000381c:	0009c783          	lbu	a5,0(s3)
    80003820:	ff279ce3          	bne	a5,s2,80003818 <namex+0x100>
    80003824:	bfad                	j	8000379e <namex+0x86>
    memmove(name, s, len);
    80003826:	2601                	sext.w	a2,a2
    80003828:	85a6                	mv	a1,s1
    8000382a:	8556                	mv	a0,s5
    8000382c:	cf8fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003830:	9cd6                	add	s9,s9,s5
    80003832:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003836:	84ce                	mv	s1,s3
    80003838:	bfbd                	j	800037b6 <namex+0x9e>
  if(nameiparent){
    8000383a:	f20b0be3          	beqz	s6,80003770 <namex+0x58>
    iput(ip);
    8000383e:	8552                	mv	a0,s4
    80003840:	b09ff0ef          	jal	80003348 <iput>
    return 0;
    80003844:	4a01                	li	s4,0
    80003846:	b72d                	j	80003770 <namex+0x58>

0000000080003848 <dirlink>:
{
    80003848:	7139                	addi	sp,sp,-64
    8000384a:	fc06                	sd	ra,56(sp)
    8000384c:	f822                	sd	s0,48(sp)
    8000384e:	f04a                	sd	s2,32(sp)
    80003850:	ec4e                	sd	s3,24(sp)
    80003852:	e852                	sd	s4,16(sp)
    80003854:	0080                	addi	s0,sp,64
    80003856:	892a                	mv	s2,a0
    80003858:	8a2e                	mv	s4,a1
    8000385a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000385c:	4601                	li	a2,0
    8000385e:	e1fff0ef          	jal	8000367c <dirlookup>
    80003862:	e535                	bnez	a0,800038ce <dirlink+0x86>
    80003864:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003866:	04c92483          	lw	s1,76(s2)
    8000386a:	c48d                	beqz	s1,80003894 <dirlink+0x4c>
    8000386c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000386e:	4741                	li	a4,16
    80003870:	86a6                	mv	a3,s1
    80003872:	fc040613          	addi	a2,s0,-64
    80003876:	4581                	li	a1,0
    80003878:	854a                	mv	a0,s2
    8000387a:	ba1ff0ef          	jal	8000341a <readi>
    8000387e:	47c1                	li	a5,16
    80003880:	04f51b63          	bne	a0,a5,800038d6 <dirlink+0x8e>
    if(de.inum == 0)
    80003884:	fc045783          	lhu	a5,-64(s0)
    80003888:	c791                	beqz	a5,80003894 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000388a:	24c1                	addiw	s1,s1,16
    8000388c:	04c92783          	lw	a5,76(s2)
    80003890:	fcf4efe3          	bltu	s1,a5,8000386e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003894:	4639                	li	a2,14
    80003896:	85d2                	mv	a1,s4
    80003898:	fc240513          	addi	a0,s0,-62
    8000389c:	d2efd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    800038a0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038a4:	4741                	li	a4,16
    800038a6:	86a6                	mv	a3,s1
    800038a8:	fc040613          	addi	a2,s0,-64
    800038ac:	4581                	li	a1,0
    800038ae:	854a                	mv	a0,s2
    800038b0:	c71ff0ef          	jal	80003520 <writei>
    800038b4:	1541                	addi	a0,a0,-16
    800038b6:	00a03533          	snez	a0,a0
    800038ba:	40a00533          	neg	a0,a0
    800038be:	74a2                	ld	s1,40(sp)
}
    800038c0:	70e2                	ld	ra,56(sp)
    800038c2:	7442                	ld	s0,48(sp)
    800038c4:	7902                	ld	s2,32(sp)
    800038c6:	69e2                	ld	s3,24(sp)
    800038c8:	6a42                	ld	s4,16(sp)
    800038ca:	6121                	addi	sp,sp,64
    800038cc:	8082                	ret
    iput(ip);
    800038ce:	a7bff0ef          	jal	80003348 <iput>
    return -1;
    800038d2:	557d                	li	a0,-1
    800038d4:	b7f5                	j	800038c0 <dirlink+0x78>
      panic("dirlink read");
    800038d6:	00004517          	auipc	a0,0x4
    800038da:	c7250513          	addi	a0,a0,-910 # 80007548 <etext+0x548>
    800038de:	eb7fc0ef          	jal	80000794 <panic>

00000000800038e2 <namei>:

struct inode*
namei(char *path)
{
    800038e2:	1101                	addi	sp,sp,-32
    800038e4:	ec06                	sd	ra,24(sp)
    800038e6:	e822                	sd	s0,16(sp)
    800038e8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800038ea:	fe040613          	addi	a2,s0,-32
    800038ee:	4581                	li	a1,0
    800038f0:	e29ff0ef          	jal	80003718 <namex>
}
    800038f4:	60e2                	ld	ra,24(sp)
    800038f6:	6442                	ld	s0,16(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret

00000000800038fc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800038fc:	1141                	addi	sp,sp,-16
    800038fe:	e406                	sd	ra,8(sp)
    80003900:	e022                	sd	s0,0(sp)
    80003902:	0800                	addi	s0,sp,16
    80003904:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003906:	4585                	li	a1,1
    80003908:	e11ff0ef          	jal	80003718 <namex>
}
    8000390c:	60a2                	ld	ra,8(sp)
    8000390e:	6402                	ld	s0,0(sp)
    80003910:	0141                	addi	sp,sp,16
    80003912:	8082                	ret

0000000080003914 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003914:	1101                	addi	sp,sp,-32
    80003916:	ec06                	sd	ra,24(sp)
    80003918:	e822                	sd	s0,16(sp)
    8000391a:	e426                	sd	s1,8(sp)
    8000391c:	e04a                	sd	s2,0(sp)
    8000391e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003920:	0001c917          	auipc	s2,0x1c
    80003924:	0f090913          	addi	s2,s2,240 # 8001fa10 <log>
    80003928:	01892583          	lw	a1,24(s2)
    8000392c:	02892503          	lw	a0,40(s2)
    80003930:	958ff0ef          	jal	80002a88 <bread>
    80003934:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003936:	02c92603          	lw	a2,44(s2)
    8000393a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000393c:	00c05f63          	blez	a2,8000395a <write_head+0x46>
    80003940:	0001c717          	auipc	a4,0x1c
    80003944:	10070713          	addi	a4,a4,256 # 8001fa40 <log+0x30>
    80003948:	87aa                	mv	a5,a0
    8000394a:	060a                	slli	a2,a2,0x2
    8000394c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000394e:	4314                	lw	a3,0(a4)
    80003950:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003952:	0711                	addi	a4,a4,4
    80003954:	0791                	addi	a5,a5,4
    80003956:	fec79ce3          	bne	a5,a2,8000394e <write_head+0x3a>
  }
  bwrite(buf);
    8000395a:	8526                	mv	a0,s1
    8000395c:	a02ff0ef          	jal	80002b5e <bwrite>
  brelse(buf);
    80003960:	8526                	mv	a0,s1
    80003962:	a2eff0ef          	jal	80002b90 <brelse>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6902                	ld	s2,0(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret

0000000080003972 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003972:	0001c797          	auipc	a5,0x1c
    80003976:	0ca7a783          	lw	a5,202(a5) # 8001fa3c <log+0x2c>
    8000397a:	08f05f63          	blez	a5,80003a18 <install_trans+0xa6>
{
    8000397e:	7139                	addi	sp,sp,-64
    80003980:	fc06                	sd	ra,56(sp)
    80003982:	f822                	sd	s0,48(sp)
    80003984:	f426                	sd	s1,40(sp)
    80003986:	f04a                	sd	s2,32(sp)
    80003988:	ec4e                	sd	s3,24(sp)
    8000398a:	e852                	sd	s4,16(sp)
    8000398c:	e456                	sd	s5,8(sp)
    8000398e:	e05a                	sd	s6,0(sp)
    80003990:	0080                	addi	s0,sp,64
    80003992:	8b2a                	mv	s6,a0
    80003994:	0001ca97          	auipc	s5,0x1c
    80003998:	0aca8a93          	addi	s5,s5,172 # 8001fa40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000399c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000399e:	0001c997          	auipc	s3,0x1c
    800039a2:	07298993          	addi	s3,s3,114 # 8001fa10 <log>
    800039a6:	a829                	j	800039c0 <install_trans+0x4e>
    brelse(lbuf);
    800039a8:	854a                	mv	a0,s2
    800039aa:	9e6ff0ef          	jal	80002b90 <brelse>
    brelse(dbuf);
    800039ae:	8526                	mv	a0,s1
    800039b0:	9e0ff0ef          	jal	80002b90 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039b4:	2a05                	addiw	s4,s4,1
    800039b6:	0a91                	addi	s5,s5,4
    800039b8:	02c9a783          	lw	a5,44(s3)
    800039bc:	04fa5463          	bge	s4,a5,80003a04 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039c0:	0189a583          	lw	a1,24(s3)
    800039c4:	014585bb          	addw	a1,a1,s4
    800039c8:	2585                	addiw	a1,a1,1
    800039ca:	0289a503          	lw	a0,40(s3)
    800039ce:	8baff0ef          	jal	80002a88 <bread>
    800039d2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800039d4:	000aa583          	lw	a1,0(s5)
    800039d8:	0289a503          	lw	a0,40(s3)
    800039dc:	8acff0ef          	jal	80002a88 <bread>
    800039e0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039e2:	40000613          	li	a2,1024
    800039e6:	05890593          	addi	a1,s2,88
    800039ea:	05850513          	addi	a0,a0,88
    800039ee:	b36fd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    800039f2:	8526                	mv	a0,s1
    800039f4:	96aff0ef          	jal	80002b5e <bwrite>
    if(recovering == 0)
    800039f8:	fa0b18e3          	bnez	s6,800039a8 <install_trans+0x36>
      bunpin(dbuf);
    800039fc:	8526                	mv	a0,s1
    800039fe:	a4eff0ef          	jal	80002c4c <bunpin>
    80003a02:	b75d                	j	800039a8 <install_trans+0x36>
}
    80003a04:	70e2                	ld	ra,56(sp)
    80003a06:	7442                	ld	s0,48(sp)
    80003a08:	74a2                	ld	s1,40(sp)
    80003a0a:	7902                	ld	s2,32(sp)
    80003a0c:	69e2                	ld	s3,24(sp)
    80003a0e:	6a42                	ld	s4,16(sp)
    80003a10:	6aa2                	ld	s5,8(sp)
    80003a12:	6b02                	ld	s6,0(sp)
    80003a14:	6121                	addi	sp,sp,64
    80003a16:	8082                	ret
    80003a18:	8082                	ret

0000000080003a1a <initlog>:
{
    80003a1a:	7179                	addi	sp,sp,-48
    80003a1c:	f406                	sd	ra,40(sp)
    80003a1e:	f022                	sd	s0,32(sp)
    80003a20:	ec26                	sd	s1,24(sp)
    80003a22:	e84a                	sd	s2,16(sp)
    80003a24:	e44e                	sd	s3,8(sp)
    80003a26:	1800                	addi	s0,sp,48
    80003a28:	892a                	mv	s2,a0
    80003a2a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a2c:	0001c497          	auipc	s1,0x1c
    80003a30:	fe448493          	addi	s1,s1,-28 # 8001fa10 <log>
    80003a34:	00004597          	auipc	a1,0x4
    80003a38:	b2458593          	addi	a1,a1,-1244 # 80007558 <etext+0x558>
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	936fd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003a42:	0149a583          	lw	a1,20(s3)
    80003a46:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a48:	0109a783          	lw	a5,16(s3)
    80003a4c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a4e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a52:	854a                	mv	a0,s2
    80003a54:	834ff0ef          	jal	80002a88 <bread>
  log.lh.n = lh->n;
    80003a58:	4d30                	lw	a2,88(a0)
    80003a5a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a5c:	00c05f63          	blez	a2,80003a7a <initlog+0x60>
    80003a60:	87aa                	mv	a5,a0
    80003a62:	0001c717          	auipc	a4,0x1c
    80003a66:	fde70713          	addi	a4,a4,-34 # 8001fa40 <log+0x30>
    80003a6a:	060a                	slli	a2,a2,0x2
    80003a6c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003a6e:	4ff4                	lw	a3,92(a5)
    80003a70:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003a72:	0791                	addi	a5,a5,4
    80003a74:	0711                	addi	a4,a4,4
    80003a76:	fec79ce3          	bne	a5,a2,80003a6e <initlog+0x54>
  brelse(buf);
    80003a7a:	916ff0ef          	jal	80002b90 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003a7e:	4505                	li	a0,1
    80003a80:	ef3ff0ef          	jal	80003972 <install_trans>
  log.lh.n = 0;
    80003a84:	0001c797          	auipc	a5,0x1c
    80003a88:	fa07ac23          	sw	zero,-72(a5) # 8001fa3c <log+0x2c>
  write_head(); // clear the log
    80003a8c:	e89ff0ef          	jal	80003914 <write_head>
}
    80003a90:	70a2                	ld	ra,40(sp)
    80003a92:	7402                	ld	s0,32(sp)
    80003a94:	64e2                	ld	s1,24(sp)
    80003a96:	6942                	ld	s2,16(sp)
    80003a98:	69a2                	ld	s3,8(sp)
    80003a9a:	6145                	addi	sp,sp,48
    80003a9c:	8082                	ret

0000000080003a9e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003aaa:	0001c517          	auipc	a0,0x1c
    80003aae:	f6650513          	addi	a0,a0,-154 # 8001fa10 <log>
    80003ab2:	942fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003ab6:	0001c497          	auipc	s1,0x1c
    80003aba:	f5a48493          	addi	s1,s1,-166 # 8001fa10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003abe:	4979                	li	s2,30
    80003ac0:	a029                	j	80003aca <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ac2:	85a6                	mv	a1,s1
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	be8fe0ef          	jal	80001eae <sleep>
    if(log.committing){
    80003aca:	50dc                	lw	a5,36(s1)
    80003acc:	fbfd                	bnez	a5,80003ac2 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ace:	5098                	lw	a4,32(s1)
    80003ad0:	2705                	addiw	a4,a4,1
    80003ad2:	0027179b          	slliw	a5,a4,0x2
    80003ad6:	9fb9                	addw	a5,a5,a4
    80003ad8:	0017979b          	slliw	a5,a5,0x1
    80003adc:	54d4                	lw	a3,44(s1)
    80003ade:	9fb5                	addw	a5,a5,a3
    80003ae0:	00f95763          	bge	s2,a5,80003aee <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003ae4:	85a6                	mv	a1,s1
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	bc6fe0ef          	jal	80001eae <sleep>
    80003aec:	bff9                	j	80003aca <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003aee:	0001c517          	auipc	a0,0x1c
    80003af2:	f2250513          	addi	a0,a0,-222 # 8001fa10 <log>
    80003af6:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003af8:	994fd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003afc:	60e2                	ld	ra,24(sp)
    80003afe:	6442                	ld	s0,16(sp)
    80003b00:	64a2                	ld	s1,8(sp)
    80003b02:	6902                	ld	s2,0(sp)
    80003b04:	6105                	addi	sp,sp,32
    80003b06:	8082                	ret

0000000080003b08 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b08:	7139                	addi	sp,sp,-64
    80003b0a:	fc06                	sd	ra,56(sp)
    80003b0c:	f822                	sd	s0,48(sp)
    80003b0e:	f426                	sd	s1,40(sp)
    80003b10:	f04a                	sd	s2,32(sp)
    80003b12:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b14:	0001c497          	auipc	s1,0x1c
    80003b18:	efc48493          	addi	s1,s1,-260 # 8001fa10 <log>
    80003b1c:	8526                	mv	a0,s1
    80003b1e:	8d6fd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003b22:	509c                	lw	a5,32(s1)
    80003b24:	37fd                	addiw	a5,a5,-1
    80003b26:	0007891b          	sext.w	s2,a5
    80003b2a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b2c:	50dc                	lw	a5,36(s1)
    80003b2e:	ef9d                	bnez	a5,80003b6c <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b30:	04091763          	bnez	s2,80003b7e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b34:	0001c497          	auipc	s1,0x1c
    80003b38:	edc48493          	addi	s1,s1,-292 # 8001fa10 <log>
    80003b3c:	4785                	li	a5,1
    80003b3e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b40:	8526                	mv	a0,s1
    80003b42:	94afd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b46:	54dc                	lw	a5,44(s1)
    80003b48:	04f04b63          	bgtz	a5,80003b9e <end_op+0x96>
    acquire(&log.lock);
    80003b4c:	0001c497          	auipc	s1,0x1c
    80003b50:	ec448493          	addi	s1,s1,-316 # 8001fa10 <log>
    80003b54:	8526                	mv	a0,s1
    80003b56:	89efd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003b5a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003b5e:	8526                	mv	a0,s1
    80003b60:	b9afe0ef          	jal	80001efa <wakeup>
    release(&log.lock);
    80003b64:	8526                	mv	a0,s1
    80003b66:	926fd0ef          	jal	80000c8c <release>
}
    80003b6a:	a025                	j	80003b92 <end_op+0x8a>
    80003b6c:	ec4e                	sd	s3,24(sp)
    80003b6e:	e852                	sd	s4,16(sp)
    80003b70:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003b72:	00004517          	auipc	a0,0x4
    80003b76:	9ee50513          	addi	a0,a0,-1554 # 80007560 <etext+0x560>
    80003b7a:	c1bfc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003b7e:	0001c497          	auipc	s1,0x1c
    80003b82:	e9248493          	addi	s1,s1,-366 # 8001fa10 <log>
    80003b86:	8526                	mv	a0,s1
    80003b88:	b72fe0ef          	jal	80001efa <wakeup>
  release(&log.lock);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	8fefd0ef          	jal	80000c8c <release>
}
    80003b92:	70e2                	ld	ra,56(sp)
    80003b94:	7442                	ld	s0,48(sp)
    80003b96:	74a2                	ld	s1,40(sp)
    80003b98:	7902                	ld	s2,32(sp)
    80003b9a:	6121                	addi	sp,sp,64
    80003b9c:	8082                	ret
    80003b9e:	ec4e                	sd	s3,24(sp)
    80003ba0:	e852                	sd	s4,16(sp)
    80003ba2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ba4:	0001ca97          	auipc	s5,0x1c
    80003ba8:	e9ca8a93          	addi	s5,s5,-356 # 8001fa40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bac:	0001ca17          	auipc	s4,0x1c
    80003bb0:	e64a0a13          	addi	s4,s4,-412 # 8001fa10 <log>
    80003bb4:	018a2583          	lw	a1,24(s4)
    80003bb8:	012585bb          	addw	a1,a1,s2
    80003bbc:	2585                	addiw	a1,a1,1
    80003bbe:	028a2503          	lw	a0,40(s4)
    80003bc2:	ec7fe0ef          	jal	80002a88 <bread>
    80003bc6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003bc8:	000aa583          	lw	a1,0(s5)
    80003bcc:	028a2503          	lw	a0,40(s4)
    80003bd0:	eb9fe0ef          	jal	80002a88 <bread>
    80003bd4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003bd6:	40000613          	li	a2,1024
    80003bda:	05850593          	addi	a1,a0,88
    80003bde:	05848513          	addi	a0,s1,88
    80003be2:	942fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003be6:	8526                	mv	a0,s1
    80003be8:	f77fe0ef          	jal	80002b5e <bwrite>
    brelse(from);
    80003bec:	854e                	mv	a0,s3
    80003bee:	fa3fe0ef          	jal	80002b90 <brelse>
    brelse(to);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	f9dfe0ef          	jal	80002b90 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf8:	2905                	addiw	s2,s2,1
    80003bfa:	0a91                	addi	s5,s5,4
    80003bfc:	02ca2783          	lw	a5,44(s4)
    80003c00:	faf94ae3          	blt	s2,a5,80003bb4 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c04:	d11ff0ef          	jal	80003914 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c08:	4501                	li	a0,0
    80003c0a:	d69ff0ef          	jal	80003972 <install_trans>
    log.lh.n = 0;
    80003c0e:	0001c797          	auipc	a5,0x1c
    80003c12:	e207a723          	sw	zero,-466(a5) # 8001fa3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003c16:	cffff0ef          	jal	80003914 <write_head>
    80003c1a:	69e2                	ld	s3,24(sp)
    80003c1c:	6a42                	ld	s4,16(sp)
    80003c1e:	6aa2                	ld	s5,8(sp)
    80003c20:	b735                	j	80003b4c <end_op+0x44>

0000000080003c22 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c22:	1101                	addi	sp,sp,-32
    80003c24:	ec06                	sd	ra,24(sp)
    80003c26:	e822                	sd	s0,16(sp)
    80003c28:	e426                	sd	s1,8(sp)
    80003c2a:	e04a                	sd	s2,0(sp)
    80003c2c:	1000                	addi	s0,sp,32
    80003c2e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c30:	0001c917          	auipc	s2,0x1c
    80003c34:	de090913          	addi	s2,s2,-544 # 8001fa10 <log>
    80003c38:	854a                	mv	a0,s2
    80003c3a:	fbbfc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c3e:	02c92603          	lw	a2,44(s2)
    80003c42:	47f5                	li	a5,29
    80003c44:	06c7c363          	blt	a5,a2,80003caa <log_write+0x88>
    80003c48:	0001c797          	auipc	a5,0x1c
    80003c4c:	de47a783          	lw	a5,-540(a5) # 8001fa2c <log+0x1c>
    80003c50:	37fd                	addiw	a5,a5,-1
    80003c52:	04f65c63          	bge	a2,a5,80003caa <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c56:	0001c797          	auipc	a5,0x1c
    80003c5a:	dda7a783          	lw	a5,-550(a5) # 8001fa30 <log+0x20>
    80003c5e:	04f05c63          	blez	a5,80003cb6 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c62:	4781                	li	a5,0
    80003c64:	04c05f63          	blez	a2,80003cc2 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c68:	44cc                	lw	a1,12(s1)
    80003c6a:	0001c717          	auipc	a4,0x1c
    80003c6e:	dd670713          	addi	a4,a4,-554 # 8001fa40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003c72:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c74:	4314                	lw	a3,0(a4)
    80003c76:	04b68663          	beq	a3,a1,80003cc2 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003c7a:	2785                	addiw	a5,a5,1
    80003c7c:	0711                	addi	a4,a4,4
    80003c7e:	fef61be3          	bne	a2,a5,80003c74 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003c82:	0621                	addi	a2,a2,8
    80003c84:	060a                	slli	a2,a2,0x2
    80003c86:	0001c797          	auipc	a5,0x1c
    80003c8a:	d8a78793          	addi	a5,a5,-630 # 8001fa10 <log>
    80003c8e:	97b2                	add	a5,a5,a2
    80003c90:	44d8                	lw	a4,12(s1)
    80003c92:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003c94:	8526                	mv	a0,s1
    80003c96:	f83fe0ef          	jal	80002c18 <bpin>
    log.lh.n++;
    80003c9a:	0001c717          	auipc	a4,0x1c
    80003c9e:	d7670713          	addi	a4,a4,-650 # 8001fa10 <log>
    80003ca2:	575c                	lw	a5,44(a4)
    80003ca4:	2785                	addiw	a5,a5,1
    80003ca6:	d75c                	sw	a5,44(a4)
    80003ca8:	a80d                	j	80003cda <log_write+0xb8>
    panic("too big a transaction");
    80003caa:	00004517          	auipc	a0,0x4
    80003cae:	8c650513          	addi	a0,a0,-1850 # 80007570 <etext+0x570>
    80003cb2:	ae3fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003cb6:	00004517          	auipc	a0,0x4
    80003cba:	8d250513          	addi	a0,a0,-1838 # 80007588 <etext+0x588>
    80003cbe:	ad7fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003cc2:	00878693          	addi	a3,a5,8
    80003cc6:	068a                	slli	a3,a3,0x2
    80003cc8:	0001c717          	auipc	a4,0x1c
    80003ccc:	d4870713          	addi	a4,a4,-696 # 8001fa10 <log>
    80003cd0:	9736                	add	a4,a4,a3
    80003cd2:	44d4                	lw	a3,12(s1)
    80003cd4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003cd6:	faf60fe3          	beq	a2,a5,80003c94 <log_write+0x72>
  }
  release(&log.lock);
    80003cda:	0001c517          	auipc	a0,0x1c
    80003cde:	d3650513          	addi	a0,a0,-714 # 8001fa10 <log>
    80003ce2:	fabfc0ef          	jal	80000c8c <release>
}
    80003ce6:	60e2                	ld	ra,24(sp)
    80003ce8:	6442                	ld	s0,16(sp)
    80003cea:	64a2                	ld	s1,8(sp)
    80003cec:	6902                	ld	s2,0(sp)
    80003cee:	6105                	addi	sp,sp,32
    80003cf0:	8082                	ret

0000000080003cf2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003cf2:	1101                	addi	sp,sp,-32
    80003cf4:	ec06                	sd	ra,24(sp)
    80003cf6:	e822                	sd	s0,16(sp)
    80003cf8:	e426                	sd	s1,8(sp)
    80003cfa:	e04a                	sd	s2,0(sp)
    80003cfc:	1000                	addi	s0,sp,32
    80003cfe:	84aa                	mv	s1,a0
    80003d00:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d02:	00004597          	auipc	a1,0x4
    80003d06:	8a658593          	addi	a1,a1,-1882 # 800075a8 <etext+0x5a8>
    80003d0a:	0521                	addi	a0,a0,8
    80003d0c:	e69fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003d10:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d14:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d18:	0204a423          	sw	zero,40(s1)
}
    80003d1c:	60e2                	ld	ra,24(sp)
    80003d1e:	6442                	ld	s0,16(sp)
    80003d20:	64a2                	ld	s1,8(sp)
    80003d22:	6902                	ld	s2,0(sp)
    80003d24:	6105                	addi	sp,sp,32
    80003d26:	8082                	ret

0000000080003d28 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d28:	1101                	addi	sp,sp,-32
    80003d2a:	ec06                	sd	ra,24(sp)
    80003d2c:	e822                	sd	s0,16(sp)
    80003d2e:	e426                	sd	s1,8(sp)
    80003d30:	e04a                	sd	s2,0(sp)
    80003d32:	1000                	addi	s0,sp,32
    80003d34:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d36:	00850913          	addi	s2,a0,8
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	eb9fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003d40:	409c                	lw	a5,0(s1)
    80003d42:	c799                	beqz	a5,80003d50 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d44:	85ca                	mv	a1,s2
    80003d46:	8526                	mv	a0,s1
    80003d48:	966fe0ef          	jal	80001eae <sleep>
  while (lk->locked) {
    80003d4c:	409c                	lw	a5,0(s1)
    80003d4e:	fbfd                	bnez	a5,80003d44 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d50:	4785                	li	a5,1
    80003d52:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d54:	b8dfd0ef          	jal	800018e0 <myproc>
    80003d58:	591c                	lw	a5,48(a0)
    80003d5a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	f2ffc0ef          	jal	80000c8c <release>
}
    80003d62:	60e2                	ld	ra,24(sp)
    80003d64:	6442                	ld	s0,16(sp)
    80003d66:	64a2                	ld	s1,8(sp)
    80003d68:	6902                	ld	s2,0(sp)
    80003d6a:	6105                	addi	sp,sp,32
    80003d6c:	8082                	ret

0000000080003d6e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003d6e:	1101                	addi	sp,sp,-32
    80003d70:	ec06                	sd	ra,24(sp)
    80003d72:	e822                	sd	s0,16(sp)
    80003d74:	e426                	sd	s1,8(sp)
    80003d76:	e04a                	sd	s2,0(sp)
    80003d78:	1000                	addi	s0,sp,32
    80003d7a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d7c:	00850913          	addi	s2,a0,8
    80003d80:	854a                	mv	a0,s2
    80003d82:	e73fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003d86:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d8a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003d8e:	8526                	mv	a0,s1
    80003d90:	96afe0ef          	jal	80001efa <wakeup>
  release(&lk->lk);
    80003d94:	854a                	mv	a0,s2
    80003d96:	ef7fc0ef          	jal	80000c8c <release>
}
    80003d9a:	60e2                	ld	ra,24(sp)
    80003d9c:	6442                	ld	s0,16(sp)
    80003d9e:	64a2                	ld	s1,8(sp)
    80003da0:	6902                	ld	s2,0(sp)
    80003da2:	6105                	addi	sp,sp,32
    80003da4:	8082                	ret

0000000080003da6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003da6:	7179                	addi	sp,sp,-48
    80003da8:	f406                	sd	ra,40(sp)
    80003daa:	f022                	sd	s0,32(sp)
    80003dac:	ec26                	sd	s1,24(sp)
    80003dae:	e84a                	sd	s2,16(sp)
    80003db0:	1800                	addi	s0,sp,48
    80003db2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003db4:	00850913          	addi	s2,a0,8
    80003db8:	854a                	mv	a0,s2
    80003dba:	e3bfc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003dbe:	409c                	lw	a5,0(s1)
    80003dc0:	ef81                	bnez	a5,80003dd8 <holdingsleep+0x32>
    80003dc2:	4481                	li	s1,0
  release(&lk->lk);
    80003dc4:	854a                	mv	a0,s2
    80003dc6:	ec7fc0ef          	jal	80000c8c <release>
  return r;
}
    80003dca:	8526                	mv	a0,s1
    80003dcc:	70a2                	ld	ra,40(sp)
    80003dce:	7402                	ld	s0,32(sp)
    80003dd0:	64e2                	ld	s1,24(sp)
    80003dd2:	6942                	ld	s2,16(sp)
    80003dd4:	6145                	addi	sp,sp,48
    80003dd6:	8082                	ret
    80003dd8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003dda:	0284a983          	lw	s3,40(s1)
    80003dde:	b03fd0ef          	jal	800018e0 <myproc>
    80003de2:	5904                	lw	s1,48(a0)
    80003de4:	413484b3          	sub	s1,s1,s3
    80003de8:	0014b493          	seqz	s1,s1
    80003dec:	69a2                	ld	s3,8(sp)
    80003dee:	bfd9                	j	80003dc4 <holdingsleep+0x1e>

0000000080003df0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003df0:	1141                	addi	sp,sp,-16
    80003df2:	e406                	sd	ra,8(sp)
    80003df4:	e022                	sd	s0,0(sp)
    80003df6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003df8:	00003597          	auipc	a1,0x3
    80003dfc:	7c058593          	addi	a1,a1,1984 # 800075b8 <etext+0x5b8>
    80003e00:	0001c517          	auipc	a0,0x1c
    80003e04:	d5850513          	addi	a0,a0,-680 # 8001fb58 <ftable>
    80003e08:	d6dfc0ef          	jal	80000b74 <initlock>
}
    80003e0c:	60a2                	ld	ra,8(sp)
    80003e0e:	6402                	ld	s0,0(sp)
    80003e10:	0141                	addi	sp,sp,16
    80003e12:	8082                	ret

0000000080003e14 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e14:	1101                	addi	sp,sp,-32
    80003e16:	ec06                	sd	ra,24(sp)
    80003e18:	e822                	sd	s0,16(sp)
    80003e1a:	e426                	sd	s1,8(sp)
    80003e1c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e1e:	0001c517          	auipc	a0,0x1c
    80003e22:	d3a50513          	addi	a0,a0,-710 # 8001fb58 <ftable>
    80003e26:	dcffc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e2a:	0001c497          	auipc	s1,0x1c
    80003e2e:	d4648493          	addi	s1,s1,-698 # 8001fb70 <ftable+0x18>
    80003e32:	0001d717          	auipc	a4,0x1d
    80003e36:	cde70713          	addi	a4,a4,-802 # 80020b10 <disk>
    if(f->ref == 0){
    80003e3a:	40dc                	lw	a5,4(s1)
    80003e3c:	cf89                	beqz	a5,80003e56 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e3e:	02848493          	addi	s1,s1,40
    80003e42:	fee49ce3          	bne	s1,a4,80003e3a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e46:	0001c517          	auipc	a0,0x1c
    80003e4a:	d1250513          	addi	a0,a0,-750 # 8001fb58 <ftable>
    80003e4e:	e3ffc0ef          	jal	80000c8c <release>
  return 0;
    80003e52:	4481                	li	s1,0
    80003e54:	a809                	j	80003e66 <filealloc+0x52>
      f->ref = 1;
    80003e56:	4785                	li	a5,1
    80003e58:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e5a:	0001c517          	auipc	a0,0x1c
    80003e5e:	cfe50513          	addi	a0,a0,-770 # 8001fb58 <ftable>
    80003e62:	e2bfc0ef          	jal	80000c8c <release>
}
    80003e66:	8526                	mv	a0,s1
    80003e68:	60e2                	ld	ra,24(sp)
    80003e6a:	6442                	ld	s0,16(sp)
    80003e6c:	64a2                	ld	s1,8(sp)
    80003e6e:	6105                	addi	sp,sp,32
    80003e70:	8082                	ret

0000000080003e72 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003e72:	1101                	addi	sp,sp,-32
    80003e74:	ec06                	sd	ra,24(sp)
    80003e76:	e822                	sd	s0,16(sp)
    80003e78:	e426                	sd	s1,8(sp)
    80003e7a:	1000                	addi	s0,sp,32
    80003e7c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003e7e:	0001c517          	auipc	a0,0x1c
    80003e82:	cda50513          	addi	a0,a0,-806 # 8001fb58 <ftable>
    80003e86:	d6ffc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003e8a:	40dc                	lw	a5,4(s1)
    80003e8c:	02f05063          	blez	a5,80003eac <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003e90:	2785                	addiw	a5,a5,1
    80003e92:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003e94:	0001c517          	auipc	a0,0x1c
    80003e98:	cc450513          	addi	a0,a0,-828 # 8001fb58 <ftable>
    80003e9c:	df1fc0ef          	jal	80000c8c <release>
  return f;
}
    80003ea0:	8526                	mv	a0,s1
    80003ea2:	60e2                	ld	ra,24(sp)
    80003ea4:	6442                	ld	s0,16(sp)
    80003ea6:	64a2                	ld	s1,8(sp)
    80003ea8:	6105                	addi	sp,sp,32
    80003eaa:	8082                	ret
    panic("filedup");
    80003eac:	00003517          	auipc	a0,0x3
    80003eb0:	71450513          	addi	a0,a0,1812 # 800075c0 <etext+0x5c0>
    80003eb4:	8e1fc0ef          	jal	80000794 <panic>

0000000080003eb8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003eb8:	7139                	addi	sp,sp,-64
    80003eba:	fc06                	sd	ra,56(sp)
    80003ebc:	f822                	sd	s0,48(sp)
    80003ebe:	f426                	sd	s1,40(sp)
    80003ec0:	0080                	addi	s0,sp,64
    80003ec2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003ec4:	0001c517          	auipc	a0,0x1c
    80003ec8:	c9450513          	addi	a0,a0,-876 # 8001fb58 <ftable>
    80003ecc:	d29fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003ed0:	40dc                	lw	a5,4(s1)
    80003ed2:	04f05a63          	blez	a5,80003f26 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003ed6:	37fd                	addiw	a5,a5,-1
    80003ed8:	0007871b          	sext.w	a4,a5
    80003edc:	c0dc                	sw	a5,4(s1)
    80003ede:	04e04e63          	bgtz	a4,80003f3a <fileclose+0x82>
    80003ee2:	f04a                	sd	s2,32(sp)
    80003ee4:	ec4e                	sd	s3,24(sp)
    80003ee6:	e852                	sd	s4,16(sp)
    80003ee8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003eea:	0004a903          	lw	s2,0(s1)
    80003eee:	0094ca83          	lbu	s5,9(s1)
    80003ef2:	0104ba03          	ld	s4,16(s1)
    80003ef6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003efa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003efe:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f02:	0001c517          	auipc	a0,0x1c
    80003f06:	c5650513          	addi	a0,a0,-938 # 8001fb58 <ftable>
    80003f0a:	d83fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003f0e:	4785                	li	a5,1
    80003f10:	04f90063          	beq	s2,a5,80003f50 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f14:	3979                	addiw	s2,s2,-2
    80003f16:	4785                	li	a5,1
    80003f18:	0527f563          	bgeu	a5,s2,80003f62 <fileclose+0xaa>
    80003f1c:	7902                	ld	s2,32(sp)
    80003f1e:	69e2                	ld	s3,24(sp)
    80003f20:	6a42                	ld	s4,16(sp)
    80003f22:	6aa2                	ld	s5,8(sp)
    80003f24:	a00d                	j	80003f46 <fileclose+0x8e>
    80003f26:	f04a                	sd	s2,32(sp)
    80003f28:	ec4e                	sd	s3,24(sp)
    80003f2a:	e852                	sd	s4,16(sp)
    80003f2c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f2e:	00003517          	auipc	a0,0x3
    80003f32:	69a50513          	addi	a0,a0,1690 # 800075c8 <etext+0x5c8>
    80003f36:	85ffc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003f3a:	0001c517          	auipc	a0,0x1c
    80003f3e:	c1e50513          	addi	a0,a0,-994 # 8001fb58 <ftable>
    80003f42:	d4bfc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f46:	70e2                	ld	ra,56(sp)
    80003f48:	7442                	ld	s0,48(sp)
    80003f4a:	74a2                	ld	s1,40(sp)
    80003f4c:	6121                	addi	sp,sp,64
    80003f4e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f50:	85d6                	mv	a1,s5
    80003f52:	8552                	mv	a0,s4
    80003f54:	336000ef          	jal	8000428a <pipeclose>
    80003f58:	7902                	ld	s2,32(sp)
    80003f5a:	69e2                	ld	s3,24(sp)
    80003f5c:	6a42                	ld	s4,16(sp)
    80003f5e:	6aa2                	ld	s5,8(sp)
    80003f60:	b7dd                	j	80003f46 <fileclose+0x8e>
    begin_op();
    80003f62:	b3dff0ef          	jal	80003a9e <begin_op>
    iput(ff.ip);
    80003f66:	854e                	mv	a0,s3
    80003f68:	be0ff0ef          	jal	80003348 <iput>
    end_op();
    80003f6c:	b9dff0ef          	jal	80003b08 <end_op>
    80003f70:	7902                	ld	s2,32(sp)
    80003f72:	69e2                	ld	s3,24(sp)
    80003f74:	6a42                	ld	s4,16(sp)
    80003f76:	6aa2                	ld	s5,8(sp)
    80003f78:	b7f9                	j	80003f46 <fileclose+0x8e>

0000000080003f7a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003f7a:	715d                	addi	sp,sp,-80
    80003f7c:	e486                	sd	ra,72(sp)
    80003f7e:	e0a2                	sd	s0,64(sp)
    80003f80:	fc26                	sd	s1,56(sp)
    80003f82:	f44e                	sd	s3,40(sp)
    80003f84:	0880                	addi	s0,sp,80
    80003f86:	84aa                	mv	s1,a0
    80003f88:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003f8a:	957fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003f8e:	409c                	lw	a5,0(s1)
    80003f90:	37f9                	addiw	a5,a5,-2
    80003f92:	4705                	li	a4,1
    80003f94:	04f76063          	bltu	a4,a5,80003fd4 <filestat+0x5a>
    80003f98:	f84a                	sd	s2,48(sp)
    80003f9a:	892a                	mv	s2,a0
    ilock(f->ip);
    80003f9c:	6c88                	ld	a0,24(s1)
    80003f9e:	a28ff0ef          	jal	800031c6 <ilock>
    stati(f->ip, &st);
    80003fa2:	fb840593          	addi	a1,s0,-72
    80003fa6:	6c88                	ld	a0,24(s1)
    80003fa8:	c48ff0ef          	jal	800033f0 <stati>
    iunlock(f->ip);
    80003fac:	6c88                	ld	a0,24(s1)
    80003fae:	ac6ff0ef          	jal	80003274 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003fb2:	46e1                	li	a3,24
    80003fb4:	fb840613          	addi	a2,s0,-72
    80003fb8:	85ce                	mv	a1,s3
    80003fba:	05093503          	ld	a0,80(s2)
    80003fbe:	d94fd0ef          	jal	80001552 <copyout>
    80003fc2:	41f5551b          	sraiw	a0,a0,0x1f
    80003fc6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003fc8:	60a6                	ld	ra,72(sp)
    80003fca:	6406                	ld	s0,64(sp)
    80003fcc:	74e2                	ld	s1,56(sp)
    80003fce:	79a2                	ld	s3,40(sp)
    80003fd0:	6161                	addi	sp,sp,80
    80003fd2:	8082                	ret
  return -1;
    80003fd4:	557d                	li	a0,-1
    80003fd6:	bfcd                	j	80003fc8 <filestat+0x4e>

0000000080003fd8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003fd8:	7179                	addi	sp,sp,-48
    80003fda:	f406                	sd	ra,40(sp)
    80003fdc:	f022                	sd	s0,32(sp)
    80003fde:	e84a                	sd	s2,16(sp)
    80003fe0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003fe2:	00854783          	lbu	a5,8(a0)
    80003fe6:	cfd1                	beqz	a5,80004082 <fileread+0xaa>
    80003fe8:	ec26                	sd	s1,24(sp)
    80003fea:	e44e                	sd	s3,8(sp)
    80003fec:	84aa                	mv	s1,a0
    80003fee:	89ae                	mv	s3,a1
    80003ff0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003ff2:	411c                	lw	a5,0(a0)
    80003ff4:	4705                	li	a4,1
    80003ff6:	04e78363          	beq	a5,a4,8000403c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003ffa:	470d                	li	a4,3
    80003ffc:	04e78763          	beq	a5,a4,8000404a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004000:	4709                	li	a4,2
    80004002:	06e79a63          	bne	a5,a4,80004076 <fileread+0x9e>
    ilock(f->ip);
    80004006:	6d08                	ld	a0,24(a0)
    80004008:	9beff0ef          	jal	800031c6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000400c:	874a                	mv	a4,s2
    8000400e:	5094                	lw	a3,32(s1)
    80004010:	864e                	mv	a2,s3
    80004012:	4585                	li	a1,1
    80004014:	6c88                	ld	a0,24(s1)
    80004016:	c04ff0ef          	jal	8000341a <readi>
    8000401a:	892a                	mv	s2,a0
    8000401c:	00a05563          	blez	a0,80004026 <fileread+0x4e>
      f->off += r;
    80004020:	509c                	lw	a5,32(s1)
    80004022:	9fa9                	addw	a5,a5,a0
    80004024:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004026:	6c88                	ld	a0,24(s1)
    80004028:	a4cff0ef          	jal	80003274 <iunlock>
    8000402c:	64e2                	ld	s1,24(sp)
    8000402e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004030:	854a                	mv	a0,s2
    80004032:	70a2                	ld	ra,40(sp)
    80004034:	7402                	ld	s0,32(sp)
    80004036:	6942                	ld	s2,16(sp)
    80004038:	6145                	addi	sp,sp,48
    8000403a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000403c:	6908                	ld	a0,16(a0)
    8000403e:	388000ef          	jal	800043c6 <piperead>
    80004042:	892a                	mv	s2,a0
    80004044:	64e2                	ld	s1,24(sp)
    80004046:	69a2                	ld	s3,8(sp)
    80004048:	b7e5                	j	80004030 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000404a:	02451783          	lh	a5,36(a0)
    8000404e:	03079693          	slli	a3,a5,0x30
    80004052:	92c1                	srli	a3,a3,0x30
    80004054:	4725                	li	a4,9
    80004056:	02d76863          	bltu	a4,a3,80004086 <fileread+0xae>
    8000405a:	0792                	slli	a5,a5,0x4
    8000405c:	0001c717          	auipc	a4,0x1c
    80004060:	a5c70713          	addi	a4,a4,-1444 # 8001fab8 <devsw>
    80004064:	97ba                	add	a5,a5,a4
    80004066:	639c                	ld	a5,0(a5)
    80004068:	c39d                	beqz	a5,8000408e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000406a:	4505                	li	a0,1
    8000406c:	9782                	jalr	a5
    8000406e:	892a                	mv	s2,a0
    80004070:	64e2                	ld	s1,24(sp)
    80004072:	69a2                	ld	s3,8(sp)
    80004074:	bf75                	j	80004030 <fileread+0x58>
    panic("fileread");
    80004076:	00003517          	auipc	a0,0x3
    8000407a:	56250513          	addi	a0,a0,1378 # 800075d8 <etext+0x5d8>
    8000407e:	f16fc0ef          	jal	80000794 <panic>
    return -1;
    80004082:	597d                	li	s2,-1
    80004084:	b775                	j	80004030 <fileread+0x58>
      return -1;
    80004086:	597d                	li	s2,-1
    80004088:	64e2                	ld	s1,24(sp)
    8000408a:	69a2                	ld	s3,8(sp)
    8000408c:	b755                	j	80004030 <fileread+0x58>
    8000408e:	597d                	li	s2,-1
    80004090:	64e2                	ld	s1,24(sp)
    80004092:	69a2                	ld	s3,8(sp)
    80004094:	bf71                	j	80004030 <fileread+0x58>

0000000080004096 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004096:	00954783          	lbu	a5,9(a0)
    8000409a:	10078b63          	beqz	a5,800041b0 <filewrite+0x11a>
{
    8000409e:	715d                	addi	sp,sp,-80
    800040a0:	e486                	sd	ra,72(sp)
    800040a2:	e0a2                	sd	s0,64(sp)
    800040a4:	f84a                	sd	s2,48(sp)
    800040a6:	f052                	sd	s4,32(sp)
    800040a8:	e85a                	sd	s6,16(sp)
    800040aa:	0880                	addi	s0,sp,80
    800040ac:	892a                	mv	s2,a0
    800040ae:	8b2e                	mv	s6,a1
    800040b0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800040b2:	411c                	lw	a5,0(a0)
    800040b4:	4705                	li	a4,1
    800040b6:	02e78763          	beq	a5,a4,800040e4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040ba:	470d                	li	a4,3
    800040bc:	02e78863          	beq	a5,a4,800040ec <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800040c0:	4709                	li	a4,2
    800040c2:	0ce79c63          	bne	a5,a4,8000419a <filewrite+0x104>
    800040c6:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800040c8:	0ac05863          	blez	a2,80004178 <filewrite+0xe2>
    800040cc:	fc26                	sd	s1,56(sp)
    800040ce:	ec56                	sd	s5,24(sp)
    800040d0:	e45e                	sd	s7,8(sp)
    800040d2:	e062                	sd	s8,0(sp)
    int i = 0;
    800040d4:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800040d6:	6b85                	lui	s7,0x1
    800040d8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800040dc:	6c05                	lui	s8,0x1
    800040de:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800040e2:	a8b5                	j	8000415e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800040e4:	6908                	ld	a0,16(a0)
    800040e6:	1fc000ef          	jal	800042e2 <pipewrite>
    800040ea:	a04d                	j	8000418c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800040ec:	02451783          	lh	a5,36(a0)
    800040f0:	03079693          	slli	a3,a5,0x30
    800040f4:	92c1                	srli	a3,a3,0x30
    800040f6:	4725                	li	a4,9
    800040f8:	0ad76e63          	bltu	a4,a3,800041b4 <filewrite+0x11e>
    800040fc:	0792                	slli	a5,a5,0x4
    800040fe:	0001c717          	auipc	a4,0x1c
    80004102:	9ba70713          	addi	a4,a4,-1606 # 8001fab8 <devsw>
    80004106:	97ba                	add	a5,a5,a4
    80004108:	679c                	ld	a5,8(a5)
    8000410a:	c7dd                	beqz	a5,800041b8 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000410c:	4505                	li	a0,1
    8000410e:	9782                	jalr	a5
    80004110:	a8b5                	j	8000418c <filewrite+0xf6>
      if(n1 > max)
    80004112:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004116:	989ff0ef          	jal	80003a9e <begin_op>
      ilock(f->ip);
    8000411a:	01893503          	ld	a0,24(s2)
    8000411e:	8a8ff0ef          	jal	800031c6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004122:	8756                	mv	a4,s5
    80004124:	02092683          	lw	a3,32(s2)
    80004128:	01698633          	add	a2,s3,s6
    8000412c:	4585                	li	a1,1
    8000412e:	01893503          	ld	a0,24(s2)
    80004132:	beeff0ef          	jal	80003520 <writei>
    80004136:	84aa                	mv	s1,a0
    80004138:	00a05763          	blez	a0,80004146 <filewrite+0xb0>
        f->off += r;
    8000413c:	02092783          	lw	a5,32(s2)
    80004140:	9fa9                	addw	a5,a5,a0
    80004142:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004146:	01893503          	ld	a0,24(s2)
    8000414a:	92aff0ef          	jal	80003274 <iunlock>
      end_op();
    8000414e:	9bbff0ef          	jal	80003b08 <end_op>

      if(r != n1){
    80004152:	029a9563          	bne	s5,s1,8000417c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004156:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000415a:	0149da63          	bge	s3,s4,8000416e <filewrite+0xd8>
      int n1 = n - i;
    8000415e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004162:	0004879b          	sext.w	a5,s1
    80004166:	fafbd6e3          	bge	s7,a5,80004112 <filewrite+0x7c>
    8000416a:	84e2                	mv	s1,s8
    8000416c:	b75d                	j	80004112 <filewrite+0x7c>
    8000416e:	74e2                	ld	s1,56(sp)
    80004170:	6ae2                	ld	s5,24(sp)
    80004172:	6ba2                	ld	s7,8(sp)
    80004174:	6c02                	ld	s8,0(sp)
    80004176:	a039                	j	80004184 <filewrite+0xee>
    int i = 0;
    80004178:	4981                	li	s3,0
    8000417a:	a029                	j	80004184 <filewrite+0xee>
    8000417c:	74e2                	ld	s1,56(sp)
    8000417e:	6ae2                	ld	s5,24(sp)
    80004180:	6ba2                	ld	s7,8(sp)
    80004182:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004184:	033a1c63          	bne	s4,s3,800041bc <filewrite+0x126>
    80004188:	8552                	mv	a0,s4
    8000418a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000418c:	60a6                	ld	ra,72(sp)
    8000418e:	6406                	ld	s0,64(sp)
    80004190:	7942                	ld	s2,48(sp)
    80004192:	7a02                	ld	s4,32(sp)
    80004194:	6b42                	ld	s6,16(sp)
    80004196:	6161                	addi	sp,sp,80
    80004198:	8082                	ret
    8000419a:	fc26                	sd	s1,56(sp)
    8000419c:	f44e                	sd	s3,40(sp)
    8000419e:	ec56                	sd	s5,24(sp)
    800041a0:	e45e                	sd	s7,8(sp)
    800041a2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800041a4:	00003517          	auipc	a0,0x3
    800041a8:	44450513          	addi	a0,a0,1092 # 800075e8 <etext+0x5e8>
    800041ac:	de8fc0ef          	jal	80000794 <panic>
    return -1;
    800041b0:	557d                	li	a0,-1
}
    800041b2:	8082                	ret
      return -1;
    800041b4:	557d                	li	a0,-1
    800041b6:	bfd9                	j	8000418c <filewrite+0xf6>
    800041b8:	557d                	li	a0,-1
    800041ba:	bfc9                	j	8000418c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800041bc:	557d                	li	a0,-1
    800041be:	79a2                	ld	s3,40(sp)
    800041c0:	b7f1                	j	8000418c <filewrite+0xf6>

00000000800041c2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800041c2:	7179                	addi	sp,sp,-48
    800041c4:	f406                	sd	ra,40(sp)
    800041c6:	f022                	sd	s0,32(sp)
    800041c8:	ec26                	sd	s1,24(sp)
    800041ca:	e052                	sd	s4,0(sp)
    800041cc:	1800                	addi	s0,sp,48
    800041ce:	84aa                	mv	s1,a0
    800041d0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800041d2:	0005b023          	sd	zero,0(a1)
    800041d6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800041da:	c3bff0ef          	jal	80003e14 <filealloc>
    800041de:	e088                	sd	a0,0(s1)
    800041e0:	c549                	beqz	a0,8000426a <pipealloc+0xa8>
    800041e2:	c33ff0ef          	jal	80003e14 <filealloc>
    800041e6:	00aa3023          	sd	a0,0(s4)
    800041ea:	cd25                	beqz	a0,80004262 <pipealloc+0xa0>
    800041ec:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800041ee:	937fc0ef          	jal	80000b24 <kalloc>
    800041f2:	892a                	mv	s2,a0
    800041f4:	c12d                	beqz	a0,80004256 <pipealloc+0x94>
    800041f6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800041f8:	4985                	li	s3,1
    800041fa:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800041fe:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004202:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004206:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000420a:	00003597          	auipc	a1,0x3
    8000420e:	3ee58593          	addi	a1,a1,1006 # 800075f8 <etext+0x5f8>
    80004212:	963fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004216:	609c                	ld	a5,0(s1)
    80004218:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000421c:	609c                	ld	a5,0(s1)
    8000421e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004222:	609c                	ld	a5,0(s1)
    80004224:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004228:	609c                	ld	a5,0(s1)
    8000422a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000422e:	000a3783          	ld	a5,0(s4)
    80004232:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004236:	000a3783          	ld	a5,0(s4)
    8000423a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000423e:	000a3783          	ld	a5,0(s4)
    80004242:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004246:	000a3783          	ld	a5,0(s4)
    8000424a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000424e:	4501                	li	a0,0
    80004250:	6942                	ld	s2,16(sp)
    80004252:	69a2                	ld	s3,8(sp)
    80004254:	a01d                	j	8000427a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004256:	6088                	ld	a0,0(s1)
    80004258:	c119                	beqz	a0,8000425e <pipealloc+0x9c>
    8000425a:	6942                	ld	s2,16(sp)
    8000425c:	a029                	j	80004266 <pipealloc+0xa4>
    8000425e:	6942                	ld	s2,16(sp)
    80004260:	a029                	j	8000426a <pipealloc+0xa8>
    80004262:	6088                	ld	a0,0(s1)
    80004264:	c10d                	beqz	a0,80004286 <pipealloc+0xc4>
    fileclose(*f0);
    80004266:	c53ff0ef          	jal	80003eb8 <fileclose>
  if(*f1)
    8000426a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000426e:	557d                	li	a0,-1
  if(*f1)
    80004270:	c789                	beqz	a5,8000427a <pipealloc+0xb8>
    fileclose(*f1);
    80004272:	853e                	mv	a0,a5
    80004274:	c45ff0ef          	jal	80003eb8 <fileclose>
  return -1;
    80004278:	557d                	li	a0,-1
}
    8000427a:	70a2                	ld	ra,40(sp)
    8000427c:	7402                	ld	s0,32(sp)
    8000427e:	64e2                	ld	s1,24(sp)
    80004280:	6a02                	ld	s4,0(sp)
    80004282:	6145                	addi	sp,sp,48
    80004284:	8082                	ret
  return -1;
    80004286:	557d                	li	a0,-1
    80004288:	bfcd                	j	8000427a <pipealloc+0xb8>

000000008000428a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000428a:	1101                	addi	sp,sp,-32
    8000428c:	ec06                	sd	ra,24(sp)
    8000428e:	e822                	sd	s0,16(sp)
    80004290:	e426                	sd	s1,8(sp)
    80004292:	e04a                	sd	s2,0(sp)
    80004294:	1000                	addi	s0,sp,32
    80004296:	84aa                	mv	s1,a0
    80004298:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000429a:	95bfc0ef          	jal	80000bf4 <acquire>
  if(writable){
    8000429e:	02090763          	beqz	s2,800042cc <pipeclose+0x42>
    pi->writeopen = 0;
    800042a2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800042a6:	21848513          	addi	a0,s1,536
    800042aa:	c51fd0ef          	jal	80001efa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800042ae:	2204b783          	ld	a5,544(s1)
    800042b2:	e785                	bnez	a5,800042da <pipeclose+0x50>
    release(&pi->lock);
    800042b4:	8526                	mv	a0,s1
    800042b6:	9d7fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800042ba:	8526                	mv	a0,s1
    800042bc:	f86fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    800042c0:	60e2                	ld	ra,24(sp)
    800042c2:	6442                	ld	s0,16(sp)
    800042c4:	64a2                	ld	s1,8(sp)
    800042c6:	6902                	ld	s2,0(sp)
    800042c8:	6105                	addi	sp,sp,32
    800042ca:	8082                	ret
    pi->readopen = 0;
    800042cc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800042d0:	21c48513          	addi	a0,s1,540
    800042d4:	c27fd0ef          	jal	80001efa <wakeup>
    800042d8:	bfd9                	j	800042ae <pipeclose+0x24>
    release(&pi->lock);
    800042da:	8526                	mv	a0,s1
    800042dc:	9b1fc0ef          	jal	80000c8c <release>
}
    800042e0:	b7c5                	j	800042c0 <pipeclose+0x36>

00000000800042e2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800042e2:	711d                	addi	sp,sp,-96
    800042e4:	ec86                	sd	ra,88(sp)
    800042e6:	e8a2                	sd	s0,80(sp)
    800042e8:	e4a6                	sd	s1,72(sp)
    800042ea:	e0ca                	sd	s2,64(sp)
    800042ec:	fc4e                	sd	s3,56(sp)
    800042ee:	f852                	sd	s4,48(sp)
    800042f0:	f456                	sd	s5,40(sp)
    800042f2:	1080                	addi	s0,sp,96
    800042f4:	84aa                	mv	s1,a0
    800042f6:	8aae                	mv	s5,a1
    800042f8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800042fa:	de6fd0ef          	jal	800018e0 <myproc>
    800042fe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004300:	8526                	mv	a0,s1
    80004302:	8f3fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004306:	0b405a63          	blez	s4,800043ba <pipewrite+0xd8>
    8000430a:	f05a                	sd	s6,32(sp)
    8000430c:	ec5e                	sd	s7,24(sp)
    8000430e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004310:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004312:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004314:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004318:	21c48b93          	addi	s7,s1,540
    8000431c:	a81d                	j	80004352 <pipewrite+0x70>
      release(&pi->lock);
    8000431e:	8526                	mv	a0,s1
    80004320:	96dfc0ef          	jal	80000c8c <release>
      return -1;
    80004324:	597d                	li	s2,-1
    80004326:	7b02                	ld	s6,32(sp)
    80004328:	6be2                	ld	s7,24(sp)
    8000432a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000432c:	854a                	mv	a0,s2
    8000432e:	60e6                	ld	ra,88(sp)
    80004330:	6446                	ld	s0,80(sp)
    80004332:	64a6                	ld	s1,72(sp)
    80004334:	6906                	ld	s2,64(sp)
    80004336:	79e2                	ld	s3,56(sp)
    80004338:	7a42                	ld	s4,48(sp)
    8000433a:	7aa2                	ld	s5,40(sp)
    8000433c:	6125                	addi	sp,sp,96
    8000433e:	8082                	ret
      wakeup(&pi->nread);
    80004340:	8562                	mv	a0,s8
    80004342:	bb9fd0ef          	jal	80001efa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004346:	85a6                	mv	a1,s1
    80004348:	855e                	mv	a0,s7
    8000434a:	b65fd0ef          	jal	80001eae <sleep>
  while(i < n){
    8000434e:	05495b63          	bge	s2,s4,800043a4 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004352:	2204a783          	lw	a5,544(s1)
    80004356:	d7e1                	beqz	a5,8000431e <pipewrite+0x3c>
    80004358:	854e                	mv	a0,s3
    8000435a:	d8dfd0ef          	jal	800020e6 <killed>
    8000435e:	f161                	bnez	a0,8000431e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004360:	2184a783          	lw	a5,536(s1)
    80004364:	21c4a703          	lw	a4,540(s1)
    80004368:	2007879b          	addiw	a5,a5,512
    8000436c:	fcf70ae3          	beq	a4,a5,80004340 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004370:	4685                	li	a3,1
    80004372:	01590633          	add	a2,s2,s5
    80004376:	faf40593          	addi	a1,s0,-81
    8000437a:	0509b503          	ld	a0,80(s3)
    8000437e:	aaafd0ef          	jal	80001628 <copyin>
    80004382:	03650e63          	beq	a0,s6,800043be <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004386:	21c4a783          	lw	a5,540(s1)
    8000438a:	0017871b          	addiw	a4,a5,1
    8000438e:	20e4ae23          	sw	a4,540(s1)
    80004392:	1ff7f793          	andi	a5,a5,511
    80004396:	97a6                	add	a5,a5,s1
    80004398:	faf44703          	lbu	a4,-81(s0)
    8000439c:	00e78c23          	sb	a4,24(a5)
      i++;
    800043a0:	2905                	addiw	s2,s2,1
    800043a2:	b775                	j	8000434e <pipewrite+0x6c>
    800043a4:	7b02                	ld	s6,32(sp)
    800043a6:	6be2                	ld	s7,24(sp)
    800043a8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800043aa:	21848513          	addi	a0,s1,536
    800043ae:	b4dfd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    800043b2:	8526                	mv	a0,s1
    800043b4:	8d9fc0ef          	jal	80000c8c <release>
  return i;
    800043b8:	bf95                	j	8000432c <pipewrite+0x4a>
  int i = 0;
    800043ba:	4901                	li	s2,0
    800043bc:	b7fd                	j	800043aa <pipewrite+0xc8>
    800043be:	7b02                	ld	s6,32(sp)
    800043c0:	6be2                	ld	s7,24(sp)
    800043c2:	6c42                	ld	s8,16(sp)
    800043c4:	b7dd                	j	800043aa <pipewrite+0xc8>

00000000800043c6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800043c6:	715d                	addi	sp,sp,-80
    800043c8:	e486                	sd	ra,72(sp)
    800043ca:	e0a2                	sd	s0,64(sp)
    800043cc:	fc26                	sd	s1,56(sp)
    800043ce:	f84a                	sd	s2,48(sp)
    800043d0:	f44e                	sd	s3,40(sp)
    800043d2:	f052                	sd	s4,32(sp)
    800043d4:	ec56                	sd	s5,24(sp)
    800043d6:	0880                	addi	s0,sp,80
    800043d8:	84aa                	mv	s1,a0
    800043da:	892e                	mv	s2,a1
    800043dc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800043de:	d02fd0ef          	jal	800018e0 <myproc>
    800043e2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800043e4:	8526                	mv	a0,s1
    800043e6:	80ffc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043ea:	2184a703          	lw	a4,536(s1)
    800043ee:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043f2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043f6:	02f71563          	bne	a4,a5,80004420 <piperead+0x5a>
    800043fa:	2244a783          	lw	a5,548(s1)
    800043fe:	cb85                	beqz	a5,8000442e <piperead+0x68>
    if(killed(pr)){
    80004400:	8552                	mv	a0,s4
    80004402:	ce5fd0ef          	jal	800020e6 <killed>
    80004406:	ed19                	bnez	a0,80004424 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004408:	85a6                	mv	a1,s1
    8000440a:	854e                	mv	a0,s3
    8000440c:	aa3fd0ef          	jal	80001eae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004410:	2184a703          	lw	a4,536(s1)
    80004414:	21c4a783          	lw	a5,540(s1)
    80004418:	fef701e3          	beq	a4,a5,800043fa <piperead+0x34>
    8000441c:	e85a                	sd	s6,16(sp)
    8000441e:	a809                	j	80004430 <piperead+0x6a>
    80004420:	e85a                	sd	s6,16(sp)
    80004422:	a039                	j	80004430 <piperead+0x6a>
      release(&pi->lock);
    80004424:	8526                	mv	a0,s1
    80004426:	867fc0ef          	jal	80000c8c <release>
      return -1;
    8000442a:	59fd                	li	s3,-1
    8000442c:	a8b1                	j	80004488 <piperead+0xc2>
    8000442e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004430:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004432:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004434:	05505263          	blez	s5,80004478 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004438:	2184a783          	lw	a5,536(s1)
    8000443c:	21c4a703          	lw	a4,540(s1)
    80004440:	02f70c63          	beq	a4,a5,80004478 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004444:	0017871b          	addiw	a4,a5,1
    80004448:	20e4ac23          	sw	a4,536(s1)
    8000444c:	1ff7f793          	andi	a5,a5,511
    80004450:	97a6                	add	a5,a5,s1
    80004452:	0187c783          	lbu	a5,24(a5)
    80004456:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000445a:	4685                	li	a3,1
    8000445c:	fbf40613          	addi	a2,s0,-65
    80004460:	85ca                	mv	a1,s2
    80004462:	050a3503          	ld	a0,80(s4)
    80004466:	8ecfd0ef          	jal	80001552 <copyout>
    8000446a:	01650763          	beq	a0,s6,80004478 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000446e:	2985                	addiw	s3,s3,1
    80004470:	0905                	addi	s2,s2,1
    80004472:	fd3a93e3          	bne	s5,s3,80004438 <piperead+0x72>
    80004476:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004478:	21c48513          	addi	a0,s1,540
    8000447c:	a7ffd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    80004480:	8526                	mv	a0,s1
    80004482:	80bfc0ef          	jal	80000c8c <release>
    80004486:	6b42                	ld	s6,16(sp)
  return i;
}
    80004488:	854e                	mv	a0,s3
    8000448a:	60a6                	ld	ra,72(sp)
    8000448c:	6406                	ld	s0,64(sp)
    8000448e:	74e2                	ld	s1,56(sp)
    80004490:	7942                	ld	s2,48(sp)
    80004492:	79a2                	ld	s3,40(sp)
    80004494:	7a02                	ld	s4,32(sp)
    80004496:	6ae2                	ld	s5,24(sp)
    80004498:	6161                	addi	sp,sp,80
    8000449a:	8082                	ret

000000008000449c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000449c:	1141                	addi	sp,sp,-16
    8000449e:	e422                	sd	s0,8(sp)
    800044a0:	0800                	addi	s0,sp,16
    800044a2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800044a4:	8905                	andi	a0,a0,1
    800044a6:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800044a8:	8b89                	andi	a5,a5,2
    800044aa:	c399                	beqz	a5,800044b0 <flags2perm+0x14>
      perm |= PTE_W;
    800044ac:	00456513          	ori	a0,a0,4
    return perm;
}
    800044b0:	6422                	ld	s0,8(sp)
    800044b2:	0141                	addi	sp,sp,16
    800044b4:	8082                	ret

00000000800044b6 <exec>:

int
exec(char *path, char **argv)
{
    800044b6:	df010113          	addi	sp,sp,-528
    800044ba:	20113423          	sd	ra,520(sp)
    800044be:	20813023          	sd	s0,512(sp)
    800044c2:	ffa6                	sd	s1,504(sp)
    800044c4:	fbca                	sd	s2,496(sp)
    800044c6:	0c00                	addi	s0,sp,528
    800044c8:	892a                	mv	s2,a0
    800044ca:	dea43c23          	sd	a0,-520(s0)
    800044ce:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800044d2:	c0efd0ef          	jal	800018e0 <myproc>
    800044d6:	84aa                	mv	s1,a0

  begin_op();
    800044d8:	dc6ff0ef          	jal	80003a9e <begin_op>

  if((ip = namei(path)) == 0){
    800044dc:	854a                	mv	a0,s2
    800044de:	c04ff0ef          	jal	800038e2 <namei>
    800044e2:	c931                	beqz	a0,80004536 <exec+0x80>
    800044e4:	f3d2                	sd	s4,480(sp)
    800044e6:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800044e8:	cdffe0ef          	jal	800031c6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800044ec:	04000713          	li	a4,64
    800044f0:	4681                	li	a3,0
    800044f2:	e5040613          	addi	a2,s0,-432
    800044f6:	4581                	li	a1,0
    800044f8:	8552                	mv	a0,s4
    800044fa:	f21fe0ef          	jal	8000341a <readi>
    800044fe:	04000793          	li	a5,64
    80004502:	00f51a63          	bne	a0,a5,80004516 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004506:	e5042703          	lw	a4,-432(s0)
    8000450a:	464c47b7          	lui	a5,0x464c4
    8000450e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004512:	02f70663          	beq	a4,a5,8000453e <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004516:	8552                	mv	a0,s4
    80004518:	eb9fe0ef          	jal	800033d0 <iunlockput>
    end_op();
    8000451c:	decff0ef          	jal	80003b08 <end_op>
  }
  return -1;
    80004520:	557d                	li	a0,-1
    80004522:	7a1e                	ld	s4,480(sp)
}
    80004524:	20813083          	ld	ra,520(sp)
    80004528:	20013403          	ld	s0,512(sp)
    8000452c:	74fe                	ld	s1,504(sp)
    8000452e:	795e                	ld	s2,496(sp)
    80004530:	21010113          	addi	sp,sp,528
    80004534:	8082                	ret
    end_op();
    80004536:	dd2ff0ef          	jal	80003b08 <end_op>
    return -1;
    8000453a:	557d                	li	a0,-1
    8000453c:	b7e5                	j	80004524 <exec+0x6e>
    8000453e:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004540:	8526                	mv	a0,s1
    80004542:	c46fd0ef          	jal	80001988 <proc_pagetable>
    80004546:	8b2a                	mv	s6,a0
    80004548:	2c050b63          	beqz	a0,8000481e <exec+0x368>
    8000454c:	f7ce                	sd	s3,488(sp)
    8000454e:	efd6                	sd	s5,472(sp)
    80004550:	e7de                	sd	s7,456(sp)
    80004552:	e3e2                	sd	s8,448(sp)
    80004554:	ff66                	sd	s9,440(sp)
    80004556:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004558:	e7042d03          	lw	s10,-400(s0)
    8000455c:	e8845783          	lhu	a5,-376(s0)
    80004560:	12078963          	beqz	a5,80004692 <exec+0x1dc>
    80004564:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004566:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004568:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000456a:	6c85                	lui	s9,0x1
    8000456c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004570:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004574:	6a85                	lui	s5,0x1
    80004576:	a085                	j	800045d6 <exec+0x120>
      panic("loadseg: address should exist");
    80004578:	00003517          	auipc	a0,0x3
    8000457c:	08850513          	addi	a0,a0,136 # 80007600 <etext+0x600>
    80004580:	a14fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004584:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004586:	8726                	mv	a4,s1
    80004588:	012c06bb          	addw	a3,s8,s2
    8000458c:	4581                	li	a1,0
    8000458e:	8552                	mv	a0,s4
    80004590:	e8bfe0ef          	jal	8000341a <readi>
    80004594:	2501                	sext.w	a0,a0
    80004596:	24a49a63          	bne	s1,a0,800047ea <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000459a:	012a893b          	addw	s2,s5,s2
    8000459e:	03397363          	bgeu	s2,s3,800045c4 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800045a2:	02091593          	slli	a1,s2,0x20
    800045a6:	9181                	srli	a1,a1,0x20
    800045a8:	95de                	add	a1,a1,s7
    800045aa:	855a                	mv	a0,s6
    800045ac:	a2bfc0ef          	jal	80000fd6 <walkaddr>
    800045b0:	862a                	mv	a2,a0
    if(pa == 0)
    800045b2:	d179                	beqz	a0,80004578 <exec+0xc2>
    if(sz - i < PGSIZE)
    800045b4:	412984bb          	subw	s1,s3,s2
    800045b8:	0004879b          	sext.w	a5,s1
    800045bc:	fcfcf4e3          	bgeu	s9,a5,80004584 <exec+0xce>
    800045c0:	84d6                	mv	s1,s5
    800045c2:	b7c9                	j	80004584 <exec+0xce>
    sz = sz1;
    800045c4:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045c8:	2d85                	addiw	s11,s11,1
    800045ca:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800045ce:	e8845783          	lhu	a5,-376(s0)
    800045d2:	08fdd063          	bge	s11,a5,80004652 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045d6:	2d01                	sext.w	s10,s10
    800045d8:	03800713          	li	a4,56
    800045dc:	86ea                	mv	a3,s10
    800045de:	e1840613          	addi	a2,s0,-488
    800045e2:	4581                	li	a1,0
    800045e4:	8552                	mv	a0,s4
    800045e6:	e35fe0ef          	jal	8000341a <readi>
    800045ea:	03800793          	li	a5,56
    800045ee:	1cf51663          	bne	a0,a5,800047ba <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800045f2:	e1842783          	lw	a5,-488(s0)
    800045f6:	4705                	li	a4,1
    800045f8:	fce798e3          	bne	a5,a4,800045c8 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800045fc:	e4043483          	ld	s1,-448(s0)
    80004600:	e3843783          	ld	a5,-456(s0)
    80004604:	1af4ef63          	bltu	s1,a5,800047c2 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004608:	e2843783          	ld	a5,-472(s0)
    8000460c:	94be                	add	s1,s1,a5
    8000460e:	1af4ee63          	bltu	s1,a5,800047ca <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004612:	df043703          	ld	a4,-528(s0)
    80004616:	8ff9                	and	a5,a5,a4
    80004618:	1a079d63          	bnez	a5,800047d2 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000461c:	e1c42503          	lw	a0,-484(s0)
    80004620:	e7dff0ef          	jal	8000449c <flags2perm>
    80004624:	86aa                	mv	a3,a0
    80004626:	8626                	mv	a2,s1
    80004628:	85ca                	mv	a1,s2
    8000462a:	855a                	mv	a0,s6
    8000462c:	d13fc0ef          	jal	8000133e <uvmalloc>
    80004630:	e0a43423          	sd	a0,-504(s0)
    80004634:	1a050363          	beqz	a0,800047da <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004638:	e2843b83          	ld	s7,-472(s0)
    8000463c:	e2042c03          	lw	s8,-480(s0)
    80004640:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004644:	00098463          	beqz	s3,8000464c <exec+0x196>
    80004648:	4901                	li	s2,0
    8000464a:	bfa1                	j	800045a2 <exec+0xec>
    sz = sz1;
    8000464c:	e0843903          	ld	s2,-504(s0)
    80004650:	bfa5                	j	800045c8 <exec+0x112>
    80004652:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004654:	8552                	mv	a0,s4
    80004656:	d7bfe0ef          	jal	800033d0 <iunlockput>
  end_op();
    8000465a:	caeff0ef          	jal	80003b08 <end_op>
  p = myproc();
    8000465e:	a82fd0ef          	jal	800018e0 <myproc>
    80004662:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004664:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004668:	6985                	lui	s3,0x1
    8000466a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000466c:	99ca                	add	s3,s3,s2
    8000466e:	77fd                	lui	a5,0xfffff
    80004670:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004674:	4691                	li	a3,4
    80004676:	6609                	lui	a2,0x2
    80004678:	964e                	add	a2,a2,s3
    8000467a:	85ce                	mv	a1,s3
    8000467c:	855a                	mv	a0,s6
    8000467e:	cc1fc0ef          	jal	8000133e <uvmalloc>
    80004682:	892a                	mv	s2,a0
    80004684:	e0a43423          	sd	a0,-504(s0)
    80004688:	e519                	bnez	a0,80004696 <exec+0x1e0>
  if(pagetable)
    8000468a:	e1343423          	sd	s3,-504(s0)
    8000468e:	4a01                	li	s4,0
    80004690:	aab1                	j	800047ec <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004692:	4901                	li	s2,0
    80004694:	b7c1                	j	80004654 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004696:	75f9                	lui	a1,0xffffe
    80004698:	95aa                	add	a1,a1,a0
    8000469a:	855a                	mv	a0,s6
    8000469c:	e8dfc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800046a0:	7bfd                	lui	s7,0xfffff
    800046a2:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800046a4:	e0043783          	ld	a5,-512(s0)
    800046a8:	6388                	ld	a0,0(a5)
    800046aa:	cd39                	beqz	a0,80004708 <exec+0x252>
    800046ac:	e9040993          	addi	s3,s0,-368
    800046b0:	f9040c13          	addi	s8,s0,-112
    800046b4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800046b6:	f82fc0ef          	jal	80000e38 <strlen>
    800046ba:	0015079b          	addiw	a5,a0,1
    800046be:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800046c2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800046c6:	11796e63          	bltu	s2,s7,800047e2 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800046ca:	e0043d03          	ld	s10,-512(s0)
    800046ce:	000d3a03          	ld	s4,0(s10)
    800046d2:	8552                	mv	a0,s4
    800046d4:	f64fc0ef          	jal	80000e38 <strlen>
    800046d8:	0015069b          	addiw	a3,a0,1
    800046dc:	8652                	mv	a2,s4
    800046de:	85ca                	mv	a1,s2
    800046e0:	855a                	mv	a0,s6
    800046e2:	e71fc0ef          	jal	80001552 <copyout>
    800046e6:	10054063          	bltz	a0,800047e6 <exec+0x330>
    ustack[argc] = sp;
    800046ea:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800046ee:	0485                	addi	s1,s1,1
    800046f0:	008d0793          	addi	a5,s10,8
    800046f4:	e0f43023          	sd	a5,-512(s0)
    800046f8:	008d3503          	ld	a0,8(s10)
    800046fc:	c909                	beqz	a0,8000470e <exec+0x258>
    if(argc >= MAXARG)
    800046fe:	09a1                	addi	s3,s3,8
    80004700:	fb899be3          	bne	s3,s8,800046b6 <exec+0x200>
  ip = 0;
    80004704:	4a01                	li	s4,0
    80004706:	a0dd                	j	800047ec <exec+0x336>
  sp = sz;
    80004708:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000470c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000470e:	00349793          	slli	a5,s1,0x3
    80004712:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde340>
    80004716:	97a2                	add	a5,a5,s0
    80004718:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000471c:	00148693          	addi	a3,s1,1
    80004720:	068e                	slli	a3,a3,0x3
    80004722:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004726:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000472a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000472e:	f5796ee3          	bltu	s2,s7,8000468a <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004732:	e9040613          	addi	a2,s0,-368
    80004736:	85ca                	mv	a1,s2
    80004738:	855a                	mv	a0,s6
    8000473a:	e19fc0ef          	jal	80001552 <copyout>
    8000473e:	0e054263          	bltz	a0,80004822 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004742:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004746:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000474a:	df843783          	ld	a5,-520(s0)
    8000474e:	0007c703          	lbu	a4,0(a5)
    80004752:	cf11                	beqz	a4,8000476e <exec+0x2b8>
    80004754:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004756:	02f00693          	li	a3,47
    8000475a:	a039                	j	80004768 <exec+0x2b2>
      last = s+1;
    8000475c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004760:	0785                	addi	a5,a5,1
    80004762:	fff7c703          	lbu	a4,-1(a5)
    80004766:	c701                	beqz	a4,8000476e <exec+0x2b8>
    if(*s == '/')
    80004768:	fed71ce3          	bne	a4,a3,80004760 <exec+0x2aa>
    8000476c:	bfc5                	j	8000475c <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000476e:	4641                	li	a2,16
    80004770:	df843583          	ld	a1,-520(s0)
    80004774:	158a8513          	addi	a0,s5,344
    80004778:	e8efc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    8000477c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004780:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004784:	e0843783          	ld	a5,-504(s0)
    80004788:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000478c:	058ab783          	ld	a5,88(s5)
    80004790:	e6843703          	ld	a4,-408(s0)
    80004794:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004796:	058ab783          	ld	a5,88(s5)
    8000479a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000479e:	85e6                	mv	a1,s9
    800047a0:	a6cfd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800047a4:	0004851b          	sext.w	a0,s1
    800047a8:	79be                	ld	s3,488(sp)
    800047aa:	7a1e                	ld	s4,480(sp)
    800047ac:	6afe                	ld	s5,472(sp)
    800047ae:	6b5e                	ld	s6,464(sp)
    800047b0:	6bbe                	ld	s7,456(sp)
    800047b2:	6c1e                	ld	s8,448(sp)
    800047b4:	7cfa                	ld	s9,440(sp)
    800047b6:	7d5a                	ld	s10,432(sp)
    800047b8:	b3b5                	j	80004524 <exec+0x6e>
    800047ba:	e1243423          	sd	s2,-504(s0)
    800047be:	7dba                	ld	s11,424(sp)
    800047c0:	a035                	j	800047ec <exec+0x336>
    800047c2:	e1243423          	sd	s2,-504(s0)
    800047c6:	7dba                	ld	s11,424(sp)
    800047c8:	a015                	j	800047ec <exec+0x336>
    800047ca:	e1243423          	sd	s2,-504(s0)
    800047ce:	7dba                	ld	s11,424(sp)
    800047d0:	a831                	j	800047ec <exec+0x336>
    800047d2:	e1243423          	sd	s2,-504(s0)
    800047d6:	7dba                	ld	s11,424(sp)
    800047d8:	a811                	j	800047ec <exec+0x336>
    800047da:	e1243423          	sd	s2,-504(s0)
    800047de:	7dba                	ld	s11,424(sp)
    800047e0:	a031                	j	800047ec <exec+0x336>
  ip = 0;
    800047e2:	4a01                	li	s4,0
    800047e4:	a021                	j	800047ec <exec+0x336>
    800047e6:	4a01                	li	s4,0
  if(pagetable)
    800047e8:	a011                	j	800047ec <exec+0x336>
    800047ea:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800047ec:	e0843583          	ld	a1,-504(s0)
    800047f0:	855a                	mv	a0,s6
    800047f2:	a1afd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    800047f6:	557d                	li	a0,-1
  if(ip){
    800047f8:	000a1b63          	bnez	s4,8000480e <exec+0x358>
    800047fc:	79be                	ld	s3,488(sp)
    800047fe:	7a1e                	ld	s4,480(sp)
    80004800:	6afe                	ld	s5,472(sp)
    80004802:	6b5e                	ld	s6,464(sp)
    80004804:	6bbe                	ld	s7,456(sp)
    80004806:	6c1e                	ld	s8,448(sp)
    80004808:	7cfa                	ld	s9,440(sp)
    8000480a:	7d5a                	ld	s10,432(sp)
    8000480c:	bb21                	j	80004524 <exec+0x6e>
    8000480e:	79be                	ld	s3,488(sp)
    80004810:	6afe                	ld	s5,472(sp)
    80004812:	6b5e                	ld	s6,464(sp)
    80004814:	6bbe                	ld	s7,456(sp)
    80004816:	6c1e                	ld	s8,448(sp)
    80004818:	7cfa                	ld	s9,440(sp)
    8000481a:	7d5a                	ld	s10,432(sp)
    8000481c:	b9ed                	j	80004516 <exec+0x60>
    8000481e:	6b5e                	ld	s6,464(sp)
    80004820:	b9dd                	j	80004516 <exec+0x60>
  sz = sz1;
    80004822:	e0843983          	ld	s3,-504(s0)
    80004826:	b595                	j	8000468a <exec+0x1d4>

0000000080004828 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004828:	7179                	addi	sp,sp,-48
    8000482a:	f406                	sd	ra,40(sp)
    8000482c:	f022                	sd	s0,32(sp)
    8000482e:	ec26                	sd	s1,24(sp)
    80004830:	e84a                	sd	s2,16(sp)
    80004832:	1800                	addi	s0,sp,48
    80004834:	892e                	mv	s2,a1
    80004836:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004838:	fdc40593          	addi	a1,s0,-36
    8000483c:	f59fd0ef          	jal	80002794 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004840:	fdc42703          	lw	a4,-36(s0)
    80004844:	47bd                	li	a5,15
    80004846:	02e7e963          	bltu	a5,a4,80004878 <argfd+0x50>
    8000484a:	896fd0ef          	jal	800018e0 <myproc>
    8000484e:	fdc42703          	lw	a4,-36(s0)
    80004852:	01a70793          	addi	a5,a4,26
    80004856:	078e                	slli	a5,a5,0x3
    80004858:	953e                	add	a0,a0,a5
    8000485a:	611c                	ld	a5,0(a0)
    8000485c:	c385                	beqz	a5,8000487c <argfd+0x54>
    return -1;
  if(pfd)
    8000485e:	00090463          	beqz	s2,80004866 <argfd+0x3e>
    *pfd = fd;
    80004862:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004866:	4501                	li	a0,0
  if(pf)
    80004868:	c091                	beqz	s1,8000486c <argfd+0x44>
    *pf = f;
    8000486a:	e09c                	sd	a5,0(s1)
}
    8000486c:	70a2                	ld	ra,40(sp)
    8000486e:	7402                	ld	s0,32(sp)
    80004870:	64e2                	ld	s1,24(sp)
    80004872:	6942                	ld	s2,16(sp)
    80004874:	6145                	addi	sp,sp,48
    80004876:	8082                	ret
    return -1;
    80004878:	557d                	li	a0,-1
    8000487a:	bfcd                	j	8000486c <argfd+0x44>
    8000487c:	557d                	li	a0,-1
    8000487e:	b7fd                	j	8000486c <argfd+0x44>

0000000080004880 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004880:	1101                	addi	sp,sp,-32
    80004882:	ec06                	sd	ra,24(sp)
    80004884:	e822                	sd	s0,16(sp)
    80004886:	e426                	sd	s1,8(sp)
    80004888:	1000                	addi	s0,sp,32
    8000488a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000488c:	854fd0ef          	jal	800018e0 <myproc>
    80004890:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004892:	0d050793          	addi	a5,a0,208
    80004896:	4501                	li	a0,0
    80004898:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000489a:	6398                	ld	a4,0(a5)
    8000489c:	cb19                	beqz	a4,800048b2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000489e:	2505                	addiw	a0,a0,1
    800048a0:	07a1                	addi	a5,a5,8
    800048a2:	fed51ce3          	bne	a0,a3,8000489a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800048a6:	557d                	li	a0,-1
}
    800048a8:	60e2                	ld	ra,24(sp)
    800048aa:	6442                	ld	s0,16(sp)
    800048ac:	64a2                	ld	s1,8(sp)
    800048ae:	6105                	addi	sp,sp,32
    800048b0:	8082                	ret
      p->ofile[fd] = f;
    800048b2:	01a50793          	addi	a5,a0,26
    800048b6:	078e                	slli	a5,a5,0x3
    800048b8:	963e                	add	a2,a2,a5
    800048ba:	e204                	sd	s1,0(a2)
      return fd;
    800048bc:	b7f5                	j	800048a8 <fdalloc+0x28>

00000000800048be <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800048be:	715d                	addi	sp,sp,-80
    800048c0:	e486                	sd	ra,72(sp)
    800048c2:	e0a2                	sd	s0,64(sp)
    800048c4:	fc26                	sd	s1,56(sp)
    800048c6:	f84a                	sd	s2,48(sp)
    800048c8:	f44e                	sd	s3,40(sp)
    800048ca:	ec56                	sd	s5,24(sp)
    800048cc:	e85a                	sd	s6,16(sp)
    800048ce:	0880                	addi	s0,sp,80
    800048d0:	8b2e                	mv	s6,a1
    800048d2:	89b2                	mv	s3,a2
    800048d4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800048d6:	fb040593          	addi	a1,s0,-80
    800048da:	822ff0ef          	jal	800038fc <nameiparent>
    800048de:	84aa                	mv	s1,a0
    800048e0:	10050a63          	beqz	a0,800049f4 <create+0x136>
    return 0;

  ilock(dp);
    800048e4:	8e3fe0ef          	jal	800031c6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800048e8:	4601                	li	a2,0
    800048ea:	fb040593          	addi	a1,s0,-80
    800048ee:	8526                	mv	a0,s1
    800048f0:	d8dfe0ef          	jal	8000367c <dirlookup>
    800048f4:	8aaa                	mv	s5,a0
    800048f6:	c129                	beqz	a0,80004938 <create+0x7a>
    iunlockput(dp);
    800048f8:	8526                	mv	a0,s1
    800048fa:	ad7fe0ef          	jal	800033d0 <iunlockput>
    ilock(ip);
    800048fe:	8556                	mv	a0,s5
    80004900:	8c7fe0ef          	jal	800031c6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004904:	4789                	li	a5,2
    80004906:	02fb1463          	bne	s6,a5,8000492e <create+0x70>
    8000490a:	044ad783          	lhu	a5,68(s5)
    8000490e:	37f9                	addiw	a5,a5,-2
    80004910:	17c2                	slli	a5,a5,0x30
    80004912:	93c1                	srli	a5,a5,0x30
    80004914:	4705                	li	a4,1
    80004916:	00f76c63          	bltu	a4,a5,8000492e <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000491a:	8556                	mv	a0,s5
    8000491c:	60a6                	ld	ra,72(sp)
    8000491e:	6406                	ld	s0,64(sp)
    80004920:	74e2                	ld	s1,56(sp)
    80004922:	7942                	ld	s2,48(sp)
    80004924:	79a2                	ld	s3,40(sp)
    80004926:	6ae2                	ld	s5,24(sp)
    80004928:	6b42                	ld	s6,16(sp)
    8000492a:	6161                	addi	sp,sp,80
    8000492c:	8082                	ret
    iunlockput(ip);
    8000492e:	8556                	mv	a0,s5
    80004930:	aa1fe0ef          	jal	800033d0 <iunlockput>
    return 0;
    80004934:	4a81                	li	s5,0
    80004936:	b7d5                	j	8000491a <create+0x5c>
    80004938:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000493a:	85da                	mv	a1,s6
    8000493c:	4088                	lw	a0,0(s1)
    8000493e:	f18fe0ef          	jal	80003056 <ialloc>
    80004942:	8a2a                	mv	s4,a0
    80004944:	cd15                	beqz	a0,80004980 <create+0xc2>
  ilock(ip);
    80004946:	881fe0ef          	jal	800031c6 <ilock>
  ip->major = major;
    8000494a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000494e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004952:	4905                	li	s2,1
    80004954:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004958:	8552                	mv	a0,s4
    8000495a:	fb8fe0ef          	jal	80003112 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000495e:	032b0763          	beq	s6,s2,8000498c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004962:	004a2603          	lw	a2,4(s4)
    80004966:	fb040593          	addi	a1,s0,-80
    8000496a:	8526                	mv	a0,s1
    8000496c:	eddfe0ef          	jal	80003848 <dirlink>
    80004970:	06054563          	bltz	a0,800049da <create+0x11c>
  iunlockput(dp);
    80004974:	8526                	mv	a0,s1
    80004976:	a5bfe0ef          	jal	800033d0 <iunlockput>
  return ip;
    8000497a:	8ad2                	mv	s5,s4
    8000497c:	7a02                	ld	s4,32(sp)
    8000497e:	bf71                	j	8000491a <create+0x5c>
    iunlockput(dp);
    80004980:	8526                	mv	a0,s1
    80004982:	a4ffe0ef          	jal	800033d0 <iunlockput>
    return 0;
    80004986:	8ad2                	mv	s5,s4
    80004988:	7a02                	ld	s4,32(sp)
    8000498a:	bf41                	j	8000491a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000498c:	004a2603          	lw	a2,4(s4)
    80004990:	00003597          	auipc	a1,0x3
    80004994:	c9058593          	addi	a1,a1,-880 # 80007620 <etext+0x620>
    80004998:	8552                	mv	a0,s4
    8000499a:	eaffe0ef          	jal	80003848 <dirlink>
    8000499e:	02054e63          	bltz	a0,800049da <create+0x11c>
    800049a2:	40d0                	lw	a2,4(s1)
    800049a4:	00003597          	auipc	a1,0x3
    800049a8:	c8458593          	addi	a1,a1,-892 # 80007628 <etext+0x628>
    800049ac:	8552                	mv	a0,s4
    800049ae:	e9bfe0ef          	jal	80003848 <dirlink>
    800049b2:	02054463          	bltz	a0,800049da <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800049b6:	004a2603          	lw	a2,4(s4)
    800049ba:	fb040593          	addi	a1,s0,-80
    800049be:	8526                	mv	a0,s1
    800049c0:	e89fe0ef          	jal	80003848 <dirlink>
    800049c4:	00054b63          	bltz	a0,800049da <create+0x11c>
    dp->nlink++;  // for ".."
    800049c8:	04a4d783          	lhu	a5,74(s1)
    800049cc:	2785                	addiw	a5,a5,1
    800049ce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800049d2:	8526                	mv	a0,s1
    800049d4:	f3efe0ef          	jal	80003112 <iupdate>
    800049d8:	bf71                	j	80004974 <create+0xb6>
  ip->nlink = 0;
    800049da:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800049de:	8552                	mv	a0,s4
    800049e0:	f32fe0ef          	jal	80003112 <iupdate>
  iunlockput(ip);
    800049e4:	8552                	mv	a0,s4
    800049e6:	9ebfe0ef          	jal	800033d0 <iunlockput>
  iunlockput(dp);
    800049ea:	8526                	mv	a0,s1
    800049ec:	9e5fe0ef          	jal	800033d0 <iunlockput>
  return 0;
    800049f0:	7a02                	ld	s4,32(sp)
    800049f2:	b725                	j	8000491a <create+0x5c>
    return 0;
    800049f4:	8aaa                	mv	s5,a0
    800049f6:	b715                	j	8000491a <create+0x5c>

00000000800049f8 <sys_dup>:
{
    800049f8:	7179                	addi	sp,sp,-48
    800049fa:	f406                	sd	ra,40(sp)
    800049fc:	f022                	sd	s0,32(sp)
    800049fe:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a00:	fd840613          	addi	a2,s0,-40
    80004a04:	4581                	li	a1,0
    80004a06:	4501                	li	a0,0
    80004a08:	e21ff0ef          	jal	80004828 <argfd>
    return -1;
    80004a0c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a0e:	02054363          	bltz	a0,80004a34 <sys_dup+0x3c>
    80004a12:	ec26                	sd	s1,24(sp)
    80004a14:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004a16:	fd843903          	ld	s2,-40(s0)
    80004a1a:	854a                	mv	a0,s2
    80004a1c:	e65ff0ef          	jal	80004880 <fdalloc>
    80004a20:	84aa                	mv	s1,a0
    return -1;
    80004a22:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a24:	00054d63          	bltz	a0,80004a3e <sys_dup+0x46>
  filedup(f);
    80004a28:	854a                	mv	a0,s2
    80004a2a:	c48ff0ef          	jal	80003e72 <filedup>
  return fd;
    80004a2e:	87a6                	mv	a5,s1
    80004a30:	64e2                	ld	s1,24(sp)
    80004a32:	6942                	ld	s2,16(sp)
}
    80004a34:	853e                	mv	a0,a5
    80004a36:	70a2                	ld	ra,40(sp)
    80004a38:	7402                	ld	s0,32(sp)
    80004a3a:	6145                	addi	sp,sp,48
    80004a3c:	8082                	ret
    80004a3e:	64e2                	ld	s1,24(sp)
    80004a40:	6942                	ld	s2,16(sp)
    80004a42:	bfcd                	j	80004a34 <sys_dup+0x3c>

0000000080004a44 <sys_read>:
{
    80004a44:	7179                	addi	sp,sp,-48
    80004a46:	f406                	sd	ra,40(sp)
    80004a48:	f022                	sd	s0,32(sp)
    80004a4a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a4c:	fd840593          	addi	a1,s0,-40
    80004a50:	4505                	li	a0,1
    80004a52:	d5ffd0ef          	jal	800027b0 <argaddr>
  argint(2, &n);
    80004a56:	fe440593          	addi	a1,s0,-28
    80004a5a:	4509                	li	a0,2
    80004a5c:	d39fd0ef          	jal	80002794 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a60:	fe840613          	addi	a2,s0,-24
    80004a64:	4581                	li	a1,0
    80004a66:	4501                	li	a0,0
    80004a68:	dc1ff0ef          	jal	80004828 <argfd>
    80004a6c:	87aa                	mv	a5,a0
    return -1;
    80004a6e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a70:	0007ca63          	bltz	a5,80004a84 <sys_read+0x40>
  return fileread(f, p, n);
    80004a74:	fe442603          	lw	a2,-28(s0)
    80004a78:	fd843583          	ld	a1,-40(s0)
    80004a7c:	fe843503          	ld	a0,-24(s0)
    80004a80:	d58ff0ef          	jal	80003fd8 <fileread>
}
    80004a84:	70a2                	ld	ra,40(sp)
    80004a86:	7402                	ld	s0,32(sp)
    80004a88:	6145                	addi	sp,sp,48
    80004a8a:	8082                	ret

0000000080004a8c <sys_write>:
{
    80004a8c:	7179                	addi	sp,sp,-48
    80004a8e:	f406                	sd	ra,40(sp)
    80004a90:	f022                	sd	s0,32(sp)
    80004a92:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a94:	fd840593          	addi	a1,s0,-40
    80004a98:	4505                	li	a0,1
    80004a9a:	d17fd0ef          	jal	800027b0 <argaddr>
  argint(2, &n);
    80004a9e:	fe440593          	addi	a1,s0,-28
    80004aa2:	4509                	li	a0,2
    80004aa4:	cf1fd0ef          	jal	80002794 <argint>
  if(argfd(0, 0, &f) < 0)
    80004aa8:	fe840613          	addi	a2,s0,-24
    80004aac:	4581                	li	a1,0
    80004aae:	4501                	li	a0,0
    80004ab0:	d79ff0ef          	jal	80004828 <argfd>
    80004ab4:	87aa                	mv	a5,a0
    return -1;
    80004ab6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ab8:	0007ca63          	bltz	a5,80004acc <sys_write+0x40>
  return filewrite(f, p, n);
    80004abc:	fe442603          	lw	a2,-28(s0)
    80004ac0:	fd843583          	ld	a1,-40(s0)
    80004ac4:	fe843503          	ld	a0,-24(s0)
    80004ac8:	dceff0ef          	jal	80004096 <filewrite>
}
    80004acc:	70a2                	ld	ra,40(sp)
    80004ace:	7402                	ld	s0,32(sp)
    80004ad0:	6145                	addi	sp,sp,48
    80004ad2:	8082                	ret

0000000080004ad4 <sys_close>:
{
    80004ad4:	1101                	addi	sp,sp,-32
    80004ad6:	ec06                	sd	ra,24(sp)
    80004ad8:	e822                	sd	s0,16(sp)
    80004ada:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004adc:	fe040613          	addi	a2,s0,-32
    80004ae0:	fec40593          	addi	a1,s0,-20
    80004ae4:	4501                	li	a0,0
    80004ae6:	d43ff0ef          	jal	80004828 <argfd>
    return -1;
    80004aea:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004aec:	02054063          	bltz	a0,80004b0c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004af0:	df1fc0ef          	jal	800018e0 <myproc>
    80004af4:	fec42783          	lw	a5,-20(s0)
    80004af8:	07e9                	addi	a5,a5,26
    80004afa:	078e                	slli	a5,a5,0x3
    80004afc:	953e                	add	a0,a0,a5
    80004afe:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004b02:	fe043503          	ld	a0,-32(s0)
    80004b06:	bb2ff0ef          	jal	80003eb8 <fileclose>
  return 0;
    80004b0a:	4781                	li	a5,0
}
    80004b0c:	853e                	mv	a0,a5
    80004b0e:	60e2                	ld	ra,24(sp)
    80004b10:	6442                	ld	s0,16(sp)
    80004b12:	6105                	addi	sp,sp,32
    80004b14:	8082                	ret

0000000080004b16 <sys_fstat>:
{
    80004b16:	1101                	addi	sp,sp,-32
    80004b18:	ec06                	sd	ra,24(sp)
    80004b1a:	e822                	sd	s0,16(sp)
    80004b1c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b1e:	fe040593          	addi	a1,s0,-32
    80004b22:	4505                	li	a0,1
    80004b24:	c8dfd0ef          	jal	800027b0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b28:	fe840613          	addi	a2,s0,-24
    80004b2c:	4581                	li	a1,0
    80004b2e:	4501                	li	a0,0
    80004b30:	cf9ff0ef          	jal	80004828 <argfd>
    80004b34:	87aa                	mv	a5,a0
    return -1;
    80004b36:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b38:	0007c863          	bltz	a5,80004b48 <sys_fstat+0x32>
  return filestat(f, st);
    80004b3c:	fe043583          	ld	a1,-32(s0)
    80004b40:	fe843503          	ld	a0,-24(s0)
    80004b44:	c36ff0ef          	jal	80003f7a <filestat>
}
    80004b48:	60e2                	ld	ra,24(sp)
    80004b4a:	6442                	ld	s0,16(sp)
    80004b4c:	6105                	addi	sp,sp,32
    80004b4e:	8082                	ret

0000000080004b50 <sys_link>:
{
    80004b50:	7169                	addi	sp,sp,-304
    80004b52:	f606                	sd	ra,296(sp)
    80004b54:	f222                	sd	s0,288(sp)
    80004b56:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b58:	08000613          	li	a2,128
    80004b5c:	ed040593          	addi	a1,s0,-304
    80004b60:	4501                	li	a0,0
    80004b62:	c6bfd0ef          	jal	800027cc <argstr>
    return -1;
    80004b66:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b68:	0c054e63          	bltz	a0,80004c44 <sys_link+0xf4>
    80004b6c:	08000613          	li	a2,128
    80004b70:	f5040593          	addi	a1,s0,-176
    80004b74:	4505                	li	a0,1
    80004b76:	c57fd0ef          	jal	800027cc <argstr>
    return -1;
    80004b7a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b7c:	0c054463          	bltz	a0,80004c44 <sys_link+0xf4>
    80004b80:	ee26                	sd	s1,280(sp)
  begin_op();
    80004b82:	f1dfe0ef          	jal	80003a9e <begin_op>
  if((ip = namei(old)) == 0){
    80004b86:	ed040513          	addi	a0,s0,-304
    80004b8a:	d59fe0ef          	jal	800038e2 <namei>
    80004b8e:	84aa                	mv	s1,a0
    80004b90:	c53d                	beqz	a0,80004bfe <sys_link+0xae>
  ilock(ip);
    80004b92:	e34fe0ef          	jal	800031c6 <ilock>
  if(ip->type == T_DIR){
    80004b96:	04449703          	lh	a4,68(s1)
    80004b9a:	4785                	li	a5,1
    80004b9c:	06f70663          	beq	a4,a5,80004c08 <sys_link+0xb8>
    80004ba0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ba2:	04a4d783          	lhu	a5,74(s1)
    80004ba6:	2785                	addiw	a5,a5,1
    80004ba8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004bac:	8526                	mv	a0,s1
    80004bae:	d64fe0ef          	jal	80003112 <iupdate>
  iunlock(ip);
    80004bb2:	8526                	mv	a0,s1
    80004bb4:	ec0fe0ef          	jal	80003274 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004bb8:	fd040593          	addi	a1,s0,-48
    80004bbc:	f5040513          	addi	a0,s0,-176
    80004bc0:	d3dfe0ef          	jal	800038fc <nameiparent>
    80004bc4:	892a                	mv	s2,a0
    80004bc6:	cd21                	beqz	a0,80004c1e <sys_link+0xce>
  ilock(dp);
    80004bc8:	dfefe0ef          	jal	800031c6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004bcc:	00092703          	lw	a4,0(s2)
    80004bd0:	409c                	lw	a5,0(s1)
    80004bd2:	04f71363          	bne	a4,a5,80004c18 <sys_link+0xc8>
    80004bd6:	40d0                	lw	a2,4(s1)
    80004bd8:	fd040593          	addi	a1,s0,-48
    80004bdc:	854a                	mv	a0,s2
    80004bde:	c6bfe0ef          	jal	80003848 <dirlink>
    80004be2:	02054b63          	bltz	a0,80004c18 <sys_link+0xc8>
  iunlockput(dp);
    80004be6:	854a                	mv	a0,s2
    80004be8:	fe8fe0ef          	jal	800033d0 <iunlockput>
  iput(ip);
    80004bec:	8526                	mv	a0,s1
    80004bee:	f5afe0ef          	jal	80003348 <iput>
  end_op();
    80004bf2:	f17fe0ef          	jal	80003b08 <end_op>
  return 0;
    80004bf6:	4781                	li	a5,0
    80004bf8:	64f2                	ld	s1,280(sp)
    80004bfa:	6952                	ld	s2,272(sp)
    80004bfc:	a0a1                	j	80004c44 <sys_link+0xf4>
    end_op();
    80004bfe:	f0bfe0ef          	jal	80003b08 <end_op>
    return -1;
    80004c02:	57fd                	li	a5,-1
    80004c04:	64f2                	ld	s1,280(sp)
    80004c06:	a83d                	j	80004c44 <sys_link+0xf4>
    iunlockput(ip);
    80004c08:	8526                	mv	a0,s1
    80004c0a:	fc6fe0ef          	jal	800033d0 <iunlockput>
    end_op();
    80004c0e:	efbfe0ef          	jal	80003b08 <end_op>
    return -1;
    80004c12:	57fd                	li	a5,-1
    80004c14:	64f2                	ld	s1,280(sp)
    80004c16:	a03d                	j	80004c44 <sys_link+0xf4>
    iunlockput(dp);
    80004c18:	854a                	mv	a0,s2
    80004c1a:	fb6fe0ef          	jal	800033d0 <iunlockput>
  ilock(ip);
    80004c1e:	8526                	mv	a0,s1
    80004c20:	da6fe0ef          	jal	800031c6 <ilock>
  ip->nlink--;
    80004c24:	04a4d783          	lhu	a5,74(s1)
    80004c28:	37fd                	addiw	a5,a5,-1
    80004c2a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ce2fe0ef          	jal	80003112 <iupdate>
  iunlockput(ip);
    80004c34:	8526                	mv	a0,s1
    80004c36:	f9afe0ef          	jal	800033d0 <iunlockput>
  end_op();
    80004c3a:	ecffe0ef          	jal	80003b08 <end_op>
  return -1;
    80004c3e:	57fd                	li	a5,-1
    80004c40:	64f2                	ld	s1,280(sp)
    80004c42:	6952                	ld	s2,272(sp)
}
    80004c44:	853e                	mv	a0,a5
    80004c46:	70b2                	ld	ra,296(sp)
    80004c48:	7412                	ld	s0,288(sp)
    80004c4a:	6155                	addi	sp,sp,304
    80004c4c:	8082                	ret

0000000080004c4e <sys_unlink>:
{
    80004c4e:	7151                	addi	sp,sp,-240
    80004c50:	f586                	sd	ra,232(sp)
    80004c52:	f1a2                	sd	s0,224(sp)
    80004c54:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c56:	08000613          	li	a2,128
    80004c5a:	f3040593          	addi	a1,s0,-208
    80004c5e:	4501                	li	a0,0
    80004c60:	b6dfd0ef          	jal	800027cc <argstr>
    80004c64:	16054063          	bltz	a0,80004dc4 <sys_unlink+0x176>
    80004c68:	eda6                	sd	s1,216(sp)
  begin_op();
    80004c6a:	e35fe0ef          	jal	80003a9e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004c6e:	fb040593          	addi	a1,s0,-80
    80004c72:	f3040513          	addi	a0,s0,-208
    80004c76:	c87fe0ef          	jal	800038fc <nameiparent>
    80004c7a:	84aa                	mv	s1,a0
    80004c7c:	c945                	beqz	a0,80004d2c <sys_unlink+0xde>
  ilock(dp);
    80004c7e:	d48fe0ef          	jal	800031c6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c82:	00003597          	auipc	a1,0x3
    80004c86:	99e58593          	addi	a1,a1,-1634 # 80007620 <etext+0x620>
    80004c8a:	fb040513          	addi	a0,s0,-80
    80004c8e:	9d9fe0ef          	jal	80003666 <namecmp>
    80004c92:	10050e63          	beqz	a0,80004dae <sys_unlink+0x160>
    80004c96:	00003597          	auipc	a1,0x3
    80004c9a:	99258593          	addi	a1,a1,-1646 # 80007628 <etext+0x628>
    80004c9e:	fb040513          	addi	a0,s0,-80
    80004ca2:	9c5fe0ef          	jal	80003666 <namecmp>
    80004ca6:	10050463          	beqz	a0,80004dae <sys_unlink+0x160>
    80004caa:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004cac:	f2c40613          	addi	a2,s0,-212
    80004cb0:	fb040593          	addi	a1,s0,-80
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	9c7fe0ef          	jal	8000367c <dirlookup>
    80004cba:	892a                	mv	s2,a0
    80004cbc:	0e050863          	beqz	a0,80004dac <sys_unlink+0x15e>
  ilock(ip);
    80004cc0:	d06fe0ef          	jal	800031c6 <ilock>
  if(ip->nlink < 1)
    80004cc4:	04a91783          	lh	a5,74(s2)
    80004cc8:	06f05763          	blez	a5,80004d36 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ccc:	04491703          	lh	a4,68(s2)
    80004cd0:	4785                	li	a5,1
    80004cd2:	06f70963          	beq	a4,a5,80004d44 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004cd6:	4641                	li	a2,16
    80004cd8:	4581                	li	a1,0
    80004cda:	fc040513          	addi	a0,s0,-64
    80004cde:	febfb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ce2:	4741                	li	a4,16
    80004ce4:	f2c42683          	lw	a3,-212(s0)
    80004ce8:	fc040613          	addi	a2,s0,-64
    80004cec:	4581                	li	a1,0
    80004cee:	8526                	mv	a0,s1
    80004cf0:	831fe0ef          	jal	80003520 <writei>
    80004cf4:	47c1                	li	a5,16
    80004cf6:	08f51b63          	bne	a0,a5,80004d8c <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004cfa:	04491703          	lh	a4,68(s2)
    80004cfe:	4785                	li	a5,1
    80004d00:	08f70d63          	beq	a4,a5,80004d9a <sys_unlink+0x14c>
  iunlockput(dp);
    80004d04:	8526                	mv	a0,s1
    80004d06:	ecafe0ef          	jal	800033d0 <iunlockput>
  ip->nlink--;
    80004d0a:	04a95783          	lhu	a5,74(s2)
    80004d0e:	37fd                	addiw	a5,a5,-1
    80004d10:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d14:	854a                	mv	a0,s2
    80004d16:	bfcfe0ef          	jal	80003112 <iupdate>
  iunlockput(ip);
    80004d1a:	854a                	mv	a0,s2
    80004d1c:	eb4fe0ef          	jal	800033d0 <iunlockput>
  end_op();
    80004d20:	de9fe0ef          	jal	80003b08 <end_op>
  return 0;
    80004d24:	4501                	li	a0,0
    80004d26:	64ee                	ld	s1,216(sp)
    80004d28:	694e                	ld	s2,208(sp)
    80004d2a:	a849                	j	80004dbc <sys_unlink+0x16e>
    end_op();
    80004d2c:	dddfe0ef          	jal	80003b08 <end_op>
    return -1;
    80004d30:	557d                	li	a0,-1
    80004d32:	64ee                	ld	s1,216(sp)
    80004d34:	a061                	j	80004dbc <sys_unlink+0x16e>
    80004d36:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004d38:	00003517          	auipc	a0,0x3
    80004d3c:	8f850513          	addi	a0,a0,-1800 # 80007630 <etext+0x630>
    80004d40:	a55fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d44:	04c92703          	lw	a4,76(s2)
    80004d48:	02000793          	li	a5,32
    80004d4c:	f8e7f5e3          	bgeu	a5,a4,80004cd6 <sys_unlink+0x88>
    80004d50:	e5ce                	sd	s3,200(sp)
    80004d52:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d56:	4741                	li	a4,16
    80004d58:	86ce                	mv	a3,s3
    80004d5a:	f1840613          	addi	a2,s0,-232
    80004d5e:	4581                	li	a1,0
    80004d60:	854a                	mv	a0,s2
    80004d62:	eb8fe0ef          	jal	8000341a <readi>
    80004d66:	47c1                	li	a5,16
    80004d68:	00f51c63          	bne	a0,a5,80004d80 <sys_unlink+0x132>
    if(de.inum != 0)
    80004d6c:	f1845783          	lhu	a5,-232(s0)
    80004d70:	efa1                	bnez	a5,80004dc8 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d72:	29c1                	addiw	s3,s3,16
    80004d74:	04c92783          	lw	a5,76(s2)
    80004d78:	fcf9efe3          	bltu	s3,a5,80004d56 <sys_unlink+0x108>
    80004d7c:	69ae                	ld	s3,200(sp)
    80004d7e:	bfa1                	j	80004cd6 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004d80:	00003517          	auipc	a0,0x3
    80004d84:	8c850513          	addi	a0,a0,-1848 # 80007648 <etext+0x648>
    80004d88:	a0dfb0ef          	jal	80000794 <panic>
    80004d8c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004d8e:	00003517          	auipc	a0,0x3
    80004d92:	8d250513          	addi	a0,a0,-1838 # 80007660 <etext+0x660>
    80004d96:	9fffb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004d9a:	04a4d783          	lhu	a5,74(s1)
    80004d9e:	37fd                	addiw	a5,a5,-1
    80004da0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004da4:	8526                	mv	a0,s1
    80004da6:	b6cfe0ef          	jal	80003112 <iupdate>
    80004daa:	bfa9                	j	80004d04 <sys_unlink+0xb6>
    80004dac:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004dae:	8526                	mv	a0,s1
    80004db0:	e20fe0ef          	jal	800033d0 <iunlockput>
  end_op();
    80004db4:	d55fe0ef          	jal	80003b08 <end_op>
  return -1;
    80004db8:	557d                	li	a0,-1
    80004dba:	64ee                	ld	s1,216(sp)
}
    80004dbc:	70ae                	ld	ra,232(sp)
    80004dbe:	740e                	ld	s0,224(sp)
    80004dc0:	616d                	addi	sp,sp,240
    80004dc2:	8082                	ret
    return -1;
    80004dc4:	557d                	li	a0,-1
    80004dc6:	bfdd                	j	80004dbc <sys_unlink+0x16e>
    iunlockput(ip);
    80004dc8:	854a                	mv	a0,s2
    80004dca:	e06fe0ef          	jal	800033d0 <iunlockput>
    goto bad;
    80004dce:	694e                	ld	s2,208(sp)
    80004dd0:	69ae                	ld	s3,200(sp)
    80004dd2:	bff1                	j	80004dae <sys_unlink+0x160>

0000000080004dd4 <sys_open>:

uint64
sys_open(void)
{
    80004dd4:	7131                	addi	sp,sp,-192
    80004dd6:	fd06                	sd	ra,184(sp)
    80004dd8:	f922                	sd	s0,176(sp)
    80004dda:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004ddc:	f4c40593          	addi	a1,s0,-180
    80004de0:	4505                	li	a0,1
    80004de2:	9b3fd0ef          	jal	80002794 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004de6:	08000613          	li	a2,128
    80004dea:	f5040593          	addi	a1,s0,-176
    80004dee:	4501                	li	a0,0
    80004df0:	9ddfd0ef          	jal	800027cc <argstr>
    80004df4:	87aa                	mv	a5,a0
    return -1;
    80004df6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004df8:	0a07c263          	bltz	a5,80004e9c <sys_open+0xc8>
    80004dfc:	f526                	sd	s1,168(sp)

  begin_op();
    80004dfe:	ca1fe0ef          	jal	80003a9e <begin_op>

  if(omode & O_CREATE){
    80004e02:	f4c42783          	lw	a5,-180(s0)
    80004e06:	2007f793          	andi	a5,a5,512
    80004e0a:	c3d5                	beqz	a5,80004eae <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004e0c:	4681                	li	a3,0
    80004e0e:	4601                	li	a2,0
    80004e10:	4589                	li	a1,2
    80004e12:	f5040513          	addi	a0,s0,-176
    80004e16:	aa9ff0ef          	jal	800048be <create>
    80004e1a:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e1c:	c541                	beqz	a0,80004ea4 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e1e:	04449703          	lh	a4,68(s1)
    80004e22:	478d                	li	a5,3
    80004e24:	00f71763          	bne	a4,a5,80004e32 <sys_open+0x5e>
    80004e28:	0464d703          	lhu	a4,70(s1)
    80004e2c:	47a5                	li	a5,9
    80004e2e:	0ae7ed63          	bltu	a5,a4,80004ee8 <sys_open+0x114>
    80004e32:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e34:	fe1fe0ef          	jal	80003e14 <filealloc>
    80004e38:	892a                	mv	s2,a0
    80004e3a:	c179                	beqz	a0,80004f00 <sys_open+0x12c>
    80004e3c:	ed4e                	sd	s3,152(sp)
    80004e3e:	a43ff0ef          	jal	80004880 <fdalloc>
    80004e42:	89aa                	mv	s3,a0
    80004e44:	0a054a63          	bltz	a0,80004ef8 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e48:	04449703          	lh	a4,68(s1)
    80004e4c:	478d                	li	a5,3
    80004e4e:	0cf70263          	beq	a4,a5,80004f12 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e52:	4789                	li	a5,2
    80004e54:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004e58:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004e5c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004e60:	f4c42783          	lw	a5,-180(s0)
    80004e64:	0017c713          	xori	a4,a5,1
    80004e68:	8b05                	andi	a4,a4,1
    80004e6a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e6e:	0037f713          	andi	a4,a5,3
    80004e72:	00e03733          	snez	a4,a4
    80004e76:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e7a:	4007f793          	andi	a5,a5,1024
    80004e7e:	c791                	beqz	a5,80004e8a <sys_open+0xb6>
    80004e80:	04449703          	lh	a4,68(s1)
    80004e84:	4789                	li	a5,2
    80004e86:	08f70d63          	beq	a4,a5,80004f20 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	be8fe0ef          	jal	80003274 <iunlock>
  end_op();
    80004e90:	c79fe0ef          	jal	80003b08 <end_op>

  return fd;
    80004e94:	854e                	mv	a0,s3
    80004e96:	74aa                	ld	s1,168(sp)
    80004e98:	790a                	ld	s2,160(sp)
    80004e9a:	69ea                	ld	s3,152(sp)
}
    80004e9c:	70ea                	ld	ra,184(sp)
    80004e9e:	744a                	ld	s0,176(sp)
    80004ea0:	6129                	addi	sp,sp,192
    80004ea2:	8082                	ret
      end_op();
    80004ea4:	c65fe0ef          	jal	80003b08 <end_op>
      return -1;
    80004ea8:	557d                	li	a0,-1
    80004eaa:	74aa                	ld	s1,168(sp)
    80004eac:	bfc5                	j	80004e9c <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004eae:	f5040513          	addi	a0,s0,-176
    80004eb2:	a31fe0ef          	jal	800038e2 <namei>
    80004eb6:	84aa                	mv	s1,a0
    80004eb8:	c11d                	beqz	a0,80004ede <sys_open+0x10a>
    ilock(ip);
    80004eba:	b0cfe0ef          	jal	800031c6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004ebe:	04449703          	lh	a4,68(s1)
    80004ec2:	4785                	li	a5,1
    80004ec4:	f4f71de3          	bne	a4,a5,80004e1e <sys_open+0x4a>
    80004ec8:	f4c42783          	lw	a5,-180(s0)
    80004ecc:	d3bd                	beqz	a5,80004e32 <sys_open+0x5e>
      iunlockput(ip);
    80004ece:	8526                	mv	a0,s1
    80004ed0:	d00fe0ef          	jal	800033d0 <iunlockput>
      end_op();
    80004ed4:	c35fe0ef          	jal	80003b08 <end_op>
      return -1;
    80004ed8:	557d                	li	a0,-1
    80004eda:	74aa                	ld	s1,168(sp)
    80004edc:	b7c1                	j	80004e9c <sys_open+0xc8>
      end_op();
    80004ede:	c2bfe0ef          	jal	80003b08 <end_op>
      return -1;
    80004ee2:	557d                	li	a0,-1
    80004ee4:	74aa                	ld	s1,168(sp)
    80004ee6:	bf5d                	j	80004e9c <sys_open+0xc8>
    iunlockput(ip);
    80004ee8:	8526                	mv	a0,s1
    80004eea:	ce6fe0ef          	jal	800033d0 <iunlockput>
    end_op();
    80004eee:	c1bfe0ef          	jal	80003b08 <end_op>
    return -1;
    80004ef2:	557d                	li	a0,-1
    80004ef4:	74aa                	ld	s1,168(sp)
    80004ef6:	b75d                	j	80004e9c <sys_open+0xc8>
      fileclose(f);
    80004ef8:	854a                	mv	a0,s2
    80004efa:	fbffe0ef          	jal	80003eb8 <fileclose>
    80004efe:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f00:	8526                	mv	a0,s1
    80004f02:	ccefe0ef          	jal	800033d0 <iunlockput>
    end_op();
    80004f06:	c03fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004f0a:	557d                	li	a0,-1
    80004f0c:	74aa                	ld	s1,168(sp)
    80004f0e:	790a                	ld	s2,160(sp)
    80004f10:	b771                	j	80004e9c <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004f12:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004f16:	04649783          	lh	a5,70(s1)
    80004f1a:	02f91223          	sh	a5,36(s2)
    80004f1e:	bf3d                	j	80004e5c <sys_open+0x88>
    itrunc(ip);
    80004f20:	8526                	mv	a0,s1
    80004f22:	b92fe0ef          	jal	800032b4 <itrunc>
    80004f26:	b795                	j	80004e8a <sys_open+0xb6>

0000000080004f28 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f28:	7175                	addi	sp,sp,-144
    80004f2a:	e506                	sd	ra,136(sp)
    80004f2c:	e122                	sd	s0,128(sp)
    80004f2e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f30:	b6ffe0ef          	jal	80003a9e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f34:	08000613          	li	a2,128
    80004f38:	f7040593          	addi	a1,s0,-144
    80004f3c:	4501                	li	a0,0
    80004f3e:	88ffd0ef          	jal	800027cc <argstr>
    80004f42:	02054363          	bltz	a0,80004f68 <sys_mkdir+0x40>
    80004f46:	4681                	li	a3,0
    80004f48:	4601                	li	a2,0
    80004f4a:	4585                	li	a1,1
    80004f4c:	f7040513          	addi	a0,s0,-144
    80004f50:	96fff0ef          	jal	800048be <create>
    80004f54:	c911                	beqz	a0,80004f68 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f56:	c7afe0ef          	jal	800033d0 <iunlockput>
  end_op();
    80004f5a:	baffe0ef          	jal	80003b08 <end_op>
  return 0;
    80004f5e:	4501                	li	a0,0
}
    80004f60:	60aa                	ld	ra,136(sp)
    80004f62:	640a                	ld	s0,128(sp)
    80004f64:	6149                	addi	sp,sp,144
    80004f66:	8082                	ret
    end_op();
    80004f68:	ba1fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004f6c:	557d                	li	a0,-1
    80004f6e:	bfcd                	j	80004f60 <sys_mkdir+0x38>

0000000080004f70 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f70:	7135                	addi	sp,sp,-160
    80004f72:	ed06                	sd	ra,152(sp)
    80004f74:	e922                	sd	s0,144(sp)
    80004f76:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f78:	b27fe0ef          	jal	80003a9e <begin_op>
  argint(1, &major);
    80004f7c:	f6c40593          	addi	a1,s0,-148
    80004f80:	4505                	li	a0,1
    80004f82:	813fd0ef          	jal	80002794 <argint>
  argint(2, &minor);
    80004f86:	f6840593          	addi	a1,s0,-152
    80004f8a:	4509                	li	a0,2
    80004f8c:	809fd0ef          	jal	80002794 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f90:	08000613          	li	a2,128
    80004f94:	f7040593          	addi	a1,s0,-144
    80004f98:	4501                	li	a0,0
    80004f9a:	833fd0ef          	jal	800027cc <argstr>
    80004f9e:	02054563          	bltz	a0,80004fc8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004fa2:	f6841683          	lh	a3,-152(s0)
    80004fa6:	f6c41603          	lh	a2,-148(s0)
    80004faa:	458d                	li	a1,3
    80004fac:	f7040513          	addi	a0,s0,-144
    80004fb0:	90fff0ef          	jal	800048be <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fb4:	c911                	beqz	a0,80004fc8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fb6:	c1afe0ef          	jal	800033d0 <iunlockput>
  end_op();
    80004fba:	b4ffe0ef          	jal	80003b08 <end_op>
  return 0;
    80004fbe:	4501                	li	a0,0
}
    80004fc0:	60ea                	ld	ra,152(sp)
    80004fc2:	644a                	ld	s0,144(sp)
    80004fc4:	610d                	addi	sp,sp,160
    80004fc6:	8082                	ret
    end_op();
    80004fc8:	b41fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004fcc:	557d                	li	a0,-1
    80004fce:	bfcd                	j	80004fc0 <sys_mknod+0x50>

0000000080004fd0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fd0:	7135                	addi	sp,sp,-160
    80004fd2:	ed06                	sd	ra,152(sp)
    80004fd4:	e922                	sd	s0,144(sp)
    80004fd6:	e14a                	sd	s2,128(sp)
    80004fd8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fda:	907fc0ef          	jal	800018e0 <myproc>
    80004fde:	892a                	mv	s2,a0
  
  begin_op();
    80004fe0:	abffe0ef          	jal	80003a9e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004fe4:	08000613          	li	a2,128
    80004fe8:	f6040593          	addi	a1,s0,-160
    80004fec:	4501                	li	a0,0
    80004fee:	fdefd0ef          	jal	800027cc <argstr>
    80004ff2:	04054363          	bltz	a0,80005038 <sys_chdir+0x68>
    80004ff6:	e526                	sd	s1,136(sp)
    80004ff8:	f6040513          	addi	a0,s0,-160
    80004ffc:	8e7fe0ef          	jal	800038e2 <namei>
    80005000:	84aa                	mv	s1,a0
    80005002:	c915                	beqz	a0,80005036 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005004:	9c2fe0ef          	jal	800031c6 <ilock>
  if(ip->type != T_DIR){
    80005008:	04449703          	lh	a4,68(s1)
    8000500c:	4785                	li	a5,1
    8000500e:	02f71963          	bne	a4,a5,80005040 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005012:	8526                	mv	a0,s1
    80005014:	a60fe0ef          	jal	80003274 <iunlock>
  iput(p->cwd);
    80005018:	15093503          	ld	a0,336(s2)
    8000501c:	b2cfe0ef          	jal	80003348 <iput>
  end_op();
    80005020:	ae9fe0ef          	jal	80003b08 <end_op>
  p->cwd = ip;
    80005024:	14993823          	sd	s1,336(s2)
  return 0;
    80005028:	4501                	li	a0,0
    8000502a:	64aa                	ld	s1,136(sp)
}
    8000502c:	60ea                	ld	ra,152(sp)
    8000502e:	644a                	ld	s0,144(sp)
    80005030:	690a                	ld	s2,128(sp)
    80005032:	610d                	addi	sp,sp,160
    80005034:	8082                	ret
    80005036:	64aa                	ld	s1,136(sp)
    end_op();
    80005038:	ad1fe0ef          	jal	80003b08 <end_op>
    return -1;
    8000503c:	557d                	li	a0,-1
    8000503e:	b7fd                	j	8000502c <sys_chdir+0x5c>
    iunlockput(ip);
    80005040:	8526                	mv	a0,s1
    80005042:	b8efe0ef          	jal	800033d0 <iunlockput>
    end_op();
    80005046:	ac3fe0ef          	jal	80003b08 <end_op>
    return -1;
    8000504a:	557d                	li	a0,-1
    8000504c:	64aa                	ld	s1,136(sp)
    8000504e:	bff9                	j	8000502c <sys_chdir+0x5c>

0000000080005050 <sys_exec>:

uint64
sys_exec(void)
{
    80005050:	7121                	addi	sp,sp,-448
    80005052:	ff06                	sd	ra,440(sp)
    80005054:	fb22                	sd	s0,432(sp)
    80005056:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005058:	e4840593          	addi	a1,s0,-440
    8000505c:	4505                	li	a0,1
    8000505e:	f52fd0ef          	jal	800027b0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005062:	08000613          	li	a2,128
    80005066:	f5040593          	addi	a1,s0,-176
    8000506a:	4501                	li	a0,0
    8000506c:	f60fd0ef          	jal	800027cc <argstr>
    80005070:	87aa                	mv	a5,a0
    return -1;
    80005072:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005074:	0c07c463          	bltz	a5,8000513c <sys_exec+0xec>
    80005078:	f726                	sd	s1,424(sp)
    8000507a:	f34a                	sd	s2,416(sp)
    8000507c:	ef4e                	sd	s3,408(sp)
    8000507e:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005080:	10000613          	li	a2,256
    80005084:	4581                	li	a1,0
    80005086:	e5040513          	addi	a0,s0,-432
    8000508a:	c3ffb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000508e:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005092:	89a6                	mv	s3,s1
    80005094:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005096:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000509a:	00391513          	slli	a0,s2,0x3
    8000509e:	e4040593          	addi	a1,s0,-448
    800050a2:	e4843783          	ld	a5,-440(s0)
    800050a6:	953e                	add	a0,a0,a5
    800050a8:	e62fd0ef          	jal	8000270a <fetchaddr>
    800050ac:	02054663          	bltz	a0,800050d8 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800050b0:	e4043783          	ld	a5,-448(s0)
    800050b4:	c3a9                	beqz	a5,800050f6 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800050b6:	a6ffb0ef          	jal	80000b24 <kalloc>
    800050ba:	85aa                	mv	a1,a0
    800050bc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800050c0:	cd01                	beqz	a0,800050d8 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800050c2:	6605                	lui	a2,0x1
    800050c4:	e4043503          	ld	a0,-448(s0)
    800050c8:	e8cfd0ef          	jal	80002754 <fetchstr>
    800050cc:	00054663          	bltz	a0,800050d8 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800050d0:	0905                	addi	s2,s2,1
    800050d2:	09a1                	addi	s3,s3,8
    800050d4:	fd4913e3          	bne	s2,s4,8000509a <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050d8:	f5040913          	addi	s2,s0,-176
    800050dc:	6088                	ld	a0,0(s1)
    800050de:	c931                	beqz	a0,80005132 <sys_exec+0xe2>
    kfree(argv[i]);
    800050e0:	963fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050e4:	04a1                	addi	s1,s1,8
    800050e6:	ff249be3          	bne	s1,s2,800050dc <sys_exec+0x8c>
  return -1;
    800050ea:	557d                	li	a0,-1
    800050ec:	74ba                	ld	s1,424(sp)
    800050ee:	791a                	ld	s2,416(sp)
    800050f0:	69fa                	ld	s3,408(sp)
    800050f2:	6a5a                	ld	s4,400(sp)
    800050f4:	a0a1                	j	8000513c <sys_exec+0xec>
      argv[i] = 0;
    800050f6:	0009079b          	sext.w	a5,s2
    800050fa:	078e                	slli	a5,a5,0x3
    800050fc:	fd078793          	addi	a5,a5,-48
    80005100:	97a2                	add	a5,a5,s0
    80005102:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005106:	e5040593          	addi	a1,s0,-432
    8000510a:	f5040513          	addi	a0,s0,-176
    8000510e:	ba8ff0ef          	jal	800044b6 <exec>
    80005112:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005114:	f5040993          	addi	s3,s0,-176
    80005118:	6088                	ld	a0,0(s1)
    8000511a:	c511                	beqz	a0,80005126 <sys_exec+0xd6>
    kfree(argv[i]);
    8000511c:	927fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005120:	04a1                	addi	s1,s1,8
    80005122:	ff349be3          	bne	s1,s3,80005118 <sys_exec+0xc8>
  return ret;
    80005126:	854a                	mv	a0,s2
    80005128:	74ba                	ld	s1,424(sp)
    8000512a:	791a                	ld	s2,416(sp)
    8000512c:	69fa                	ld	s3,408(sp)
    8000512e:	6a5a                	ld	s4,400(sp)
    80005130:	a031                	j	8000513c <sys_exec+0xec>
  return -1;
    80005132:	557d                	li	a0,-1
    80005134:	74ba                	ld	s1,424(sp)
    80005136:	791a                	ld	s2,416(sp)
    80005138:	69fa                	ld	s3,408(sp)
    8000513a:	6a5a                	ld	s4,400(sp)
}
    8000513c:	70fa                	ld	ra,440(sp)
    8000513e:	745a                	ld	s0,432(sp)
    80005140:	6139                	addi	sp,sp,448
    80005142:	8082                	ret

0000000080005144 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005144:	7139                	addi	sp,sp,-64
    80005146:	fc06                	sd	ra,56(sp)
    80005148:	f822                	sd	s0,48(sp)
    8000514a:	f426                	sd	s1,40(sp)
    8000514c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000514e:	f92fc0ef          	jal	800018e0 <myproc>
    80005152:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005154:	fd840593          	addi	a1,s0,-40
    80005158:	4501                	li	a0,0
    8000515a:	e56fd0ef          	jal	800027b0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000515e:	fc840593          	addi	a1,s0,-56
    80005162:	fd040513          	addi	a0,s0,-48
    80005166:	85cff0ef          	jal	800041c2 <pipealloc>
    return -1;
    8000516a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000516c:	0a054463          	bltz	a0,80005214 <sys_pipe+0xd0>
  fd0 = -1;
    80005170:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005174:	fd043503          	ld	a0,-48(s0)
    80005178:	f08ff0ef          	jal	80004880 <fdalloc>
    8000517c:	fca42223          	sw	a0,-60(s0)
    80005180:	08054163          	bltz	a0,80005202 <sys_pipe+0xbe>
    80005184:	fc843503          	ld	a0,-56(s0)
    80005188:	ef8ff0ef          	jal	80004880 <fdalloc>
    8000518c:	fca42023          	sw	a0,-64(s0)
    80005190:	06054063          	bltz	a0,800051f0 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005194:	4691                	li	a3,4
    80005196:	fc440613          	addi	a2,s0,-60
    8000519a:	fd843583          	ld	a1,-40(s0)
    8000519e:	68a8                	ld	a0,80(s1)
    800051a0:	bb2fc0ef          	jal	80001552 <copyout>
    800051a4:	00054e63          	bltz	a0,800051c0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051a8:	4691                	li	a3,4
    800051aa:	fc040613          	addi	a2,s0,-64
    800051ae:	fd843583          	ld	a1,-40(s0)
    800051b2:	0591                	addi	a1,a1,4
    800051b4:	68a8                	ld	a0,80(s1)
    800051b6:	b9cfc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800051ba:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051bc:	04055c63          	bgez	a0,80005214 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800051c0:	fc442783          	lw	a5,-60(s0)
    800051c4:	07e9                	addi	a5,a5,26
    800051c6:	078e                	slli	a5,a5,0x3
    800051c8:	97a6                	add	a5,a5,s1
    800051ca:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800051ce:	fc042783          	lw	a5,-64(s0)
    800051d2:	07e9                	addi	a5,a5,26
    800051d4:	078e                	slli	a5,a5,0x3
    800051d6:	94be                	add	s1,s1,a5
    800051d8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800051dc:	fd043503          	ld	a0,-48(s0)
    800051e0:	cd9fe0ef          	jal	80003eb8 <fileclose>
    fileclose(wf);
    800051e4:	fc843503          	ld	a0,-56(s0)
    800051e8:	cd1fe0ef          	jal	80003eb8 <fileclose>
    return -1;
    800051ec:	57fd                	li	a5,-1
    800051ee:	a01d                	j	80005214 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800051f0:	fc442783          	lw	a5,-60(s0)
    800051f4:	0007c763          	bltz	a5,80005202 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800051f8:	07e9                	addi	a5,a5,26
    800051fa:	078e                	slli	a5,a5,0x3
    800051fc:	97a6                	add	a5,a5,s1
    800051fe:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005202:	fd043503          	ld	a0,-48(s0)
    80005206:	cb3fe0ef          	jal	80003eb8 <fileclose>
    fileclose(wf);
    8000520a:	fc843503          	ld	a0,-56(s0)
    8000520e:	cabfe0ef          	jal	80003eb8 <fileclose>
    return -1;
    80005212:	57fd                	li	a5,-1
}
    80005214:	853e                	mv	a0,a5
    80005216:	70e2                	ld	ra,56(sp)
    80005218:	7442                	ld	s0,48(sp)
    8000521a:	74a2                	ld	s1,40(sp)
    8000521c:	6121                	addi	sp,sp,64
    8000521e:	8082                	ret

0000000080005220 <sys_chmod>:

uint64
sys_chmod(void)
{
    80005220:	7171                	addi	sp,sp,-176
    80005222:	f506                	sd	ra,168(sp)
    80005224:	f122                	sd	s0,160(sp)
    80005226:	1900                	addi	s0,sp,176
    char path[MAXPATH];
    int perm;

    // Extraer los argumentos
    if(argstr(0, path, MAXPATH) < 0)  // Extraer el nombre del archivo
    80005228:	08000613          	li	a2,128
    8000522c:	f6040593          	addi	a1,s0,-160
    80005230:	4501                	li	a0,0
    80005232:	d9afd0ef          	jal	800027cc <argstr>
        return -1;
    80005236:	57fd                	li	a5,-1
    if(argstr(0, path, MAXPATH) < 0)  // Extraer el nombre del archivo
    80005238:	04054263          	bltz	a0,8000527c <sys_chmod+0x5c>
    8000523c:	ed26                	sd	s1,152(sp)

    argint(1, &perm);  // Extraer el segundo argumento (permiso)
    8000523e:	f5c40593          	addi	a1,s0,-164
    80005242:	4505                	li	a0,1
    80005244:	d50fd0ef          	jal	80002794 <argint>

    struct inode *ip;
    begin_op();
    80005248:	857fe0ef          	jal	80003a9e <begin_op>

    if((ip = namei(path)) == 0){  // Buscar el archivo por su nombre
    8000524c:	f6040513          	addi	a0,s0,-160
    80005250:	e92fe0ef          	jal	800038e2 <namei>
    80005254:	84aa                	mv	s1,a0
    80005256:	c905                	beqz	a0,80005286 <sys_chmod+0x66>
        end_op();
        return -1; // Error si el archivo no existe
    }

    ilock(ip);
    80005258:	f6ffd0ef          	jal	800031c6 <ilock>

    // Verificar si el archivo es inmutable
    if(ip->perm == 5) {
    8000525c:	0844c703          	lbu	a4,132(s1)
    80005260:	4795                	li	a5,5
    80005262:	02f70763          	beq	a4,a5,80005290 <sys_chmod+0x70>
        iunlock(ip);
        end_op();
        return -1; // Error: archivo inmutable
    }

    ip->perm = perm;  // Cambiar los permisos
    80005266:	f5c42783          	lw	a5,-164(s0)
    8000526a:	08f48223          	sb	a5,132(s1)
    iunlock(ip);
    8000526e:	8526                	mv	a0,s1
    80005270:	804fe0ef          	jal	80003274 <iunlock>
    end_op();
    80005274:	895fe0ef          	jal	80003b08 <end_op>

    return 0; // Éxito
    80005278:	4781                	li	a5,0
    8000527a:	64ea                	ld	s1,152(sp)
}
    8000527c:	853e                	mv	a0,a5
    8000527e:	70aa                	ld	ra,168(sp)
    80005280:	740a                	ld	s0,160(sp)
    80005282:	614d                	addi	sp,sp,176
    80005284:	8082                	ret
        end_op();
    80005286:	883fe0ef          	jal	80003b08 <end_op>
        return -1; // Error si el archivo no existe
    8000528a:	57fd                	li	a5,-1
    8000528c:	64ea                	ld	s1,152(sp)
    8000528e:	b7fd                	j	8000527c <sys_chmod+0x5c>
        iunlock(ip);
    80005290:	8526                	mv	a0,s1
    80005292:	fe3fd0ef          	jal	80003274 <iunlock>
        end_op();
    80005296:	873fe0ef          	jal	80003b08 <end_op>
        return -1; // Error: archivo inmutable
    8000529a:	57fd                	li	a5,-1
    8000529c:	64ea                	ld	s1,152(sp)
    8000529e:	bff9                	j	8000527c <sys_chmod+0x5c>

00000000800052a0 <kernelvec>:
    800052a0:	7111                	addi	sp,sp,-256
    800052a2:	e006                	sd	ra,0(sp)
    800052a4:	e40a                	sd	sp,8(sp)
    800052a6:	e80e                	sd	gp,16(sp)
    800052a8:	ec12                	sd	tp,24(sp)
    800052aa:	f016                	sd	t0,32(sp)
    800052ac:	f41a                	sd	t1,40(sp)
    800052ae:	f81e                	sd	t2,48(sp)
    800052b0:	e4aa                	sd	a0,72(sp)
    800052b2:	e8ae                	sd	a1,80(sp)
    800052b4:	ecb2                	sd	a2,88(sp)
    800052b6:	f0b6                	sd	a3,96(sp)
    800052b8:	f4ba                	sd	a4,104(sp)
    800052ba:	f8be                	sd	a5,112(sp)
    800052bc:	fcc2                	sd	a6,120(sp)
    800052be:	e146                	sd	a7,128(sp)
    800052c0:	edf2                	sd	t3,216(sp)
    800052c2:	f1f6                	sd	t4,224(sp)
    800052c4:	f5fa                	sd	t5,232(sp)
    800052c6:	f9fe                	sd	t6,240(sp)
    800052c8:	b52fd0ef          	jal	8000261a <kerneltrap>
    800052cc:	6082                	ld	ra,0(sp)
    800052ce:	6122                	ld	sp,8(sp)
    800052d0:	61c2                	ld	gp,16(sp)
    800052d2:	7282                	ld	t0,32(sp)
    800052d4:	7322                	ld	t1,40(sp)
    800052d6:	73c2                	ld	t2,48(sp)
    800052d8:	6526                	ld	a0,72(sp)
    800052da:	65c6                	ld	a1,80(sp)
    800052dc:	6666                	ld	a2,88(sp)
    800052de:	7686                	ld	a3,96(sp)
    800052e0:	7726                	ld	a4,104(sp)
    800052e2:	77c6                	ld	a5,112(sp)
    800052e4:	7866                	ld	a6,120(sp)
    800052e6:	688a                	ld	a7,128(sp)
    800052e8:	6e6e                	ld	t3,216(sp)
    800052ea:	7e8e                	ld	t4,224(sp)
    800052ec:	7f2e                	ld	t5,232(sp)
    800052ee:	7fce                	ld	t6,240(sp)
    800052f0:	6111                	addi	sp,sp,256
    800052f2:	10200073          	sret
	...

00000000800052fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800052fe:	1141                	addi	sp,sp,-16
    80005300:	e422                	sd	s0,8(sp)
    80005302:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005304:	0c0007b7          	lui	a5,0xc000
    80005308:	4705                	li	a4,1
    8000530a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000530c:	0c0007b7          	lui	a5,0xc000
    80005310:	c3d8                	sw	a4,4(a5)
}
    80005312:	6422                	ld	s0,8(sp)
    80005314:	0141                	addi	sp,sp,16
    80005316:	8082                	ret

0000000080005318 <plicinithart>:

void
plicinithart(void)
{
    80005318:	1141                	addi	sp,sp,-16
    8000531a:	e406                	sd	ra,8(sp)
    8000531c:	e022                	sd	s0,0(sp)
    8000531e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005320:	d94fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005324:	0085171b          	slliw	a4,a0,0x8
    80005328:	0c0027b7          	lui	a5,0xc002
    8000532c:	97ba                	add	a5,a5,a4
    8000532e:	40200713          	li	a4,1026
    80005332:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005336:	00d5151b          	slliw	a0,a0,0xd
    8000533a:	0c2017b7          	lui	a5,0xc201
    8000533e:	97aa                	add	a5,a5,a0
    80005340:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005344:	60a2                	ld	ra,8(sp)
    80005346:	6402                	ld	s0,0(sp)
    80005348:	0141                	addi	sp,sp,16
    8000534a:	8082                	ret

000000008000534c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000534c:	1141                	addi	sp,sp,-16
    8000534e:	e406                	sd	ra,8(sp)
    80005350:	e022                	sd	s0,0(sp)
    80005352:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005354:	d60fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005358:	00d5151b          	slliw	a0,a0,0xd
    8000535c:	0c2017b7          	lui	a5,0xc201
    80005360:	97aa                	add	a5,a5,a0
  return irq;
}
    80005362:	43c8                	lw	a0,4(a5)
    80005364:	60a2                	ld	ra,8(sp)
    80005366:	6402                	ld	s0,0(sp)
    80005368:	0141                	addi	sp,sp,16
    8000536a:	8082                	ret

000000008000536c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000536c:	1101                	addi	sp,sp,-32
    8000536e:	ec06                	sd	ra,24(sp)
    80005370:	e822                	sd	s0,16(sp)
    80005372:	e426                	sd	s1,8(sp)
    80005374:	1000                	addi	s0,sp,32
    80005376:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005378:	d3cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000537c:	00d5151b          	slliw	a0,a0,0xd
    80005380:	0c2017b7          	lui	a5,0xc201
    80005384:	97aa                	add	a5,a5,a0
    80005386:	c3c4                	sw	s1,4(a5)
}
    80005388:	60e2                	ld	ra,24(sp)
    8000538a:	6442                	ld	s0,16(sp)
    8000538c:	64a2                	ld	s1,8(sp)
    8000538e:	6105                	addi	sp,sp,32
    80005390:	8082                	ret

0000000080005392 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005392:	1141                	addi	sp,sp,-16
    80005394:	e406                	sd	ra,8(sp)
    80005396:	e022                	sd	s0,0(sp)
    80005398:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000539a:	479d                	li	a5,7
    8000539c:	04a7ca63          	blt	a5,a0,800053f0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800053a0:	0001b797          	auipc	a5,0x1b
    800053a4:	77078793          	addi	a5,a5,1904 # 80020b10 <disk>
    800053a8:	97aa                	add	a5,a5,a0
    800053aa:	0187c783          	lbu	a5,24(a5)
    800053ae:	e7b9                	bnez	a5,800053fc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800053b0:	00451693          	slli	a3,a0,0x4
    800053b4:	0001b797          	auipc	a5,0x1b
    800053b8:	75c78793          	addi	a5,a5,1884 # 80020b10 <disk>
    800053bc:	6398                	ld	a4,0(a5)
    800053be:	9736                	add	a4,a4,a3
    800053c0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800053c4:	6398                	ld	a4,0(a5)
    800053c6:	9736                	add	a4,a4,a3
    800053c8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800053cc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053d0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053d4:	97aa                	add	a5,a5,a0
    800053d6:	4705                	li	a4,1
    800053d8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053dc:	0001b517          	auipc	a0,0x1b
    800053e0:	74c50513          	addi	a0,a0,1868 # 80020b28 <disk+0x18>
    800053e4:	b17fc0ef          	jal	80001efa <wakeup>
}
    800053e8:	60a2                	ld	ra,8(sp)
    800053ea:	6402                	ld	s0,0(sp)
    800053ec:	0141                	addi	sp,sp,16
    800053ee:	8082                	ret
    panic("free_desc 1");
    800053f0:	00002517          	auipc	a0,0x2
    800053f4:	28050513          	addi	a0,a0,640 # 80007670 <etext+0x670>
    800053f8:	b9cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800053fc:	00002517          	auipc	a0,0x2
    80005400:	28450513          	addi	a0,a0,644 # 80007680 <etext+0x680>
    80005404:	b90fb0ef          	jal	80000794 <panic>

0000000080005408 <virtio_disk_init>:
{
    80005408:	1101                	addi	sp,sp,-32
    8000540a:	ec06                	sd	ra,24(sp)
    8000540c:	e822                	sd	s0,16(sp)
    8000540e:	e426                	sd	s1,8(sp)
    80005410:	e04a                	sd	s2,0(sp)
    80005412:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005414:	00002597          	auipc	a1,0x2
    80005418:	27c58593          	addi	a1,a1,636 # 80007690 <etext+0x690>
    8000541c:	0001c517          	auipc	a0,0x1c
    80005420:	81c50513          	addi	a0,a0,-2020 # 80020c38 <disk+0x128>
    80005424:	f50fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005428:	100017b7          	lui	a5,0x10001
    8000542c:	4398                	lw	a4,0(a5)
    8000542e:	2701                	sext.w	a4,a4
    80005430:	747277b7          	lui	a5,0x74727
    80005434:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005438:	18f71063          	bne	a4,a5,800055b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000543c:	100017b7          	lui	a5,0x10001
    80005440:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005442:	439c                	lw	a5,0(a5)
    80005444:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005446:	4709                	li	a4,2
    80005448:	16e79863          	bne	a5,a4,800055b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000544c:	100017b7          	lui	a5,0x10001
    80005450:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005452:	439c                	lw	a5,0(a5)
    80005454:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005456:	16e79163          	bne	a5,a4,800055b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000545a:	100017b7          	lui	a5,0x10001
    8000545e:	47d8                	lw	a4,12(a5)
    80005460:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005462:	554d47b7          	lui	a5,0x554d4
    80005466:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000546a:	14f71763          	bne	a4,a5,800055b8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000546e:	100017b7          	lui	a5,0x10001
    80005472:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005476:	4705                	li	a4,1
    80005478:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000547a:	470d                	li	a4,3
    8000547c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000547e:	10001737          	lui	a4,0x10001
    80005482:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005484:	c7ffe737          	lui	a4,0xc7ffe
    80005488:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddb0f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000548c:	8ef9                	and	a3,a3,a4
    8000548e:	10001737          	lui	a4,0x10001
    80005492:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005494:	472d                	li	a4,11
    80005496:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005498:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000549c:	439c                	lw	a5,0(a5)
    8000549e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054a2:	8ba1                	andi	a5,a5,8
    800054a4:	12078063          	beqz	a5,800055c4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054a8:	100017b7          	lui	a5,0x10001
    800054ac:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800054b0:	100017b7          	lui	a5,0x10001
    800054b4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800054b8:	439c                	lw	a5,0(a5)
    800054ba:	2781                	sext.w	a5,a5
    800054bc:	10079a63          	bnez	a5,800055d0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800054c0:	100017b7          	lui	a5,0x10001
    800054c4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800054c8:	439c                	lw	a5,0(a5)
    800054ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800054cc:	10078863          	beqz	a5,800055dc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800054d0:	471d                	li	a4,7
    800054d2:	10f77b63          	bgeu	a4,a5,800055e8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800054d6:	e4efb0ef          	jal	80000b24 <kalloc>
    800054da:	0001b497          	auipc	s1,0x1b
    800054de:	63648493          	addi	s1,s1,1590 # 80020b10 <disk>
    800054e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054e4:	e40fb0ef          	jal	80000b24 <kalloc>
    800054e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054ea:	e3afb0ef          	jal	80000b24 <kalloc>
    800054ee:	87aa                	mv	a5,a0
    800054f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800054f2:	6088                	ld	a0,0(s1)
    800054f4:	10050063          	beqz	a0,800055f4 <virtio_disk_init+0x1ec>
    800054f8:	0001b717          	auipc	a4,0x1b
    800054fc:	62073703          	ld	a4,1568(a4) # 80020b18 <disk+0x8>
    80005500:	0e070a63          	beqz	a4,800055f4 <virtio_disk_init+0x1ec>
    80005504:	0e078863          	beqz	a5,800055f4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005508:	6605                	lui	a2,0x1
    8000550a:	4581                	li	a1,0
    8000550c:	fbcfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005510:	0001b497          	auipc	s1,0x1b
    80005514:	60048493          	addi	s1,s1,1536 # 80020b10 <disk>
    80005518:	6605                	lui	a2,0x1
    8000551a:	4581                	li	a1,0
    8000551c:	6488                	ld	a0,8(s1)
    8000551e:	faafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005522:	6605                	lui	a2,0x1
    80005524:	4581                	li	a1,0
    80005526:	6888                	ld	a0,16(s1)
    80005528:	fa0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000552c:	100017b7          	lui	a5,0x10001
    80005530:	4721                	li	a4,8
    80005532:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005534:	4098                	lw	a4,0(s1)
    80005536:	100017b7          	lui	a5,0x10001
    8000553a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000553e:	40d8                	lw	a4,4(s1)
    80005540:	100017b7          	lui	a5,0x10001
    80005544:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005548:	649c                	ld	a5,8(s1)
    8000554a:	0007869b          	sext.w	a3,a5
    8000554e:	10001737          	lui	a4,0x10001
    80005552:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005556:	9781                	srai	a5,a5,0x20
    80005558:	10001737          	lui	a4,0x10001
    8000555c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005560:	689c                	ld	a5,16(s1)
    80005562:	0007869b          	sext.w	a3,a5
    80005566:	10001737          	lui	a4,0x10001
    8000556a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000556e:	9781                	srai	a5,a5,0x20
    80005570:	10001737          	lui	a4,0x10001
    80005574:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005578:	10001737          	lui	a4,0x10001
    8000557c:	4785                	li	a5,1
    8000557e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005580:	00f48c23          	sb	a5,24(s1)
    80005584:	00f48ca3          	sb	a5,25(s1)
    80005588:	00f48d23          	sb	a5,26(s1)
    8000558c:	00f48da3          	sb	a5,27(s1)
    80005590:	00f48e23          	sb	a5,28(s1)
    80005594:	00f48ea3          	sb	a5,29(s1)
    80005598:	00f48f23          	sb	a5,30(s1)
    8000559c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800055a0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800055a4:	100017b7          	lui	a5,0x10001
    800055a8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800055ac:	60e2                	ld	ra,24(sp)
    800055ae:	6442                	ld	s0,16(sp)
    800055b0:	64a2                	ld	s1,8(sp)
    800055b2:	6902                	ld	s2,0(sp)
    800055b4:	6105                	addi	sp,sp,32
    800055b6:	8082                	ret
    panic("could not find virtio disk");
    800055b8:	00002517          	auipc	a0,0x2
    800055bc:	0e850513          	addi	a0,a0,232 # 800076a0 <etext+0x6a0>
    800055c0:	9d4fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800055c4:	00002517          	auipc	a0,0x2
    800055c8:	0fc50513          	addi	a0,a0,252 # 800076c0 <etext+0x6c0>
    800055cc:	9c8fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800055d0:	00002517          	auipc	a0,0x2
    800055d4:	11050513          	addi	a0,a0,272 # 800076e0 <etext+0x6e0>
    800055d8:	9bcfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800055dc:	00002517          	auipc	a0,0x2
    800055e0:	12450513          	addi	a0,a0,292 # 80007700 <etext+0x700>
    800055e4:	9b0fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800055e8:	00002517          	auipc	a0,0x2
    800055ec:	13850513          	addi	a0,a0,312 # 80007720 <etext+0x720>
    800055f0:	9a4fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800055f4:	00002517          	auipc	a0,0x2
    800055f8:	14c50513          	addi	a0,a0,332 # 80007740 <etext+0x740>
    800055fc:	998fb0ef          	jal	80000794 <panic>

0000000080005600 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005600:	7159                	addi	sp,sp,-112
    80005602:	f486                	sd	ra,104(sp)
    80005604:	f0a2                	sd	s0,96(sp)
    80005606:	eca6                	sd	s1,88(sp)
    80005608:	e8ca                	sd	s2,80(sp)
    8000560a:	e4ce                	sd	s3,72(sp)
    8000560c:	e0d2                	sd	s4,64(sp)
    8000560e:	fc56                	sd	s5,56(sp)
    80005610:	f85a                	sd	s6,48(sp)
    80005612:	f45e                	sd	s7,40(sp)
    80005614:	f062                	sd	s8,32(sp)
    80005616:	ec66                	sd	s9,24(sp)
    80005618:	1880                	addi	s0,sp,112
    8000561a:	8a2a                	mv	s4,a0
    8000561c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000561e:	00c52c83          	lw	s9,12(a0)
    80005622:	001c9c9b          	slliw	s9,s9,0x1
    80005626:	1c82                	slli	s9,s9,0x20
    80005628:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000562c:	0001b517          	auipc	a0,0x1b
    80005630:	60c50513          	addi	a0,a0,1548 # 80020c38 <disk+0x128>
    80005634:	dc0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005638:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000563a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000563c:	0001bb17          	auipc	s6,0x1b
    80005640:	4d4b0b13          	addi	s6,s6,1236 # 80020b10 <disk>
  for(int i = 0; i < 3; i++){
    80005644:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005646:	0001bc17          	auipc	s8,0x1b
    8000564a:	5f2c0c13          	addi	s8,s8,1522 # 80020c38 <disk+0x128>
    8000564e:	a8b9                	j	800056ac <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005650:	00fb0733          	add	a4,s6,a5
    80005654:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005658:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000565a:	0207c563          	bltz	a5,80005684 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000565e:	2905                	addiw	s2,s2,1
    80005660:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005662:	05590963          	beq	s2,s5,800056b4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005666:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005668:	0001b717          	auipc	a4,0x1b
    8000566c:	4a870713          	addi	a4,a4,1192 # 80020b10 <disk>
    80005670:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005672:	01874683          	lbu	a3,24(a4)
    80005676:	fee9                	bnez	a3,80005650 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005678:	2785                	addiw	a5,a5,1
    8000567a:	0705                	addi	a4,a4,1
    8000567c:	fe979be3          	bne	a5,s1,80005672 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005680:	57fd                	li	a5,-1
    80005682:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005684:	01205d63          	blez	s2,8000569e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005688:	f9042503          	lw	a0,-112(s0)
    8000568c:	d07ff0ef          	jal	80005392 <free_desc>
      for(int j = 0; j < i; j++)
    80005690:	4785                	li	a5,1
    80005692:	0127d663          	bge	a5,s2,8000569e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005696:	f9442503          	lw	a0,-108(s0)
    8000569a:	cf9ff0ef          	jal	80005392 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000569e:	85e2                	mv	a1,s8
    800056a0:	0001b517          	auipc	a0,0x1b
    800056a4:	48850513          	addi	a0,a0,1160 # 80020b28 <disk+0x18>
    800056a8:	807fc0ef          	jal	80001eae <sleep>
  for(int i = 0; i < 3; i++){
    800056ac:	f9040613          	addi	a2,s0,-112
    800056b0:	894e                	mv	s2,s3
    800056b2:	bf55                	j	80005666 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056b4:	f9042503          	lw	a0,-112(s0)
    800056b8:	00451693          	slli	a3,a0,0x4

  if(write)
    800056bc:	0001b797          	auipc	a5,0x1b
    800056c0:	45478793          	addi	a5,a5,1108 # 80020b10 <disk>
    800056c4:	00a50713          	addi	a4,a0,10
    800056c8:	0712                	slli	a4,a4,0x4
    800056ca:	973e                	add	a4,a4,a5
    800056cc:	01703633          	snez	a2,s7
    800056d0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056d2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056d6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056da:	6398                	ld	a4,0(a5)
    800056dc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056de:	0a868613          	addi	a2,a3,168
    800056e2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056e4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056e6:	6390                	ld	a2,0(a5)
    800056e8:	00d605b3          	add	a1,a2,a3
    800056ec:	4741                	li	a4,16
    800056ee:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800056f0:	4805                	li	a6,1
    800056f2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800056f6:	f9442703          	lw	a4,-108(s0)
    800056fa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800056fe:	0712                	slli	a4,a4,0x4
    80005700:	963a                	add	a2,a2,a4
    80005702:	058a0593          	addi	a1,s4,88
    80005706:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005708:	0007b883          	ld	a7,0(a5)
    8000570c:	9746                	add	a4,a4,a7
    8000570e:	40000613          	li	a2,1024
    80005712:	c710                	sw	a2,8(a4)
  if(write)
    80005714:	001bb613          	seqz	a2,s7
    80005718:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000571c:	00166613          	ori	a2,a2,1
    80005720:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005724:	f9842583          	lw	a1,-104(s0)
    80005728:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000572c:	00250613          	addi	a2,a0,2
    80005730:	0612                	slli	a2,a2,0x4
    80005732:	963e                	add	a2,a2,a5
    80005734:	577d                	li	a4,-1
    80005736:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000573a:	0592                	slli	a1,a1,0x4
    8000573c:	98ae                	add	a7,a7,a1
    8000573e:	03068713          	addi	a4,a3,48
    80005742:	973e                	add	a4,a4,a5
    80005744:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005748:	6398                	ld	a4,0(a5)
    8000574a:	972e                	add	a4,a4,a1
    8000574c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005750:	4689                	li	a3,2
    80005752:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005756:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000575a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000575e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005762:	6794                	ld	a3,8(a5)
    80005764:	0026d703          	lhu	a4,2(a3)
    80005768:	8b1d                	andi	a4,a4,7
    8000576a:	0706                	slli	a4,a4,0x1
    8000576c:	96ba                	add	a3,a3,a4
    8000576e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005772:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005776:	6798                	ld	a4,8(a5)
    80005778:	00275783          	lhu	a5,2(a4)
    8000577c:	2785                	addiw	a5,a5,1
    8000577e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005782:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005786:	100017b7          	lui	a5,0x10001
    8000578a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000578e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005792:	0001b917          	auipc	s2,0x1b
    80005796:	4a690913          	addi	s2,s2,1190 # 80020c38 <disk+0x128>
  while(b->disk == 1) {
    8000579a:	4485                	li	s1,1
    8000579c:	01079a63          	bne	a5,a6,800057b0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800057a0:	85ca                	mv	a1,s2
    800057a2:	8552                	mv	a0,s4
    800057a4:	f0afc0ef          	jal	80001eae <sleep>
  while(b->disk == 1) {
    800057a8:	004a2783          	lw	a5,4(s4)
    800057ac:	fe978ae3          	beq	a5,s1,800057a0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800057b0:	f9042903          	lw	s2,-112(s0)
    800057b4:	00290713          	addi	a4,s2,2
    800057b8:	0712                	slli	a4,a4,0x4
    800057ba:	0001b797          	auipc	a5,0x1b
    800057be:	35678793          	addi	a5,a5,854 # 80020b10 <disk>
    800057c2:	97ba                	add	a5,a5,a4
    800057c4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800057c8:	0001b997          	auipc	s3,0x1b
    800057cc:	34898993          	addi	s3,s3,840 # 80020b10 <disk>
    800057d0:	00491713          	slli	a4,s2,0x4
    800057d4:	0009b783          	ld	a5,0(s3)
    800057d8:	97ba                	add	a5,a5,a4
    800057da:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057de:	854a                	mv	a0,s2
    800057e0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057e4:	bafff0ef          	jal	80005392 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057e8:	8885                	andi	s1,s1,1
    800057ea:	f0fd                	bnez	s1,800057d0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057ec:	0001b517          	auipc	a0,0x1b
    800057f0:	44c50513          	addi	a0,a0,1100 # 80020c38 <disk+0x128>
    800057f4:	c98fb0ef          	jal	80000c8c <release>
}
    800057f8:	70a6                	ld	ra,104(sp)
    800057fa:	7406                	ld	s0,96(sp)
    800057fc:	64e6                	ld	s1,88(sp)
    800057fe:	6946                	ld	s2,80(sp)
    80005800:	69a6                	ld	s3,72(sp)
    80005802:	6a06                	ld	s4,64(sp)
    80005804:	7ae2                	ld	s5,56(sp)
    80005806:	7b42                	ld	s6,48(sp)
    80005808:	7ba2                	ld	s7,40(sp)
    8000580a:	7c02                	ld	s8,32(sp)
    8000580c:	6ce2                	ld	s9,24(sp)
    8000580e:	6165                	addi	sp,sp,112
    80005810:	8082                	ret

0000000080005812 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005812:	1101                	addi	sp,sp,-32
    80005814:	ec06                	sd	ra,24(sp)
    80005816:	e822                	sd	s0,16(sp)
    80005818:	e426                	sd	s1,8(sp)
    8000581a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000581c:	0001b497          	auipc	s1,0x1b
    80005820:	2f448493          	addi	s1,s1,756 # 80020b10 <disk>
    80005824:	0001b517          	auipc	a0,0x1b
    80005828:	41450513          	addi	a0,a0,1044 # 80020c38 <disk+0x128>
    8000582c:	bc8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005830:	100017b7          	lui	a5,0x10001
    80005834:	53b8                	lw	a4,96(a5)
    80005836:	8b0d                	andi	a4,a4,3
    80005838:	100017b7          	lui	a5,0x10001
    8000583c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000583e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005842:	689c                	ld	a5,16(s1)
    80005844:	0204d703          	lhu	a4,32(s1)
    80005848:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000584c:	04f70663          	beq	a4,a5,80005898 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005850:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005854:	6898                	ld	a4,16(s1)
    80005856:	0204d783          	lhu	a5,32(s1)
    8000585a:	8b9d                	andi	a5,a5,7
    8000585c:	078e                	slli	a5,a5,0x3
    8000585e:	97ba                	add	a5,a5,a4
    80005860:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005862:	00278713          	addi	a4,a5,2
    80005866:	0712                	slli	a4,a4,0x4
    80005868:	9726                	add	a4,a4,s1
    8000586a:	01074703          	lbu	a4,16(a4)
    8000586e:	e321                	bnez	a4,800058ae <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005870:	0789                	addi	a5,a5,2
    80005872:	0792                	slli	a5,a5,0x4
    80005874:	97a6                	add	a5,a5,s1
    80005876:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005878:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000587c:	e7efc0ef          	jal	80001efa <wakeup>

    disk.used_idx += 1;
    80005880:	0204d783          	lhu	a5,32(s1)
    80005884:	2785                	addiw	a5,a5,1
    80005886:	17c2                	slli	a5,a5,0x30
    80005888:	93c1                	srli	a5,a5,0x30
    8000588a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000588e:	6898                	ld	a4,16(s1)
    80005890:	00275703          	lhu	a4,2(a4)
    80005894:	faf71ee3          	bne	a4,a5,80005850 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005898:	0001b517          	auipc	a0,0x1b
    8000589c:	3a050513          	addi	a0,a0,928 # 80020c38 <disk+0x128>
    800058a0:	becfb0ef          	jal	80000c8c <release>
}
    800058a4:	60e2                	ld	ra,24(sp)
    800058a6:	6442                	ld	s0,16(sp)
    800058a8:	64a2                	ld	s1,8(sp)
    800058aa:	6105                	addi	sp,sp,32
    800058ac:	8082                	ret
      panic("virtio_disk_intr status");
    800058ae:	00002517          	auipc	a0,0x2
    800058b2:	eaa50513          	addi	a0,a0,-342 # 80007758 <etext+0x758>
    800058b6:	edffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
