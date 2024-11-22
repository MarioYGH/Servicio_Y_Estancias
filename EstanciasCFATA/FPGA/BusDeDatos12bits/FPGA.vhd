library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ImageReceiver is
    Port (
        data_bus : in STD_LOGIC_VECTOR (15 downto 0);  -- Bus de datos de 16 bits
        control : in STD_LOGIC;                        -- Señal de control
        clk : in STD_LOGIC;                            -- Reloj
        image_data : out STD_LOGIC_VECTOR (15 downto 0) -- Salida de datos de imagen
    );
end ImageReceiver;

architecture Behavioral of ImageReceiver is
    signal buffer : STD_LOGIC_VECTOR (15 downto 0);
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if control = '1' then
                buffer <= data_bus;  -- Leer datos cuando la señal de control está activa
            end if;
        end if;
    end process;

    image_data <= buffer;  -- Salida de los datos recibidos
end Behavioral;
