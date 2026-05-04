.section .note.GNU-stack,"",@progbits

.data
    a: .ascii   "Error within Utils Atoi\n"
    error: .ascii "Runtime Error"
.text
    .global My_Atoi32
    .global My_UnAtoi32
    .global ABS
    .global MCD
    .global MCM
    .global Vectorial_MCM
    .global Max_Value
    .global Min_Value
    .global ceil_div
    .global Bubble_sort_tasks
    .global Error_exit
    .global exit

#This function transform a string number into an integer. The first and only argument must be the address to the string
#The function returns the translated value
My_Atoi32:
                    push %ebp
                    movl %esp, %ebp

                    push %ebx
                    push %ecx
                    push %esi

                    #ebx -> address to the string / %esi -> current char of the string / %ecx -> current char
                    movl 8(%ebp), %ebx
                    movl $0, %esi
                    movl $0, %ecx

                    #Space for the integer
                    subl $4, %esp
                    movl $0, -16(%ebp)      # Initialize the integer to zero

b1:                 
                    cmpl $11, %esi
                    jge error1

                    movb (%ebx, %esi, 1), %cl

                    #Failure or termination cases
                    cmpb $'\n', %cl
                    je end 

                    cmpb $0, %cl
                    je end

                    cmpb $' ', %cl
                    je error1
                
                    cmpb $'0', %cl
                    jl error1

                    cmpb $'9', %cl
                    jg error1
                    
                    #Convert char to integer
                    subb $'0', %cl

                    #Actual_int = Actual_int * 10 + NewInteger
                    movl -16(%ebp), %eax
                    imull $10, %eax, %eax
                    addl %ecx, %eax
                    movl %eax, -16(%ebp)
                    
                    #Repeat until the char is '\n'
                    addl $1, %esi
                    jmp b1

end:                
                    #Set the returning value
                    movl -16(%ebp), %eax

                    addl $4, %esp
                    pop %esi
                    pop %ecx
                    pop %ebx

                    pop %ebp
                    ret

error1:                
                    lea a, %eax
                    push %eax
                    push $32
                    call Error_exit
                    jmp .

#This is the sibling function to My_Atoi. It converts an integer into an string. The first argument is the address to where the string will be stored, the second is the integer
#This function return the size of the string
My_UnAtoi32:
                    push %ebp
                    movl %esp, %ebp

                    push %ebx
                    push %edx
                    push %esi

                    #The maxium lenght of a 32 bits integer is 10 chars (2^32 = 4294967296)
                    subl $12, %esp
                    movl $0, %esi
                    movl 12(%ebp), %eax
                    movl $10, %ebx

                    #Building the string
b2:                 
                    cmpl $10, %esi
                    jge error2
                    
                    xorl %edx, %edx
                    div %ebx

                    addb $'0', %dl
                    movb %dl, -24(%ebp, %esi, 1)
                    
                    addl $1, %esi
                    cmpl $0, %eax
                    jne b2

                    #Storing the string into the given address
                    #al -> current char / %ebx -> string address
                    #%esi -> index for the built string / %edx -> index for the new string
                    movl 8(%ebp), %ebx
                    movl $0, %edx
                    subl $1, %esi

b3:
                    movb -24(%ebp, %esi, 1), %al 
                    movb %al, (%ebx, %edx, 1)

                    subl $1, %esi
                    addl $1, %edx

                    cmpl $0, %esi
                    jge b3

                    movl %edx, %eax
                    addl $12, %esp

                    pop %esi
                    pop %edx
                    pop %ebx
                    pop %ebp
                    
                    ret
                    

error2:             
                    lea a, %eax
                    push %eax
                    push $32
                    call Error_exit
                    jmp .

#This function returns the absolute of the given Number
ABS:
                    push %ebp
                    movl %esp, %ebp
                    
                    movl 8(%ebp), %eax
                    cmpl $0, %eax
                    jl  negate
                    jmp no_negate

negate:             
                    neg %eax

no_negate:          
                    pop %ebp
                    ret

#This function calculates the MCD between two numbers using the Euclides algorithm
#The function expets two integers as parameters and returns mcd(a,b)
MCD:
                    push %ebp
                    movl %esp, %ebp

                    push %edx

                    cmpl $0, 12(%ebp)
                    je abs

                    movl 8(%ebp), %eax
                    cltd
                    idivl 12(%ebp)
                    push %edx
                    push 12(%ebp)
                    call MCD
                    addl $8, %esp
                    jmp end_mcd

