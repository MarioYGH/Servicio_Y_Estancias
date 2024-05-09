--Este código llama los dos anteriores para poderlos correr en simultaneo
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity Servo_bien is
    Port (
        clk : in std_logic; -- Señal de 50MHz del FPGA
        reset : in std_logic; -- Reset
        servo : out std_logic -- Señal PWM de salida
    );
end Servo_bien;

architecture combined_architecture of Servo_bien is 

    -- Señal de reloj a 128kHz generada por el primer módulo
    signal clk_128khz : std_logic;
    -- Vector de 7 posiciones para la posición del servo
    signal posicion : std_logic_vector(6 downto 0);

begin 

    -- Instanciación del primer módulo para generar la señal de reloj a 128kHz
    clk_divider_inst : entity work.clk128kHz
        port map (
            clk => clk,
            reset => reset,
            clk_128khz => clk_128khz
        );

    -- Instanciación del segundo módulo para generar la señal PWM del servo
    servo_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion,
            servo => servo
        );

    -- Proceso para generar la posición del servo
    process (clk)
    begin 
        if rising_edge(clk) then 
            -- Aquí puedes incluir la lógica para cambiar la posición del servo
            -- basado en alguna condición o entrada externa.
            -- Por ahora, se puede establecer una posición fija para el ejemplo.
            posicion <= "0000101"; -- Por ejemplo, posición 5
        end if;
    end process;

end combined_architecture;
