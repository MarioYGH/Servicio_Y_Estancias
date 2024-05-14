library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity servo is 
port(clk: in std_logic;
	  sel: in std_logic_vector(4 downto 0);
	  pin: buffer integer);
end entity;

architecture arqservo of servo is
signal clkl, clk2: std_logic;
signal ct: integer;
begin 
	u0: entity work.divf(arqdivf) generic map(500) port map(clk, clkl);
	u1: entity work.divf(arqdivf) generic map(5000000) port map(clk, clk2);
	u2: entity work.cont(arqcont) port map(clk2, sel, ct);
	u3: entity work.senal(arqcont) port map(clkl, ct, pin);
end architecture;
