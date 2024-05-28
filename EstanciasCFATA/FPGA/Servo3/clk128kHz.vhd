library IEEE;
use IEEE.std_logic_1164.ALL;

entity clk128kHz is
    Port (
        clk : in std_logic; --señal de 50MHz del FPGA
        reset : in std_logic; --Reset
        clk_128khz : out std_logic --Señal de reloj
    );
end clk128kHz;

architecture simple of clk128kHz is 
    signal temporal : std_logic; --Almacena la salida temporal del divisor de frecuencia.
    signal counter : integer range 0 to 360 := 0; -- Se utiliza como contador para dividir la frecuencia.
begin 
    freq_divider : process (reset, clk)
    begin 
        if (reset = '1') then
            temporal <= '0';
            counter <= 0;
        elsif rising_edge(clk) then 
            if (counter = 195) then --Contador que va a contar 195 pulsos
                temporal <= NOT(temporal); --Guardara y negara esta señal 
                counter <= 0;
            else 
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_128khz <= temporal; -- La señal de salida (clk128Khz) se asigna a la señal temporal
end simple;
