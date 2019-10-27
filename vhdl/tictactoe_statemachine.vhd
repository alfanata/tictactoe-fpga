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
-- Title       : tictactoe_statemachine
-- Design      : tictactoe
-- Author      : J. Tetteroo
-- Year		   : 2019
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- Description : tictactoe statemachine
--
-------------------------------------------------------------------------------

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tictactoe_global.all;

-- P1 : green, human
-- P2 : red, AI/human


entity tictactoe_statemachine is
	port (clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		input : in tictactoe_state_in_type;
		output : out tictactoe_state_out_type;
		debug_load : in std_logic;
		debug_in : in stm_reg_type;
		debug_out : out stm_reg_type);
end tictactoe_statemachine;

architecture Behavioural of tictactoe_statemachine is

-- Change these to low numbers when running testbench, but don't forget to change them back for synthesis
constant MAX_DELAY : natural := 12000000; -- process cycles	based on 12 Mhz clock (pin J3)
constant BLINK_DELAY : natural := 6000000;
constant TRANSITION_DELAY : natural := 5;

constant MAX_MOVES : natural := 4519; -- maximum number of possible board configurations that need to be considered
											  
component tictactoe_ram is
port (
    input : in tictactoe_ram_input_type;
    output : out tictactoe_ram_output_type;
    
    clk : in std_logic;
    reset : in std_logic
    );
end component;	
	
	signal ram_input : tictactoe_ram_input_type;
	signal ram_output : tictactoe_ram_output_type;
	signal ram_reset : std_logic := '1';  
	
	signal win_p1, win_p2 : std_logic := '0';
	
	signal r, rin : stm_reg_type := (state => st_reset, 
									board_p1 => "000000000",
									board_p2 => "000000000",
									win_p1 => '0',
									win_p2 => '0',
									search_idx => 0,
									delay => 0);
	
	-- Check if board is in winning state 
    function check_win(board : std_logic_vector(8 downto 0) := "000000000"
						) return std_logic is
		variable return_val : std_logic;
    begin
		if (board AND "111000000") = "111000000" then
			return '1';
		elsif (board AND "000111000") = "000111000" then
			return '1';
		elsif (board AND "000000111") = "000000111" then
			return '1';
		elsif (board AND "100010001") = "100010001" then
			return '1';
		elsif (board AND "001010100") = "001010100" then
			return '1';
		elsif (board AND "100100100") = "100100100" then
			return '1';
		elsif (board AND "010010010") = "010010010" then
			return '1';
		elsif (board AND "001001001") = "001001001" then
			return '1';
		else
			return '0';
		end if;
		return '0';
    end function;
	
    

