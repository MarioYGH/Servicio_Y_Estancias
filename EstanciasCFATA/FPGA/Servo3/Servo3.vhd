library IEEE;
use IEEE.std_logic_1164.ALL;

entity Servo3 is
    Port (
        clk : in std_logic;      -- Reloj principal del FPGA
        reset : in std_logic;    -- Señal de reset
        start : in std_logic;    -- Botón para iniciar
        servo1 : out std_logic;  -- Salida PWM para el servomotor 1
        servo2 : out std_logic;  -- Salida PWM para el servomotor 2
        servo3 : out std_logic;  -- Salida PWM para el servomotor 3
        servo4 : out std_logic   -- Salida PWM para el servomotor 4
    );
end Servo3;

architecture structure of Servo3 is
    signal clk_128khz : std_logic;
    signal servo1_pos, servo2_pos, servo3_pos, servo4_pos : std_logic_vector(7 downto 0);

    component clk128kHz
        Port (
            clk : in std_logic;
            reset : in std_logic;
            clk_128khz : out std_logic
        );
    end component;

    component servo_pwm
        Port (
            clk_128khz : in std_logic;
            reset : in std_logic;
            posicion : in std_logic_vector(7 downto 0);
            servo : out std_logic
        );
    end component;

    component marcha_control
        Port (
            clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            servo1_pos : out std_logic_vector(7 downto 0);
            servo2_pos : out std_logic_vector(7 downto 0);
            servo3_pos : out std_logic_vector(7 downto 0);
            servo4_pos : out std_logic_vector(7 downto 0)
        );
    end component;
begin
    U1: clk128kHz
        Port map (
            clk => clk,
            reset => reset,
            clk_128khz => clk_128khz
        );

    U2: marcha_control
        Port map (
            clk => clk,
            reset => reset,
            start => start,
            servo1_pos => servo1_pos,
            servo2_pos => servo2_pos,
            servo3_pos => servo3_pos,
            servo4_pos => servo4_pos
        );

    U3: servo_pwm
        Port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => servo1_pos,
            servo => servo1
        );

    U4: servo_pwm
        Port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => servo2_pos,
            servo => servo2
        );

    U5: servo_pwm
        Port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => servo3_pos,
            servo => servo3
        );

    U6: servo_pwm
        Port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => servo4_pos,
            servo => servo4
        );
end structure;
