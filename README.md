# cse_0175_joalch

Test Bench:

1. Compile: `make build_test`

2. Files:

  1. keyboardTest.asm: Press SZXC or neighboring keys to display a direction word (North, Southwest, etc.); press A to display "Jump"; press direction keys and D for "Punch [direction]". Conflicting direction keys (say, up and down, or more than two direction keys), when pressed, shall not be recorded. If it does, and "Error!" will be shown.

  2. physicsTest.asm: Prints register values for the physics state machines for both players. For each player, display value: X-axis speed, Y-axis speed, air state.

3. Keyboard control:

  P1: SZXC for directions, A for jump, D for punch
  
  P2: 9IOP for directions, 8 for jump, 0 for punch 
