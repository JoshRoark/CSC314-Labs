;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Name: Joshua Roark                                Class: CSC-314              ;
; Assignment: Lab0x01-Diagonals                                                 ;
;                                                                               ;
; Description:  Takes input from stdin (keyboard or input redirection)          ;
;               and prints the each line diagonally.                            ;
;               Input restricted to 1000 chars                                  ;
;                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .text "read only", typically used for the actual instructions of your progam
section .text

        ; "global" keyword will make symbols in your assembly program visible to the linker
        global _start
        

_start:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        call stdIN ; gets user input
      
        
        loop_do:                             ; a sort of do/while loop to setup ecx (loop counter) with the correct number of characters)            
                xor ecx, ecx                 ; clears out the registers 
                xor ebx, ebx
                xor eax, eax
                xor edx, edx
           
                mov  [numSpaces], ecx        ;initializes numSpaces (necessary since this will loop)
                mov eax, [counter]           ; moves the number of bytes we've processed to eax for our check
                cmp eax, 0                   ; this is a quick check to see if it's the first time the loop has run...   
                je loop_while                ; if this is the first run, it skips the next section of code which is only relevant for multi-line input

                                             ; the following code is only really relevant for longer/multi-line input.
                call varPP                   ; increases counter/numSpaces otherwise we reprint characters
                mov ebx, [numSpaces]         ; stores the value of x (our incremental counter) in ebx
                add ebx, userInput           ; ebx = ebx + address of our data (so that the start of ebx is the character we want to print)
                
                mov ecx, [msglen]            ; sets ecx in prep for the "while" portion of the loop
                xor eax, eax                 ; zero's out eax 
                mov  [numSpaces], eax        ;initializes x necessary since varPP will have added 1 to it.
                
        loop_while:               
                mov [mainLoop],ecx           ; stores ecx away so we don't lose our place in the loop
                
                ; print spaces
                mov ebx, spaces              ; stores the value of x (our incremental counter) in ebx
                ;add ebx, spaces             ; ebx = ebx + address of our spaces buffer (so that the start of ebx is the character we want to print)
                mov ecx, ebx                 ; moves ebx to ecx in preperation to print to screen             
                mov edx, [numSpaces]         ; print number of space based on the count of numSpaces
                call print                   ; ctrl+p Print

                ; print the next character in our line                
                mov ebx, [counter]           ; stores the value of x (our incremental counter) in ebx
                add ebx, userInput           ; ebx = ebx + address of our data (so that the start of ebx is the character we want to print)
                mov ecx, ebx                 ; moves ebx to ecx in preperation to print to screen             
                mov edx, 1                   ; sets the number of characters to be printed (1)
                call print                   ; ctrl+p Print


               ; Check to see if that character was a newline character (if so, reset X)
                    
                xor edx, edx                ; clears edx    
                mov ebx, [counter]          ; stores the value of stringCounter (our incremental counter) in ebx
                add ebx, userInput          ; ebx = ebx + address of our data (so that the start of ebx is the character we want to print)            
                mov dl, [ebx]               ; hopefully moves first character to dl so we can check to see if it's a newline 
                cmp dl, [newLine]           ; compares dl to see if it's a newline character (if newline then go back to start and print next line)
                
                je loop_do                  ; if newline, then go back to start 
                mov eax, [msglen]           ; else check an see if we're at the end of the buffer
                mov ebx, [counter]          ; moves msglen to eax and counter to ebx
                cmp eax, ebx                ; then compares - if counter is greater than or equal to counter then we're done
                jl end                      ; skips to the end of program if numSpaces <= counter

               ; print newline and prep for next character 
                call varPP                  ; x++
                mov ecx, newLine            ; moves address of variable set to  0x0A to ecx as address of value to be printed
                mov edx, 1                  ; specifies only to print the one character
                call print                  ; prints ecx to screen                
                mov ecx, [mainLoop]         ; sets ecx back to the value of mainLoop before loop command decrements it and moves to loop_while
            loop loop_while

        jmp end 
        

        print:
                mov ebx, 1                  ; moves 1 into ebx   (command to stdOut)      
                mov eax, 4                  ; moves 4 into eax, (sys_write)                
                int 0x80                    ; interupt to print ecx to stdout
                ret                         ; return

        varPP: ; numSpaces++ , stringCounter++
            mov ebx, [numSpaces]            ; moves numSpaces to a register 
            inc ebx                         ; increments the register
            mov [numSpaces], ebx            ; moves the incremented data back (numspaces++)

            mov ecx, [counter]              ; moves counter to ecx
            inc ecx                         ; increments ecx 
            mov [counter], ecx              ; moves the incremented ecx back to counter (counter++)

            ret                             ; return


            stdIN: ; Making this a function so I can copy/paste it for future labs
                    mov ebx, 0              ; moves 0 into ebx (stdin/keyboard)
                    mov eax, 3              ; moves 3 into eax, (sys_write)
                    mov ecx, userInput      ; sets address for where the data will be stored      
                    mov edx, 1000           ; sets max input
                    int 0x80                ; interupt to take input from stdin
                    mov [msglen],eax        ; stores the length of the message
                    ret                     ; return






        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        end:        
            mov ebx, 0
            mov eax, 1
            int 0x80        ; system call to "sys_exit" to end the program cleanly
    



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
; another section for data (fixed values)
section .data


 ; big ass spaces buffer - 180 spaces , which should be enough to print a diagonal text line on all but the largest command line windows (looks like standard is around 80 columns of text... so 180 should more than cover us here.
    spaces db "                                                                                                                                                                    "
    newLine db 0x0A
    cR db 0x0D



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; section for variables
section .bss 

    ;note: I realize that the size for most of these is probably overkill, but was focused on getting it to work first. 


    userInput resb 1000                     ; reserving to store user input 
    mainLoop resb 16                        ; inner loop temp for ecx
    counter resb 16                         ; Keeping track of where in overall userinput are we
    numSpaces resb 16                       ; "numSpaces" used for incrementing the line
    msglen resb 8                           ; size of what was actually typed in

    
