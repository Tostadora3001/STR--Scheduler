.data
    a: .ascii   "Error within Main\n" #18
    b: .ascii   "Error within Main - Get_Input\n" #30
    z: .ascii   "Invalid Task value\n"  #19

    mes1: .ascii    "RTOS-Commander v1.0: Determinism or Death\n - 'Because in Real-Time, being late is the same as being wrong'\n"  #108
    mes2: .ascii    "\nWhich scheedule do you wish to use?\n  Ciclic -> c\n  Deadline -> d\n  Fixed -> f\nSchelude : " #90
    mes3: .ascii    "Number of task : " #17
    mes4: .ascii    "Please enter the data for each task (Compute time - Deadline - Period)\n"   #72
.text
    .global _start
    .global Get_Input

_start:
            push %ebp
            movl %esp, %ebp

            #Allocate Heap Memory for the incoming data
            push $1000
            call Get_Heap
            addl $4, %esp
            push %eax
            
            #Initial message for User interaction
            push $108
            lea mes1, %eax
            push %eax
            call Print_string
            addl $8, %esp

            #Get Number of Task
            call Get_Num
            push %eax

            cmpl $0, %eax
            je error1

            #Get all the Task's data
            #Passing Num of Task and the pointer to Heap as arguments to Get_Input (We do a copy for both values)
            push %eax
            push -4(%ebp)
            call Get_Input
            addl $8, %esp

            #Allocate Heap Memory for Output data
            push $1000
            call Get_Heap
            addl $4, %esp
            push %eax


            #Three possible schedule
            push $91
            lea mes2, %eax
            push %eax
            call Print_string
            addl $8, %esp
            
            subl $4, %esp
            movl $0, -16(%ebp)
            lea -16(%ebp), %eax
            
            #The string to read is always the number + (\n or " ") -> One number needs two bytes
            push $2 
            push %eax
            call Read_string
            addl $8, %esp

            #Check that a correct option has been chosed and execute the corresponding function
            cmpl $0, %eax
            jne error1

            movb -16(%ebp), %al
            cmpb $'c', %al
            je else1

            cmpb $'d', %al
            je else2

            cmpb $'f', %al
            je else3

            jmp error1

            #The computational functions expects arg1 -> pointer to data / arg2 -> Number of task / arg3 -> pointer to output data
else1:
            #Erase the option (c, f, d) input
            addl $4, %esp

            #The arguments are : @Input, NumTask, @Output
            push -12(%ebp)
            push -8(%ebp)
            push -4(%ebp)
            call Cyclic
            jmp end

else2:     
            #Erase the option (c, f, d) input
            addl $4, %esp

            #The arguments are : @Input, NumTask, @Output
            push -12(%ebp)
            push -8(%ebp)
            push -4(%ebp)
            call Deadline
            jmp end

else3:      
            #Erase the option (c, f, d) input
            addl $4, %esp

            #The arguments are : @Input, NumTask, @Output
            push -12(%ebp)
            push -8(%ebp)
            push -4(%ebp)
            call F_Prior

end:
            #Free the Heap  2000 = 1000(f1) + 1000(f2)
            push $2000
            call Free_Heap
            addl $4, %esp

            movl %ebp, %esp
            call exit

error1:     
            lea a, %eax
            push %eax
            push $32
            call Error_exit
            jmp .


Get_Num:
            push %ebp
            movl %esp, %ebp

            #Print a message
            push $17
            lea mes3, %eax
            push %eax
            call Print_string
            addl $8, %esp

            subl $12, %esp
            lea -12(%ebp), %eax
            push $12
            push %eax
            call Read_string
            addl $8, %esp

            #Ensuring the input is a string number
            cmpl $0, %eax
            je error2

            #We need a NewInteger
            lea -12(%ebp), %eax
            push %eax
            call My_Atoi32

            movl %ebp, %esp
            pop %ebp
            ret

error2:     
            lea a, %eax
            push %eax
            push $32
            call Error_exit
            jmp .

#This functions collects all the Task's data and stores it in the given pointer
#The first argument is the pointer where to store the data. The second argument is the total number of task
Get_Input:  
            push %ebp
            movl %esp, %ebp

            push %eax
            push %ebx
            push %ecx
            push %edx
            push %esi

            #Instrucction message
            push $71
            lea mes4, %eax
            push %eax
            call Print_string
            addl $8, %esp

            #Reserve stack memory for the strings
            subl $32, %esp
            xor %esi, %esi

            #Pointer to Heap
            movl 8(%ebp), %edx

b1:
            #Reverse Atoi, translate 32 bits into a string

            addl $1, %esi
            push %esi
            lea -50(%ebp), %eax
            push %eax
            call My_UnAtoi32
            addl $8, %esp
            subl $1, %esi

            #If the string is void -> error
            cmpl $0, %eax
            je error3

            movb $'\n', -52(%ebp)
            movb $'t', -51(%ebp)
            movb $':', -50(%ebp, %eax, 1)
            movb $' ', -49(%ebp, %eax, 1)

            #The size is the string number size + 4
            addl $4, %eax
            lea -52(%ebp), %ebx
            push %eax
            push %ebx
            call Print_string
            addl $8, %esp

            #Read the input, expected three numbers. Calculating the index (three values per 1 slot)
            #%ecx = 3 * %esi
            leal (%esi, %esi, 2), %ecx

            #First Number (tc - Time of Computation)
            push $12
            lea -52(%ebp), %eax
            push %eax
            call Read_string
            addl $8, %esp

            cmpl $0, %eax
            je error3

            lea -52(%ebp), %eax
            push %eax
            call My_Atoi32
            addl $4, %esp

            movl %eax, (%edx, %ecx, 4)

            #Second Number (D - Deadline)
            push $12
            lea -52(%ebp), %eax
            push %eax
            call Read_string
            addl $8, %esp

            cmpl $0, %eax
            je error3

            lea -52(%ebp), %eax
            push %eax
            call My_Atoi32
            addl $4, %esp

            movl %eax, 4(%edx, %ecx, 4)

            #Third Number (T - Period)
            push $12
            lea -52(%ebp), %eax
            push %eax
            call Read_string
            addl $8, %esp

            cmpl $0, %eax
            je error3

            lea -52(%ebp), %eax
            push %eax
            call My_Atoi32
            addl $4, %esp

            movl %eax, 8(%edx, %ecx, 4)

            movl 8(%edx, %ecx, 4), %eax
            movl 4(%edx, %ecx, 4), %ebx
            cmpl %eax, %ebx
            jg error4

            movl (%edx, %ecx, 4), %eax 
            cmpl %eax, %ebx
            jl error4

            addl $1, %esi
            cmpl 12(%ebp), %esi
            jl b1

            addl $32, %esp
            pop %esi
            pop %edx
            pop %ecx
            pop %ebx
            pop %eax

            pop %ebp
            ret
            
error3:     
            lea b, %eax
            push %eax
            push $32
            call Error_exit
            jmp .

error4:
            lea z, %eax
            push %eax
            push $19
            call Error_exit
            jmp .
