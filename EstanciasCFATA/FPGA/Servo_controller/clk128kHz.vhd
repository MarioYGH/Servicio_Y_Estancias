library IEEE;
use IEEE.std_logic_1164.ALL;

entity clk128kHz is
    Port (
        clk : in std_logic; -- Señal de 50MHz del FPGA
        reset : in std_logic; -- Reset
        clk_128khz : out std_logic -- Señal de reloj a 128kHz
    );
end clk128kHz;

architecture behavioral of clk128kHz is
    signal temporal : std_logic := '0'; -- Almacena la salida temporal del divisor de frecuencia
    signal counter : integer range 0 to 360 := 0; -- Contador para dividir la frecuencia
begin
    process (reset, clk)
    begin
        if (reset = '1') then
            temporal <= '0';
            counter <= 0;
        elsif rising_edge(clk) then
            if (counter = 195) then
                temporal <= not temporal;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    clk_128khz <= temporal; -- La señal de salida (clk_128khz) se asigna a la señal temporal
end behavioral;
