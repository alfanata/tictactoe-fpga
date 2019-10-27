-- MIT License
-- 
-- Copyright (c) 2019 J. Tetteroo
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- Testbench for tictactoe_statemachine entity

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tictactoe_global.all;
use work.tictactoe_ram;

entity tictactoe_statemachine_tb is
end tictactoe_statemachine_tb;


architecture test of tictactoe_statemachine_tb is

	constant DELTA : time := 100 ns;
	constant MAX_DELAY : natural := 100;


    signal sim_finished : boolean := false;

    signal clk : std_logic;
    signal reset : std_logic;
	
	signal stm_input : tictactoe_state_in_type;
	signal stm_output : tictactoe_state_out_type;
	signal stm_debug_out : stm_reg_type;
	signal stm_debug_in : stm_reg_type;
	signal stm_debug_load : std_logic;


begin
    -- statemachine instance
    tttstm : entity tictactoe_statemachine
        port map(clk => clk,
                reset => reset,
				input => stm_input,
				output => stm_output,
				debug_in => stm_debug_in,
				debug_load => stm_debug_load,
				debug_out => stm_debug_out);             
          
    -- Test
    clock : process
    begin
        if not sim_finished then
            clk <= '1';
            wait for DELTA / 2;
            clk <= '0';
            wait for DELTA / 2;
        else
            wait;
        end if;
    end process clock;
    
    
    simulation : process
		procedure sync_reset is
		begin
			wait until rising_edge(CLK);
			wait for DELTA / 4;
			reset <= '1';
			wait until rising_edge(CLK);
			wait for DELTA / 4;
			reset <= '0';
		end procedure sync_reset;
		
		variable buttons : std_logic_vector(8 downto 0);
	begin
		report "#### START TESTS ####";	

		stm_input.button_in <= "000000000";
		stm_input.switch_in <= '0';
		
		-- Test all state transitions
		
		-- Reset to st_move1
		sync_reset;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move1 report "Failed transition reset -> st_move1" severity error;

		-- Transition st_move1 -> st_delay1
		
		buttons := "100000000";
		for i in 0 to 8 loop
			stm_input.button_in <= "000000000";
			sync_reset;
			wait until rising_edge(clk);
			assert stm_debug_out.state = st_move1 report "Failed transition st_move1 -> st_delay1 (a) : " & integer'image(i) severity error;
			stm_input.button_in <= buttons;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			assert stm_debug_out.state = st_delay1 report "Failed transition st_move1 -> st_delay1 (b) : " & integer'image(i) severity error;
			buttons := '0' & buttons(8 downto 1);
		end loop;
		
		stm_input.button_in <= "000000000";
		sync_reset;			
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move1 report "Failed transition st_move1 -> st_move1 (a)" severity error;
		stm_input.button_in <= "100000001";
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move1 report "Failed transition st_move1 -> st_move1 (b)" severity error;
		
		-- Transition st_move1 -> st_move1
		sync_reset;
		stm_debug_in.state <= st_move1;
		stm_input.button_in <= "000000000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move1 report "Failed transition st_move1 -> st_move1 (a)" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_move1;
		stm_input.button_in <= "100010000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move1 report "Failed transition st_move1 -> st_move1 (b)" severity error;
		
		-- Transition st_delay1 -> st_delay1
		sync_reset;
		stm_debug_in.state <= st_delay1;
		stm_debug_in.delay <= 10;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay1 report "Failed transition st_delay1 -> st_delay1 (a)" severity error;
		assert stm_debug_out.delay = 9 report "Failed transition st_delay1 -> st_delay1 (b) : " & integer'image(stm_debug_out.delay) severity error;
			
		-- Transition st_delay1 -> st_check1 
		sync_reset;
		stm_debug_in.state <= st_delay1;
		stm_input.button_in <= "000000000";
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_check1 report "Failed transition st_delay1 -> st_check1" severity error;
		
		-- Transition st_check1 -> st_reset_idx
		sync_reset;
		stm_input.switch_in <= '1';
		stm_debug_in.state <= st_check1;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_reset_idx report "Failed transition st_check1 -> st_reset_idx" severity error;		
		
		-- Transition st_check1 -> st_move2_hum
		sync_reset;
		stm_input.switch_in <= '0';
		stm_debug_in.state <= st_check1;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move2_hum report "Failed transition st_check1 -> st_move2_hum" severity error;
		
		-- Transition st_reset_idx -> st_move2_loop
		sync_reset;
		stm_debug_in.state <= st_reset_idx;
		stm_debug_in.search_idx <= 10;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move2_loop report "Failed transition st_reset_idx -> st_move2_loop (a)" severity error;
		assert stm_debug_out.search_idx = 0 report "Failed transition st_reset_idx -> st_move2_loop (b)" severity error;
		
		-- Transition st_move2_loop -> st_inc_idx
		sync_reset;
		stm_debug_in.state <= st_move2_loop;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "000000000";
		stm_debug_in.search_idx <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		-- wait a few cycles for the RAM to return
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_inc_idx report "Failed transition st_move2_loop -> st_inc_idx" severity error;
		
		-- Transition st_inc_idx -> st_move2_loop
		sync_reset;
		stm_debug_in.state <= st_inc_idx;
		stm_debug_in.search_idx <= 10;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move2_loop report "Failed transition st_inc_idx -> st_move2_loop (a)" severity error;
		assert stm_debug_out.search_idx = 11 report "Failed transition st_inc_idx -> st_move2_loop (b)" severity error;
		
		-- Transition st_move2_loop -> st_delay2
		sync_reset;
		stm_debug_in.state <= st_move2_loop;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "000000000";
		stm_debug_in.search_idx <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		-- wait a few cycles for the RAM to return
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay2 report "Failed transition st_move2_loop -> st_delay2" severity error;
		
		-- Transition st_delay2 -> st_delay2
		sync_reset;
		stm_debug_in.state <= st_delay2;
		stm_debug_in.delay <= 10;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay2 report "Failed transition st_delay2 -> st_delay2 (a)" severity error;
		assert stm_debug_out.delay = 9 report "Failed transition st_delay2 -> st_delay2 (b) : " & integer'image(stm_debug_out.delay) severity error;
		
		-- Transition st_delay2 -> st_check2
		sync_reset;
		stm_debug_in.state <= st_delay2;
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_check2 report "Failed transition st_delay2 -> st_check2" severity error;
		
		-- Transition st_move2_hum -> st_move2_hum 
		sync_reset;
		stm_debug_in.state <= st_move2_hum;
		stm_input.button_in <= "000000000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move2_hum report "Failed transition st_move2_hum -> st_move2_hum (a)" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_move2_hum;
		stm_input.button_in <= "100010000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move2_hum report "Failed transition st_move2_hum -> st_move2_hum (b)" severity error;
		
		-- Transition st_move2_hum -> st_delay2_hum
		buttons := "100000000";
		for i in 0 to 8 loop
			sync_reset;
			stm_input.button_in <= "000000000";
			stm_debug_in.state <= st_move2_hum;
			stm_debug_load <= '1';
			wait until rising_edge(clk);
			stm_debug_load <= '0';
			wait until rising_edge(clk);
			assert stm_debug_out.state = st_move2_hum report "Failed transition st_move2_hum -> st_delay2_hum (a) : " & integer'image(i) severity error;
			stm_input.button_in <= buttons;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			assert stm_debug_out.state = st_delay2_hum report "Failed transition st_move2_hum -> st_delay2_hum (b) : " & integer'image(i) severity error;
			buttons := '0' & buttons(8 downto 1);
		end loop;
		
		-- Transition st_delay2_hum -> st_check2
		sync_reset;
		stm_debug_in.state <= st_delay2_hum;
		stm_input.button_in <= "000000000";
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_check2 report "Failed transition st_delay2_hum -> st_check2" severity error;
		
		-- Transition st_check2 -> st_delay_done
		
		-- P2 win conditions
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "111000000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "000111000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "000000111";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "100100100";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "010010010";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "001001001";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "100010001";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "001010100";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		-- Tie conditions
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "000000000";
		stm_debug_in.board_p2 <= "111111111";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_check2;
		stm_debug_in.board_p1 <= "111111111";
		stm_debug_in.board_p2 <= "000000000";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_check2 -> st_delay_done" severity error;
		
		-- Transition st_delay_done -> st_delay_done
		sync_reset;
		stm_debug_in.state <= st_delay_done;
		stm_debug_in.delay <= 10;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_delay_done report "Failed transition st_delay_done -> st_delay_done (a)" severity error;
		assert stm_debug_out.delay = 9 report "Failed transition st_delay_done -> st_delay_done (b) : " & integer'image(stm_debug_out.delay) severity error;
		
		-- Transition st_delay_done -> st_p1win
		sync_reset;
		stm_debug_in.state <= st_delay_done;
		stm_debug_in.win_p1 <= '1';
		stm_debug_in.win_p2 <= '0';
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p1win report "Failed transition st_delay_done -> st_p1win" severity error;
		
		-- Transition st_delay_done -> st_p2win
		sync_reset;
		stm_debug_in.state <= st_delay_done;
		stm_debug_in.win_p1 <= '0';
		stm_debug_in.win_p2 <= '1';
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p2win report "Failed transition st_delay_done -> st_p2win" severity error;
		
		-- Transition st_delay_done -> st_tie
		sync_reset;
		stm_debug_in.state <= st_delay_done;
		stm_debug_in.win_p1 <= '0';
		stm_debug_in.win_p2 <= '0';
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_tie report "Failed transition st_delay_done -> st_tie" severity error;
		
		-- Transition st_p1win -> st_p1win
		sync_reset;
		stm_debug_in.state <= st_p1win;
		stm_debug_in.delay <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p1win report "Failed transition st_p1win -> st_p1win" severity error;
		
		-- Transition st_p2win -> st_p2win
		sync_reset;
		stm_debug_in.state <= st_p2win;
		stm_debug_in.delay <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p2win report "Failed transition st_p2win -> st_p2win" severity error;
		
		-- Transition st_tie -> st_tie
		sync_reset;
		stm_debug_in.state <= st_tie;
		stm_debug_in.delay <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_tie report "Failed transition st_tie -> st_tie" severity error;
		
		-- Transition st_p1win -> st_p1_blink
		sync_reset;
		stm_debug_in.state <= st_p1win;
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p1_blink report "Failed transition st_p1win -> st_p1_blink" severity error;
		
		-- Transition st_p2win -> st_p2_blink
		sync_reset;
		stm_debug_in.state <= st_p2win;
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p2_blink report "Failed transition st_p2win -> st_p2_blink" severity error;
		
		-- Transition st_tie -> st_tie_blink
		sync_reset;
		stm_debug_in.state <= st_tie;
		stm_debug_in.delay <= 0;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_tie_blink report "Failed transition st_tie -> st_tie_blink" severity error;
		
		-- Transition st_p1_blink -> st_p1_blink
		sync_reset;
		stm_debug_in.state <= st_p1_blink;
		stm_debug_in.delay <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p1_blink report "Failed transition st_p1_blink -> st_p1_blink" severity error;
		
		-- Transition st_p2_blink -> st_p2_blink
		sync_reset;
		stm_debug_in.state <= st_p2_blink;
		stm_debug_in.delay <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_p2_blink report "Failed transition st_p2_blink -> st_p2_blink" severity error;
		
		-- Transition st_tie_blink -> st_tie_blink
		sync_reset;
		stm_debug_in.state <= st_tie_blink;
		stm_debug_in.delay <= 5;
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_tie_blink report "Failed transition st_p2_blink -> st_p2_blink" severity error;
		
		-- Test internal RAM unit
		
		sync_reset;
		stm_debug_in.state <= st_reset_idx;
		stm_debug_in.board_p1 <= "101000000";
		stm_debug_in.board_p2 <= "000010001";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until stm_debug_out.state = st_delay2;
		assert stm_debug_out.board_p2 = "010010001" report "Failed RAM test 1" severity error;
		
		sync_reset;
		stm_debug_in.state <= st_reset_idx;
		stm_debug_in.board_p1 <= "000010010";
		stm_debug_in.board_p2 <= "000000001";
		stm_debug_load <= '1';
		wait until rising_edge(clk);
		stm_debug_load <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until stm_debug_out.state = st_delay2;
		assert stm_debug_out.board_p2 = "010000001" report "Failed RAM test 2" severity error;
		
		-- Test full game scenarios
		
		-- Press multiple buttons for p1 and p2
		-- Wait till button released for p1 and p2
		-- Don't occupy already taken positions
		--  test game X X X vertical with AI
--		stm_debug_in.state <= st_reset_idx;
--		stm_debug_in.board_p1 <= "000010010";
--		stm_debug_in.board_p2 <= "000000001";
--		stm_debug_load <= '1';
--		wait until rising_edge(clk);
--		stm_debug_load <= '0';
--		wait until rising_edge(clk);
--		wait until rising_edge(clk);
--		wait until stm_debug_out.state = st_delay2;
--		assert stm_debug_out.board_p2 = "010000001" report "Failed RAM test 2" severity error;
		
		
		report "#### TESTS COMPLETED ####";
        sim_finished <= true;
        wait;	
	end process simulation;
	
end test;