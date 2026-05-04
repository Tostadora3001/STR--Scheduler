.data
    a: .ascii   "\nCalculating Cyclic schedule :\n"   #31
    b: .ascii   "\nCalculating Fixed schedule :\n"    #30
    c: .ascii   "\nCalculating Deadline schedule :\n"     #33
    d: .ascii   "\n  HiperPeriod : "  #17
    e1: .ascii  "  Ocupation Factor : "   #21
    e2: .ascii  " / 1000 "  #8
    e3: .ascii  "< 1"   #3
    e4: .ascii  "= 1"   #3
    e5: .ascii  "> 1"   #3
    f1: .ascii  " -> Invalid Frame\n"   #18
    f2: .ascii  "Valid Frame\n"     #12
    g1: .ascii  "\n\nPotential Frame values :"    #27
    g2: .ascii  " H % f != 0\n" #12
    g3: .ascii  " > "   #3
    h1: .ascii  "\nValid Candidates :\n"  #19
    h2: .ascii  "\nThere is no possible F value. The schedule is not feasible. Consider dividing the larger tasks.\n"   #97
    i1: .ascii  "\n\n  Iteration "  #13
    i2: .ascii  "  R = "    #6
    i3: .ascii  "\n"    #1
    i4: .ascii  "\n\nCalculating R :" #16
    i5: .ascii  " Task (Tc, D, T) :" 
    i6: .ascii  "\nThe schedule is not feasible due to being R bigger than the Deadline (D < R): "   #80
    i7: .ascii  " < "   #3
    i8: .ascii  "\nThe schedule is feasible due to being R smaller than the Deadline (D > R): "  #77
    i9: .ascii  " > "   #3
    j1: .ascii "\n  Checking L = "   # 16
    j2: .ascii "   Demand = "       # 12
    j4: .ascii "\nThe schedule is not feasible due to being Demand bigger than L (L < Demand): " # 78
    j5: .ascii " < "                # 3
    j6: .ascii "\nThe schedule is feasible due to being Demand smaller or equal than L in all points.\n" # 85
    z: .ascii   "\n\n"  #2

.text
    .global Cyclic
    .global F_Prior
    .global Deadline
    .global Ocupation_F
    .global Hiper
    .global Print_Info_f

# Structure Task: [C (4B), D (4B), T (4B)] -> 12 bytes
# Al functions expects this parameters
        #Arg1 -> Pointer to Input
        #Arg2 -> Total Number of tasks
        #Arg3 -> Pointer to Output

Cyclic:
                push %ebp
                movl %esp, %ebp
                
                push %eax
                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                #Starting Message
                push $31
                lea a, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Ocupation Factor
                push 12(%ebp)
                push 8(%ebp)
                call Ocupation_F
                addl $8, %esp

                #Save the Ocupation Factor in the Heap and Stack
                movl 16(%ebp), %ecx
                movl %eax, (%ecx)
                push %eax

                #HiperPeriod
                push 12(%ebp)
                push 8(%ebp)
                call Hiper
                addl $8, %esp

                #Save the HiperPeriod in the Heap and Stack
                movl 16(%ebp), %ecx
                movl %eax, 4(%ecx)
                push %eax

                #Calculus of the optimal frame
                #Print Message
                push $27
                lea g1, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Find maxium compute time
                push $0
                push 12(%ebp)
                push 8(%ebp)
                call Max_Value
                addl $12, %esp
                push %eax

                #Find minium Period
                push $8
                push 12(%ebp)
                push 8(%ebp)
                call Min_Value
                addl $12, %esp
                push %eax

                #Do a loop trying all possible frame (min T -> max Tc)
                movl -40(%ebp), %ebx
                xorl %edi, %edi

Cyclic_b1:      
                #f % H == 0
                xorl %edx, %edx
                movl -32(%ebp), %eax
                divl %ebx

                cmpl $0, %edx
                jne Cyclic_b1_end_f

                #Print info
                push %ebx
                call Print_Info_f
                addl $4, %esp


                #2f - gcd(ti, f) <= Di
                movl 8(%ebp), %esi
                movl $0, %ecx

