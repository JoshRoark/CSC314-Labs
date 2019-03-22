;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Name: Joshua Roark                                Class: CSC-314              ;
; Assignment: Lab0x02-BinaryCalculator                                          ;
;                                                                               ;
; Description:  Takes input from stdin and does 1-byte binary calculations      ;
;               Supports +-*/%                                                  ;
;               "x" exit                                                        ;
;                                                                               ;
;               All other symbols will result in an error!                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "var_macros.mac"                       ;file with macros written to maniupulate variables (read/print/incv/clear)


; .text "read only", typically used for the actual instructions of your progam
section .text

        ; "global" keyword will make symbols in your assembly program visible to the linker
        global _start
        

_start:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        
        print welcomeMessage, welcomeMessageLen     ;start of prog welcome message
       

        startLoop:
            print calcStart, calcStartLen
            mov eax, msglen
            cmp eax, 0
            je startRead           
            clear userInput, msglen; zeros out userInput
            startRead:
            read userInput, 1000                    ; sys_read up to 1000 bytes into userInput
            cmp eax, 1                              ; if = 1 then that means blank + 0x0A... so no user input
            je errZero                              ; if blank then throws error and loops back to start
            mov [msglen],eax                        ; stores the length of the message
            call chkSymbol                          ; Loop through each char of user input, jumps if valid, error if not valid (valid = o+-*/%x)
            call chkLen                            ; if length is over 255, throw error
            call convertInput                       ; converts userinput to binary and stores it in "converted"            
