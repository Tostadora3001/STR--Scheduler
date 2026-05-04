.data
    a: .ascii   "Error within Memeory_functions - Get_Heap\n"
    b: .ascii   "Error within Memeory_functions - Free_Heap\n"

.text
    .global Get_Heap
    .global Free_Heap

#This function uses brk in order to allocate memeory from the Heap.
#It is mandatory to Free the Heap (suing Free_Heap) after using it, before exiting.
#The first and only argument is the size in bytes to allocate
Get_Heap:           
                    push %ebp
                    movl %esp, %ebp

                    push %ebx

                    movl $45, %eax
                    xorl %ebx, %ebx
                    int $0x80

                    push %eax
                    movl %eax, %ebx
                    addl 8(%ebp), %ebx
                    movl $45, %eax
                    int $0x80

                    cmpl %eax, -8(%ebp)
                    je error1

                    pop %eax
                    pop %ebx
                    pop %ebp

                    ret

error1:             
                    lea a, %eax
                    push %eax
                    push $32
                    call Error_exit
                    jmp .


#This function is the sibling of Get_Heap. It free the allocated memory with Get_Heap
#The first and only argument is the size in bytes of the memory to free.
#Please take into consideration that the order of free Heap allocations matters
Free_Heap:
                    push %ebp
                    movl %esp, %ebp

                    push %eax
                    push %ebx

                    movl $45, %eax
                    xorl %ebx, %ebx
                    int $0x80
                    push %eax

                    movl %eax, %ebx
                    subl 8(%ebp), %ebx
                    movl $45, %eax
                    int $0x80

                    subl -12(%ebp), %eax
                    neg %eax
                    cmpl %eax, 8(%ebp)
                    jne error2

                    addl $4, %esp
                    pop %ebx
                    pop %eax
                    pop %ebp
                    
                    ret

error2:
                    lea b, %eax
                    push %eax
                    push $32
                    call Error_exit
                    jmp .

