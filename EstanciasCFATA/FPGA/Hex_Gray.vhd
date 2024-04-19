--Codificador hexadecimal a Gray, es cuando solo puedes cambiar de un bit en un bit 
--De un valor en código Gray al siguiente solo hay un cambio de un bit.
lirary IEEE;
use IEEE.std_logic_1164.all;

entity Hex_Gray is 
port(
	H : in  std_logic_vector(3 downto 0); --Entrada Hexadecimal
	G : out std_logic_vector(3 downto 0) --Salida Gray
	); 
end Hex_Gray; 

architecture Decodificador of Hex_Gray is 
	begin 
		process(H)
			begin 
				case H is
					when "0000" => G <= "0000"; --Conversion del codigo 
					when "0001" => G <= "0001";
					when "0010" => G <= "0011";
					when "0011" => G <= "0010";
					when "0100" => G <= "0110";
					when "0101" => G <= "0111";
					when "0110" => G <= "0101";
					when "0111" => G <= "0100";
					when "1000" => G <= "1100";
					when "1001" => G <= "1101";
					when "1010" => G <= "1111";
					when "1011" => G <= "1110";
					when "1100" => G <= "1010";
					when "1101" => G <= "1011";
					when "1110" => G <= "1001";
					when others => G <= "1000"; 
				end case;
			end process;
		end Decodificador; 
