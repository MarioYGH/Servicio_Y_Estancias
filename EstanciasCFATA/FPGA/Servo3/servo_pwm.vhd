library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity servo_pwm is
    Port (
        clk_128khz : in std_logic; --reloj 128 kHz
        reset : in std_logic;  --reset
        posicion : in std_logic_vector(7 downto 0); --vector de 8 posiciones para mayor rango
        servo : out std_logic --Señal pwm de salida
    );
end servo_pwm;

architecture simple of servo_pwm is 
    signal cnt : unsigned(12 downto 0);
    signal pwmi : unsigned(7 downto 0); -- Ajustado a 8 bits
begin 
    -- Proceso del contador
    counter : process (reset, clk_128khz)
    begin 
        if (reset = '1') then 
            cnt <= (others => '0');
        elsif rising_edge(clk_128khz) then 
            if(cnt = 2560 ) then 
                cnt <= (others => '0');
            else 
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    -- Señal PWM para el servomotor
    pwmi <= unsigned(posicion) + 68; -- Ajuste de posición para PWM

    servo <= '1' when (cnt < pwmi) else '0';
end simple;