begin
	
	ram_inst: tictactoe_ram
	port map (
		input => ram_input,
		output => ram_output,
		clk => clk,
		reset => ram_reset
	);
	
	
	combinatorial : process(input, ram_output, reset, r)
		variable v : stm_reg_type;
		variable b1, b2 : std_logic_vector(8 downto 0);
	begin
		v := r;
		case (r.state) is
			when st_move1 =>
				case (input.button_in) is
					when "100000000"|"010000000"|"001000000"|"000100000"|"000010000"|"000001000"|"000000100"|"000000010"|"000000001" =>	-- Only one button should be active
						b1 := r.board_p1 AND input.button_in;
						b2 := r.board_p2 AND input.button_in;
						if (b1 /= "000000000" OR b2 /= "000000000") then	
							v.state := st_move1;
						else
							v.board_p1 := r.board_p1 OR input.button_in;
							v.delay := MAX_DELAY;
							v.state := st_delay1;
						end if;
					when others =>
						v.state := st_move1;
				end case;
            when st_reset_idx => -- Reset search index
            	v.state := st_move2_loop;
                v.search_idx := 0;
			when st_move2_loop => -- Try to find the best AI move
				if r.search_idx > MAX_MOVES then
					v.state := st_fail;
				elsif ram_output.done = '1' then
					if ram_output.match = '1' then
						v.board_p2(v.board_p2'length - 1 - to_integer(unsigned(ram_output.output_move))) := '1';
						v.state := st_delay2;
					else
						v.state := st_inc_idx;
					end if;
				else
					v.state := st_move2_loop;
				end if;
            when st_inc_idx => -- No matching board found, increment index
				v.search_idx := r.search_idx + 1;
            	v.state := st_move2_loop;
			when st_move2_hum =>	-- P2 is a human
				case (input.button_in) is
					when "100000000"|"010000000"|"001000000"|"000100000"|"000010000"|"000001000"|"000000100"|"000000010"|"000000001" =>
						b1 := r.board_p1 AND input.button_in;
						b2 := r.board_p2 AND input.button_in;
						if (b1 /= "000000000" OR b2 /= "000000000") then
							v.state := st_move2_hum;
						else
							v.board_p2 := r.board_p2 OR input.button_in;
							v.delay := MAX_DELAY;
							v.state := st_delay2_hum;
						end if;
					when others =>
						v.state := st_move2_hum;
				end case;
			when st_delay1 =>
				if (r.delay = 0) then
					if (input.button_in = "000000000") then	-- Check if button is let go		
						v.state := st_check1;
					else
						v.state := st_delay1;
					end if;
				else
				    v.delay := r.delay - 1;
					v.state := st_delay1;
                end if;
			when st_delay2 => 
				if (r.delay = 0) then
                	v.state := st_check2;
                else
                	v.delay := r.delay - 1;
                    v.state := st_delay2;
                end if;
            when st_delay2_hum =>
				if (r.delay = 0) then 
					if (input.button_in = "000000000") then -- Check if button is let go
                		v.state := st_check2;
					else
						v.state := st_delay2_hum;
					end if;
                else
                	v.delay := r.delay - 1;
                    v.state := st_delay2_hum;
                end if;
			when st_check1 =>
				if check_win(r.board_p1) = '1' then	-- P1 win
					v.win_p1 := '1';
					v.delay := TRANSITION_DELAY;
					v.state := st_delay_done;
				elsif ((r.board_p1 OR r.board_p2) = "111111111") then -- Tie
					v.delay := TRANSITION_DELAY;
					v.state := st_delay_done;
				else
					if input.switch_in = '0' then
						v.state := st_reset_idx; 	-- AI player
					else
						v.state := st_move2_hum;  	-- Human player
					end if;
				end if;
			when st_check2 =>
				if check_win(r.board_p2) = '1' then	-- P2 win
					v.win_p2 := '1';
					v.delay := BLINK_DELAY;
					v.state := st_delay_done;
				elsif ((r.board_p1 OR r.board_p2) = "111111111") then -- Tie
					v.delay := TRANSITION_DELAY;
					v.state := st_delay_done;
				else
					v.state := st_move1;	
				end if;
			when st_delay_done =>
				if (r.delay = 0) then
					v.delay := TRANSITION_DELAY;
                	if (r.win_p1 = '1') then
						v.state := st_p1win;
					elsif (r.win_p2 = '1') then
						v.state := st_p2win;
					else
						v.state := st_tie;
					end if;
                else
                	v.delay := r.delay - 1;
                    v.state := st_delay_done;
                end if;					
			when st_p1win =>
				if (r.delay = 0) then	   
					v.delay := BLINK_DELAY;
					v.state := st_p1_blink;
				else
					v.delay := r.delay - 1;
					v.state := st_p1win;
				end if;
			when st_p2win =>
				if (r.delay = 0) then	   
					v.delay := BLINK_DELAY;
					v.state := st_p2_blink;
				else
					v.delay := r.delay - 1;
					v.state := st_p2win;
				end if;
			when st_tie =>
				if (r.delay = 0) then	   
					v.delay := BLINK_DELAY;
					v.state := st_tie_blink;
				else
					v.delay := r.delay - 1;
					v.state := st_tie;
				end if;
			when st_p1_blink =>
				if (r.delay = 0) then	   
					v.delay := BLINK_DELAY;
					v.state := st_p1win;
				else
					v.delay := r.delay - 1;
					v.state := st_p1_blink;
				end if;
			when st_p2_blink =>
				if (r.delay = 0) then	   
					v.delay := BLINK_DELAY;
					v.state := st_p2win;
				else
					v.delay := r.delay - 1;
					v.state := st_p2_blink;
				end if;
			when st_tie_blink =>
				if (r.delay = 0) then	   
					v.delay := BLINK_DELAY;
					v.state := st_tie;
				else
					v.delay := r.delay - 1;
					v.state := st_tie_blink;
				end if;
			when st_reset => -- Settle everything to prevent glitches
				v.win_p1 := '0';
				v.win_p2 := '0';
				v.board_p1 := "000000000";
				v.board_p2 := "000000000";
				if (r.delay = 0) then
					v.state := st_move1;
				else
					v.delay := r.delay - 1;
				end if;
			when st_fail =>	-- Should never reach
				v.board_p1 := "110000011";
				v.board_p2 := "110000011";
				v.state := st_fail;
			when others => v.state := st_move1;
		end case;
        
		if (reset = '1') then
			v.delay := 0;
			v.win_p1 := '0';
			v.win_p2 := '0';
			v.board_p1 := "000000000";
			v.board_p2 := "000000000"; 
			v.state := st_reset;
		end if;
        
		output.board_p1 <= r.board_p1 when (r.state /= st_p1_blink AND r.state /= st_p2_blink AND r.state /= st_tie_blink AND r.state /= st_p2win) else "000000000";
		output.board_p2 <= r.board_p2 when (r.state /= st_p1_blink AND r.state /= st_p2_blink AND r.state /= st_tie_blink AND r.state /= st_p1win) else "000000000";													   
		output.led_p1 <= '1' when (r.state = st_move1 OR r.state = st_p1win) else '0';
		output.led_p2 <= '1' when (r.state = st_move2_hum OR r.state = st_delay1 OR r.state = st_move2_loop OR r.state = st_reset_idx OR r.state = st_inc_idx OR r.state = st_delay2 OR r.state = st_p2win) else '0';
		
		ram_input.perm_idx <= v.search_idx;
        ram_input.board_p1 <= r.board_p1;
        ram_input.board_p2 <= r.board_p2;
		
		ram_reset <= '0' when (r.state = st_move2_loop) else '1';
		
		if debug_load = '1' then
			rin <= debug_in;
		else
			rin <= v;
		end if;
	end process;
	
	synchronous : process(clk)
	begin
		if clk'event and clk = '1' then
			r <= rin;
		end if;
	end process;
	debug_out <= r;
end architecture;
		
		
	


	
	