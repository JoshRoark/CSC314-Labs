;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Name: Joshua Roark                                Class: CSC-314              ;
; Assignment: Lab0x02-stoneAgeCalculator                                        ;
;                                                                               ;
; Description:  Takes input from stdin and does 1-byte calculations using a     ;
;               a base-1 math system... pebbles "o" - Supports +-*/%            ;
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
            call chkLen                             ; if length is over 255, throw error
            call doMath                             ; assuming all is well - time to count pebbles!
            call chkLen                             ; final sanity check for post-math data length issu
            jmp startLoop                           ;infinite loop unless first char is "x" 
        


            chkLen:
                    push eax                        ;preserves eax... just in case we needed that value later                    
                    mov eax, [msglen]
                    cmp eax, 257                    ;if message length is more than 255 (257 total) characters plus starting symbol and ending 0x0A, throw error            
                    pop eax                         ;restores eax
                    jge errBig  
                    ret

            chkResult:
                    push eax                        ;preserves eax... just in case we needed that value later                    
                    mov eax, [counter]
                    cmp eax, 255                    ;if pile bigger than 255 error
                    pop eax                         ;restores eax
                    jge errBig  
                    ret

            chkSymbol:                              ; determines whether the first symbol is valid input "o+-*/%x" are considered valid
                         xor ebx, ebx
                         xor eax, eax
                         mov AL, [userInput + ebx]  ; moves the first byte into AL (since ebx just got zeroed out)
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
                         mov AL, [userInput + ebx] ;ebx is our offset here, so we're moving each subsequent char into AL then checking to make sure it's 
                                                   ;an "o" anything else is invalid.
                         cmp AL, 'o'
                         je chkSymbolLoop
                         cmp AL, 0x0A                ;check if at end of userinput
                         jne errBad                 ;if it's not the first symbol and not either a 'o' or 0x0A then error, else return                  
                    ret                     ; returns


            doMath: ; determines whether the first symbol is valid input "o+-*/%x" are considered valid
                         xor ebx, ebx
                         xor eax, eax
                         mov AL, [userInput + ebx] ; puts first char of userInput into AL
                         cmp AL, '+'
                            je addPebbles
                         cmp AL, '-'
                            je subPebbles
                         cmp AL, '*'
                            je mulPebbles
                         cmp AL, '/'
                            je divPebbles
                         cmp AL, '%'
                            je modPebbles
                         cmp AL, 'x'
                            je end         ; end prog



            addPebbles: 
                    ;'+'
                    mov ecx, [msglen]
                    sub ecx, 2              ;decrements by 2 so that we're only adding the actual pebbles, not the symbol or 0x0A 
                    mov ebx, [counter]
                    add ebx, ecx
                    mov [counter], ebx      ;updates counter with the new total
                    call chkResult
                    call printPebbles
                    jmp startLoop


            subPebbles:
                    ;'-'
                    mov ecx, [msglen]
                    sub ecx, 2              ;decrements by 2 so that we're only adding the actual pebbles, not the symbol or 0x0A 
                    mov ebx, [counter]
                    cmp ebx, ecx
                    jl errNeg               ;if result will be negative, throw error and clear pile
                    sub ebx, ecx
                    mov [counter], ebx      ;else, updates counter with the new total
                    call printPebbles
                    jmp startLoop

            mulPebbles:
                    ;'*'
                    mov ecx, [msglen]
                    sub ecx, 2              ;decrements by 2 so that we're only adding the actual pebbles, not the symbol or 0x0A 
                    mov eax, [counter]
                    mul ecx
                    mov [counter], eax      ;updates counter with the new total
                    call chkResult
                    call printPebbles
                    jmp startLoop


            divPebbles:
                    ;'/'
                    xor edx, edx                    
                    mov bx, [msglen]
                    sub bx, 2              ;decrements by 2 so that we're only adding the actual pebbles, not the symbol or 0x0A 
                    mov ax, [counter]
                    cmp ax, bx
                    jl errNeg               ; checks for division that would result in a fraction of a pebble - errors and zeros out pile
                    div bx
                    mov [counter], ax      ;updates counter with the new total
                    call chkResult
                    call printPebbles
                    jmp startLoop



            modPebbles:
                    ;'%'
                    mov bx, [msglen]
                    sub bx, 2              ;decrements by 2 so that we're only adding the actual pebbles, not the symbol or 0x0A 
                    mov ax, [counter]
                    xor edx,edx
                    div bx
                    mov [counter], dx      ;updates counter with the new total
                    call chkResult
                    call printPebbles
                    jmp startLoop
                    jmp startLoop

                    
            printPebbles:
                mov ecx, [counter]
                cmp ecx, 0      ;checks to make sure the result isn't zero pebbles
                je skipLoop     ;otherwise it infinite loops printing pebbles
                ctrlP:
                print pebble,1
                loop ctrlP
                skipLoop:
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
    welcomeMessage db "Welcome to PebbleCalc! We math for you!", 0x0A, "So easy... caveman do it!", 0x0A
    welcomeMessageLen equ $ - welcomeMessage 

    pebble db "o"
    newLine db 0x0A

    calcStart db "="
    calcStartLen equ $ - calcStart 

    testGood db "Test Successful!", 0x0A
    testGoodLen equ $ - testGood

    badSymbolError db "ERROR: That symbol not covered in school of rock ... try these ( + - * / %)", 0x0A
    badSymbolErrorLen equ $ - badSymbolError 

    tooBigError db "ERROR: I not count that high... pile too big... go math yourself!", 0x0A
    tooBigErrorLen equ $ - tooBigError 

    negativeError db "ERROR: It takes pebbles to make pebbles.... can't make pile less than nothing", 0x0A
    negativeErrorLen equ $ - negativeError 

    noInput db "ERROR: What?! You no like to talk? (input = null... try again)",10  ;error message used for when no characters are read in
    noInputLen equ $ - noInput  ;calculates length of noInput

    goodbye db "See? So easy caveman can do it!", 0x0A
    goodbyeLen equ $ - goodbye 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; section for variables
section .bss 

    ;note: I realize that the size for most of these is probably overkill, but was focused on getting it to work first. 


    userInput resb 1000                     ; reserving to store user input 
    mainLoop resb 16                        ; inner loop temp for ecx
    counter resb 16                         ; Keeping track of where in overall userinput are we
    
    msglen resb 1                           ; size of what was actually typed in



