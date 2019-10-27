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
-- Title       : tictactoe_top
-- Design      : tictactoe
-- Author      : J. Tetteroo
-- Year		   : 2019
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- Description : Top entity for tictactoe
--
-------------------------------------------------------------------------------

library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tictactoe_global.all;

entity tictactoe_top is
    Port ( clk : in  STD_LOGIC;
           reset : in STD_LOGIC;
           GLED1 : out  STD_LOGIC;
           GLED2 : out  STD_LOGIC;
           GLED3 : out  STD_LOGIC;
           GLED4 : out  STD_LOGIC;
           GLED5 : out  STD_LOGIC;
           GLED6 : out  STD_LOGIC;
           GLED7 : out  STD_LOGIC;
           GLED8 : out  STD_LOGIC;
           GLED9 : out  STD_LOGIC;
           RLED1 : out  STD_LOGIC;
           RLED2 : out  STD_LOGIC;
           RLED3 : out  STD_LOGIC;
           RLED4 : out  STD_LOGIC;
           RLED5 : out  STD_LOGIC;
           RLED6 : out  STD_LOGIC;
           RLED7 : out  STD_LOGIC;
           RLED8 : out  STD_LOGIC;
           RLED9 : out  STD_LOGIC;
           BUT1  : in   STD_LOGIC;
           BUT2  : in   STD_LOGIC;
           BUT3  : in   STD_LOGIC;
           BUT4  : in   STD_LOGIC;
           BUT5  : in   STD_LOGIC;
           BUT6  : in   STD_LOGIC;
           BUT7  : in   STD_LOGIC;
           BUT8  : in   STD_LOGIC;
           BUT9  : in   STD_LOGIC;
           SW1   : in   STD_LOGIC;
           LEDP1_G : out  STD_LOGIC;
           LEDP2_R : out STD_LOGIC;
		   BOARDLED_0 : out STD_LOGIC;
		   BOARDLED_1 : out STD_LOGIC;
		   BOARDLED_2 : out STD_LOGIC;
		   BOARDLED_3 : out STD_LOGIC;
		   BOARDLED_4 : out STD_LOGIC;
		   BOARDLED_5 : out STD_LOGIC;
		   BOARDLED_6 : out STD_LOGIC;
		   BOARDLED_7 : out STD_LOGIC);
end tictactoe_top;

architecture behavioral of tictactoe_top is

component tictactoe_statemachine is
	port (clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		input : in tictactoe_state_in_type;
		output : out tictactoe_state_out_type;
		debug_load : in std_logic;
		debug_in : in stm_reg_type;
		debug_out : out stm_reg_type);
end component;


signal buttons : std_logic_vector(8 downto 0) := (others => '0');
signal p1_status : std_logic := '0';
signal p2_status : std_logic := '0';
signal switch : std_logic := '0';
signal board_p1 : std_logic_vector(8 downto 0) := (others => '0');
signal board_p2 : std_logic_vector(8 downto 0) := (others => '0');

signal input : tictactoe_state_in_type;
signal output : tictactoe_state_out_type;
signal debug : stm_reg_type;

begin	  
	
	ttt_inst : tictactoe_statemachine
		port map (
			clk => clk,
			reset => reset,
			input => input,
			output => output,
			debug_load => '0',
			debug_in => debug,
			debug_out => open
		);

GLED1 <= output.board_p1(8);
GLED2 <= output.board_p1(7);
GLED3 <= output.board_p1(6);
GLED4 <= output.board_p1(5);
GLED5 <= output.board_p1(4);
GLED6 <= output.board_p1(3);
GLED7 <= output.board_p1(2);
GLED8 <= output.board_p1(1);
GLED9 <= output.board_p1(0);

RLED1 <= output.board_p2(8);
RLED2 <= output.board_p2(7);
RLED3 <= output.board_p2(6);
RLED4 <= output.board_p2(5);
RLED5 <= output.board_p2(4);
RLED6 <= output.board_p2(3);
RLED7 <= output.board_p2(2);
RLED8 <= output.board_p2(1);
RLED9 <= output.board_p2(0);

input.switch_in <= SW1;	

LEDP1_G <= output.led_p1;
LEDP2_R <= output.led_p2;

input.button_in(8) <= BUT1;
input.button_in(7) <= BUT2;
input.button_in(6) <= BUT3;
input.button_in(5) <= BUT4;
input.button_in(4) <= BUT5;
input.button_in(3) <= BUT6;
input.button_in(2) <= BUT7;
input.button_in(1) <= BUT8;
input.button_in(0) <= BUT9;

BOARDLED_0 <= '0';
BOARDLED_1 <= '0';
BOARDLED_2 <= '0';
BOARDLED_3 <= '0';
BOARDLED_4 <= '0';
BOARDLED_5 <= '0';
BOARDLED_6 <= '0';
BOARDLED_7 <= '0';


end behavioral;