abs:
                    push 8(%ebp)
                    call ABS
                    addl $4, %esp

end_mcd:            
                    pop %edx

                    pop %ebp
                    ret

#This function calculates the MCM of the two given intergers (arg1 and arg2)
MCM:
                    push %ebp
                    movl %esp, %ebp

                    push %ebx
                    push %edx

                    #mcd(a,b)
                    push 12(%ebp)
                    push 8(%ebp)
                    call MCD
                    addl $8, %esp
                    push %eax

                    #abs(a*b)
                    movl 8(%ebp), %eax                    
                    imull 12(%ebp)
                    push %eax
                    call ABS
                    addl $4, %esp
                    
                    #abs(a*b) / mcd(a,b)
                    cltd
                    idivl -12(%ebp)

                    addl $4, %esp
                    pop %edx
                    pop %ebx 

                    pop %ebp
                    ret

#This function calculates the mcm between all the numbers in a Vector
#The function expects as first arguemnt the pointer to the vector and as second argument its size
#The function returns the mcm(V)
Vectorial_MCM:  
                    push %ebp
                    movl %esp, %ebp

                    push %ebx
                    push %esi

                    movl 8(%ebp), %ebx
                    movl (%ebx), %eax
                    movl $1, %esi

VEC_MCM_b1:
                    cmpl 12(%ebp), %esi
                    jge VEC_MCM_end

                    push (%ebx, %esi, 4)
                    push %eax
                    call MCM
                    addl $8, %esp

                    addl $1, %esi
                    jmp VEC_MCM_b1

VEC_MCM_end:
                    pop %esi
                    pop %ebx

                    pop %ebp
                    ret

#Gemini comment :)
# =============================================================================
# FUNCTION: find_min
# -----------------------------------------------------------------------------
# DESCRIPTION:
#   Finds the maxium value in a vector. Supports both simple arrays and 
#   arrays of structures (structs) using a custom memory offset.
#
# PARAMETERS (Stack):
#   1. [ebp + 8]  (Pointer) : Base address of the vector.
#   2. [ebp + 12] (Integer) : Total number of tasks/elements.
#   3. [ebp + 16] (Integer) : Step size (Offset) in bytes to the next element.
#                             Example: 12 bytes for a (C, D, T) struct.
#
# RETURNS:
#   eax: The maxium value found.
#
# USAGE NOTE:
#   The offset allows the pointer to skip between specific fields (e.g., 
#   jumping from T1 to T2) regardless of the structure's total size.
# =============================================================================
Max_Value:
                    push %ebp
                    movl %esp, %ebp
                    
                    push %ebx
                    push %esi
                    push %ecx                 
                    movl 8(%ebp), %ebx        
                    movl 16(%ebp), %esi       
                    
                    movl (%ebx, %esi, 1), %eax 
                    movl $1, %ecx             

Max_value_b1:       
                    cmpl 12(%ebp), %ecx       
                    jge  Max_value_end        

                    addl $12, %ebx            
                    
                    cmpl (%ebx, %esi, 1), %eax
                    jge  smaller

                    movl (%ebx, %esi, 1), %eax
smaller:            
                    addl $1, %ecx             
                    jmp Max_value_b1          
Max_value_end:
                    pop %ecx
                    pop %esi
                    pop %ebx

                    pop %ebp
                    ret

#Gemini comment :)
# =============================================================================
# FUNCTION: find_min
# -----------------------------------------------------------------------------
# DESCRIPTION:
#   Finds the minimum value in a vector. Supports both simple arrays and 
#   arrays of structures (structs) using a custom memory offset.
#
# PARAMETERS (Stack):
#   1. [ebp + 8]  (Pointer) : Base address of the vector.
#   2. [ebp + 12] (Integer) : Total number of tasks/elements.
#   3. [ebp + 16] (Integer) : Step size (Offset) in bytes to the next element.
#                             Example: 12 bytes for a (C, D, T) struct.
#
# RETURNS:
#   eax: The minimum value found.
#
# USAGE NOTE:
#   The offset allows the pointer to skip between specific fields (e.g., 
#   jumping from T1 to T2) regardless of the structure's total size.
# =============================================================================
Min_Value:
                    push %ebp
                    movl %esp, %ebp
                    
                    push %ebx
                    push %esi
                    push %ecx                 
                    movl 8(%ebp), %ebx        
                    movl 16(%ebp), %esi       
                    
                    movl (%ebx, %esi, 1), %eax 
                    movl $1, %ecx             