Cyclic_b2:
                push %ebx
                movl 8(%esi), %eax
                push %eax
                call MCD 
                addl $8, %esp

                #2*f - g > d
                movl %ebx, %edx
                addl %edx, %edx
                subl %eax, %edx
                cmpl 4(%esi), %edx
                jg Cyclic_b2_fail

                addl $1, %ecx
                addl $12, %esi
                cmpl 12(%ebp), %ecx
                jl Cyclic_b2

Cyclic_b2_win:  
                push $12
                lea f2, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Save in the Heap
                movl 16(%ebp), %ecx
                movl %ebx, 8(%ecx, %edi, 4)
                addl $1, %edi

                jmp Cyclic_b1_end


Cyclic_b2_fail:
                push %edx
                push 4(%esi)
                call Invalid_frame
                addl $8, %esp

                jmp Cyclic_b1_end

Cyclic_b1_end_f:
                push %ebx
                call Print_Info_f
                addl $4, %esp

                push $12
                lea g2, %eax
                push %eax
                call Print_string
                addl $8, %esp

Cyclic_b1_end:  
                subl $1, %ebx
                cmpl -36(%ebp), %ebx
                jge Cyclic_b1


                #Print all valid candidates
                push $20
                lea h1, %eax
                push %eax
                call Print_string
                addl $8, %esp

                cmpl $0, %edi
                je Cyclic_no_b3

                movl 16(%ebp), %esi
                xorl %eax, %eax

Cyclic_b3:
                push 8(%esi, %eax, 4)
                call Print_Info_f
                addl $4, %esp

                addl $1, %eax
                cmpl %edi, %eax
                jl Cyclic_b3
                jmp Cyclic_end

Cyclic_no_b3:  
                push $97
                lea h2, %eax
                push %eax
                call Print_string
                addl $8, %esp

Cyclic_end:
                #Endline
                push $2
                lea z, %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -24(%ebp), %esp
                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx
                pop %eax

                pop %ebp
                ret


F_Prior:
                push %ebp
                movl %esp, %ebp
                
                push %eax
                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                #Starting Message
                push $30
                lea b, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Ocupation Factor
                push 12(%ebp)
                push 8(%ebp)
                call Ocupation_F
                addl $8, %esp

                #Save the Ocupation Factor in the Heap and the stack
                push %eax
                movl 16(%ebp), %ecx
                movl %eax, (%ecx)

                #Sort the tasks
                push $12
                push 12(%ebp)
                push 8(%ebp)
                call Bubble_sort_tasks
                addl $12, %esp

                xorl %esi, %esi
                movl 8(%ebp), %ebx

F_Prior_b1: 
                #Interface Message
                push $17
                lea i4, %eax
                push %eax
                call Print_string
                addl $8, %esp

                addl $1, %esi
                push %esi
                subl $1, %esi
                push %ebx
                call Print_Info_Task
                addl $8, %esp

                #old = %ecx
                #new = (%ebx)
                movl (%ebx), %edx
                #iter 
                push $0
    
F_Prior_b2:
                movl %edx, %ecx 
                #Interference
                push $0

                movl $0, -36(%ebp)      
                movl 8(%ebp), %edx      
                xorl %edi, %edi         

F_Prior_b3:
                cmpl %esi, %edi     
                jge F_Prior_b3_end

                push 8(%edx)        
                push %ecx           
                call ceil_div
                addl $8, %esp       

                imull (%edx), %eax  
                addl %eax, -36(%ebp)

                addl $12, %edx      # Mover puntero a la siguiente tarea de mayor prioridad
                addl $1, %edi
                jmp F_Prior_b3

F_Prior_b3_end:
                movl -36(%ebp), %edx
                addl (%ebx), %edx   # %edx ahora tiene el nuevo R
                
                addl $1, -32(%ebp)

                #Print info
                push -32(%ebp)
                push %edx
                call Print_R_info
                addl $8, %esp

                # r < Deadline
                cmpl 4(%ebx), %edx
                jle F_Prior_win

                push %edx
                push 4(%ebx)
                call F_Prior_fail
                addl $8, %esp
                jmp F_Prior_end

