--Codificador BCD a decimal 
lirary IEEE;
use IEEE.std_logic_1164.all;

entity BCD_decimal is 
port(
	B : in  std_logic_vector(3 downto 0); --Entrada BCD
	D : out std_logic_vector(9 downto 0); --Salidas decimales
	); 
end BCD_decimal; 

architecture Concurrente of BDC_decimal is 
	begin 
		process(B)
			begin
				D <= "0000000000"; --Valores por omision
				case B is
					when "0000" => D(0) <= '1'; -- Activar digito 0
					when "0001" => D(1) <= '1'; --                1
					when "0010" => D(2) <= '1'; 
					when "0011" => D(3) <= '1';
					when "0100" => D(4) <= '1';
					when "0101" => D(5) <= '1';
					when "0110" => D(6) <= '1';
					when "0111" => D(7) <= '1';
					when "1000" => D(8) <= '1';
					when "1001" => D(9) <= '1'; --                9   
					when others => null; --Mantener valores por omision
				end case;
			end process;
		end Concurrente; 
