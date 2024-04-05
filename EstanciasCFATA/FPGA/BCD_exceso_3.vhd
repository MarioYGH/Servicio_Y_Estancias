--Codificador decimal binario a Exceso3, que es cuando al número que tengo en binario le sumo 3
library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity BCD_exceso_3 is 
port(
	B : in  std_logic_vector(3 downto 0); --Entrada BCD
	E : out std_logic_vector(3 downto 0); --Salida exceso 3
	);
--Descripción circuito 

architecture Decodificador of BCD_exceso_3 is 
	begin 
		process(B) --Declaración del proceso 
			begin 
				case B is --Declaracion del case
					when "0000" => E <= "0011"; --Conversion del codigo 
					when "0001" => E <= "0100";
					when "0010" => E <= "0101";
					when "0011" => E <= "0110";
					when "0100" => E <= "0111";
					when "0101" => E <= "1000";
					when "0110" => E <= "1001";
					when "0111" => E <= "1010";
					when "1000" => E <= "1011";
					when "1001" => E <= "1100";
					when others => E <= "----"; --Dont care
				end case;
			end process;
		end Decodificador; 