;            call printBinary                       ; prints "counter" the running total in binary
            call doMath                            ; assuming all is well - time to count Binary!
            call chkLen                            ; final sanity check for post-math data length issues
            jmp end                         ;for now, I don't want it to infinite loop
        jmp startLoop                               ;infinite loop unless first char is "x" 
        


            chkLen:
                    push eax                ;preserves eax... just in case we needed that value later                    
                    mov eax, [msglen]
                    cmp eax, 10            ;if message length is more than 255 (257 total) characters plus starting symbol and ending 0x0A, throw error            
                    pop eax                 ;restores eax
                    jne errBig              ; if not the correct length, error out
                    ;print testGood, testGoodLen                    
                    ret

            chkResult:
                    push eax                ;preserves eax... just in case we needed that value later                    
                    mov eax, [counter]
                    cmp eax, 255            ;if number bigger than 255 error
                    pop eax                 ;restores eax
                    jg errBig  
                    ;print testGood, testGoodLen                    
                    ret

            chkSymbol: ; determines whether the first symbol is valid input "o+-*/%x" are considered valid
                         xor ebx, ebx
                         xor eax, eax
                         mov AL, [userInput + ebx]
                         cmp AL, '+'
                             je chkSymbolLoop
                         cmp AL, '-'
                             je chkSymbolLoop
                         cmp AL, '*'
                             je chkSymbolLoop
                         cmp AL, '/'
                             je chkSymbolLoop
                         cmp AL, '%'
                             je chkSymbolLoop
                         cmp AL, 'x'
                             je chkSymbolLoop                   
                         jmp errBad                     ;if not a valid symbol, error out

                    chkSymbolLoop:                 ;checks the rest of the string to make sure that everything after the first char is a "o"
                         inc ebx
                         mov AL, [userInput + ebx]
                         cmp AL, '0'
                         je chkSymbolLoop
                         cmp AL, '1'
                         je chkSymbolLoop
                         cmp AL, 0x0A                ;check if at end of userinput
                         jne errBad                 ;if it's not the first symbol and not either a 'o' or 0x0A then error, else return                  
                    ret                     ; returns


            doMath: ; determines whether the first symbol is valid input "o+-*/%x" are considered valid
                         xor ebx, ebx
                         xor eax, eax
                         mov AL, [userInput + ebx] ; puts first char of userInput into AL
                         cmp AL, '+'
                            je addBinary
                         cmp AL, '-'
                            je subBinary
                         cmp AL, '*'
                            je mulBinary
                         cmp AL, '/'
                            je divBinary
                         cmp AL, '%'
                            je modBinary
                         cmp AL, 'x'
                            je end         ; end prog

            convertInput:
                    xor ebx, ebx                ; clearing out ebx for storage of our converted text
                    xor edx, edx                ; moving through user input
                    mov ecx, 10                 ;static sized input allows for lazy programmer to hardcode values
                    convertLoop:                    
                         inc edx
                         mov AL, [userInput + edx]
                         cmp AL, '0'
                         je addZero
                         cmp AL, '1'
                         je addOne
                         cmp AL, 0x0A
                         je breakLoop
                         addZero:
                            shl ebx, 1
                            loop convertLoop
                         addOne:
                            shl ebx, 1
                            inc ebx
                            loop convertLoop
                         breakLoop:
                    mov [converted], ebx
                    ret
         
            

            addBinary: 
                    ;'+'
                    mov ecx, [converted]
                    mov ebx, [counter]
                    add ebx, ecx
                    mov [counter], ebx      ;updates counter with the new total
                    call chkResult
                    call printBinary
                    jmp startLoop


            subBinary:
                    ;'-'
                    mov ecx, [converted]
                    mov ebx, [counter]
                    cmp ebx, ecx
                    jl errNeg               ;if result will be negative, throw error and clear pile
                    sub ebx, ecx
                    mov [counter], ebx      ;else, updates counter with the new total
                    call printBinary
                    jmp startLoop

            mulBinary:
                    ;'*'
                    mov ecx, [converted]
                    mov eax, [counter]
                    mul ecx
                    mov [counter], eax      ;updates counter with the new total
                    call chkResult
                    call printBinary
                    jmp startLoop


            divBinary:
                    ;'/'
                    xor edx, edx                    
                    mov bx, [converted]
                    mov ax, [counter]
                    cmp ax, bx
                    jl errNeg               ; checks for division that would result in a fraction of a pebble - errors and zeros out pile
                    div bx
                    mov [counter], ax      ;updates counter with the new total
                    call chkResult
                    call printBinary
                    jmp startLoop



            modBinary:
                    ;'%'
                    mov bx, [converted]
                    mov ax, [counter]
                    xor edx,edx
                    div bx
                    mov [counter], dx      ;updates counter with the new total
                    call chkResult
                    call printBinary
                    jmp startLoop
                    jmp startLoop

                    
            printBinary:
                mov ebx, [counter]
                xor edx,edx
                mov eax, output
                mov ecx, 8                      
                cmp [counter], edx;checks to make sure the result isn't zero Binary
                je printNothing                    ;otherwise it infinite loops printing Binary
                ctrlP:
                    
                    cmp ecx, 0                          ; since I have two options looping, I need this check to avoid infinite loop once the binary-->text 
                                                        ; conversion is complete
                    jle skipLoop                        ; if ecx has already looped 8 times, jump to the actual printing. 
                    shl bl, 1                           ;shift left and check for a carry 
                    jc out1                             ;if carry put 0x31 in the next outputBuffer byte 
                    jnc out0                            ;if no carry, the put 0x30 in the next outputBuffer byte
                     
                    
                    
                    out1:
                        mov [eax+edx], byte '1'         ;puts a "1" in our output buffer
                        inc edx                         ;increment the offset for the outputBuffer 
                        loop ctrlP
                    out0:
                        mov [eax+edx], byte '0'
                        inc edx                         ;increment the offset for the outputBuffer 
                        loop ctrlP
                skipLoop:
                print eax, 8
                mov [outputLen], edx 
                clear output, outputLen                       ; the way I wrote the macro, it errors out unless %2 is a memory address        
                print newLine, 1
                ret
                printNothing:
                    print rock, 1                           ;prints 8 zeros .... if o = pebble, 0 = rock (late/last min humor... apologies) 
                    loop printNothing                    
                    print newLine, 1
                    ret
            

            errBig:
                print tooBigError, tooBigErrorLen; print error
                clear userInput, msglen; zeros out the pile
                xor eax, eax
                mov [counter], eax      ; should never be more than 4 bytes... this just clears it out. 
                jmp startLoop
                

            errNeg:
                print negativeError, negativeErrorLen
                clear userInput, msglen; zeros out the pile
                xor eax, eax
                mov [counter], eax      ; should never be more than 4 bytes... this just clears it out. 
                jmp startLoop
                

            errBad:
                print badSymbolError, badSymbolErrorLen
                clear userInput, msglen; zeros out userInput
                xor eax, eax
                mov [counter], eax      ; should never be more than 4 bytes... this just clears it out. 
                jmp startLoop

            errZero:
                print noInput, noInputLen
                nop     ;I just want a breakpoint
                xor eax, eax
                mov [userInput], AL     ; swaps that 0x0A for 0x00
                mov [counter], eax      ; should never be more than 4 bytes... this just clears it out. 
                jmp startLoop

  





        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        end:        
            print goodbye, goodbyeLen            
            mov ebx, 0
            mov eax, 1
            int 0x80        ; system call to "sys_exit" to end the program cleanly
    



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
; another section for data (fixed values)
section .data


    ;;;; Messages and Errors ;;;;
    welcomeMessage db "One byte binary calculator", 0x0A, "Valid input is symbol with binary value from 00000000 to 11111111 ", 0x0A,"All other input will result in an error.", 0x0A
    welcomeMessageLen equ $ - welcomeMessage 

    rock db "0"
    newLine db 0x0A

    calcStart db "="
    calcStartLen equ $ - calcStart 

    testGood db "Test Successful!", 0x0A
    testGoodLen equ $ - testGood

    badSymbolError db "ERROR: Unsupported user input - includes invalid symbol ( + - * / %)", 0x0A
    badSymbolErrorLen equ $ - badSymbolError 

    tooBigError db "ERROR: Unsupported user input - size of input or operation must be between 00000000 and 11111111 maximum value", 0x0A
    tooBigErrorLen equ $ - tooBigError 

    negativeError db "ERROR: Value results in a negative calculation", 0x0A
    negativeErrorLen equ $ - negativeError 

    noInput db "ERROR: Unsupported user input - input = null",0x0A  ;error message used for when no characters are read in
    noInputLen equ $ - noInput  ;calculates length of noInput

    goodbye db "01010100 01101000 01100001 01101110 01101011 00100000 01111001 01101111 01110101 00101100 00100000 01100011 01101111 01101101 01100101 00100000 01100001 01100111 01100001 01101001 01101110 00100001", 0x0A
    goodbyeLen equ $ - goodbye 




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; section for variables
section .bss 

    ;note: I realize that the size for most of these is probably overkill, but was focused on getting it to work first. 


    userInput resb 1000                     ; reserving to store user input 
    mainLoop resb 16                        ; inner loop temp for ecx
    counter resb 16                         ; Keeping track of where in overall userinput are we
    output resb 16                           ; for printing the result
    outputLen resb 2
    converted resb 1                   ; for the binary storage of userInput
    msglen resb 1                           ; size of what was actually typed in



