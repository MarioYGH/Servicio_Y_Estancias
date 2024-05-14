library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity senal is 
port(clk: in std_logic;
	  D: in integer;
	  s: out std_logic);
end entity;

architecture arqsenal of senal is
signal cuenta: integer range 0 to 1000 :=0;
begin 
	process (clk)
	begin 
		if rising_edge (clk) then 
			if(cuenta=1000) then
				cuenta<=0;
			else
				cuenta<=cuenta+1;
			end if;
			if cuneta < D then 
				S <= '1';
			else 
				S <= '0';
			end if;
		end if;
		end process;
end architecture;
