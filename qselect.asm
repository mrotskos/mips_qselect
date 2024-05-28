.text   
    .globl  main

main:
    li      $a0,                    0                               # load the first index into $a0
    li      $a1,                    3                               # load the last index into $a1
    li      $a2,                    2                               # load the kth element into $a2

    jal     qselect                                                 # qselect(0, 20, 12)

    move    $t0,                    $v0                             # move the result into $t0

    li      $v0,                    1                               # syscall 1 is print_int
    move    $a0,                    $t0                             # move the result into $a0
    syscall 

    li      $v0,                    10                              # exit
    syscall 

swap:
    la      $t0,                    v                               # load the address of the vector v into $t0
    sll     $t1,                    $a0,        2                   # calculate the offset of the first element
    sll     $t2,                    $a1,        2                   # calculate the offset of the second element
    add     $t1,                    $t1,        $t0                 # add the offset to the address of the vector
    add     $t2,                    $t2,        $t0                 # add the offset to the address of the vector
    lw      $t3,                    0($t1)                          # load the first element into $t3
    lw      $t4,                    0($t2)                          # load the second element into $t4
    sw      $t4,                    0($t1)                          # store the second element in the first element's place
    sw      $t3,                    0($t2)                          # store the first element in the second element's place
    jr      $ra                                                     # return

partition:
    la      $t0,                    v                               # load the address of the vector v into $t0
    sll     $t1,                    $a1,        2                   # calculate the offset of the pivot element
    add     $t1,                    $t1,        $t0                 # add the offset to the address of the vector
    lw      $t1,                    0($t1)                          # load the pivot element into $t1 (int pivot = v[l])
    move    $t2,                    $a0                             # move the first index into $t2 (int i = f)
    move    $t3,                    $a1                             # move the last index into $t3 (int l = l)
    move    $t4,                    $a0                             # move the first index into $t4 (int j = f)
loop:
    bge     $t4,                    $t3,        loop_end            # if j >= l, goto end
    sll     $t5,                    $t4,        2                   # calculate the offset of the current element
    add     $t5,                    $t5,        $t0                 # add the offset to the address of the vector
    lw      $t5,                    0($t5)                          # load the current element into $t5 (int x = v[j])
    bge     $t5,                    $t1,        skip                # if x >= pivot, goto skip
    addi    $sp,                    $sp,        -20                 # allocate space for 5 integers
    sw      $t2,                    0($sp)                          # store i on the stack
    sw      $t4,                    4($sp)                          # store j on the stack
    sw      $t1,                    8($sp)                          # store pivot on the stack
    sw      $t3,                    12($sp)                         # store l on the stack
    sw      $ra,                    16($sp)                         # store ra on the stack
    move    $a0,                    $t2                             # move i into $a0
    move    $a1,                    $t4                             # move j into $a1
    jal     swap                                                    # swap(i, j)
    lw      $t2,                    0($sp)                          # load i from the stack
    lw      $t4,                    4($sp)                          # load j from the stack
    lw      $t1,                    8($sp)                          # load pivot from the stack
    lw      $t3,                    12($sp)                         # load l from the stack
    lw      $ra,                    16($sp)                         # load ra from the stack
    addi    $sp,                    $sp,        20                  # deallocate space for 5 integers
    addi    $t2,                    $t2,        1                   # i++
skip:
    addi    $t4,                    $t4,        1                   # j++
    j       loop                                                    # goto loop
loop_end:
    addi    $sp,                    $sp,        -8                   # deallocate space for 5 integers
    sw      $t2,                    0($sp)                          # store i on the stack
    sw      $ra,                    4($sp)                          # store ra on the stack
    move    $a0,                    $t2                             # move i into $a0
    move    $a1,                    $t3                             # move l into $a1
    jal     swap                                                    # swap(i, l)
    lw      $v0,                    0($sp)                          # load i from the stack
    lw      $ra,                    4($sp)                          # load ra from the stack
    addi    $sp,                    $sp,        8                   # deallocate space for 2 integers
    jr      $ra                                                     # return

qselect:
    beq     $a0,                    $a1,        qselect_base_case   # if f == l, goto qselect_base_case
    addi    $sp,                    $sp,        -16                 # allocate space for 4 integers
    sw      $a0,                    0($sp)                          # store f on the stack
    sw      $a1,                    4($sp)                          # store l on the stack
    sw      $a2,                    8($sp)                          # store k on the stack
    sw      $ra,                    12($sp)                         # store ra on the stack
    jal     partition                                               # partition(f, l)
    beq     $v0,                    $a2,        qselect_pivot_is_k  # if i == k, goto qselect_pivot_is_k
    bgt     $v0,                    $a2,        qselect_left        # if p > k, goto qselect_left
    addi    $a0,                    $v0,        1                   # f = p + 1
    lw      $a1,                    4($sp)                          # l = l
    lw      $a2,                    8($sp)                          # k = k
    j       qselect_recursive_call                                  # goto qselect_recursive_call
qselect_left:
    lw      $a0,                    0($sp)                          # f = f
    addi    $a1,                    $v0,        -1                  # l = p - 1
    lw      $a2,                    8($sp)                          # k = k
qselect_recursive_call:
    jal     qselect                                                 # qselect(f, l, k)
    j       qselect_end                                             # goto qselect_end
qselect_base_case:
    sll     $t0,                    $a0,        2                   # calculate the offset of the pivot element
    la      $t1,                    v                               # load the address of the vector v into $t1
    add     $t0,                    $t0,        $t1                 # add the offset to the address of the vector
    lw      $v0,                    0($t0)                          # load the pivot element into $v0
    jr      $ra                                                     # return
qselect_pivot_is_k:
    sll     $t0,                    $v0,        2                   # calculate the offset of the pivot element
    la      $t1,                    v                               # load the address of the vector v into $t1
    add     $t0,                    $t0,        $t1                 # add the offset to the address of the vector
    lw      $v0,                    0($t0)                          # load the pivot element into $v0
qselect_end:
    lw      $ra,                    12($sp)                         # load ra from the stack
    addi    $sp,                    $sp,        16                  # deallocate space for 4 integers
    jr      $ra                                                     # return

.data   
v:  .word   3, 10, 8, 2