Min_value_b1:       
                    cmpl 12(%ebp), %ecx       
                    jge  Min_value_end        

                    addl $12, %ebx            
                    
                    cmpl (%ebx, %esi, 1), %eax
                    jle  bigger

                    movl (%ebx, %esi, 1), %eax
bigger:            
                    addl $1, %ecx             
                    jmp Min_value_b1          
Min_value_end:
                    pop %ecx
                    pop %esi
                    pop %ebx

                    pop %ebp
                    ret

#Returns the higher number of the division Ej: 10 / 3 = 3.333 -> 4
#First argument is a, second is b -> a / b
ceil_div:
                    push %ebp
                    movl %esp, %ebp

                    push %ebx
                    push %edx

                    xorl %edx, %edx
                    movl 8(%ebp), %eax
                    idivl 12(%ebp)

                    cmpl $0, %edx
                    je ceil_div_end
                    addl $1, %eax
ceil_div_end:
                    pop %edx
                    pop %ebx
                    pop %ebp

                    ret

#Sorts the given Vector of tasks. The first arguemnt is the Pointer vector and the second its size. The third
# is the offset of the value of reference
Bubble_sort_tasks:
                    push %ebp
                    movl %esp, %ebp

                    push %eax
                    push %ebx
                    push %ecx
                    push %edx
                    push %esi
                    push %edi

                    cmpl $0, 12(%ebp)
                    je Bubble_end

                    xorl %esi, %esi
                    movl 12(%ebp), %ecx
                    subl %esi, %ecx
                    push %ecx

Bubble_b1:
                    xorl %edi, %edi
                    movl 8(%ebp), %eax
Bubble_b2:
                    #Add offset
                    addl 16(%ebp), %eax

                    movl (%eax), %ebx
                    movl 12(%eax), %ecx
                    subl 16(%ebp), %eax

                    cmpl %ecx, %ebx
                    jle Bubble_false

                    #Swap tasks
                    #Time Compute
                    movl 0(%eax), %ebx
                    movl 12(%eax), %ecx
                    movl %ebx, %edx
                    movl %ecx, %ebx
                    movl %edx, %ecx
                    movl %ebx, 0(%eax)
                    movl %ecx, 12(%eax)

                    #DEadline
                    movl 4(%eax), %ebx
                    movl 16(%eax), %ecx
                    movl %ebx, %edx
                    movl %ecx, %ebx
                    movl %edx, %ecx
                    movl %ebx, 4(%eax)
                    movl %ecx, 16(%eax)

                    #Period
                    movl 8(%eax), %ebx
                    movl 20(%eax), %ecx
                    movl %ebx, %edx
                    movl %ecx, %ebx
                    movl %edx, %ecx
                    movl %ebx, 8(%eax)
                    movl %ecx, 20(%eax)

Bubble_false:
                    addl $1, %edi
                    addl $12, %eax
                    movl -28(%ebp), %ecx
                    subl $1, %ecx
                    cmpl %ecx, %edi
                    jl Bubble_b2

                    addl $1, %esi
                    cmpl -28(%ebp), %esi
                    jl Bubble_b1

Bubble_end:
                    lea -24(%ebp), %esp
                    pop %edi
                    pop %esi
                    pop %edx
                    pop %ecx
                    pop %ebx
                    pop %eax

                    pop %ebp
                    ret


#A function to manage errors and print a given message
#The first argument must be the address of the string. The second its size
Error_exit:         
                    push %ebp
                    movl %esp, %ebp

                    #Write a in terminal the error message 
                    movl $4, %eax
                    movl $1, %ebx
                    movl 12(%ebp), %ecx
                    movl 8(%ebp), %edx
                    int $0x80
                    
                    #exit
                    movl $2, %eax
                    xor %ebx, %ebx
                    int $0x80

#exit
exit:  
                    movl $1, %eax
                    xor %ebx, %ebx
                    int $0x80
                    jmp .