F_Prior_win:
                cmpl %ecx, %edx
                jne F_Prior_b2

                addl $1, %esi
                addl $12, %ebx
                cmpl 12(%ebp), %esi
                jl F_Prior_b1

                push %edx
                subl $12, %ebx
                push 4(%ebx)
                call F_Prior_winner
                addl $8, %esp

F_Prior_end:
                #Endline
                push $2
                lea z, %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -24(%ebp), %esp
                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx
                pop %eax

                pop %ebp
                ret


Deadline:
                push %ebp
                movl %esp, %ebp
                
                push %eax
                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                #Starting Message
                push $33
                lea c, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Ocupation Factor
                push 12(%ebp)
                push 8(%ebp)
                call Ocupation_F
                addl $8, %esp

                #Save the Ocupation Factor in the Heap and Stack
                movl 16(%ebp), %ecx
                movl %eax, (%ecx)

                subl $16, %esp

                #HiperPeriod
                push 12(%ebp)           
                push 8(%ebp)           
                call Hiper
                addl $8, %esp
                movl %eax, -28(%ebp)    

                movl $1, -32(%ebp)      

Deadline_L_loop:
                movl -32(%ebp), %eax
                cmpl -28(%ebp), %eax
                jg Deadline_L_loop_end  

                movl $0, -40(%ebp)      
                movl 8(%ebp), %ebx      
                xorl %esi, %esi         

Deadline_check_task:
                cmpl 12(%ebp), %esi
                jge Deadline_check_done

                movl 4(%ebx), %ecx      
                cmpl %ecx, -32(%ebp)
                jl Deadline_check_next 

                movl -32(%ebp), %eax
                subl %ecx, %eax        
                xorl %edx, %edx
                divl 8(%ebx)            
                cmpl $0, %edx           
                jne Deadline_check_next 

                movl $1, -40(%ebp)      
                jmp Deadline_check_done 

Deadline_check_next:
                addl $12, %ebx
                addl $1, %esi
                jmp Deadline_check_task

Deadline_check_done:
                cmpl $0, -40(%ebp)
                je Deadline_next_L      

                movl $0, -36(%ebp)      
                movl 8(%ebp), %ebx      
                xorl %esi, %esi         

Deadline_calc_demand:
                cmpl 12(%ebp), %esi
                jge Deadline_evaluate

                movl 4(%ebx), %ecx      
                cmpl %ecx, -32(%ebp)
                jl Deadline_calc_next   

                movl -32(%ebp), %eax
                subl %ecx, %eax         
                xorl %edx, %edx
                divl 8(%ebx)            
                addl $1, %eax           
                
                imull 0(%ebx), %eax     
                addl %eax, -36(%ebp)    

Deadline_calc_next:
                addl $12, %ebx
                addl $1, %esi
                jmp Deadline_calc_demand

Deadline_evaluate:
                push -36(%ebp)          
                push -32(%ebp)          
                call Print_L_info
                addl $8, %esp

                movl -36(%ebp), %eax
                cmpl -32(%ebp), %eax
                jg Deadline_failed      

Deadline_next_L:
                addl $1, -32(%ebp)      
                jmp Deadline_L_loop

Deadline_failed:
                push -36(%ebp)          
                push -32(%ebp)          
                call Deadline_fail
                addl $8, %esp
                jmp Deadline_cleanup

Deadline_L_loop_end:
                call Deadline_winner

Deadline_cleanup:
                #Endline
                push $2
                lea z, %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -24(%ebp), %esp
                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx
                pop %eax

                pop %ebp
                ret


#This function calculates the Ocupation factor. The first argument must be the pointer to the Input
#The second argument is the total number of tasks
#The function return the ocuption factor
Ocupation_F:
                push %ebp
                movl %esp, %ebp

                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                movl 8(%ebp), %esi
                xorl %edi, %edi

                #total sum
                subl $4, %esp
                movl $0, -24(%ebp)

