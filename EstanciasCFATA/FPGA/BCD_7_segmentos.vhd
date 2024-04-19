--Codificador decimal binario a 7 segmentos, cada posicion del vector S, representa un led del display
--Como es downto se el digito izquierdo es el más alto, por lo que s(7) es a y s(1) es g
lirary IEEE;
use IEEE.std_logic_1164.all;

entity BCD_7_segmentos is 
port(
	B : in  std_logic_vector(3 downto 0); --Entrada BCD
	S : out std_logic_vector(7 downto 1) --Salida 7 segmentos 
	); 
end BCD_7_segmentos;

architecture Decodificador of BCD_7_segmentos is 
	begin 
		process(B)
			begin 
				case B is
					when "0000" => S <= "1111110"; --Conversion del codigo 
					when "0001" => S <= "0110000";
					when "0010" => S <= "1101101";
					when "0011" => S <= "1111001";
					when "0100" => S <= "0110011";
					when "0101" => S <= "1011011";
					when "0110" => S <= "1011111";
					when "0111" => S <= "1110000";
					when "1000" => S <= "1111111";
					when "1001" => S <= "1110011";
					when others => S <= "-------"; --Dont care
				end case;
			end process;
		end Decodificador; 
