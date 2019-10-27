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
-- Title       : tictactoe_top_tb
-- Design      : tictactoe
-- Author      : J. Tetteroo
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Description : Testbench for the tictactoe_top entity
--
-------------------------------------------------------------------------------

library IEEE;
library work;
use IEEE.STD_LOGIC_1164.all;
use work.tictactoe_global.all;


entity tictactoe_top_tb is
end tictactoe_top_tb;

--}} End of automatically maintained section

architecture tictactoe_top_tb of tictactoe_top_tb is

	constant DELTA : time := 100 ns;
	constant MAX_DELAY : natural := 100;

    signal sim_finished : boolean := false;

    signal clk : std_logic;
    signal reset : std_logic;
	signal gleds : std_logic_vector(8 downto 0);
	signal rleds : std_logic_vector(8 downto 0);
	signal status_p1, status_p2 : std_logic;
	signal buttons : std_logic_vector(8 downto 0);
	signal switch : std_logic;

begin
	ttt_top: entity tictactoe_top
    	port map ( clk => clk,
           reset => reset,
           GLED1  =>	gleds(8),
           GLED2  =>	gleds(7),
           GLED3  =>	gleds(6),
           GLED4  =>	gleds(5),
           GLED5  =>	gleds(4),
           GLED6  =>	gleds(3),
           GLED7  =>	gleds(2),
           GLED8  =>	gleds(1),
           GLED9  =>	gleds(0),
           RLED1  =>	rleds(8),
           RLED2  =>	rleds(7),
           RLED3  =>	rleds(6),
           RLED4  =>	rleds(5),
           RLED5  =>	rleds(4),
           RLED6  =>	rleds(3),
           RLED7  =>	rleds(2),
           RLED8  =>	rleds(1),
           RLED9  =>	rleds(0),
           BUT1   => buttons(8),
           BUT2   => buttons(7),
           BUT3   => buttons(6),
           BUT4   => buttons(5),
           BUT5   => buttons(4),
           BUT6   => buttons(3),
           BUT7   => buttons(2),
           BUT8   => buttons(1),
           BUT9   => buttons(0),
           SW1    => switch,
           LEDP1_G => status_p1,
           LEDP2_R => status_p2,
		   BOARDLED_0 => open,
		   BOARDLED_1 => open,
		   BOARDLED_2 => open,
		   BOARDLED_3 => open,
		   BOARDLED_4 => open,
		   BOARDLED_5 => open,
		   BOARDLED_6 => open,
		   BOARDLED_7 => open);	

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
		
	begin
		

		
		report "#### START TESTS ####";	

		buttons <= "000000000";
		switch <= '0';
		
		-- Test all state transitions
		
		-- Reset to st_move1
		sync_reset;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		switch <= '1'; -- AI player
		
		-- Play game
		-- Move 1
		report "Move 1"; 
		buttons <= "000010000";	-- Press middle button
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		buttons <= "000000000";
		
		assert gleds = "000010000" report "Failed game move 1a" severity error;
		assert rleds = "000000000" report "Failed game move 1b" severity error;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until status_p1 = '1';
		
		assert rleds = "100000000" report "Failed game move 1c" severity error; 
		
		
		-- Move 2 
		report "Move 2";
		buttons <= "010000000"; -- Press top middle button
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		buttons <= "000000000";
		
		assert gleds = "010010000" report "Failed game move 2a" severity error;
		assert rleds = "100000000" report "Failed game move 2b" severity error;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until status_p1 = '1';	
		
		assert rleds = "100000010" report "Failed game move 2c" severity error;
		
		-- Move 3
		report "Move 3";
		buttons <= "000000001";	-- Bottom right button
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		buttons <= "000000000";	
		
		assert gleds = "010010001" report "Failed game move 3a" severity error;
		assert rleds = "100000010" report "Failed game move 3b" severity error;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until status_p1 = '1';

		assert rleds = "101000010" report "Failed game move 3c" severity error;	 
		
		-- Move 4 
		report "Move 4";
		buttons <= "000100000"; -- Left middle button
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		buttons <= "000000000";
		
		assert gleds = "010110001" report "Failed game move 4a" severity error;
		assert rleds = "101000010" report "Failed game move 4b" severity error;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until status_p1 = '1';
		
		assert rleds = "101001010" report "Failed game move 4c" severity error;

		
		report "#### TESTS COMPLETED ####";
        sim_finished <= true;
        wait;	
	end process simulation;

end tictactoe_top_tb;
