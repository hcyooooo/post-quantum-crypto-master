.file "poly_basemul.c"
.option nopic


.section .text.basemul_fast,"ax",@progbits
.align 1
.globl basemul_fast
.type basemul_fast, @function
basemul_fast:
  ### save registers
  add sp,sp,-64
  sw ra,60(sp)
  sw s0,56(sp)
  sw s1,52(sp)
  sw s2,48(sp)
  sw s3,44(sp)


  #  poly0 -> t0
  #  poly1 -> t1
  #  poly2 -> t2
  #  poly3 -> t3
  #  zeta -> a7, -zeta -> a6, q -> a5
  #  tmp -> t4,t5,t6

  pq.set_kyber x0,x0,x0
  addi a3,a3,128    # Twiddle offset
  li a5,3329        # q for -zeta calculation
#  li a4,0x68a       # 2^(2*18) mod q
  li a4,3270         # switch from mont18 to mont16 mod q
  pv.pack.h a4,a4,a4
  li t4,64
  lp.setup x0,t4,(.LBM)
    ### Load coefficients
    p.lw t0,4(a1!)  # (a)
    p.lw t1,4(a2!)  # (b)
    p.lw t2,4(a1!)  # (a next)
    p.lw t3,4(a2!)  # (b next)
    p.lh a7,2(a3!)  # zeta[64+i]
    sub a6,a5,a7  # -zeta

    #################################################################################
    #    ### First basemul
    #    ## calc r0
    #    mv t4,t0  # copy b into t4
    #    nop
    #    pq.mod_mul_r x0,t4,t1    # t4 = a1*b1,a0*b0
    #    srl t5,t4,16             # t5 = 0,a1*b1
    #    nop
    #    pq.mod_mul_r x0,t5,a7    # t5 = a1*b1*zeta
    #    pq.mod_add_r x0,t5,t4    # t5 = a0*b0+a1*b1*zeta (result in lower part of t5)
    #
    #    # calc r1
    #    srl t4,t1,16
    #    pv.pack.h t4,t1,t4       # swap register t4=b0,b1
    #    nop
    #    pq.mod_mul_r x0,t4,t0    # t4=a1*b0,a0*b1
    #    srl t6,t4,16             # t6=0,a1*b0
    #    nop
    #    pq.mod_add_r x0,t4,t6    # t4=a1*b0+a0*b1 (result in lower part of t4)
    #    pv.pack.h t4,t4,t5       # r=r1,r0
    #    
    #    p.sw t4,4(a0!)
    #
    #    ### Second basemul
    #    ## calc r0
    #    mv t4,t2  # copy b into t4
    #    nop
    #    pq.mod_mul_r x0,t4,t3    # t4 = a1*b1,a0*b0
    #    srl t5,t4,16             # t5 = 0,a1*b1
    #    nop
    #    pq.mod_mul_r x0,t5,a6    # t5 = a1*b1*zeta
    #    pq.mod_add_r x0,t5,t4    # t5 = a0*b0+a1*b1*zeta (result in lower part of t5)
    #
    #    # calc r1
    #    srl t4,t3,16
    #    pv.pack.h t4,t3,t4       # swap register t4=b0,b1
    #    nop
    #    pq.mod_mul_r x0,t4,t2    # t4=a1*b0,a0*b1
    #    srl t6,t4,16             # t6=0,a1*b0
    #    nop
    #    pq.mod_add_r x0,t4,t6    # t4=a1*b0+a0*b1 (result in lower part of t4)
    #    pv.pack.h t4,t4,t5       # r=r1,r0
    #    
    #    p.sw t4,4(a0!)
    #################################################################################

    ########### Reduced amount of NOPS ###########
    mv s0,t0  # copy b into s0
    mv s1,t2  # copy b next into s1

    srl s2,t1,16
    pv.pack.h s2,t1,s2       # swap register s2=b0,b1

    srl s3,t3,16
    pv.pack.h s3,t3,s3       # swap register s3=b0,b1
    nop

    ### First basemul
    ## calc r0
    pq.mod_mul_r x0,s0,t1    # s0 = a1*b1,a0*b0
    srl t5,s0,16             # t5 = 0,a1*b1
    nop
    pq.mod_mul_r x0,t5,a7    # t5 = a1*b1*zeta
    pq.mod_add_r x0,t5,s0    # t5 = a0*b0+a1*b1*zeta (result in lower part of t5)

    # calc r1
    pq.mod_mul_r x0,s2,t0    # s2=a1*b0,a0*b1
    srl t6,s2,16             # t6=0,a1*b0
    nop
    pq.mod_add_r x0,s2,t6    # s2=a1*b0+a0*b1 (result in lower part of s2)
    pv.pack.h s2,s2,t5       # r=r1,r0
    
    # transform and store
    nop
    pq.mod_mul_r x0,s2,a4
    p.sw s2,4(a0!)

    ### Second basemul
    ## calc r0
    pq.mod_mul_r x0,s1,t3    # s1 = a1*b1,a0*b0
    srl t5,s1,16             # t5 = 0,a1*b1
    nop
    pq.mod_mul_r x0,t5,a6    # t5 = a1*b1*zeta
    pq.mod_add_r x0,t5,s1    # t5 = a0*b0+a1*b1*zeta (result in lower part of t5)

    # calc r1
    pq.mod_mul_r x0,s3,t2    # s3=a1*b0,a0*b1
    srl t6,s3,16             # t6=0,a1*b0
    nop
    pq.mod_add_r x0,s3,t6    # s3=a1*b0+a0*b1 (result in lower part of s3)
    pv.pack.h s3,s3,t5       # r=r1,r0

    # transform and store
    nop
    pq.mod_mul_r x0,s3,a4 
    p.sw s3,4(a0!)

  .LBM:
  nop

  lw s0,56(sp)
  lw s1,52(sp)
  lw s2,48(sp)
  lw s3,44(sp)
  lw ra,60(sp)
  add sp,sp,64
jr ra
.size basemul_fast, .-basemul_fast

