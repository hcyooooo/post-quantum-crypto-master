.file "fastinvntt.c"
.option nopic


.macro double_butterfly_ll a0,b0,a1,b1,twiddle
  pq.bf_dif \twiddle,\a0,\b0
  pq.bf_dif \twiddle,\a1,\b1
.endm

.macro double_butterfly_lh a0,b0,a1,b1,twiddle,tmp
  pq.bf_dif \twiddle,\a0,\b0
  srl \tmp,\twiddle,16
  nop
  pq.bf_dif \tmp,\a1,\b1
.endm


.section .text.invntt_fast,"ax",@progbits
.align 1
.globl invntt_fast
.type invntt_fast, @function
invntt_fast:
  ### save registers
  add sp,sp,-64
  sw s4,40(sp)
  sw s5,36(sp)
  sw ra,60(sp)
  sw s0,56(sp)
  sw s2,48(sp)
  sw s3,44(sp)

  #####################
  #  poly -> s4
  #  twiddle_ptr -> s5
  #  poly0 -> t0
  #  poly1 -> t1
  #  poly2 -> t2
  #  poly3 -> t3
  #  poly4 -> t4
  #  poly5 -> t5
  #  poly6 -> t6
  #  poly7 -> s0
  #  twiddle -> a0-a4
  #####################

  li x31,0xabc
  pq.set_kyber x0,x0,x0
  pq.set_first_rounds x0,x0,x0

  mv s2,a0  # Address of poly
  mv s3,a1  # Address of zetas

  ############ LAYER 1(skip layer 0) ############ 
  li s5,16
  lp.setup x0,s5,(.LINVNTT1)  
    lw t0, 0(s2)    # poly0
    lw t1, 4(s2)    # poly1
    lw t2, 8(s2)    # poly2
    lw t3, 12(s2)   # poly3
    lw t4, 16(s2)   # poly4
    lw t5, 20(s2)   # poly5
    lw t6, 24(s2)   # poly6
    lw s0, 28(s2)   # poly7

    ## Load Twiddle factors ##
    p.lw a0, 4(s3!)    # twiddle_array
    p.lw a1, 4(s3!)    # twiddle_array

    ####
    nop
    nop
    double_butterfly_lh t0,t1,t2,t3,a0,s4    # poly0, poly1, poly2, poly3

    ####
    double_butterfly_lh t4,t5,t6,s0,a1,s4    # poly4, poly5, poly6, poly7    

    p.sw t0, 4(s2!)    # poly0
    p.sw t1, 4(s2!)    # poly1
    p.sw t2, 4(s2!)    # poly2
    p.sw t3, 4(s2!)    # poly3
    p.sw t4, 4(s2!)    # poly4
    p.sw t5, 4(s2!)    # poly5
    p.sw t6, 4(s2!)    # poly6
    p.sw s0, 4(s2!)    # poly7

  .LINVNTT1:
  nop

  ############ LAYER 2 + 3 + 4 ############
  # distance = 32
  addi s2,s2,-512

  li s5,8
  lp.setup x0,s5,(.LINVNTT2)
    ######## 1st ########
    lw t0, 0(s2)    # poly0 = poly[0]
    lw t1, 8(s2)    # poly1 = poly[1*distance/4]
    lw t2, 16(s2)   # poly2 = poly[2*distance/4]
    lw t3, 24(s2)   # poly3 = poly[3*distance/4]
    lw t4, 32(s2)   # poly4 = poly[4*distance/4]
    lw t5, 40(s2)   # poly5 = poly[5*distance/4]
    lw t6, 48(s2)   # poly6 = poly[6*distance/4]
    lw s0, 56(s2)   # poly7 = poly[7*distance/4]

    ## Load Twiddle factors ##
    lw a0, 0(s3)    # twiddle_array
    lw a1, 4(s3)    # twiddle_array
    lw a2, 8(s3)    # twiddle_array
    srl a3,a2,16
    lw a4, 12(s3)    # twiddle_array

    ####
    nop
    nop
    double_butterfly_lh t0,t1,t2,t3,a0,s4    # poly0, poly1, poly2, poly3

    ####
    double_butterfly_lh t4,t5,t6,s0,a1,s4    # poly4, poly5, poly6, poly7

    ####
    double_butterfly_ll t0,t2,t1,t3,a2    # poly0, poly2, poly1, poly3
    double_butterfly_ll t4,t6,t5,s0,a3    # poly4, poly6, poly5, poly7

    ####
    double_butterfly_ll t0,t4,t1,t5,a4    # poly0, poly4, poly1, poly5
    double_butterfly_ll t2,t6,t3,s0,a4    # poly2, poly6, poly3, poly7

    sw t0, 0(s2)    # poly[0] = poly0
    sw t1, 8(s2)    # poly[1*distance/4] = poly1
    sw t2, 16(s2)   # poly[2*distance/4] = poly2
    sw t3, 24(s2)   # poly[3*distance/4] = poly3
    sw t4, 32(s2)   # poly[4*distance/4] = poly4
    sw t5, 40(s2)   # poly[5*distance/4] = poly5
    sw t6, 48(s2)   # poly[6*distance/4] = poly6
    sw s0, 56(s2)   # poly[7*distance/4] = poly7

    addi s2,s2,4
    
    ######## 2nd ########
    lw t0, 0(s2)    # poly0 = poly[0]
    lw t1, 8(s2)    # poly1 = poly[1*distance/4]
    lw t2, 16(s2)   # poly2 = poly[2*distance/4]
    lw t3, 24(s2)   # poly3 = poly[3*distance/4]
    lw t4, 32(s2)   # poly4 = poly[4*distance/4]
    lw t5, 40(s2)   # poly5 = poly[5*distance/4]
    lw t6, 48(s2)   # poly6 = poly[6*distance/4]
    lw s0, 56(s2)   # poly7 = poly[7*distance/4]

    ####
    nop
    nop
    double_butterfly_lh t0,t1,t2,t3,a0,s4    # poly0, poly1, poly2, poly3

    ####
    double_butterfly_lh t4,t5,t6,s0,a1,s4    # poly4, poly5, poly6, poly7

    ####
    double_butterfly_ll t0,t2,t1,t3,a2    # poly0, poly2, poly1, poly3
    double_butterfly_ll t4,t6,t5,s0,a3    # poly4, poly6, poly5, poly7

    ####
    double_butterfly_ll t0,t4,t1,t5,a4    # poly0, poly4, poly1, poly5
    double_butterfly_ll t2,t6,t3,s0,a4    # poly2, poly6, poly3, poly7

    sw t0, 0(s2)    # poly[0] = poly0
    sw t1, 8(s2)    # poly[1*distance/4] = poly1
    sw t2, 16(s2)   # poly[2*distance/4] = poly2
    sw t3, 24(s2)   # poly[3*distance/4] = poly3
    sw t4, 32(s2)   # poly[4*distance/4] = poly4
    sw t5, 40(s2)   # poly[5*distance/4] = poly5
    sw t6, 48(s2)   # poly[6*distance/4] = poly6
    sw s0, 56(s2)   # poly[7*distance/4] = poly7

    addi s2,s2,60
    addi s3,s3,14 
  .LINVNTT2:
  nop

  ############ LAYER 5 + 6 + 7 ############
  # distance=256
  addi s2,s2,-512
  li s5,16
  lp.setup x0,s5,(.LINVNTT3)
    lw t0, 0(s2)    # poly0 = poly[0]
    lw t1, 64(s2)   # poly1 = poly[1*distance/4]
    lw t2, 128(s2)  # poly2 = poly[2*distance/4]
    lw t3, 192(s2)  # poly3 = poly[3*distance/4]
    lw t4, 256(s2)  # poly4 = poly[4*distance/4]
    lw t5, 320(s2)  # poly5 = poly[5*distance/4]
    lw t6, 384(s2)  # poly6 = poly[6*distance/4]
    lw s0, 448(s2)  # poly7 = poly[7*distance/4]

    ## Load Twiddle factors ##
    lw a0, 0(s3)    # twiddle_array[0]
    lw a1, 4(s3)    # twiddle_array[1,2]
    lw a2, 8(s3)    # twiddle_array[3,4]   
    srl a3,a2,16
    lw a4, 12(s3)    # twiddle_array[5,6]

    ####
    nop
    nop
    double_butterfly_lh t0,t1,t2,t3,a0,s4    # poly0, poly1, poly2, poly3

    ####
    double_butterfly_lh t4,t5,t6,s0,a1,s4    # poly4, poly5, poly6, poly7

    ####
    double_butterfly_ll t0,t2,t1,t3,a2    # poly0, poly2, poly1, poly3
    double_butterfly_ll t4,t6,t5,s0,a3    # poly4, poly6, poly5, poly7

    ####
    double_butterfly_ll t0,t4,t1,t5,a4    # poly0, poly4, poly1, poly5
    double_butterfly_ll t2,t6,t3,s0,a4    # poly2, poly6, poly3, poly7

    #### Post-Processing ####
    srl a4,a4,16
    pv.pack.h a0,a4,a4
    nop
    pq.mod_mul_r x0,t0,a0
    pq.mod_mul_r x0,t1,a0
    pq.mod_mul_r x0,t2,a0
    pq.mod_mul_r x0,t3,a0

    sw t0, 0(s2)    # poly[0] = poly0
    sw t1, 64(s2)   # poly[1*distance/4] = poly1
    sw t2, 128(s2)  # poly[2*distance/4] = poly2
    sw t3, 192(s2)  # poly[3*distance/4] = poly3
    sw t4, 256(s2)  # poly[4*distance/4] = poly4
    sw t5, 320(s2)  # poly[5*distance/4] = poly5
    sw t6, 384(s2)  # poly[6*distance/4] = poly6
    sw s0, 448(s2)  # poly[7*distance/4] = poly7

    addi s2,s2,4
  .LINVNTT3:
  nop

  lw ra,60(sp)
  lw s0,56(sp)
  lw s2,48(sp)
  lw s3,44(sp)
  lw s4,40(sp)
  lw s5,36(sp)
  add sp,sp,64
  jr ra
.size invntt_fast, .-invntt_fast

