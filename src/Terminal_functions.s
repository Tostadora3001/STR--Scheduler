.data
    a: .ascii "\nError within Terminal_functions\n"
.text
    .global Print_string
    .global Read_string

#This function prints into terminal the given string. The first argument must be the address to the
# string. The second is its size. This function does not return a value
Print_string:   
                push %ebp
                movl %esp, %ebp
                
                push %eax
                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                movl $4, %eax
                movl $1, %ebx
                movl 8(%ebp), %ecx
                movl 12(%ebp), %edx
                int $0x80

                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx
                pop %eax

                pop %ebp
                ret

error1:         
                lea a, %eax
                push %eax
                push $33
                call Error_exit
                jmp .

# This function reads from terminal and stores the first string. 
# 1st arg: string address, 2nd arg: buffer size
# Returns: 1 if the string is entirely numbers, 0 if not
Read_string:
                push %ebp
                movl %esp, %ebp

                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                # %edi -> bool -> True if it is a number
                movl $1, %edi

                movl $0, %esi          
                movl 8(%ebp), %ecx     
                
                movl $0, %ebx          
                movl $1, %edx

b1:             
                cmpl 12(%ebp), %esi
                jge error2            

                #Read one byte
                movl $3, %eax
                int $0x80

                cmpb $'\n', (%ecx)
                je end1

                cmpb $' ', (%ecx)
                je end1

                cmpb $'0', (%ecx)
                jl bool_false

                cmpb $'9', (%ecx)
                jg bool_false

                addl $1, %ecx          
                addl $1, %esi         
                jmp b1

bool_false:     
                movl $0, %edi          
                addl $1, %ecx          
                addl $1, %esi          
                jmp b1

end1:           
                cmpl $0, %esi
                je b1
                
                movb $0, (%ecx)

                # Return the bool
                movl %edi, %eax

                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx

                pop %ebp
                ret

error2:         
                lea a, %eax
                push %eax
                push $33
                call Error_exit
                jmp .
