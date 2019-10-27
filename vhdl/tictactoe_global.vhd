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

-- Global data structures

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tictactoe_global is
	
	-- statemachine types
	type tictactoe_state_in_type is record
		button_in : std_logic_vector(8 downto 0);
		switch_in : std_logic;
	end record;
	
	type tictactoe_state_out_type is record
		board_p1 : std_logic_vector(8 downto 0);
		board_p2 : std_logic_vector(8 downto 0);
		led_p1 : std_logic;
		led_p2 : std_logic;
	end record;
	
	type stm_state_type is (st_move1, st_reset, st_reset_idx, st_move2_loop, st_inc_idx, st_move2_hum, st_delay1, st_delay2, st_delay2_hum, st_check1, st_check2, st_delay_done, st_p1win, st_p2win, st_tie, st_p1_blink, st_p2_blink, st_tie_blink, st_fail);
	
	type stm_reg_type is record
		state : stm_state_type;
		
		board_p1 : std_logic_vector(8 downto 0);
		board_p2 : std_logic_vector(8 downto 0);
		
		win_p1 : std_logic;
		win_p2 : std_logic;
		
        search_idx : natural range 0 to 5000;
		delay : natural range 0 to 12000000;
	end record;
    
	-- ram types
    type tictactoe_ram_input_type is record
        perm_idx : natural range 0 to 4836;
        board_p1 : std_logic_vector(8 downto 0);
        board_p2 : std_logic_vector(8 downto 0);
    end record;
    
    type tictactoe_ram_output_type is record
        match : std_logic;
        done : std_logic;
        output_move : std_logic_vector(3 downto 0);
    end record;
    
end package;
