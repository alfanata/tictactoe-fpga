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

-------------------------------------------------------------------------------
--
-- Title       : tictactoe_game_tb
-- Design      : tictactoe
-- Author      : J. Tetteroo
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Description : Testbench for a full game scenario on the tictactoe_statemachine entity
--
-------------------------------------------------------------------------------


library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tictactoe_global.all;
use work.tictactoe_ram;

entity tictactoe_game_tb is
end tictactoe_game_tb;


architecture tictactoe_game_tb of tictactoe_game_tb is

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
	
	-- Simulation
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
		
		-- Reset to st_move1
		sync_reset;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert stm_debug_out.state = st_move1 report "Failed transition reset -> st_move1" severity error;
		
		stm_input.switch_in <= '1'; -- AI player
		
		-- Play game 
		
		-- Move 1
		report "Move 1";
		stm_input.button_in <= "000010000";	-- Press middle button
		wait until stm_debug_out.state = st_delay1;
		stm_input.button_in <= "000000000";
		wait until stm_debug_out.state = st_delay2;
		
		wait until stm_debug_out.state = st_move1;
		assert stm_debug_out.board_p1 = "000010000" report "Failed game move 1a" severity error;
		assert stm_debug_out.board_p2 = "100000000" report "Failed game move 1b" severity error;
		
		-- Move 2
		report "Move 2";
		stm_input.button_in <= "010000000"; -- Press top middle button
		wait until stm_debug_out.state = st_delay1;
		stm_input.button_in <= "000000000";
		wait until stm_debug_out.state = st_delay2;
		
		wait until stm_debug_out.state = st_move1;
		assert stm_debug_out.board_p1 = "010010000" report "Failed game move 2a" severity error;
		assert stm_debug_out.board_p2 = "100000010" report "Failed game move 2b" severity error;
		
		-- Move 3
		report "Move 3";
		stm_input.button_in <= "000000001";	-- Bottom right button
		wait until stm_debug_out.state = st_delay1;
		stm_input.button_in <= "000000000";
		wait until stm_debug_out.state = st_delay2;
		
		wait until stm_debug_out.state = st_move1;
		assert stm_debug_out.board_p1 = "010010001" report "Failed game move 3a" severity error;
		assert stm_debug_out.board_p2 = "101000010" report "Failed game move 3b" severity error;
		
		-- Move 4 
		report "Move 4";
		stm_input.button_in <= "000100000"; -- Left middle button
		wait until stm_debug_out.state = st_delay1;
		stm_input.button_in <= "000000000";
		wait until stm_debug_out.state = st_delay2;
		
		wait until stm_debug_out.state = st_move1;
		assert stm_debug_out.board_p1 = "010110001" report "Failed game move 4a" severity error;
		assert stm_debug_out.board_p2 = "101001010" report "Failed game move 4b" severity error;
		
		-- Move 5
		report "Move 5";
		stm_input.button_in <= "000000100"; -- Left bottom button
		wait until stm_debug_out.state = st_delay1;
		stm_input.button_in <= "000000000";
		wait until stm_debug_out.state = st_check1;	-- No more moves for player 2
		
		wait until stm_debug_out.state = st_tie;
		assert stm_debug_out.board_p1 = "010110101" report "Failed game move 5a" severity error;
		assert stm_debug_out.board_p2 = "101001010" report "Failed game move 5b" severity error;
		
		report "Game finished";
		
		report "#### TESTS COMPLETED ####";
        sim_finished <= true;
        wait;	
	end process simulation;

end tictactoe_game_tb;