Ocupation_F_b1: 
                #For Avoiding treat with decimal the number is multiplied by 1000
                #T
                movl 8(%esi), %ebx

                #Tc
                movl (%esi), %eax
                imull $1000, %eax

                #tc / T
                xorl %edx, %edx
                idivl %ebx

                addl %eax, -24(%ebp)
                addl $1, %edi
                addl $12, %esi
                cmpl 12(%ebp), %edi
                jl Ocupation_F_b1

                push %eax

                #Print the result
                push $21
                lea e1, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Get the string number
                subl $12, %esp
                push -24(%ebp)
                lea -36(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                #Print the string number
                push %eax
                lea -36(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Print the final part of the message
                push $8
                lea e2, %eax
                push %eax
                call Print_string
                addl $8, %esp

                cmpl $1000, -24(%ebp) 
                je equal
                jg bigger


smaller:
                push $3
                lea e3, %eax
                push %eax
                call Print_string
                addl $8, %esp
                jmp end

equal:
                push $3
                lea e4, %eax
                push %eax
                call Print_string
                addl $8, %esp
                jmp end

bigger:
                push $3
                lea e5, %eax
                push %eax
                call Print_string
                addl $8, %esp

end:
                lea -24(%ebp), %esp
                pop %eax
                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx

                pop %ebp
                ret

#First Argument is the pointer to the Input. The second the Number of tasks
#The function Returns the HiperPeriod
Hiper:    
                push %ebp
                movl %esp, %ebp

                push %ebx
                push %ecx
                push %edx
                push %esi

                #Calculus of the HiperPeriod
                push $17
                lea d, %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Initialice a vector containing all the periods
                movl 12(%ebp), %eax
                shll $2, %eax
                subl %eax, %esp

                movl 8(%ebp), %esi
                addl $8, %esi
                movl $0, %ebx

C_b1:           
                movl (%esi), %eax
                movl %eax, (%esp, %ebx, 4)

                addl $1, %ebx
                addl $12, %esi
                cmpl 12(%ebp), %ebx
                jl C_b1
                
                movl %esp, %eax
                push %ebx
                push %eax
                call Vectorial_MCM

                #Delete the vector and save HiperPeriod
                lea -16(%ebp), %esp
                push %eax

                subl $17, %esp
                push %eax
                lea -36(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                push %eax
                lea -36(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -20(%ebp), %esp
                #return value HiperPeriod
                pop %eax

                pop %esi
                pop %edx
                pop %ecx
                pop %ebx

                pop %ebp
                ret

#The first and only argument is the value of the frame
Print_Info_f:
                push %ebp
                movl %esp, %ebp

                push %eax

                subl $28, %esp
                push 8(%ebp)
                lea -28(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $'\n', -32(%ebp)
                movb $' ', -31(%ebp)
                movb $' ', -30(%ebp)
                movb $'f', -29(%ebp)
                movb $' ', -28(%ebp, %eax, 1)
                movb $':', -27(%ebp, %eax, 1)
                movb $' ', -26(%ebp, %eax, 1)

                addl $7, %eax
                push %eax
                lea -32(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                addl $28, %esp

                pop %eax
                pop %ebp
                ret

#First argument is the Deadline, the second is the calculated value
Invalid_frame:  
                push %ebp
                movl %esp, %ebp

                push %eax
                push %ebx
                subl $12, %esp

                push 12(%ebp)
                lea -20(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                push %eax
                lea -20(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $3
                lea g3, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 8(%ebp)
                lea -20(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                push %eax
                lea -20(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $18
                lea f1, %eax
                push %eax
                call Print_string
                addl $8, %esp

                addl $12, %esp
                pop %ebx
                pop %eax
                pop %ebp

                ret

#The function prints the Tasks Information. The first arguemnt is the pointer to the task
#The second argument is the task number
Print_Info_Task:
                push %ebp
                movl %esp, %ebp

                push %eax
                push %ebx
                push %ecx
                push %edx
                push %esi
                push %edi

                movl 8(%ebp), %ebx

                subl $12, %esp
                push 12(%ebp)
                lea -33(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $' ', -36(%ebp)
                movb $' ', -35(%ebp)
                movb $'t', -34(%ebp)
                movb $' ', -33(%ebp, %eax, 1)
                movb $':', -33(%ebp, %eax, 1)
                addl $4, %eax

                push %eax
                lea -36(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Time Compute
                push (%ebx)
                lea -34(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $' ', -36(%ebp)
                movb $' ', -35(%ebp)
                addl $2, %eax
                push %eax
                lea -36(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Deadline
                push 4(%ebx)
                lea -34(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $' ', -36(%ebp)
                movb $' ', -35(%ebp)
                addl $2, %eax
                push %eax
                lea -36(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                #Period
                push 8(%ebx)
                lea -34(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $' ', -36(%ebp)
                movb $' ', -35(%ebp)
                addl $2, %eax
                push %eax
                lea -36(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -24(%ebp), %esp
                pop %edi
                pop %esi
                pop %edx
                pop %ecx
                pop %ebx
                pop %eax

                pop %ebp
                ret

#This functions prints information about R (Fixed). The first arguemtn is the R
#The second argument is the iteration or num R
Print_R_info:
                push %ebp
                movl %esp, %ebp

                push %eax
                push %ebx
                push %ecx
                push %edx

                push $14
                lea i1, %eax
                push %eax
                call Print_string
                addl $8, %esp

                subl $12, %esp
                push 12(%ebp)
                lea -28(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                push %eax
                lea -28(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $6
                lea i2, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 8(%ebp)
                lea -28(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $'\n', -28(%ebp, %eax, 1)
                addl $1, %eax
                push %eax
                lea -28(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -16(%ebp), %esp
                pop %edx
                pop %ecx
                pop %ebx
                pop %eax

                pop %ebp
                ret


#This is an auxiliar function for printing info. First Argument is the Deadline, the second the R
F_Prior_fail:
                push %ebp
                movl %esp, %ebp

                push %eax

                push $80
                lea i6, %eax
                push %eax
                call Print_string

                subl $12, %esp
                push 8(%ebp)
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $3
                lea i7, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 12(%ebp)
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $' ', -15(%ebp, %eax, 1)
                addl $1, %eax
                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp
                
                lea -4(%ebp), %esp
                pop %eax
                pop %ebp
                ret

#This is an auxiliar function for printing info. First Argument is the Deadline, the second the R
F_Prior_winner:
                push %ebp
                movl %esp, %ebp

                push %eax

                push $77
                lea i8, %eax
                push %eax
                call Print_string

                subl $12, %esp
                push 8(%ebp)
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $3
                lea i9, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 12(%ebp)
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp

                movb $' ', -15(%ebp, %eax, 1)
                addl $1, %eax
                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp
                
                lea -4(%ebp), %esp
                pop %eax
                pop %ebp
                ret

# Prints "  Checking L = [L]   Demand = [Demand]"
Print_L_info:
                push %ebp
                movl %esp, %ebp
                push %eax
                subl $16, %esp          

                push $16
                lea j1, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 8(%ebp)            # L
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp
                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $12
                lea j2, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 12(%ebp)           # D
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp
                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -4(%ebp), %esp
                pop %eax
                pop %ebp
                ret

# Prints the failure message for EDF
Deadline_fail:
                push %ebp
                movl %esp, %ebp
                push %eax
                subl $16, %esp

                push $78
                lea j4, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 8(%ebp)            # L
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp
                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                push $3
                lea j5, %eax
                push %eax
                call Print_string
                addl $8, %esp

                push 12(%ebp)           # Demand
                lea -16(%ebp), %eax
                push %eax
                call My_UnAtoi32
                addl $8, %esp
                push %eax
                lea -16(%ebp), %eax
                push %eax
                call Print_string
                addl $8, %esp

                lea -4(%ebp), %esp
                pop %eax
                pop %ebp
                ret

# Prints the success message for EDF
Deadline_winner:
                push %ebp
                movl %esp, %ebp
                push %eax

                push $85
                lea j6, %eax
                push %eax
                call Print_string
                addl $8, %esp

                pop %eax
                pop %ebp
                ret
