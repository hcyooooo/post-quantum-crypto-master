.file	"PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample.c"
	.option nopic
#----------------------------------------------------------------------------
#
# void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample( poly *r, const unsigned char *seed, unsigned char nonce)
#
.section	.text.PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample,"ax",@progbits
.align	1
.globl	PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample
.type	PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample, @function
PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample:
    addi sp,sp,-216
    sw ra,212(sp)  # Store return address
    sw s0,208(sp)  # Store previous frame pointer
    sw s1,204(sp)  # Store s1
    sw s2,200(sp)  # Store s2
    sw s3,196(sp)  # Store s3
    sw s4,192(sp)  # Store s4

    sw a0,188(sp)  # Store address of poly r
    sw a1,184(sp)  # Store address of seed
    sb a2,183(sp)  # Store nonce

    #### Allocate stack memory for extseed and buf ####
    addi s3,sp,144  # 144 to 180 -> 36 bytes for extseed (34 required)
    addi t0,sp,144
    addi s4,sp,16  # 16 to 144 -> 128 bytes for buf

    #### Copy seed to extseed ####
    # 1
    p.lw t1,4(a1!)  # a1 contains address of seed
    p.lw t2,4(a1!)  # a1 contains address of seed
    p.lw t3,4(a1!)  # a1 contains address of seed
    p.lw t4,4(a1!)  # a1 contains address of seed
    p.lw t5,4(a1!)  # a1 contains address of seed
    p.lw t6,4(a1!)  # a1 contains address of seed

    p.sw t1,4(t0!)  # t0 contains address of extseed
    p.sw t2,4(t0!)  # t0 contains address of extseed
    p.sw t3,4(t0!)  # t0 contains address of extseed
    p.sw t4,4(t0!)  # t0 contains address of extseed
    p.sw t5,4(t0!)  # t0 contains address of extseed
    p.sw t6,4(t0!)  # t0 contains address of extseed

    # 2
    p.lw t1,4(a1!)  # a1 contains address of seed
    p.lw t2,4(a1!)  # a1 contains address of seed

    p.sw t1,4(t0!)  # t0 contains address of extseed
    p.sw t2,4(t0!)  # t0 contains address of extseed


    sb a2,0(t0)  # extseed[32] = nonce
    sb x0,1(t0)  # extseed[32] = 0
    sh x0,2(t0)  # setting remaining values of word to 0

    #### s1: loop counter for extseed, s2: address of poly, s3: extseed, s4: buf ####
    li s1,0  # i=0
    lw s2,188(sp)  # address of poly

    ########## 1 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs1)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs1:
    nop

    ########## 2 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs2)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs2:
    nop

    ########## 3 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs3)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs3:
    nop

    ########## 4 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs4)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs4:
    nop

    ########## 5 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs5)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs5:
    nop

    ########## 6 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs6)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs6:
    nop

    ########## 7 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
      
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs7)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs7:
    nop

    ########## 8 ##########
    addi t0,sp,144
    sb s1,33(t0)  # extseed[32] = i
    addi s1,s1,1  # i++
    #### Prepare arguments for shake256_hw ####
    li a3,34  # 34
    mv a2,s3  # extseed
    li a1,128  # 128
    mv a0,s4  # buf
    jal shake256_hw # shake256_hw(buf, 128, extseed, NEWHOPE_SYMBYTES + 2)
    nop
     
    # Sample binom
    addi t6,sp,16
    lp.setupi x0,32,(.loop_bs8)
      p.lbu t1,1(t6!)
      p.lbu t2,1(t6!)
      p.lbu t3,1(t6!)
      p.lbu t4,1(t6!)
      slli t3,t3,16
      or t1,t1,t3
      slli t4,t4,16
      or t2,t2,t4
      pq.bs_k8 t5,t1,t2
      p.sw t5,4(s2!)
    .loop_bs8:
    nop

  lw ra,212(sp)
  lw s0,208(sp)
  lw s1,204(sp)
  lw s2,200(sp)
  lw s3,196(sp)
  lw s4,192(sp)
  addi sp,sp,216
  jr ra

.size	PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample, .-PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample


###########
# ra
# previous fp
#
# a0
# a1
