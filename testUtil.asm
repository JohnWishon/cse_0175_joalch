
punchstr:
    defb    "Punch "
Xpunchstr:
jumpstr:
    defb    "Jump", newline
Xjumpstr:

nstr:
    defb    "North", newline
Xnstr:
estr:
    defb    "East", newline
Xestr:
wstr:
    defb    "West", newline
Xwstr:
sstr:
    defb    "South", newline
Xsstr:

nestr:
    defb    "Northeast", newline
Xnestr:
sestr:
    defb    "Southeast", newline
Xsestr:
nwstr:
    defb    "Northwest", newline
Xnwstr:
swstr:
    defb    "Southwest", newline
Xswstr:
errorstr:
    defb    "Error!", newline
Xerrorstr:


p1str:
    defb    "P1: "
Xp1str:
p2str:
    defb    "P2: "
Xp2str:
spacestr:
    defb    " "
newlinestr:
    defb    newline
grdstr:
    defb    "GRD "
jmpstr:
    defb    "JMP "
falstr:
    defb    "FAL "


testingStr:
    defb    "Testing:", newline
XtestingStr:
testPassedStr:
    defb    "Test passed!", newline
XtestPassedStr:
allTestPassedStr:
    defb    "All tests passed!", newline
XallTestPassedStr:


test_print_num_and_space:
    call    printNumber    ; Prints number in BC
    call    test_print_space
    ret
test_print_space:
    ld  de,spacestr ; addr. of " " string
    ld  bc,1
    call    print
    ret
test_print_newline:
    ld  de,newlinestr ; addr. of "\n" string
    ld  bc,1
    call    print
    ret
test_print_error:
    ld  de,errorstr         ; addr. of "Error!" string
    ld  bc,Xerrorstr-errorstr
    call    print           ; print our string
    ret
test_print_error_with_num:  ; BC has a number to print
    call    test_print_num_and_space
    ld  de,errorstr         ; addr. of "Error!" string
    ld  bc,Xerrorstr-errorstr
    call    print           ; print our string
    ret

test_print_testing_header_with_num:
    call    test_print_num_and_space
    ld  de,testingStr         ; addr. of "Error!" string
    ld  bc,XtestingStr-testingStr
    call    print           ; print our string
    ret

test_print_test_passed:
    ld  de,testPassedStr
    ld  bc,XtestPassedStr - testPassedStr
    call    print
    call    test_print_newline
    ret

test_print_all_test_passed:
    ld  de,allTestPassedStr
    ld  bc,XallTestPassedStr - allTestPassedStr
    call    print
    call    test_print_newline
    ret
