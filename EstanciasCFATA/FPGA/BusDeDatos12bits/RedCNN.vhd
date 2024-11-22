library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CNN_Module is
    Port (
        clk : in STD_LOGIC;                      -- Reloj del sistema
        reset : in STD_LOGIC;                    -- Señal de reset
        input_image : in STD_LOGIC_VECTOR(7 downto 0); -- Imagen de entrada en formato de 8 bits
        kernel : in STD_LOGIC_VECTOR(8*8-1 downto 0); -- Kernel 3x3 (8 bits por cada peso)
        output_feature : out STD_LOGIC_VECTOR(7 downto 0) -- Salida de la característica
    );
end CNN_Module;

architecture Behavioral of CNN_Module is
    signal conv_result : STD_LOGIC_VECTOR(7 downto 0);
    signal pool_result : STD_LOGIC_VECTOR(7 downto 0);
begin

    -- Convolución 3x3
    Convolution_Layer: process(clk, reset)
    begin
        if reset = '1' then
            conv_result <= (others => '0');
        elsif rising_edge(clk) then
            -- Operaciones de convolución aquí (simplificado)
            conv_result <= input_image AND kernel(7 downto 0); -- Ejemplo básico
        end if;
    end process;

    -- Pooling Layer
    Pooling_Layer: process(clk, reset)
    begin
        if reset = '1' then
            pool_result <= (others => '0');
        elsif rising_edge(clk) then
            -- Max pooling o average pooling simplificado
            pool_result <= conv_result; -- Sustitúyase por lógica de pooling real
        end if;
    end process;

    -- Resultado de la característica de salida
    output_feature <= pool_result;

end Behavioral;
