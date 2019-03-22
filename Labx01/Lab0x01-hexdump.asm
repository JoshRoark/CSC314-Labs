;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Name: Joshua Roark                                Class: CSC-314              ;
; Assignment: Lab0x01-HexDump                                                   ;
;                                                                               ;
; Description:  Takes input from stdin (keyboard or input redirection)          ;
;               and prints the hex values in rows with size determined          ;
;               by lineLength. Input restricted to 1000 chars                   ;
;                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; .text "read only", typically used for the actual instructions of your progam
section .text

        ; "global" keyword will make symbols in your assembly program visible to the linker
        global _start
        

_start:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

        call stdIN ; gets user input
        
        mov ecx, [msglen]                       ; sets ecx in prep for the "while" portion of the loop
              
                
        loop_while:               
                mov [mainLoop],ecx              ; stores ecx away so we don't lose our place in the loop
                
                mov ecx, [lineLength]           ; stores our constant for determining number of columns in ecx for hexloop (since loop decrements ecx)
                call hexloop                    ; print hex loop - goes through and prints out [lineLength] number of bytes in hex and adds a space after each byte
                call printNewLine               ; prints 0x0A (newline) 

                ; check and see if we're at the end of the buffer, if so, jump to the end      

                mov eax, [msglen]               ; moves the total length of userInput to eax
                mov ebx, [counter]              ; moves the total number of times we've printed bytes to ebx
                cmp eax, ebx                    ; if the counter is greater than or equal to msglen that means we've processed the whole queue
                jl end                          ; skips to the end of program if msglen <= counter
                mov ecx, [mainLoop]             ; sets ecx back to the value of mainLoop before loop command decrements it and moves to loop_while
                mov ebx, [lineLength]           ; makes sure ecx is decremented by the total number of bytes we've printed
                sub ebx, 1                      ; reduces ebx by 1 so the following line decrements ecx by the correct number           
                sub ecx, ebx                    ; inner loop printed X bytes - loop will decrease ecx by 1, we are reducing it the other X-1 here to stay on track
            loop loop_while

        jmp end 
        

                hexloop:                            ; used hexloop as a separate subprogram because otherwise loop loop_while's short jump wouldn't reach and it errors out.
                     mov [hexLoopX], ecx            ; temp storage for ecx since it's used by loop later
                     mov ebx, [counter]             ; stores the value of x (our incremental counter) in ebx
                     add ebx, userInput             ; ebx = ebx + address of our data (so that the start of ebx is the character we want to print)
                     mov eax,[ebx]                  ; moves the data from ebx (where we're at in userInput) to eax for temp storage
                     xor ebx, ebx                   ;zeros out ebx since we're going to be storing only a single byte from EAX (al) 
                     mov bl, al                     ; moves the last (first, litle endian) byte in EAX to bl so we can isolate that byte
                     add ebx, ebx                   ;index = index *2
                     add ebx, hexComplete           ; output + hexComplete  (location in the array for the start of the 2 bytes representing the hex of the character we're looking up)
                     mov ecx, ebx                   ; moves the result to ecx 
                     mov edx, 2                     ; prints 2 bytes
                     call print                     ; ctrl+p print
                     call printSpace                ; prints a space
                     call varPP                     ; increases the counter for each byte printed
                     mov ecx, [hexLoopX]            
                     loop hexloop
                     ret



        printSpace:
                mov edx, 1                          ; sets the number of chars to print to 1
                mov ecx, space                      ; sets ecx to 0x20 (space) for easy printing
                mov ebx, 1                          ; moves 1 into ebx   (command to stdOut)      
                mov eax, 4                          ; moves 4 into eax, (sys_write)                
                int 0x80                            ; interupt to print ecx to stdout
                ret

        printNewLine:
                mov edx, 1                          ; sets the number of chars to print to 1
                mov ecx, newLine                    ; moves newLine (0x0A) to ecx for printing
                mov ebx, 1                          ; moves 1 into ebx   (command to stdOut)      
                mov eax, 4                          ; moves 4 into eax, (sys_write)                
                int 0x80                            ; interupt to print ecx to stdout
                ret                                 ; return

        print:
                mov ebx, 1                          ; moves 1 into ebx   (command to stdOut)      
                mov eax, 4                          ; moves 4 into eax, (sys_write)                
                int 0x80                            ; interupt to print ecx to stdout
                ret                                 ; return

        varPP: ; stringCounter++
            mov ecx, [counter]                      ; moves the data in the variable "counter" to ecx
            inc ecx                                 ; increments ecx
            mov [counter], ecx                      ; moves the incremented ecx back into "counter" (counter++)
            ret                                     ; return


            stdIN: ; Making this a function so I can copy/paste it for future labs
                    mov ebx, 0                      ; moves 0 into ebx (stdin/keyboard)
                    mov eax, 3                      ; moves 3 into eax, (sys_write)
                    mov ecx, userInput              ; sets address for where the data will be stored      
                    mov edx, 1000                   ; sets max input
                    int 0x80                        ; interupt to take input from stdin
                    mov [msglen],eax                ; stores the length of the message
                    ret                             ; return






        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        end:        
            mov ebx, 0
            mov eax, 1
            int 0x80        ; system call to "sys_exit" to end the program cleanly
    



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
; another section for data (fixed values)
section .data

    space db 0x20
    newLine db 0x0A                             ; newline char - 
    lineLength db 0x04,0x00,0x00,0x00           ; how many bytes to print per row- note: reversed to account for little endian
    ;below: every single possible hex combination 
    hexComplete db "000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; section for variables
section .bss 

    ;note: I know most of these are WAY bigger than needed, but ran out of time to optimize them. Wanted to make sure that it worked first.

    userInput resb 1000                        ; reserving to store user input 
    hexOutput resb 2                           ; Probably more than we need, but we'll see
    mainLoop resb 16                           ; inner loop temp for ecx
    counter resb 16                            ; Keeping track of where in overall userinput we are
    msglen resb 32                             ; size of what was actually typed in
    hexLoopX resb 4                            ; max size of line length, so unlikely to need more than this.






    
